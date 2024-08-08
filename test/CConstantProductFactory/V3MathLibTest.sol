// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

import {V3MathLib} from "@src/libraries/V3MathLib.sol";
import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {LiquidityAmounts} from "@v4-core-test/utils/LiquidityAmounts.sol";
import {TickMath} from "@v4-core/libraries/TickMath.sol";

contract V3MathLibTest is CConstantProductFactoryTestHarness {
    struct LP {
        uint256 currentPrice;
        uint256 priceUpper;
        uint256 priceLower;
        uint256 amount0;
        uint256 amount1;
    }

    LP lp;
    uint128 liquidity;
    uint256 amount0Provided;
    uint256 amount1Provided;

    function setUp() public override {
        super.setUp();

        lp = LP({
            currentPrice: 5000 ether,
            priceLower: 4545 ether,
            priceUpper: 5500 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });
    }

    function test_uniswapV3_math_tick_and_prices() public {
        int24 tickLower = V3MathLib.getTickFromPrice(4545 ether);
        int24 tickCurrent = V3MathLib.getTickFromPrice(5000 ether);
        int24 tickUpper = V3MathLib.getTickFromPrice(5500 ether);

        assertEq(tickLower, 84222);
        assertEq(tickCurrent, 85176);
        assertEq(tickUpper, 86129);

        uint160 sqrtPriceLower = V3MathLib.getSqrtPriceAtTick(tickLower);
        uint160 sqrtPriceCurrent = V3MathLib.getSqrtPriceAtTick(tickCurrent);
        uint160 sqrtPriceUpper = V3MathLib.getSqrtPriceAtTick(tickUpper);

        assertEq(sqrtPriceLower, 5341283623238412454227108479223);
        assertEq(sqrtPriceCurrent, 5602223755577321903022134995689);
        assertEq(sqrtPriceUpper, 5875617940067453351001625213169);

        sqrtPriceLower = V3MathLib.getSqrtPriceFromPrice(4545 ether);
        sqrtPriceCurrent = V3MathLib.getSqrtPriceFromPrice(5000 ether);
        sqrtPriceUpper = V3MathLib.getSqrtPriceFromPrice(5500 ether);

        assertEq(sqrtPriceLower, 5341283623238412454227108479223);
        assertEq(sqrtPriceCurrent, 5602223755577321903022134995689);
        assertEq(sqrtPriceUpper, 5875617940067453351001625213169);
    }

    function test_uniswapV3_math_liquidity() public {
        (liquidity, amount0Provided, amount1Provided) = provideLiquidity(lp);

        assertEq(liquidity, 1518129116516325614066);
        assertApproxEqAbs(amount0Provided, lp.amount0, 1e16);
        assertApproxEqAbs(amount1Provided, lp.amount1, 1e4);
    }

    function test_uniswapV3_math_swap_amount0() public {
        (liquidity, , ) = provideLiquidity(lp);

        uint256 swapAmount0 = 8396874645169942;
        (uint256 amount0Swap, uint256 amount1Swap) = V3MathLib
            .getSwapAmountsFromAmount0(
                V3MathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                swapAmount0
            );

        assertApproxEqAbs(amount0Swap, swapAmount0, 1e4);
        assertEq(amount1Swap, 41967160291541203252);
    }

    function test_uniswapV3_math_swap_amount0_full_range() public {
        (liquidity, amount0Provided, amount1Provided) = provideLiquidity(lp);

        (uint256 amount0Swap, uint256 amount1Swap) = V3MathLib
            .getSwapAmountsFromAmount0(
                V3MathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                amount0Provided
            );

        assertApproxEqAbs(amount0Provided, amount0Swap, 1e1);
        assertEq(amount1Swap, 4772802897174754244068);

        assertGe(amount0Provided, amount0Swap);
        assertGe(amount1Provided, amount1Swap);
    }

    function test_uniswapV3_math_swap_amount1() public {
        (liquidity, , ) = provideLiquidity(lp);

        uint256 swapAmount1 = 42 ether;
        (uint256 amount0Swap, uint256 amount1Swap) = V3MathLib
            .getSwapAmountsFromAmount1(
                V3MathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                swapAmount1
            );

        assertEq(amount0Swap, 8396874645169942);
        assertApproxEqAbs(amount1Swap, swapAmount1, 1e4);
    }

    function test_uniswapV3_math_swap_amount1_full_range() public {
        (liquidity, amount0Provided, amount1Provided) = provideLiquidity(lp);

        (uint256 amount0Swap, uint256 amount1Swap) = V3MathLib
            .getSwapAmountsFromAmount1(
                V3MathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                amount1Provided
            );

        assertEq(amount0Swap, 955513191680349318);
        assertApproxEqAbs(amount1Provided, amount1Swap, 1e1);

        assertGe(amount0Provided, amount0Swap);
        assertGe(amount1Provided, amount1Swap);
    }

    function test_uniswapV3_math_swap_sqrt_price() public {
        // No, the same problem is here of how to get the order of tokens, who is buy and who is sell
        (liquidity, amount0Provided, amount1Provided) = provideLiquidity(lp);

        uint160 newSqrtPriceX96 = V3MathLib.getSqrtPriceFromPrice(4565 ether);

        (uint256 amount0Swap, uint256 amount1Swap) = V3MathLib
            .getAmountsFromSqrtPrice(
                newSqrtPriceX96,
                V3MathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity
            );

        assertEq(amount0Swap, 1000512716629909196);
        assertEq(amount1Swap, 4779728434348080898402);
    }

    // Helpers

    function provideLiquidity(
        LP memory lpFixture
    ) internal view returns (uint128, uint256, uint256) {
        uint128 _liquidity = V3MathLib.getLiquidityForAmounts(
            lpFixture.currentPrice,
            lpFixture.priceLower,
            lpFixture.priceUpper,
            lpFixture.amount0,
            lpFixture.amount1
        );

        (uint256 _amount0, uint256 _amount1) = V3MathLib.getAmountsForLiquidity(
            V3MathLib.getTickFromPrice(lpFixture.currentPrice),
            V3MathLib.getTickFromPrice(lpFixture.priceLower),
            V3MathLib.getTickFromPrice(lpFixture.priceUpper),
            _liquidity
        );
        return (_liquidity, _amount0, _amount1);
    }
}
