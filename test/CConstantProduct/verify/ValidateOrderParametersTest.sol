// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, GPv2Order, IERC20, IConditionalOrder} from "src/CConstantProduct.sol";
import {TradingParams} from "src/interfaces/ICConstantProduct.sol";

import {CConstantProductTestHarness} from "../CConstantProductTestHarness.sol";

abstract contract ValidateOrderParametersTest is CConstantProductTestHarness {
    function setUpBasicOrder()
        internal
        returns (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        )
    {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        defaultTradingParams = setUpDefaultTradingParams();

        setUpDefaultCommitment();
        defaultOrder = getDefaultOrder();
    }

    function testDefaultDoesNotRevert() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }

    function testRevertsIfDifferentReceiver() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        defaultOrder.receiver = makeAddr("bad receiver");
        vm.expectRevert(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "receiver must be zero address"
            )
        );
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }

    function testRevertsIfExpiresFarInTheFuture() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        defaultOrder.validTo =
            uint32(block.timestamp) +
            constantProduct.MAX_ORDER_DURATION() +
            1;
        vm.expectRevert(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "validity too far in the future"
            )
        );
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }

    function testRevertsIfDifferentAppData() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        defaultOrder.appData = keccak256(bytes("bad app data"));
        vm.expectRevert(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "invalid appData"
            )
        );
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }

    function testRevertsIfNonzeroFee() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        defaultOrder.feeAmount = 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "fee amount must be zero"
            )
        );
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }

    function testRevertsIfSellTokenBalanceIsNotErc20() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        defaultOrder.sellTokenBalance = GPv2Order.BALANCE_EXTERNAL;
        vm.expectRevert(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "sellTokenBalance must be erc20"
            )
        );
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }

    function testRevertsIfBuyTokenBalanceIsNotErc20() public {
        (
            TradingParams memory defaultTradingParams,
            GPv2Order.Data memory defaultOrder
        ) = setUpBasicOrder();
        defaultOrder.buyTokenBalance = GPv2Order.BALANCE_EXTERNAL;
        vm.expectRevert(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "buyTokenBalance must be erc20"
            )
        );
        constantProduct.verify(defaultTradingParams, defaultOrder);
    }
}
