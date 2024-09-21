// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {CMathLib} from "@src/libraries/CMathLib.sol";

contract CMathLibTest is Test {
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

    function setUp() public {
        lp = LP({
            currentPrice: 5000 ether,
            priceLower: 4545 ether,
            priceUpper: 5500 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });
    }

    function test_uniswapV3_math_tick_and_prices() public {
        int24 tickLower = CMathLib.getTickFromPrice(4545 ether);
        int24 tickCurrent = CMathLib.getTickFromPrice(5000 ether);
        int24 tickUpper = CMathLib.getTickFromPrice(5500 ether);

        assertEq(tickLower, 84222);
        assertEq(tickCurrent, 85176);
        assertEq(tickUpper, 86129);

        uint160 sqrtPriceLower = CMathLib.getSqrtPriceAtTick(tickLower);
        uint160 sqrtPriceCurrent = CMathLib.getSqrtPriceAtTick(tickCurrent);
        uint160 sqrtPriceUpper = CMathLib.getSqrtPriceAtTick(tickUpper);

        assertEq(sqrtPriceLower, 5341283623238412454227108479223);
        assertEq(sqrtPriceCurrent, 5602223755577321903022134995689);
        assertEq(sqrtPriceUpper, 5875617940067453351001625213169);

        sqrtPriceLower = CMathLib.getSqrtPriceFromPrice(4545 ether);
        sqrtPriceCurrent = CMathLib.getSqrtPriceFromPrice(5000 ether);
        sqrtPriceUpper = CMathLib.getSqrtPriceFromPrice(5500 ether);

        assertEq(sqrtPriceLower, 5341283623238412454227108479223);
        assertEq(sqrtPriceCurrent, 5602223755577321903022134995689);
        assertEq(sqrtPriceUpper, 5875617940067453351001625213169);
    }

    function test_uniswapV3_math_liquidity() public {
        (liquidity, amount0Provided, amount1Provided) = _provideLiquidity(lp);

        assertEq(liquidity, 1518129116516325614066);
        assertApproxEqAbs(amount0Provided, lp.amount0, 1e16);
        assertApproxEqAbs(amount1Provided, lp.amount1, 1e4);
    }

    function test_uniswapV3_math_swap_amount0() public {
        (liquidity, , ) = _provideLiquidity(lp);

        uint256 swapAmount0 = 8396874645169942;
        (uint256 amount0Swap, uint256 amount1Swap) = CMathLib
            .getSwapAmountsFromAmount0(
                CMathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                swapAmount0
            );

        assertApproxEqAbs(amount0Swap, swapAmount0, 1e4);
        assertEq(amount1Swap, 41967160291541203252);
    }

    function test_uniswapV3_math_swap_amount0_full_range() public {
        (liquidity, amount0Provided, amount1Provided) = _provideLiquidity(lp);

        (uint256 amount0Swap, uint256 amount1Swap) = CMathLib
            .getSwapAmountsFromAmount0(
                CMathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                amount0Provided
            );

        assertApproxEqAbs(amount0Provided, amount0Swap, 1e1);
        assertEq(amount1Swap, 4772802897174754244068);

        assertGe(amount0Provided, amount0Swap);
        assertGe(amount1Provided, amount1Swap);
    }

    function test_uniswapV3_math_swap_amount1() public {
        (liquidity, , ) = _provideLiquidity(lp);

        uint256 swapAmount1 = 42 ether;
        (uint256 amount0Swap, uint256 amount1Swap) = CMathLib
            .getSwapAmountsFromAmount1(
                CMathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                swapAmount1
            );

        assertEq(amount0Swap, 8396874645169942);
        assertApproxEqAbs(amount1Swap, swapAmount1, 1e4);
    }

    function test_uniswapV3_math_swap_amount1_full_range() public {
        (liquidity, amount0Provided, amount1Provided) = _provideLiquidity(lp);

        (uint256 amount0Swap, uint256 amount1Swap) = CMathLib
            .getSwapAmountsFromAmount1(
                CMathLib.getSqrtPriceFromPrice(lp.currentPrice),
                liquidity,
                amount1Provided
            );

        assertEq(amount0Swap, 955513191680349318);
        assertApproxEqAbs(amount1Provided, amount1Swap, 1e1);

        assertGe(amount0Provided, amount0Swap);
        assertGe(amount1Provided, amount1Swap);
    }

    // Helpers

    function _provideLiquidity(
        LP memory lpFixture
    ) internal pure returns (uint128, uint256, uint256) {
        uint128 _liquidity = CMathLib.getLiquidityFromAmountsSqrtPriceX96(
            CMathLib.getSqrtPriceFromPrice(lpFixture.currentPrice),
            CMathLib.getSqrtPriceFromPrice(lpFixture.priceUpper),
            CMathLib.getSqrtPriceFromPrice(lpFixture.priceLower),
            lpFixture.amount0,
            lpFixture.amount1
        );

        (uint256 _amount0, uint256 _amount1) = CMathLib
            .getAmountsFromLiquiditySqrtPriceX96(
                CMathLib.getSqrtPriceFromPrice(lpFixture.currentPrice),
                CMathLib.getSqrtPriceFromPrice(lpFixture.priceUpper),
                CMathLib.getSqrtPriceFromPrice(lpFixture.priceLower),
                _liquidity
            );
        return (_liquidity, _amount0, _amount1);
    }
}
