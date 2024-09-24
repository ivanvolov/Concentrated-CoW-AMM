// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {FixedPointMathLib} from "@src/libraries/math/FixedPointMathLib.sol";

import {TickMath} from "@forks/uniswap-v3/libraries/TickMath.sol";
import {LiquidityAmounts} from "@forks/uniswap-v4/LiquidityAmounts.sol";

/**
 * @title Concentrated Math Library
 * @author IVikkk
 * @dev A smart contract library that can be used by the Concentrated CoW AMM as a math library.
 */
library CMathLib {
    using FixedPointMathLib for uint256;

    function getNextSqrtPriceX96FromAmount0(
        uint160 sqrtPriceCurrentX96,
        uint128 liquidity,
        uint256 amount0
    ) internal pure returns (uint160) {
        return
            toUint160(
                uint256(liquidity).mul(uint256(sqrtPriceCurrentX96)).div(
                    uint256(liquidity) +
                        amount0.mul(uint256(sqrtPriceCurrentX96)).div(2 ** 96)
                )
            );
    }

    function getNextSqrtPriceX96FromAmount1(
        uint160 sqrtPriceCurrentX96,
        uint128 liquidity,
        uint256 amount1
    ) internal pure returns (uint160) {
        uint160 sqrtPriceDeltaX96 = toUint160((amount1 * 2 ** 96) / liquidity);
        return sqrtPriceCurrentX96 + sqrtPriceDeltaX96;
    }

    function getSwapAmountsFromAmount0(
        uint160 sqrtPriceCurrentX96,
        uint128 liquidity,
        uint256 amount0
    ) internal pure returns (uint256, uint256) {
        uint160 sqrtPriceNextX96 = getNextSqrtPriceX96FromAmount0(
            sqrtPriceCurrentX96,
            liquidity,
            amount0
        );
        return (
            LiquidityAmounts.getAmount0ForLiquidity(
                sqrtPriceNextX96,
                sqrtPriceCurrentX96,
                liquidity
            ),
            LiquidityAmounts.getAmount1ForLiquidity(
                sqrtPriceNextX96,
                sqrtPriceCurrentX96,
                liquidity
            )
        );
    }

    function getSwapAmountsFromAmount1(
        uint160 sqrtPriceCurrentX96,
        uint128 liquidity,
        uint256 amount1
    ) internal pure returns (uint256, uint256) {
        uint160 sqrtPriceNextX96 = getNextSqrtPriceX96FromAmount1(
            sqrtPriceCurrentX96,
            liquidity,
            amount1
        );

        return (
            LiquidityAmounts.getAmount0ForLiquidity(
                sqrtPriceNextX96,
                sqrtPriceCurrentX96,
                liquidity
            ),
            LiquidityAmounts.getAmount1ForLiquidity(
                sqrtPriceNextX96,
                sqrtPriceCurrentX96,
                liquidity
            )
        );
    }

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

    // Helpers

    function getSqrtPriceFromPrice(
        uint256 price
    ) internal pure returns (uint160) {
        return getSqrtPriceAtTick(CMathLib.getTickFromPrice(price));
    }

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

    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "MH2");
        return uint160(value);
    }
}
