// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {BaseComposableCoWTest} from "lib/composable-cow/test/ComposableCoW.base.t.sol";

import {CConstantProduct, IERC20, GPv2Order, ISettlement} from "src/CConstantProduct.sol";
import {CConstantProductFactory, IConditionalOrder} from "src/CConstantProductFactory.sol";
import {PriceOracle} from "src/oracles/PriceOracle.sol";
import {ISettlement} from "src/interfaces/ISettlement.sol";
import {UniswapV2Helper, IUniswapV2Factory} from "test/libraries/UniswapV2Helper.sol";

import {ICPriceOracle} from "src/interfaces/ICPriceOracle.sol";
import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract E2EConditionalOrderTest is BaseComposableCoWTest {
    using UniswapV2Helper for IUniswapV2Factory;
    using GPv2Order for GPv2Order.Data;

    bytes DEFAULT_PRICE_ORACLE_DATA = bytes("some price oracle data");

    uint160 DEFAULT_PRICE_UPPER_X96 =
        CMathLib.getSqrtPriceFromPrice(5500 ether);
    uint160 DEFAULT_PRICE_LOWER_X96 =
        CMathLib.getSqrtPriceFromPrice(4545 ether);

    uint160 DEFAULT_PRICE_CURRENT_X96 =
        CMathLib.getSqrtPriceFromPrice(5000 ether);
    uint160 DEFAULT_NEW_PRICE_X96 = CMathLib.getSqrtPriceFromPrice(4565 ether);

    uint128 DEFAULT_LIQUIDITY = 1518129116516325613903;

    address public constant owner = 0x1234567890123456789012345678901234567890;
    IERC20 public DAI;
    IERC20 public WETH;
    CConstantProductFactory ammFactory;
    PriceOracle priceOracle;

    function setUp() public virtual override(BaseComposableCoWTest) {
        super.setUp();
        DAI = token0;
        WETH = token1;
        ammFactory = new CConstantProductFactory(
            ISettlement(address(settlement))
        );
        priceOracle = new PriceOracle();
    }

    function testE2ESettle() public {
        uint256 startAmountDai = 998995580131581598;
        uint256 startAmountWeth = 4999999999999999999461;

        // Deal the AMM reserves to the owner.
        deal(address(DAI), address(owner), startAmountDai);
        deal(address(WETH), address(owner), startAmountWeth);
        vm.startPrank(owner);
        DAI.approve(address(ammFactory), type(uint256).max);
        WETH.approve(address(ammFactory), type(uint256).max);

        // Funds have been allocated.
        assertEq(DAI.balanceOf(owner), startAmountDai);
        assertEq(WETH.balanceOf(owner), startAmountWeth);
        uint256 minTradedToken0 = 0;
        bytes32 appData = keccak256("order app data");

        setUpOracleResponse(
            DEFAULT_PRICE_CURRENT_X96,
            address(priceOracle),
            address(DAI),
            address(WETH),
            DEFAULT_PRICE_ORACLE_DATA
        );

        CConstantProduct amm = ammFactory.create(
            DAI,
            WETH,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            priceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            appData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
        vm.stopPrank();
        // Funds have been transferred to the AMM.
        assertEq(DAI.balanceOf(owner), 0);
        assertEq(WETH.balanceOf(owner), 0);

        assertEq(DAI.balanceOf(address(amm)), startAmountDai);
        assertEq(WETH.balanceOf(address(amm)), startAmountWeth);

        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(priceOracle),
            address(DAI),
            address(WETH),
            DEFAULT_PRICE_ORACLE_DATA
        );

        CConstantProduct.TradingParams memory data = CConstantProduct
            .TradingParams({
                minTradedToken0: minTradedToken0,
                priceOracle: priceOracle,
                priceOracleData: DEFAULT_PRICE_ORACLE_DATA,
                appData: appData,
                sqrtPriceCurrentX96: DEFAULT_PRICE_CURRENT_X96, //TODO: rename to not current but initial
                sqrtPriceAX96: DEFAULT_PRICE_UPPER_X96,
                sqrtPriceBX96: DEFAULT_PRICE_LOWER_X96
            });
        IConditionalOrder.ConditionalOrderParams memory params = super
            .createOrder(
                IConditionalOrder(address(ammFactory)),
                keccak256("e2e:any salt"),
                abi.encode(data)
            );
        (GPv2Order.Data memory order, bytes memory sig) = ammFactory
            .getTradeableOrderWithSignature(
                amm,
                params,
                hex"",
                new bytes32[](0)
            );

        // The trade will be settled against bob.
        uint256 bobWethBefore = WETH.balanceOf(bob.addr);
        uint256 bobDaiBefore = 1000512716629909195;
        deal(address(DAI), bob.addr, bobDaiBefore);
        vm.prank(bob.addr);
        DAI.approve(address(relayer), type(uint256).max);
        assertEq(WETH.balanceOf(bob.addr), bobWethBefore);

        settle(address(amm), bob, order, sig, hex"");

        uint256 endBalanceDai = DAI.balanceOf(address(amm));
        uint256 endBalanceWeth = WETH.balanceOf(address(amm));

        assertEq(bobDaiBefore + startAmountDai, endBalanceDai);
        assertEq(
            endBalanceWeth + WETH.balanceOf(bob.addr) - bobWethBefore,
            startAmountWeth
        );

        vm.prank(owner);
        ammFactory.disableTrading(amm);
        vm.prank(owner);
        ammFactory.withdraw(amm, endBalanceDai, endBalanceWeth);
        // Funds have been transferred to the owner.
        assertEq(DAI.balanceOf(owner), endBalanceDai);
        assertEq(WETH.balanceOf(owner), endBalanceWeth);
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
}
