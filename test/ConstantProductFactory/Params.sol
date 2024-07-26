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

        uint256 amount0 = 1 ether;
        uint256 amount1 = 5000 ether;

        uint128 liquidity = V3MathLib.getLiquidityForAmountsSqrtX96(
            V3MathLib.getSqrtPriceAtTick(tickCurrent),
            V3MathLib.getSqrtPriceAtTick(tickLower),
            V3MathLib.getSqrtPriceAtTick(tickUpper),
            amount0,
            amount1
        );

        assertEq(liquidity, 1518129116516325614066);

        (uint256 _amount0, uint256 _amount1) = V3MathLib.getAmountsForLiquidity(
            tickCurrent,
            tickLower,
            tickUpper,
            liquidity
        );
        assertApproxEqAbs(_amount0, amount0, 1e16);
        assertApproxEqAbs(_amount1, amount1, 1e4);
    }

    function test_uniswapV3_math_swap_amount0() public {
        uint256 priceLower = 4545 ether;
        uint256 currentPrice = 5000 ether;
        uint256 priceUpper = 5500 ether;

        uint256 amount0 = 1 ether;
        uint256 amount1 = 5000 ether;

        uint128 liquidity = V3MathLib.getLiquidityForAmounts(
            currentPrice,
            priceLower,
            priceUpper,
            amount0,
            amount1
        );

        assertEq(liquidity, 1518129116516325614066);

        uint256 swapAmount0 = 8396874645169942;
        (uint256 _amount0, uint256 _amount1) = V3MathLib
            .getSwapAmountsFromAmount0(
                V3MathLib.getSqrtPriceFromPrice(currentPrice),
                liquidity,
                swapAmount0
            );

        console.log(_amount0);
        console.log(_amount1);
        // assertEq(_amount0, 8396874645169942);
        // assertApproxEqAbs(_amount1, swapAmount1, 1e4);
    }

    function test_uniswapV3_math_swap_amount1() public {
        uint256 priceLower = 4545 ether;
        uint256 currentPrice = 5000 ether;
        uint256 priceUpper = 5500 ether;

        uint256 amount0 = 1 ether;
        uint256 amount1 = 5000 ether;

        uint128 liquidity = V3MathLib.getLiquidityForAmounts(
            currentPrice,
            priceLower,
            priceUpper,
            amount0,
            amount1
        );

        uint256 swapAmount1 = 42 ether;
        (uint256 _amount0, uint256 _amount1) = V3MathLib
            .getSwapAmountsFromAmount1(
                V3MathLib.getSqrtPriceFromPrice(currentPrice),
                liquidity,
                swapAmount1
            );

        assertEq(_amount0, 8396874645169942);
        assertApproxEqAbs(_amount1, swapAmount1, 1e4);
    }
}
