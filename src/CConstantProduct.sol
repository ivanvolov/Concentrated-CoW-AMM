// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20 as OZIERC20} from "lib/openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC1271} from "lib/openzeppelin/contracts/interfaces/IERC1271.sol";
import {SafeERC20} from "lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "lib/openzeppelin/contracts/utils/math/Math.sol";
import {ConditionalOrdersUtilsLib as Utils} from "lib/composable-cow/src/types/ConditionalOrdersUtilsLib.sol";
import {IConditionalOrder, GPv2Order, IERC20} from "lib/composable-cow/src/BaseConditionalOrder.sol";
import {ICPriceOracle} from "./interfaces/ICPriceOracle.sol";
import {ISettlement} from "./interfaces/ISettlement.sol";
import {IWatchtowerCustomErrors} from "./interfaces/IWatchtowerCustomErrors.sol";
import {CMathLib} from "./libraries/CMathLib.sol";

/**
 * @title Concentrated CoW AMM
 * @author IVikkk
 * @dev Automated market maker based on the concept of function-maximising AMMs & concentrated liquidity.
 * It relies on the CoW Protocol infrastructure to guarantee batch execution of
 * its orders.
 * Order creation and execution is based on the Composable CoW base contracts.
 */
contract CConstantProduct is IERC1271 {
    using SafeERC20 for OZIERC20;
    using GPv2Order for GPv2Order.Data;

    /// All data used by an order to validate the AMM conditions.
    struct TradingParams {
        /// The minimum amount of token0 that needs to be traded for an order
        /// to be created on getTradeableOrder.
        uint256 minTradedToken0;
        /// An onchain source for the price of the two tokens. The price should
        /// be expressed in terms of amount of token0 per amount of token1.
        ICPriceOracle priceOracle;
        /// The data that needs to be provided to the price oracle to retrieve
        /// the relative price of the two tokens.
        bytes priceOracleData;
        /// The app data that must be used in the order.
        /// See `GPv2Order.Data` for more information on the app data.
        bytes32 appData;
        /// The price of the token0 at the moment of the last deposit.
        uint160 sqrtPriceDepositX96;
        /// The price upper bound of the AMM.
        uint160 sqrtPriceUpperX96;
        /// The price lower bound of the AMM.
        uint160 sqrtPriceLowerX96;
    }

    uint160 public lastSqrtPriceX96;

    /**
     * @notice The largest possible duration of any AMM order, starting from the
     * current block timestamp.
     */
    uint32 public constant MAX_ORDER_DURATION = 5 * 60;
    /**
     * @notice The value representing the absence of a commitment. It signifies
     * that the AMM will enforce that the order matches the order obtained from
     * calling `getTradeableOrder`.
     */
    bytes32 public constant EMPTY_COMMITMENT = bytes32(0);
    /**
     * @notice The value representing that no trading parameters are currently
     * accepted as valid by this contract, meaning that no trading can occur.
     */
    bytes32 public constant NO_TRADING = bytes32(0);
    /**
     * @notice The transient storage slot specified in this variable stores the
     * value of the order commitment, that is, the only order hash that can be
     * validated by calling `isValidSignature`.
     * The hash corresponding to the constant `EMPTY_COMMITMENT` has special
     * semantics, discussed in the related documentation.
     * @dev This value is:
     * uint256(keccak256("CoWAMM.CConstantProduct.commitment")) - 1
     */
    uint256 public constant COMMITMENT_SLOT = 0x6c3c90245457060f6517787b2c4b8cf500ca889d2304af02043bd5b513e3b593;

    /**
     * @notice The address of the CoW Protocol settlement contract. It is the
     * only address that can set commitments.
     */
    ISettlement public immutable solutionSettler;
    /**
     * @notice The first of the two tokens traded by this AMM.
     */
    IERC20 public immutable token0;
    /**
     * @notice The second of the two tokens traded by this AMM.
     */
    IERC20 public immutable token1;
    /**
     * @notice The address that can execute administrative tasks on this AMM,
     * as for example enabling/disabling trading or withdrawing funds.
     */
    address public immutable manager;
    /**
     * @notice The domain separator used for hashing CoW Protocol orders.
     */
    bytes32 public immutable solutionSettlerDomainSeparator;

    /**
     * The hash of the data describing which `TradingParams` currently apply
     * to this AMM. If this parameter is set to `NO_TRADING`, then the AMM
     * does not accept any order as valid.
     * If trading is enabled, then this value will be the [`hash`] of the only
     * admissible [`TradingParams`].
     */
    bytes32 public tradingParamsHash;

    /**
     * Emitted when the manager disables all trades by the AMM. Existing open
     * order will not be tradeable. Note that the AMM could resume trading with
     * different parameters at a later point.
     */
    event TradingDisabled();
    /**
     * Emitted when the manager enables the AMM to trade on CoW Protocol.
     * @param hash The hash of the trading parameters.
     * @param params Trading has been enabled for these parameters.
     */
    event TradingEnabled(bytes32 indexed hash, TradingParams params);

    /**
     * @notice This function is permissioned and can only be called by the
     * contract's manager.
     */
    error OnlyManagerCanCall();
    /**
     * @notice The `commit` function can only be called inside a CoW Swap
     * settlement. This error is thrown when the function is called from another
     * context.
     */
    error CommitOutsideOfSettlement();
    /**
     * @notice The `postHook` function can only be called inside a CoW Swap
     * settlement. This error is thrown when the function is called from another
     * context.
     */
    error PostHookOutsideOfSettlement();
    /**
     * @notice Error thrown when a solver tries to settle an AMM order on CoW
     * Protocol whose hash doesn't match the one that has been committed to.
     */
    error OrderDoesNotMatchCommitmentHash();
    /**
     * @notice If an AMM order is settled and the AMM committment is set to
     * empty, then that order must match the output of `getTradeableOrder`.
     * This error is thrown when some of the parameters don't match the expected
     * ones.
     */
    error OrderDoesNotMatchDefaultTradeableOrder();
    /**
     * @notice On signature verification, the hash of the order supplied as part
     * of the signature does not match the provided message hash.
     * This usually means that the verification function is being provided a
     * signature that belongs to a different order.
     */
    error OrderDoesNotMatchMessageHash();
    /**
     * @notice The order trade parameters that were provided during signature
     * verification does not match the data stored in this contract _or_ the
     * AMM has not enabled trading.
     */
    error TradingParamsDoNotMatchHash();

    modifier onlyManager() {
        if (manager != msg.sender) {
            revert OnlyManagerCanCall();
        }
        _;
    }

    /**
     * @param _solutionSettler The CoW Protocol contract used to settle user
     * orders on the current chain.
     * @param _token0 The first of the two tokens traded by this AMM.
     * @param _token1 The second of the two tokens traded by this AMM.
     */
    constructor(ISettlement _solutionSettler, IERC20 _token0, IERC20 _token1) {
        solutionSettler = _solutionSettler;
        solutionSettlerDomainSeparator = _solutionSettler.domainSeparator();

        approveUnlimited(_token0, msg.sender);
        approveUnlimited(_token1, msg.sender);
        manager = msg.sender;

        address vaultRelayer = _solutionSettler.vaultRelayer();
        approveUnlimited(_token0, vaultRelayer);
        approveUnlimited(_token1, vaultRelayer);

        token0 = _token0;
        token1 = _token1;
    }

    /**
     * @notice Once this function is called, it will be possible to trade with
     * this AMM on CoW Protocol.
     * @param tradingParams Trading is enabled with the parameters specified
     * here.
     */
    function enableTrading(TradingParams calldata tradingParams) external onlyManager {
        bytes32 _tradingParamsHash = hash(tradingParams);
        tradingParamsHash = _tradingParamsHash;
        emit TradingEnabled(_tradingParamsHash, tradingParams);
    }

    /**
     * @notice Disable any form of trading on CoW Protocol by this AMM.
     */
    function disableTrading() external onlyManager {
        tradingParamsHash = NO_TRADING;
        emit TradingDisabled();
    }

    /**
     * @notice Restricts a specific AMM to being able to trade only the order
     * with the specified hash.
     * @dev The commitment is used to enforce that exactly one AMM order is
     * valid when a CoW Protocol batch is settled.
     * @param orderHash the order hash that will be enforced by the order
     * verification function.
     */
    function commit(bytes32 orderHash) external {
        if (msg.sender != address(solutionSettler)) {
            revert CommitOutsideOfSettlement();
        }
        assembly ("memory-safe") {
            tstore(COMMITMENT_SLOT, orderHash)
        }
    }

    /**
     * @inheritdoc IERC1271
     */
    function isValidSignature(bytes32 _hash, bytes calldata signature) external view returns (bytes4) {
        (GPv2Order.Data memory order, TradingParams memory tradingParams) =
            abi.decode(signature, (GPv2Order.Data, TradingParams));

        if (hash(tradingParams) != tradingParamsHash) {
            revert TradingParamsDoNotMatchHash();
        }
        bytes32 orderHash = order.hash(solutionSettlerDomainSeparator);
        if (orderHash != _hash) {
            revert OrderDoesNotMatchMessageHash();
        }

        requireMatchingCommitment(orderHash, tradingParams, order);

        verify(tradingParams, order);

        // A signature is valid according to EIP-1271 if this function returns
        // its selector as the so-called "magic value".
        return this.isValidSignature.selector;
    }

    /**
     * @notice The order returned by this function is the order that needs to be
     * executed for the price on this AMM to match that of the reference pair.
     * @param tradingParams the trading parameters of all discrete orders cut
     * from this AMM
     * @return order the tradeable order for submission to the CoW Protocol API
     */
    function getTradeableOrder(TradingParams memory tradingParams) public view returns (GPv2Order.Data memory order) {
        (uint256 sellAmount, uint256 buyAmount, IERC20 sellToken, IERC20 buyToken) = getTargetAmounts(tradingParams);

        uint256 tradedAmountToken0 = sellToken == token0 ? sellAmount : buyAmount;

        if (tradedAmountToken0 < tradingParams.minTradedToken0) {
            revertPollAtNextBlock("traded amount too small");
        }

        order = GPv2Order.Data(
            sellToken,
            buyToken,
            GPv2Order.RECEIVER_SAME_AS_OWNER,
            sellAmount,
            buyAmount,
            Utils.validToBucket(MAX_ORDER_DURATION),
            tradingParams.appData,
            0,
            GPv2Order.KIND_SELL,
            false,
            GPv2Order.BALANCE_ERC20,
            GPv2Order.BALANCE_ERC20
        );
    }

    function getTargetSqrtPriceX96(TradingParams memory tradingParams) private view returns (uint160) {
        uint160 targetSqrtPriceX96 =
            tradingParams.priceOracle.getSqrtPriceX96(address(token0), address(token1), tradingParams.priceOracleData);

        if (targetSqrtPriceX96 > tradingParams.sqrtPriceUpperX96) {
            return tradingParams.sqrtPriceUpperX96;
        }
        if (targetSqrtPriceX96 < tradingParams.sqrtPriceLowerX96) {
            return tradingParams.sqrtPriceLowerX96;
        }
        return targetSqrtPriceX96;
    }

    function getTargetAmounts(TradingParams memory tradingParams)
        private
        view
        returns (uint256, uint256, IERC20, IERC20)
    {
        uint160 targetSqrtPriceX96 = getTargetSqrtPriceX96(tradingParams);
        (uint256 selfReserve0, uint256 selfReserve1) =
            (token0.balanceOf(address(this)), token1.balanceOf(address(this)));

        uint160 _lastSqrtPriceX96 = lastSqrtPriceX96 != 0 ? lastSqrtPriceX96 : tradingParams.sqrtPriceDepositX96;

        uint128 liquidity = CMathLib.getLiquidityFromAmountsSqrtPriceX96(
            _lastSqrtPriceX96,
            tradingParams.sqrtPriceUpperX96,
            tradingParams.sqrtPriceLowerX96,
            selfReserve0,
            selfReserve1
        );

        (uint256 newAmount0, uint256 newAmount1) = CMathLib.getAmountsFromLiquiditySqrtPriceX96(
            targetSqrtPriceX96, tradingParams.sqrtPriceUpperX96, tradingParams.sqrtPriceLowerX96, liquidity
        );

        if (targetSqrtPriceX96 > _lastSqrtPriceX96) {
            // sell token0 for token1

            return (selfReserve0 - newAmount0, newAmount1 - selfReserve1, token0, token1);
        } else {
            // sell token1 for token0

            return (selfReserve1 - newAmount1, newAmount0 - selfReserve0, token1, token0);
        }
    }

    /**
     * @notice This function checks that the input order is admissible for the
     * constant-product curve for the given trading parameters.
     * @param tradingParams the trading parameters of all discrete orders cut
     * from this AMM
     * @param order `GPv2Order.Data` of a discrete order to be verified.
     */
    function verify(TradingParams memory tradingParams, GPv2Order.Data memory order) public view {
        IERC20 sellToken = token0;
        IERC20 buyToken = token1;
        if (order.sellToken != sellToken) {
            if (order.sellToken != buyToken) {
                revert IConditionalOrder.OrderNotValid("invalid sell token");
            }
            (sellToken, buyToken) = (buyToken, sellToken);
        }

        if (order.buyToken != buyToken) {
            revert IConditionalOrder.OrderNotValid("invalid buy token");
        }

        if (order.receiver != GPv2Order.RECEIVER_SAME_AS_OWNER) {
            revert IConditionalOrder.OrderNotValid("receiver must be zero address");
        }
        // We add a maximum duration to avoid spamming the orderbook and force
        // an order refresh if the order is old.
        if (order.validTo > block.timestamp + MAX_ORDER_DURATION) {
            revert IConditionalOrder.OrderNotValid("validity too far in the future");
        }
        if (order.appData != tradingParams.appData) {
            revert IConditionalOrder.OrderNotValid("invalid appData");
        }
        if (order.feeAmount != 0) {
            revert IConditionalOrder.OrderNotValid("fee amount must be zero");
        }
        if (order.buyTokenBalance != GPv2Order.BALANCE_ERC20) {
            revert IConditionalOrder.OrderNotValid("buyTokenBalance must be erc20");
        }
        if (order.sellTokenBalance != GPv2Order.BALANCE_ERC20) {
            revert IConditionalOrder.OrderNotValid("sellTokenBalance must be erc20");
        }

        // These are the checks needed to satisfy the conditions on in/out
        // amounts for a constant-product curve AMM.

        (uint256 sellAmount, uint256 buyAmount,,) = getTargetAmounts(tradingParams);

        if (!(order.sellAmount <= sellAmount && order.buyAmount >= buyAmount)) {
            revert IConditionalOrder.OrderNotValid("received amount too low");
        }

        uint256 tradedAmountToken0 = sellToken == token0 ? sellAmount : buyAmount;

        if (tradedAmountToken0 < tradingParams.minTradedToken0) {
            revert IConditionalOrder.OrderNotValid("traded amount too small");
        }

        // No checks on:
        // - kind
        // - partiallyFillable
    }

    function postHook(TradingParams memory tradingParams) public {
        if (msg.sender != address(solutionSettler)) {
            revert PostHookOutsideOfSettlement();
        }
        if (hash(tradingParams) != tradingParamsHash) {
            revert TradingParamsDoNotMatchHash();
        }

        uint160 targetSqrtPriceX96 = getTargetSqrtPriceX96(tradingParams);
        lastSqrtPriceX96 = targetSqrtPriceX96;
    }

    function commitment() public view returns (bytes32 value) {
        assembly ("memory-safe") {
            value := tload(COMMITMENT_SLOT)
        }
    }

    /**
     * @notice Approves the spender to transfer an unlimited amount of tokens
     * and reverts if the approval was unsuccessful.
     * @param token The ERC-20 token to approve.
     * @param spender The address that can transfer on behalf of this contract.
     */
    function approveUnlimited(IERC20 token, address spender) internal {
        OZIERC20(address(token)).safeApprove(spender, type(uint256).max);
    }

    /**
     * @dev Computes the difference between the two input values. If it detects
     * an underflow, the function reverts with a custom error that informs the
     * watchtower to poll next.
     * If the function reverted with a standard underflow, the watchtower would
     * stop polling the order.
     * @param lhs The minuend of the subtraction
     * @param rhs The subtrahend of the subtraction
     * @return The difference of the two input values
     */
    function sub(uint256 lhs, uint256 rhs) internal view returns (uint256) {
        if (lhs < rhs) {
            revertPollAtNextBlock("subtraction underflow");
        }
        unchecked {
            return lhs - rhs;
        }
    }

    /**
     * @dev Reverts call execution with a custom error that indicates to the
     * watchtower to poll for new order when the next block is mined.
     */
    function revertPollAtNextBlock(string memory message) internal view {
        revert IWatchtowerCustomErrors.PollTryAtBlock(block.number + 1, message);
    }

    /**
     * @notice This function triggers a revert if either (1) the order hash does
     * not match the current commitment, or (2) in the case of a commitment to
     * `EMPTY_COMMITMENT`, the non-constant parameters of the order from
     * `getTradeableOrder` don't match those of the input order.
     * @param orderHash the hash of the current order as defined by the
     * `GPv2Order` library.
     * @param tradingParams the trading parameters of all discrete orders cut
     * from this AMM
     * @param order `GPv2Order.Data` of a discrete order to be verified
     */
    function requireMatchingCommitment(
        bytes32 orderHash,
        TradingParams memory tradingParams,
        GPv2Order.Data memory order
    ) internal view {
        bytes32 committedOrderHash = commitment();

        if (orderHash != committedOrderHash) {
            if (committedOrderHash != EMPTY_COMMITMENT) {
                revert OrderDoesNotMatchCommitmentHash();
            }
            GPv2Order.Data memory computedOrder = getTradeableOrder(tradingParams);
            if (!matchFreeOrderParams(order, computedOrder)) {
                revert OrderDoesNotMatchDefaultTradeableOrder();
            }
        }
    }

    /**
     * @dev Computes an identifier that uniquely represents the parameters in
     * the function input parameters.
     * @param tradingParams Bytestring that decodes to `TradingParams`
     * @return The hash of the input parameter, intended to be used as a unique
     * identifier
     */
    function hash(TradingParams memory tradingParams) public pure returns (bytes32) {
        return keccak256(abi.encode(tradingParams));
    }

    /**
     * @notice Check if the parameters of the two input orders are the same,
     * with the exception of those parameters that have a single possible value
     * that passes the validation of `verify`.
     * @param lhs a CoW Swap order
     * @param rhs another CoW Swap order
     * @return true if the order parameters match, false otherwise
     */
    function matchFreeOrderParams(GPv2Order.Data memory lhs, GPv2Order.Data memory rhs) internal pure returns (bool) {
        bool sameSellToken = lhs.sellToken == rhs.sellToken;
        bool sameBuyToken = lhs.buyToken == rhs.buyToken;
        bool sameSellAmount = lhs.sellAmount == rhs.sellAmount;
        bool sameBuyAmount = lhs.buyAmount == rhs.buyAmount;
        bool sameValidTo = lhs.validTo == rhs.validTo;
        bool sameKind = lhs.kind == rhs.kind;
        bool samePartiallyFillable = lhs.partiallyFillable == rhs.partiallyFillable;

        // The following parameters are untested:
        // - receiver
        // - appData
        // - feeAmount
        // - sellTokenBalance
        // - buyTokenBalance

        return sameSellToken && sameBuyToken && sameSellAmount && sameBuyAmount && sameValidTo && sameKind
            && samePartiallyFillable;
    }
}
