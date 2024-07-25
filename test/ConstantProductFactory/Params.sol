// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import {ConstantProductFactoryTestHarness} from "./ConstantProductFactoryTestHarness.sol";

import {V3MathLib} from "@src/libraries/V3MathLib.sol";
import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {LiquidityAmounts} from "@v4-core-test/utils/LiquidityAmounts.sol";
import {TickMath} from "@v4-core/libraries/TickMath.sol";

contract Params is ConstantProductFactoryTestHarness {
    function test_uniswapV3_math_liquidity() public {
        uint256 priceLower = 4545 ether;
        uint256 currentPrice = 5000 ether;
        uint256 priceUpper = 5500 ether;

        int24 tickLower = V3MathLib.getTickFromPrice(priceLower);
        int24 tickCurrent = V3MathLib.getTickFromPrice(currentPrice);
        int24 tickUpper = V3MathLib.getTickFromPrice(priceUpper);

        assertEq(tickLower, 84222);
        assertEq(tickCurrent, 85176);
        assertEq(tickUpper, 86129);

        console.log("Liquidity for amounts");
        uint256 amount0 = 1 ether;
        uint128 liquidityFor0 = LiquidityAmounts.getLiquidityForAmount0(
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            amount0
        );

        console.log(liquidityFor0);
        console.log(1519437308014769733632);
        // assertEq(liquidityFor0, 1000);

        uint256 amount1 = 5000 ether;
        uint128 liquidityFor1 = LiquidityAmounts.getLiquidityForAmount1(
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            amount1
        );

        console.log(liquidityFor1);
        console.log(1517882343751509868544);

        uint128 liquidityForAmounts = LiquidityAmounts.getLiquidityForAmounts(
            TickMath.getSqrtPriceAtTick(tickCurrent),
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            amount0,
            amount1
        );

        console.log(liquidityForAmounts);
        console.log(1517882343751509868544);

        console.log("Amounts fro Liquidity");
        amount0 = LiquidityAmounts.getAmount0ForLiquidity(
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityFor0
        );
        console.log(amount0);

        amount1 = LiquidityAmounts.getAmount1ForLiquidity(
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityFor1
        );
        console.log(amount1);

        (amount0, amount1) = LiquidityAmounts.getAmountsForLiquidity(
            TickMath.getSqrtPriceAtTick(tickCurrent),
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityForAmounts
        );
        console.log(amount0);
        console.log(amount1);
    }

    function test_uniswapV3_math_swap() public {
        uint256 priceLower = 4545 ether;
        uint256 currentPrice = 5000 ether;
        uint256 priceUpper = 5500 ether;

        int24 tickLower = V3MathLib.getTickFromPrice(priceLower);
        int24 tickCurrent = V3MathLib.getTickFromPrice(currentPrice);
        int24 tickUpper = V3MathLib.getTickFromPrice(priceUpper);

        uint256 amount0 = 1 ether;
        uint256 amount1 = 5000 ether;

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            TickMath.getSqrtPriceAtTick(tickCurrent),
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            amount0,
            amount1
        );

        uint256 damount1 = 42 ether;

        // liquidity = 1517882343751509868544;
        console.log(damount1);
        console.log(liquidity);
        uint256 dSqrtP = (damount1 * 2 ** 96) / liquidity;
        console.log(dSqrtP);

        uint256 sqrtNext = TickMath.getSqrtPriceAtTick(tickCurrent) + dSqrtP;
        console.log(sqrtNext);

        console.log("Amounts out");
        console.log(
            LiquidityAmounts.getAmount0ForLiquidity(
                V3MathLib.toUint160(sqrtNext),
                TickMath.getSqrtPriceAtTick(tickCurrent),
                liquidity
            )
        );
        console.log(
            LiquidityAmounts.getAmount1ForLiquidity(
                V3MathLib.toUint160(sqrtNext),
                TickMath.getSqrtPriceAtTick(tickCurrent),
                liquidity
            )
        );
    }
}
