// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {GPv2Interaction} from "cowprotocol/contracts/GPv2Settlement.sol";
import {GPv2Order} from "lib/composable-cow/src/BaseConditionalOrder.sol";

import {ICConstantProduct, TradingParams} from "./interfaces/ICConstantProduct.sol";
import {CConstantProduct} from "./CConstantProduct.sol";
import {IERC20} from "lib/composable-cow/src/BaseConditionalOrder.sol";

import {ConditionalOrdersUtilsLib as Utils} from "lib/composable-cow/src/types/ConditionalOrdersUtilsLib.sol";

/**
 * @title CCoWHelper
 * @author IVikkk
 * @notice Helper contract that allows to create orders for Concentrated CoW AMM.
 * @dev This contract supports only 2-token equal-weights pools.
 */
contract CCoWHelper {
    using GPv2Order for GPv2Order.Data;

    /// @notice The app data used by this helper's factory.
    bytes32 internal immutable _APP_DATA;

    constructor(bytes32 APP_DATA) {
        _APP_DATA = APP_DATA;
    }

    function order(
        TradingParams calldata tradingParams,
        address pool,
        address tokenIn,
        uint256 amountIn
    )
        external
        view
        returns (
            GPv2Order.Data memory order_,
            GPv2Interaction.Data[] memory preInteractions,
            GPv2Interaction.Data[] memory postInteractions,
            bytes memory sig
        )
    {
        uint256 tokenAmountOut = ICConstantProduct(pool).calcOutGivenIn(
            tradingParams.liquidity,
            amountIn,
            tokenIn
        );
        order_ = GPv2Order.Data({
            sellToken: tokenIn == address(ICConstantProduct(pool).token0())
                ? ICConstantProduct(pool).token1()
                : ICConstantProduct(pool).token0(),
            buyToken: IERC20(tokenIn),
            receiver: GPv2Order.RECEIVER_SAME_AS_OWNER,
            sellAmount: tokenAmountOut,
            buyAmount: amountIn,
            validTo: Utils.validToBucket(
                ICConstantProduct(pool).MAX_ORDER_DURATION()
            ),
            appData: _APP_DATA,
            feeAmount: 0,
            kind: GPv2Order.KIND_SELL,
            partiallyFillable: false,
            sellTokenBalance: GPv2Order.BALANCE_ERC20,
            buyTokenBalance: GPv2Order.BALANCE_ERC20
        });

        // A ERC-1271 signature on CoW Protocol is composed of two parts: the
        // signer address and the valid ERC-1271 signature data for that signer.
        bytes memory eip1271sig;
        eip1271sig = abi.encode(order_);
        sig = abi.encodePacked(pool, eip1271sig);

        // Generate the order commitment post-interaction
        postInteractions = new GPv2Interaction.Data[](1);
        postInteractions[0] = GPv2Interaction.Data({
            target: pool,
            value: 0,
            callData: abi.encodeWithSelector(
                ICConstantProduct.postHook.selector,
                tradingParams
            )
        });

        return (order_, preInteractions, postInteractions, sig);
    }

    function tokens(
        address pool
    ) public view virtual returns (address[] memory tokens_) {
        tokens_ = new address[](2);
        tokens_[0] = address(ICConstantProduct(pool).token0());
        tokens_[1] = address(ICConstantProduct(pool).token1());
    }
}
