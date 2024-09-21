// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC1271} from "lib/openzeppelin/contracts/interfaces/IERC1271.sol";
import {IConditionalOrder} from "lib/composable-cow/src/BaseConditionalOrder.sol";

import {CConstantProduct, GPv2Order} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

abstract contract GetTradeableOrderWithSignature is
    CConstantProductFactoryTestHarness
{
    using GPv2Order for GPv2Order.Data;

    // function testRevertsIfHandlerIsNotFactory() public {
    //     CConstantProduct.TradingParams memory tradingParams = getDefaultTradingParams();
    //     IConditionalOrder.ConditionalOrderParams memory params = IConditionalOrder.ConditionalOrderParams(
    //         IConditionalOrder(makeAddr("GetTradeableOrderWithSignature: not the factory")),
    //         keccak256("some salt"),
    //         abi.encode(tradingParams)
    //     );

    //     vm.expectRevert(abi.encodeWithSelector(IConditionalOrder.OrderNotValid.selector, "can only handle own orders"));
    //     constantProductFactory.getTradeableOrderWithSignature(constantProduct, params, hex"", new bytes32[](0));
    // }

    // function testRevertsIfTradingWithDifferentParameters() public {
    //     CConstantProduct.TradingParams memory tradingParams = getDefaultTradingParams();
    //     setUpDefaultReserves(address(constantProduct));

    //     constantProduct.enableTrading(tradingParams);

    //     bytes32 hashEnabledParams = constantProduct.hash(tradingParams);
    //     CConstantProduct.TradingParams memory modifiedParams = getDefaultTradingParams();
    //     modifiedParams.appData = keccak256("GetTradeableOrderWithSignature: any different app data");
    //     bytes32 hashModifiedParams = constantProduct.hash(modifiedParams);
    //     require(hashEnabledParams != hashModifiedParams, "Incorrect test setup");
    //     vm.expectRevert(abi.encodeWithSelector(IConditionalOrder.OrderNotValid.selector, "invalid trading parameters"));
    //     getTradeableOrderWithSignatureWrapper(constantProduct, modifiedParams);
    // }

    // function testOrderMatchesTradeableOrder() public {
    //     CConstantProduct.TradingParams memory tradingParams = getDefaultTradingParams();
    //     setUpDefaultReserves(address(constantProduct));

    //     constantProduct.enableTrading(tradingParams);

    //     GPv2Order.Data memory order = checkedGetTradeableOrder(tradingParams);
    //     (GPv2Order.Data memory orderSigned,) = getTradeableOrderWithSignatureWrapper(constantProduct, tradingParams);
    //     assertEq(orderSigned.hash(bytes32(0)), order.hash(bytes32(0)));
    // }

    // function testSignatureIsValid() public {
    //     CConstantProduct.TradingParams memory tradingParams = getDefaultTradingParams();
    //     setUpDefaultReserves(address(constantProduct));

    //     constantProduct.enableTrading(tradingParams);

    //     (GPv2Order.Data memory order, bytes memory signature) =
    //         getTradeableOrderWithSignatureWrapper(constantProduct, tradingParams);
    //     bytes32 orderHash = order.hash(solutionSettler.domainSeparator());

    //     bytes4 result = constantProduct.isValidSignature(orderHash, signature);
    //     assertEq(result, IERC1271.isValidSignature.selector);
    // }
}
