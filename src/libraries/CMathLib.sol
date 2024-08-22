// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {FixedPointMathLib} from "@src/libraries/math/FixedPointMathLib.sol";

import {TickMath} from "@forks/uniswap-v3/libraries/TickMath.sol";
import {LiquidityAmounts} from "@forks/uniswap-v4/LiquidityAmounts.sol";

library CMathLib {
    using FixedPointMathLib for uint256;

    function getLiquidityFromAmountsSqrtPriceX96(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128) {
        uint256 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceCurrentX96,
            sqrtPriceUpperX96,
            sqrtPriceLowerX96,
            amount0,
            amount1
        );
        return uint128(liquidity);
    }

    function getAmountsFromLiquiditySqrtPriceX96(
        uint160 sqrtPriceNextX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint128 liquidity
    ) internal pure returns (uint256, uint256) {
        return
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceNextX96,
                sqrtPriceUpperX96,
                sqrtPriceLowerX96,
                liquidity
            );
    }

    function getSqrtPriceFromPrice(
        uint256 price
    ) internal pure returns (uint160) {
        return getSqrtPriceAtTick(CMathLib.getTickFromPrice(price));
    }

    // Helpers

    function getTickFromPrice(uint256 price) internal pure returns (int24) {
        return
            toInt24(
                (
                    (int256(PRBMathUD60x18.ln(price * 1e18)) -
                        int256(41446531673892820000))
                ) / 99995000333297
            );
    }

    function getSqrtPriceAtTick(int24 tick) internal pure returns (uint160) {
        return TickMath.getSqrtRatioAtTick(tick);
    }

    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "MH1");
        return int24(value);
    }
}
