// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, GPv2Order, IERC20, IConditionalOrder} from "src/CConstantProduct.sol";
import {TradingParams} from "src/interfaces/ICConstantProduct.sol";
import {CConstantProductTestHarness} from "../CConstantProductTestHarness.sol";

abstract contract EnforceCommitmentTest is CConstantProductTestHarness {
    using GPv2Order for GPv2Order.Data;

    function testRevertsIfCommitDoesNotMatch() public {
        setUpDefaultReserves(address(constantProduct));

        bytes32 badCommitment = keccak256("some bad commitment");
        SignatureData memory data = defaultSignatureAndHashes();
        constantProduct.enableTrading(data.tradingParams);

        vm.prank(address(solutionSettler));
        constantProduct.commit(badCommitment);

        vm.expectRevert(
            abi.encodeWithSelector(
                CConstantProduct.OrderDoesNotMatchCommitmentHash.selector
            )
        );
        constantProduct.isValidSignature(data.orderHash, data.signature);
    }

    function testTradeableOrderPassesValidationWithZeroCommit() public {
        setUpDefaultReserves(address(constantProduct));

        require(
            constantProduct.commitment() == constantProduct.EMPTY_COMMITMENT(),
            "test expects unset commitment"
        );

        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        constantProduct.enableTrading(defaultTradingParams);

        GPv2Order.Data memory order = checkedGetTradeableOrder(
            defaultTradingParams,
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        bytes32 orderHash = order.hash(solutionSettler.domainSeparator());
        bytes memory signature = abi.encode(order, defaultTradingParams);
        constantProduct.isValidSignature(orderHash, signature);
    }

    function testZeroCommitRevertsForOrdersOtherThanTradeableOrder() public {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();

        require(
            constantProduct.commitment() == constantProduct.EMPTY_COMMITMENT(),
            "test expects unset commitment"
        );

        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        constantProduct.enableTrading(defaultTradingParams);

        GPv2Order.Data memory originalOrder = checkedGetTradeableOrder(
            defaultTradingParams,
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        GPv2Order.Data memory modifiedOrder;

        // All GPv2Order.Data parameters are included in this test. They are:
        // - IERC20 sellToken;
        // - IERC20 buyToken;
        // - address receiver;
        // - uint256 sellAmount;
        // - uint256 buyAmount;
        // - uint32 validTo;
        // - bytes32 appData;
        // - uint256 feeAmount;
        // - bytes32 kind;
        // - bool partiallyFillable;
        // - bytes32 sellTokenBalance;
        // - bytes32 buyTokenBalance;

        modifiedOrder = deepClone(originalOrder);
        modifiedOrder.receiver = makeAddr("bad receiver");
        expectRevertIsValidSignature(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "receiver must be zero address"
            ),
            defaultTradingParams,
            modifiedOrder
        );

        modifiedOrder = deepClone(originalOrder);
        modifiedOrder.appData = keccak256("bad app data");
        expectRevertIsValidSignature(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "invalid appData"
            ),
            defaultTradingParams,
            modifiedOrder
        );

        modifiedOrder = deepClone(originalOrder);
        modifiedOrder.feeAmount = modifiedOrder.feeAmount + 1;
        expectRevertIsValidSignature(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "fee amount must be zero"
            ),
            defaultTradingParams,
            modifiedOrder
        );

        modifiedOrder = deepClone(originalOrder);
        modifiedOrder.sellTokenBalance = GPv2Order.BALANCE_EXTERNAL;
        expectRevertIsValidSignature(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "sellTokenBalance must be erc20"
            ),
            defaultTradingParams,
            modifiedOrder
        );

        modifiedOrder = deepClone(originalOrder);
        modifiedOrder.buyTokenBalance = GPv2Order.BALANCE_EXTERNAL;
        expectRevertIsValidSignature(
            abi.encodeWithSelector(
                IConditionalOrder.OrderNotValid.selector,
                "buyTokenBalance must be erc20"
            ),
            defaultTradingParams,
            modifiedOrder
        );
    }

    function expectRevertIsValidSignature(
        bytes memory revertDataMask,
        TradingParams memory tradingParams,
        GPv2Order.Data memory order
    ) private {
        bytes32 orderHash = order.hash(solutionSettler.domainSeparator());
        bytes memory signature = abi.encode(order, tradingParams);
        vm.expectRevert(revertDataMask);
        constantProduct.isValidSignature(orderHash, signature);
    }

    function deepClone(
        GPv2Order.Data memory order
    ) private pure returns (GPv2Order.Data memory) {
        return abi.decode(abi.encode(order), (GPv2Order.Data));
    }
}
