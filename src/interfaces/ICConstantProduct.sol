// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20} from "lib/composable-cow/src/BaseConditionalOrder.sol";

/// All data used by an order to validate the AMM conditions.
struct TradingParams {
    /// The minimum amount of token0 that needs to be traded for an order
    /// to be created on getTradeableOrder.
    uint256 minTradedToken0;
    /// The app data that must be used in the order.
    /// See `GPv2Order.Data` for more information on the app data.
    bytes32 appData;
    /// The price of the token0 at the moment of the last deposit.
    uint160 sqrtPriceDepositX96;
    /// The price upper bound of the AMM.
    uint160 sqrtPriceUpperX96;
    /// The price lower bound of the AMM.
    uint160 sqrtPriceLowerX96;
    uint128 liquidity;
}

interface ICConstantProduct {
    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function lastLiquidity() external view returns (uint128);

    function lastSqrtPriceX96() external view returns (uint160);

    function MAX_ORDER_DURATION() external view returns (uint32);

    function calcOutGivenIn(
        uint128 liquidity,
        uint256 amountIn,
        address tokenIn
    ) external view returns (uint256 tokenAmountOut);

    function postHook(TradingParams memory tradingParams) external;
}
