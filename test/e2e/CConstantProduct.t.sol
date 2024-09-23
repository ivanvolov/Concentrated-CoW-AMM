// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {BaseComposableCoWTest} from "lib/composable-cow/test/ComposableCoW.base.t.sol";

import {CConstantProduct, IERC20, ISettlement} from "src/CConstantProduct.sol";
import {CConstantProductFactory, IConditionalOrder} from "src/CConstantProductFactory.sol";
import {ISettlement} from "src/interfaces/ISettlement.sol";

import {CMathLib} from "src/libraries/CMathLib.sol";

import {TestAccount, TestAccountLib} from "lib/composable-cow/test/libraries/TestAccountLib.t.sol";
import {GPv2TradeEncoder} from "lib/composable-cow/test/vendored/GPv2TradeEncoder.sol";

import {IERC20, GPv2Settlement, GPv2Order, GPv2Trade, GPv2Interaction, GPv2Signing} from "cowprotocol/contracts/GPv2Settlement.sol";

contract E2EConditionalOrderTest is BaseComposableCoWTest {
    // using GPv2Order for GPv2Order.Data;
    // using TestAccountLib for TestAccount;
    // bytes DEFAULT_PRICE_ORACLE_DATA = bytes("some price oracle data");
    // uint160 DEFAULT_PRICE_UPPER_X96 = CMathLib.getSqrtPriceFromPrice(5500 ether);
    // uint160 DEFAULT_PRICE_LOWER_X96 = CMathLib.getSqrtPriceFromPrice(4545 ether);
    // uint160 DEFAULT_PRICE_CURRENT_X96 = CMathLib.getSqrtPriceFromPrice(5000 ether);
    // uint160 DEFAULT_NEW_PRICE_X96 = CMathLib.getSqrtPriceFromPrice(4565 ether);
    // uint128 DEFAULT_LIQUIDITY = 1518129116516325613903;
    // address public constant owner = 0x1234567890123456789012345678901234567890;
    // IERC20 public DAI;
    // IERC20 public WETH;
    // CConstantProductFactory ammFactory;
    // PriceOracle priceOracle;
    // CConstantProduct amm;
    // function setUp() public virtual override(BaseComposableCoWTest) {
    //     super.setUp();
    //     DAI = token0;
    //     WETH = token1;
    //     ammFactory = new CConstantProductFactory(ISettlement(address(settlement)));
    //     priceOracle = new PriceOracle();
    // }
    // function testE2ESettle() public {
    //     uint256 startAmountDai = 998995580131581598;
    //     uint256 startAmountWeth = 4999999999999999999461;
    //     // Deal the AMM reserves to the owner.
    //     deal(address(DAI), address(owner), startAmountDai);
    //     deal(address(WETH), address(owner), startAmountWeth);
    //     vm.startPrank(owner);
    //     DAI.approve(address(ammFactory), type(uint256).max);
    //     WETH.approve(address(ammFactory), type(uint256).max);
    //     // Funds have been allocated.
    //     assertEq(DAI.balanceOf(owner), startAmountDai);
    //     assertEq(WETH.balanceOf(owner), startAmountWeth);
    //     uint256 minTradedToken0 = 0;
    //     bytes32 appData = keccak256("order app data");
    //     setUpOracleResponse(
    //         DEFAULT_PRICE_CURRENT_X96, address(priceOracle), address(DAI), address(WETH), DEFAULT_PRICE_ORACLE_DATA
    //     );
    //     amm = ammFactory.create(
    //         DAI,
    //         WETH,
    //         DEFAULT_LIQUIDITY,
    //         minTradedToken0,
    //         priceOracle,
    //         DEFAULT_PRICE_ORACLE_DATA,
    //         appData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    //     vm.stopPrank();
    //     // Funds have been transferred to the AMM.
    //     assertEq(DAI.balanceOf(owner), 0);
    //     assertEq(WETH.balanceOf(owner), 0);
    //     assertEq(DAI.balanceOf(address(amm)), startAmountDai);
    //     assertEq(WETH.balanceOf(address(amm)), startAmountWeth);
    //     setUpOracleResponse(
    //         DEFAULT_NEW_PRICE_X96, address(priceOracle), address(DAI), address(WETH), DEFAULT_PRICE_ORACLE_DATA
    //     );
    //     TradingParams memory data = TradingParams({
    //         minTradedToken0: minTradedToken0,
    //         priceOracle: priceOracle,
    //         priceOracleData: DEFAULT_PRICE_ORACLE_DATA,
    //         appData: appData,
    //         sqrtPriceDepositX96: DEFAULT_PRICE_CURRENT_X96,
    //         sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
    //         sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96
    //     });
    //     IConditionalOrder.ConditionalOrderParams memory params =
    //         super.createOrder(IConditionalOrder(address(ammFactory)), keccak256("e2e:any salt"), abi.encode(data));
    //     (GPv2Order.Data memory order, bytes memory sig) =
    //         ammFactory.getTradeableOrderWithSignature(amm, params, hex"", new bytes32[](0));
    //     // The trade will be settled against bob.
    //     uint256 bobWethBefore = WETH.balanceOf(bob.addr);
    //     uint256 bobDaiBefore = 1000512716629909195;
    //     deal(address(DAI), bob.addr, bobDaiBefore);
    //     vm.prank(bob.addr);
    //     DAI.approve(address(relayer), type(uint256).max);
    //     assertEq(WETH.balanceOf(bob.addr), bobWethBefore);
    //     assertEq(amm.lastSqrtPriceX96(), 0);
    //     settleWithPostHook(address(amm), bob, order, sig, hex"", data);
    //     assertEq(amm.lastSqrtPriceX96(), DEFAULT_NEW_PRICE_X96);
    //     uint256 endBalanceDai = DAI.balanceOf(address(amm));
    //     uint256 endBalanceWeth = WETH.balanceOf(address(amm));
    //     assertEq(bobDaiBefore + startAmountDai, endBalanceDai);
    //     assertEq(endBalanceWeth + WETH.balanceOf(bob.addr) - bobWethBefore, startAmountWeth);
    //     vm.prank(owner);
    //     ammFactory.disableTrading(amm);
    //     vm.prank(owner);
    //     ammFactory.withdraw(amm, endBalanceDai, endBalanceWeth);
    //     // Funds have been transferred to the owner.
    //     assertEq(DAI.balanceOf(owner), endBalanceDai);
    //     assertEq(WETH.balanceOf(owner), endBalanceWeth);
    // }
    // function setUpOracleResponse(
    //     uint160 newSqrtPriceX96,
    //     address oracle,
    //     address token0,
    //     address token1,
    //     bytes memory priceOracleData
    // ) public {
    //     vm.mockCall(
    //         oracle,
    //         abi.encodeCall(ICPriceOracle.getSqrtPriceX96, (token0, token1, priceOracleData)),
    //         abi.encode(newSqrtPriceX96)
    //     );
    // }
    // /**
    //  * Settle a CoW Protocol Order
    //  * @dev This generates a counter order and signs it.
    //  * @param who this order belongs to
    //  * @param counterParty the account that is on the other side of the trade
    //  * @param order the order to settle
    //  * @param bundleBytes the ERC-1271 bundle for the order
    //  * @param _revertSelector the selector to revert with if the order is invalid
    //  */
    // function settleWithPostHook(
    //     address who,
    //     TestAccount memory counterParty,
    //     GPv2Order.Data memory order,
    //     bytes memory bundleBytes,
    //     bytes4 _revertSelector,
    //     TradingParams memory tradingParams
    // ) internal {
    //     // Generate counter party's order
    //     GPv2Order.Data memory counterOrder = GPv2Order.Data({
    //         sellToken: order.buyToken,
    //         buyToken: order.sellToken,
    //         receiver: address(0),
    //         sellAmount: order.buyAmount,
    //         buyAmount: order.sellAmount,
    //         validTo: order.validTo,
    //         appData: order.appData,
    //         feeAmount: 0,
    //         kind: GPv2Order.KIND_BUY,
    //         partiallyFillable: false,
    //         buyTokenBalance: GPv2Order.BALANCE_ERC20,
    //         sellTokenBalance: GPv2Order.BALANCE_ERC20
    //     });
    //     bytes memory counterPartySig =
    //         counterParty.signPacked(GPv2Order.hash(counterOrder, settlement.domainSeparator()));
    //     // Authorize the GPv2VaultRelayer to spend bob's sell token
    //     vm.prank(counterParty.addr);
    //     IERC20(counterOrder.sellToken).approve(address(relayer), counterOrder.sellAmount);
    //     // first declare the tokens we will be trading
    //     IERC20[] memory tokens = new IERC20[](2);
    //     tokens[0] = IERC20(order.sellToken);
    //     tokens[1] = IERC20(order.buyToken);
    //     // second declare the clearing prices
    //     uint256[] memory clearingPrices = new uint256[](2);
    //     clearingPrices[0] = counterOrder.sellAmount;
    //     clearingPrices[1] = counterOrder.buyAmount;
    //     // third declare the trades
    //     GPv2Trade.Data[] memory trades = new GPv2Trade.Data[](2);
    //     // The safe's order is the first trade
    //     trades[0] = GPv2Trade.Data({
    //         sellTokenIndex: 0,
    //         buyTokenIndex: 1,
    //         receiver: order.receiver,
    //         sellAmount: order.sellAmount,
    //         buyAmount: order.buyAmount,
    //         validTo: order.validTo,
    //         appData: order.appData,
    //         feeAmount: order.feeAmount,
    //         flags: GPv2TradeEncoder.encodeFlags(order, GPv2Signing.Scheme.Eip1271),
    //         executedAmount: order.sellAmount,
    //         signature: abi.encodePacked(who, bundleBytes)
    //     });
    //     // Bob's order is the second trade
    //     trades[1] = GPv2Trade.Data({
    //         sellTokenIndex: 1,
    //         buyTokenIndex: 0,
    //         receiver: address(0),
    //         sellAmount: counterOrder.sellAmount,
    //         buyAmount: counterOrder.buyAmount,
    //         validTo: counterOrder.validTo,
    //         appData: counterOrder.appData,
    //         feeAmount: counterOrder.feeAmount,
    //         flags: GPv2TradeEncoder.encodeFlags(counterOrder, GPv2Signing.Scheme.Eip712),
    //         executedAmount: counterOrder.sellAmount,
    //         signature: counterPartySig
    //     });
    //     // fourth declare the interactions
    //     GPv2Interaction.Data[][3] memory interactions =
    //         [new GPv2Interaction.Data[](0), new GPv2Interaction.Data[](0), new GPv2Interaction.Data[](1)];
    //     interactions[2][0] = GPv2Interaction.Data({
    //         target: address(amm),
    //         value: 0,
    //         callData: abi.encodeWithSelector(amm.postHook.selector, tradingParams)
    //     });
    //     // finally we can execute the settlement
    //     vm.prank(solver.addr);
    //     if (_revertSelector == bytes4(0)) {
    //         settlement.settle(tokens, clearingPrices, trades, interactions);
    //     } else {
    //         vm.expectRevert(_revertSelector);
    //         settlement.settle(tokens, clearingPrices, trades, interactions);
    //     }
    // }
}
