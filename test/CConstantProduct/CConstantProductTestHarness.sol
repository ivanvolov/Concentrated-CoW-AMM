// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {BaseComposableCoWTest} from "lib/composable-cow/test/ComposableCoW.base.t.sol";
import {CConstantProduct, GPv2Order, IERC20, TradingParams} from "src/CConstantProduct.sol";
import {ISettlement} from "src/interfaces/ISettlement.sol";
import {TradingParams} from "src/interfaces/ICConstantProduct.sol";
import {CMathLib} from "src/libraries/CMathLib.sol";
import {CCoWHelper} from "src/CCoWHelper.sol";

import "forge-std/console.sol";

abstract contract CConstantProductTestHarness is BaseComposableCoWTest {
    using GPv2Order for GPv2Order.Data;

    struct SignatureData {
        GPv2Order.Data order;
        bytes32 orderHash;
        TradingParams tradingParams;
        bytes signature;
    }

    ISettlement internal solutionSettler =
        ISettlement(DEFAULT_SOLUTION_SETTLER);
    CConstantProduct internal constantProduct;
    CCoWHelper internal helper;

    address internal vaultRelayer = makeAddr("vault relayer");
    address private USDC = makeAddr("USDC");
    address private WETH = makeAddr("WETH");
    address private DEFAULT_PAIR = makeAddr("default USDC/WETH pair");
    address private DEFAULT_RECEIVER = makeAddr("default receiver");
    address private DEFAULT_SOLUTION_SETTLER = makeAddr("settlement contract");
    bytes32 private DEFAULT_APPDATA = keccak256(bytes("unit test"));
    bytes32 private DEFAULT_COMMITMENT = keccak256(bytes("order hash"));
    bytes32 private DEFAULT_DOMAIN_SEPARATOR =
        keccak256(bytes("domain separator hash"));

    // --- DEFAULT SQRT PRICES ---
    uint160 DEFAULT_PRICE_UPPER_X96 =
        CMathLib.getSqrtPriceFromPrice(5500 ether);
    uint160 DEFAULT_PRICE_LOWER_X96 =
        CMathLib.getSqrtPriceFromPrice(4545 ether);
    uint160 DEFAULT_PRICE_CURRENT_X96 =
        CMathLib.getSqrtPriceFromPrice(5000 ether);
    uint160 DEFAULT_NEW_PRICE_X96 = CMathLib.getSqrtPriceFromPrice(4565 ether);
    uint160 DEFAULT_NEW_PRICE_OTHER_SIDE_X96 =
        CMathLib.getSqrtPriceFromPrice(5499 ether);

    // --- DEFAULT LIQUIDITY ---
    uint128 DEFAULT_LIQUIDITY = 1518129116516325613903;
    uint256 DEFAULT_AMOUNT_IN_SWAP = 1 ether / 2;

    function setUp() public virtual override(BaseComposableCoWTest) {
        super.setUp();

        address constantProductAddress = vm.computeCreateAddress(
            address(this),
            vm.getNonce(address(this))
        );
        setUpSolutionSettler();
        setUpAmmDeployment(constantProductAddress);
        // constantProduct = new CConstantProduct(
        //     solutionSettler,
        //     IERC20(USDC),
        //     IERC20(WETH)
        // );

        // helper = new CCoWHelper("");
    }

    function setUpSolutionSettler() internal {
        vm.mockCall(
            DEFAULT_SOLUTION_SETTLER,
            abi.encodeCall(ISettlement.domainSeparator, ()),
            abi.encode(DEFAULT_DOMAIN_SEPARATOR)
        );
        vm.mockCall(
            DEFAULT_SOLUTION_SETTLER,
            abi.encodeCall(ISettlement.vaultRelayer, ()),
            abi.encode(vaultRelayer)
        );
        vm.mockCallRevert(
            DEFAULT_SOLUTION_SETTLER,
            hex"",
            abi.encode("Called unexpected function on mock settlement contract")
        );
    }

    function getDefaultTradingParams()
        internal
        view
        returns (TradingParams memory)
    {
        return
            TradingParams(
                0,
                DEFAULT_APPDATA,
                DEFAULT_PRICE_CURRENT_X96,
                DEFAULT_PRICE_UPPER_X96,
                DEFAULT_PRICE_LOWER_X96,
                DEFAULT_LIQUIDITY
            );
    }

    function setUpDefaultTradingParams()
        internal
        view
        returns (TradingParams memory)
    {
        return getDefaultTradingParams();
    }

    function setUpDefaultCommitment() internal {
        vm.prank(address(solutionSettler));
        constantProduct.commit(DEFAULT_COMMITMENT);
    }

    function setUpDefaultReserves(address owner) internal {
        (
            ,
            uint256 ownerReserve0,
            uint256 ownerReserve1
        ) = calculateProvidedLiquidityDefault();
        setUpReserves(owner, ownerReserve0, ownerReserve1);
    }

    function setUpReserves(
        address owner,
        uint256 amount0,
        uint256 amount1
    ) internal {
        vm.mockCall(
            address(constantProduct.token0()),
            abi.encodeCall(IERC20.balanceOf, (owner)),
            abi.encode(amount0)
        );
        vm.mockCall(
            address(constantProduct.token1()),
            abi.encodeCall(IERC20.balanceOf, (owner)),
            abi.encode(amount1)
        );
    }

    function defaultSignatureAndHashes()
        internal
        returns (SignatureData memory out)
    {
        TradingParams memory tradingParams = getDefaultTradingParams();
        GPv2Order.Data memory order = getDefaultOrder();
        bytes32 orderHash = order.hash(solutionSettler.domainSeparator());
        bytes memory signature = abi.encode(order, tradingParams);
        out = SignatureData(order, orderHash, tradingParams, signature);
    }

    // This function calls `getTradeableOrder` and immediately checks that the
    // order is valid for the default commitment.
    // This function use default AMOUNT IN
    function checkedGetTradeableOrder(
        TradingParams memory tradingParams
    ) internal view returns (GPv2Order.Data memory order) {
        (order, , , ) = helper.order(
            tradingParams,
            address(constantProduct),
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        constantProduct.verify(tradingParams, order);
    }

    function getDefaultOrder() internal view returns (GPv2Order.Data memory) {
        TradingParams memory tradingParams = getDefaultTradingParams();

        return
            GPv2Order.Data({
                sellToken: IERC20(USDC),
                buyToken: IERC20(WETH),
                receiver: GPv2Order.RECEIVER_SAME_AS_OWNER,
                sellAmount: 4779728434348080898426,
                buyAmount: 1000512716629909196,
                validTo: uint32(block.timestamp) +
                    constantProduct.MAX_ORDER_DURATION() /
                    2,
                appData: tradingParams.appData,
                feeAmount: 0,
                kind: GPv2Order.KIND_SELL,
                partiallyFillable: false,
                sellTokenBalance: GPv2Order.BALANCE_ERC20,
                buyTokenBalance: GPv2Order.BALANCE_ERC20
            });
    }

    function setUpAmmDeployment(address constantProductAddress) internal {
        setUpTokenForDeployment(
            IERC20(USDC),
            constantProductAddress,
            address(this)
        );
        // setUpTokenForDeployment(
        //     IERC20(WETH),
        //     constantProductAddress,
        //     address(this)
        // );
    }

    function setUpTokenForDeployment(
        IERC20 token,
        address constantProductAddress,
        address owner
    ) internal {
        console.log("!");
        console.log(">", address(solutionSettler));
        console.log(">", address(vaultRelayer));
        console.log(">", address(solutionSettler.vaultRelayer()));
        console.log("!");
        // mockSafeApprove(token, constantProductAddress, vaultRelayer);
        // mockSafeApprove(token, constantProductAddress, owner);
    }

    function mockSafeApprove(
        IERC20 token,
        address owner,
        address spender
    ) internal {
        // mockZeroAllowance(token, owner, spender);
        // mockApprove(token, spender);
    }

    function mockApprove(IERC20 token, address spender) internal {
        vm.mockCall(
            address(token),
            abi.encodeCall(IERC20.approve, (spender, type(uint256).max)),
            abi.encode(true)
        );
    }

    function mockZeroAllowance(
        IERC20 token,
        address owner,
        address spender
    ) internal {
        vm.mockCall(
            address(token),
            abi.encodeCall(IERC20.allowance, (owner, spender)),
            abi.encode(0)
        );
    }

    function calculateProvidedLiquidityDefault()
        internal
        view
        returns (uint128, uint256, uint256)
    {
        uint128 _liquidity = CMathLib.getLiquidityFromAmountsSqrtPriceX96(
            DEFAULT_PRICE_CURRENT_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96,
            1 ether,
            5000 ether
        );

        (uint256 _amount0, uint256 _amount1) = CMathLib
            .getAmountsFromLiquiditySqrtPriceX96(
                DEFAULT_PRICE_CURRENT_X96,
                DEFAULT_PRICE_UPPER_X96,
                DEFAULT_PRICE_LOWER_X96,
                _liquidity
            );
        return (_liquidity, _amount0, _amount1);
    }
}
