// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {TickMath} from "@v4-core/libraries/TickMath.sol";
// import {TickMath as V3TickMath} from "@forks/uniswap-v3/TickMath.sol";
import {LiquidityAmounts} from "@v4-core-test/utils/LiquidityAmounts.sol";
import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {FixedPointMathLib} from "@src/libraries/math/FixedPointMathLib.sol";

library V3MathLib {
    using FixedPointMathLib for uint256;

    function getAmountsFromSqrtPrice(
        uint160 sqrtPriceNextX96,
        uint160 sqrtPriceCurrentX96,
        uint128 liquidity
    ) internal pure returns (uint256, uint256) {
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

    function getSwapAmountsFromAmount0(
        uint160 sqrtPriceCurrentX96,
        uint128 liquidity,
        uint256 amount0
    ) internal view returns (uint256, uint256) {
        uint160 sqrtPriceNextX96 = toUint160(
            uint256(liquidity).mul(uint256(sqrtPriceCurrentX96)).div(
                uint256(liquidity) +
                    amount0.mul(uint256(sqrtPriceCurrentX96)).div(2 ** 96)
            )
        );
        console.log(">>sqrtPriceNextX96 (0)", sqrtPriceNextX96);
        console.log(">>sqrtPriceCurrentX96 ", sqrtPriceCurrentX96);
        console.log(">>liquidity", liquidity);

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
    ) internal view returns (uint256, uint256) {
        uint160 sqrtPriceDeltaX96 = toUint160((amount1 * 2 ** 96) / liquidity);
        uint160 sqrtPriceNextX96 = sqrtPriceCurrentX96 + sqrtPriceDeltaX96;

        console.log(">>sqrtPriceNextX96 (1)", sqrtPriceNextX96);
        console.log(">>sqrtPriceCurrentX96 ", sqrtPriceCurrentX96);
        console.log(">>liquidity", liquidity);

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

    function getLiquidityForAmounts(
        uint256 priceCurrent,
        uint256 priceA,
        uint256 priceB,
        uint256 amount0,
        uint256 amount1
    ) internal view returns (uint128) {
        uint256 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            getSqrtPriceFromPrice(priceCurrent),
            getSqrtPriceFromPrice(priceA),
            getSqrtPriceFromPrice(priceB),
            amount0,
            amount1
        );
        return uint128(liquidity);
    }

    function getLiquidityForAmountsSqrtX96(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128) {
        uint256 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceCurrentX96,
            sqrtPriceAX96,
            sqrtPriceBX96,
            amount0,
            amount1
        );
        return uint128(liquidity);
    }

    function getAmountsForLiquidity(
        int24 tickCurrent,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    ) internal pure returns (uint256, uint256) {
        (uint256 amount0, uint256 amount1) = LiquidityAmounts
            .getAmountsForLiquidity(
                TickMath.getSqrtPriceAtTick(tickCurrent),
                TickMath.getSqrtPriceAtTick(tickLower),
                TickMath.getSqrtPriceAtTick(tickUpper),
                liquidity
            );
        return (amount0, amount1);
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

    // Helpers

    function getSqrtPriceFromPrice(
        uint256 price
    ) internal pure returns (uint160) {
        return getSqrtPriceAtTick(V3MathLib.getTickFromPrice(price));
    }

    // function getPriceFromSqrtPrice(
    //     uint160 sqrtPriceX96
    // ) internal view returns (uint160) {
    //     console.logInt(TickMath.getTickAtSqrtPrice(sqrtPriceX96));
    //     return
    //         V3TickMath.getSqrtRatioAtTick(
    //             TickMath.getTickAtSqrtPrice(sqrtPriceX96)
    //         );
    // }

    function getSqrtPriceAtTick(int24 tick) internal pure returns (uint160) {
        return TickMath.getSqrtPriceAtTick(tick);
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
