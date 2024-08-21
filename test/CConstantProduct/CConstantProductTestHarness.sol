// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {BaseComposableCoWTest} from "lib/composable-cow/test/ComposableCoW.base.t.sol";

import {CConstantProduct, GPv2Order, IERC20} from "src/CConstantProduct.sol";
import {PriceOracle} from "src/oracles/PriceOracle.sol";
import {ISettlement} from "src/interfaces/ISettlement.sol";
import {V3MathLib} from "src/libraries/V3MathLib.sol";

import {ICPriceOracle} from "src/interfaces/ICPriceOracle.sol";

abstract contract CConstantProductTestHarness is BaseComposableCoWTest {
    using GPv2Order for GPv2Order.Data;

    struct SignatureData {
        GPv2Order.Data order;
        bytes32 orderHash;
        CConstantProduct.TradingParams tradingParams;
        bytes signature;
    }

    struct LPFixture {
        uint256 currentPrice;
        uint256 priceUpper;
        uint256 priceLower;
        uint256 amount0;
        uint256 amount1;
    }

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
    bytes DEFAULT_PRICE_ORACLE_DATA = bytes("some price oracle data");

    uint160 DEFAULT_PRICE_UPPER_X96 =
        V3MathLib.getSqrtPriceFromPrice(5500 ether);
    uint160 DEFAULT_PRICE_LOWER_X96 =
        V3MathLib.getSqrtPriceFromPrice(4545 ether);

    uint160 DEFAULT_PRICE_CURRENT_X96 =
        V3MathLib.getSqrtPriceFromPrice(5000 ether);
    uint160 DEFAULT_NEW_PRICE_X96 = V3MathLib.getSqrtPriceFromPrice(4565 ether);
    uint160 DEFAULT_NEW_PRICE_OTHER_SIDE_X96 =
        V3MathLib.getSqrtPriceFromPrice(5499 ether);

    uint128 DEFAULT_LIQUIDITY = 1518129116516325613903;

    ISettlement internal solutionSettler =
        ISettlement(DEFAULT_SOLUTION_SETTLER);
    CConstantProduct internal constantProduct;
    PriceOracle internal priceOracle;

    LPFixture defaultLpFixture;

    function setUp() public virtual override(BaseComposableCoWTest) {
        super.setUp();

        defaultLpFixture = LPFixture({
            currentPrice: 5000 ether,
            priceLower: 4545 ether,
            priceUpper: 5500 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });
        address constantProductAddress = vm.computeCreateAddress(
            address(this),
            vm.getNonce(address(this))
        );
        setUpSolutionSettler();
        setUpAmmDeployment(constantProductAddress);
        constantProduct = new CConstantProduct(
            solutionSettler,
            IERC20(USDC),
            IERC20(WETH)
        );
        priceOracle = new PriceOracle();
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

    function setUpDefaultPair() internal {
        // TODO: remove
        // @Notice: we don't need it in our oracle simulation case.
    }

    function getDefaultTradingParams()
        internal
        view
        returns (CConstantProduct.TradingParams memory)
    {
        return
            CConstantProduct.TradingParams(
                0,
                priceOracle,
                DEFAULT_PRICE_ORACLE_DATA,
                DEFAULT_APPDATA,
                V3MathLib.getSqrtPriceFromPrice(defaultLpFixture.currentPrice),
                V3MathLib.getSqrtPriceFromPrice(defaultLpFixture.priceLower),
                V3MathLib.getSqrtPriceFromPrice(defaultLpFixture.priceUpper)
            );
    }

    function setUpDefaultTradingParams()
        internal
        returns (CConstantProduct.TradingParams memory)
    {
        setUpDefaultPair();
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
        ) = calculateProvideLiquidity(defaultLpFixture);
        setUpReserves(owner, ownerReserve0, ownerReserve1);
    }

    function setUpReserves(
        address owner,
        uint256 amount0,
        uint256 amount1
    ) internal {
        //TODO: maybe rewrite this to Oracle token0 and token1
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

    function setUpDefaultOracleResponse() public {
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(priceOracle),
            address(constantProduct.token0()),
            address(constantProduct.token1())
        );
    }

    function setUpDefaultOracleResponseOtherSide() public {
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_OTHER_SIDE_X96,
            address(priceOracle),
            address(constantProduct.token0()),
            address(constantProduct.token1())
        );
    }

    function setUpOracleResponse(
        uint160 newSqrtPriceX96,
        address oracle,
        address token0,
        address token1
    ) public {
        vm.mockCall(
            oracle,
            abi.encodeCall(
                ICPriceOracle.getSqrtPriceX96,
                (token0, token1, DEFAULT_PRICE_ORACLE_DATA)
            ),
            abi.encode(newSqrtPriceX96)
        );
    }

    function setUpOracleResponse(
        uint160 newSqrtPriceX96,
        address oracle,
        address token0,
        address token1,
        bytes memory priceOracleData
    ) public {
        vm.mockCall(
            oracle,
            abi.encodeCall(
                ICPriceOracle.getSqrtPriceX96,
                (token0, token1, priceOracleData)
            ),
            abi.encode(newSqrtPriceX96)
        );
    }

    function defaultSignatureAndHashes()
        internal
        returns (SignatureData memory out)
    {
        CConstantProduct.TradingParams
            memory tradingParams = getDefaultTradingParams();
        GPv2Order.Data memory order = getDefaultOrder();
        bytes32 orderHash = order.hash(solutionSettler.domainSeparator());
        bytes memory signature = abi.encode(order, tradingParams);
        out = SignatureData(order, orderHash, tradingParams, signature);
    }

    // This function calls `getTradeableOrder` and immediately checks that the
    // order is valid for the default commitment.
    function checkedGetTradeableOrder(
        CConstantProduct.TradingParams memory tradingParams
    ) internal view returns (GPv2Order.Data memory order) {
        order = constantProduct.getTradeableOrder(tradingParams);
        console.log("> order", order.sellAmount);
        constantProduct.verify(tradingParams, order);
    }

    function getDefaultOrder() internal view returns (GPv2Order.Data memory) {
        CConstantProduct.TradingParams
            memory tradingParams = getDefaultTradingParams();

        return
            GPv2Order.Data(
                IERC20(USDC), // IERC20 sellToken;
                IERC20(WETH), // IERC20 buyToken;
                GPv2Order.RECEIVER_SAME_AS_OWNER, // address receiver;
                4779728434348080898426, // uint256 sellAmount;
                1000512716629909196, // uint256 buyAmount;
                uint32(block.timestamp) +
                    constantProduct.MAX_ORDER_DURATION() /
                    2, // uint32 validTo;
                tradingParams.appData, // bytes32 appData;
                0, // uint256 feeAmount;
                GPv2Order.KIND_SELL, // bytes32 kind;
                false, // bool partiallyFillable;
                GPv2Order.BALANCE_ERC20, // bytes32 sellTokenBalance;
                GPv2Order.BALANCE_ERC20 // bytes32 buyTokenBalance;
            );
    }

    function setUpAmmDeployment(address constantProductAddress) internal {
        setUpTokenForDeployment(
            IERC20(USDC),
            constantProductAddress,
            address(this)
        );
        setUpTokenForDeployment(
            IERC20(WETH),
            constantProductAddress,
            address(this)
        );
    }

    function setUpTokenForDeployment(
        IERC20 token,
        address constantProductAddress,
        address owner
    ) internal {
        mockSafeApprove(
            token,
            constantProductAddress,
            solutionSettler.vaultRelayer()
        );
        mockSafeApprove(token, constantProductAddress, owner);
    }

    function mockSafeApprove(
        IERC20 token,
        address owner,
        address spender
    ) internal {
        mockZeroAllowance(token, owner, spender);
        mockApprove(token, spender);
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

    function calculateProvideLiquidity(
        LPFixture memory lpFixture
    ) internal pure returns (uint128, uint256, uint256) {
        uint128 _liquidity = V3MathLib.getLiquidityFromAmountsPrice(
            lpFixture.currentPrice,
            lpFixture.priceLower,
            lpFixture.priceUpper,
            lpFixture.amount0,
            lpFixture.amount1
        );

        (uint256 _amount0, uint256 _amount1) = V3MathLib
            .getAmountsFromLiquiditySqrtPriceX96(
                V3MathLib.getSqrtPriceFromPrice(lpFixture.currentPrice),
                V3MathLib.getSqrtPriceFromPrice(lpFixture.priceUpper),
                V3MathLib.getSqrtPriceFromPrice(lpFixture.priceLower),
                _liquidity
            );
        return (_liquidity, _amount0, _amount1);
    }
}
