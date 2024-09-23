// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, GPv2Order} from "src/CConstantProduct.sol";
import {IWatchtowerCustomErrors} from "src/interfaces/IWatchtowerCustomErrors.sol";
import {TradingParams, ICConstantProduct} from "src/interfaces/ICConstantProduct.sol";

import {CConstantProductTestHarness} from "../CConstantProductTestHarness.sol";

abstract contract ValidateOrderParametersTest is CConstantProductTestHarness {
    function testValidOrderParameters() public {
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        GPv2Order.Data memory order = checkedGetTradeableOrder(
            defaultTradingParams,
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        // Test all parameters with the exception of sell/buy tokens and amounts
        assertEq(order.receiver, GPv2Order.RECEIVER_SAME_AS_OWNER);
        assertEq(order.validTo, constantProduct.MAX_ORDER_DURATION());
        assertEq(order.appData, defaultTradingParams.appData);
        assertEq(order.feeAmount, 0);
        assertEq(order.kind, GPv2Order.KIND_SELL);
        assertEq(order.partiallyFillable, false);
        assertEq(order.sellTokenBalance, GPv2Order.BALANCE_ERC20);
        assertEq(order.buyTokenBalance, GPv2Order.BALANCE_ERC20);
    }

    function testOrderValidityMovesToNextBucket() public {
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        GPv2Order.Data memory order;
        order = checkedGetTradeableOrder(
            defaultTradingParams,
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        assertEq(order.validTo, constantProduct.MAX_ORDER_DURATION());
        // Bump time so that it falls somewhere in the middle of the next
        // bucket.
        uint256 smallOffset = 42;
        require(smallOffset < constantProduct.MAX_ORDER_DURATION());
        vm.warp(
            block.timestamp + constantProduct.MAX_ORDER_DURATION() + smallOffset
        );
        order = checkedGetTradeableOrder(
            defaultTradingParams,
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        assertEq(order.validTo, 2 * constantProduct.MAX_ORDER_DURATION());
    }
}
