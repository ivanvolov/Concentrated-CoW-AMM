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

    function test_uniswapV3_math_swap_sqrt_price() public {
        (liquidity, amount0Provided, amount1Provided) = _provideLiquidity(lp);
        assertApproxEqAbs(liquidity, 1518129116516325613903, 1e3);

        uint160 newSqrtPriceX96 = CMathLib.getSqrtPriceFromPrice(4565 ether);
        assertEq(newSqrtPriceX96, 5352779161536754564491933729506);

        (uint256 newAmount0, uint256 newAmount1) = CMathLib
            .getAmountsFromLiquiditySqrtPriceX96(
                newSqrtPriceX96,
                CMathLib.getSqrtPriceFromPrice(lp.priceUpper),
                CMathLib.getSqrtPriceFromPrice(lp.priceLower),
                liquidity
            );

        assertEq(amount0Provided, 998995580131581599);
        assertEq(amount1Provided, 4999999999999999999998);
        assertEq(newAmount0, 1999508296761490795);
        assertEq(newAmount1, 220271565651919101596);

        // @Notice: the sqrtPriceX96 goes down so price goes down. This means we will sell token1 for token0.
    }

    function test_uniswapV3_math_swap_sqrt_price_out_of_range() public {
        (liquidity, amount0Provided, amount1Provided) = _provideLiquidity(lp);
        assertApproxEqAbs(liquidity, 1518129116516325613903, 1e3);

        (uint256 newAmount0, uint256 newAmount1) = CMathLib
            .getAmountsFromLiquiditySqrtPriceX96(
                CMathLib.getSqrtPriceFromPrice(5550 ether),
                CMathLib.getSqrtPriceFromPrice(lp.priceUpper),
                CMathLib.getSqrtPriceFromPrice(lp.priceLower),
                liquidity
            );

        assertEq(newAmount0, 0);
        assertEq(newAmount1, 10238638112880364775103);

        (newAmount0, newAmount1) = CMathLib.getAmountsFromLiquiditySqrtPriceX96(
            CMathLib.getSqrtPriceFromPrice(6000 ether),
            CMathLib.getSqrtPriceFromPrice(lp.priceUpper),
            CMathLib.getSqrtPriceFromPrice(lp.priceLower),
            liquidity
        );

        assertEq(newAmount0, 0);
        assertEq(newAmount1, 10238638112880364775103);
    }

    function test_uniswapV3_math_swap_sqrt_price_other_side() public {
        (liquidity, amount0Provided, amount1Provided) = _provideLiquidity(lp);
        assertApproxEqAbs(liquidity, 1518129116516325613903, 1e3);

        uint160 newSqrtPriceX96 = CMathLib.getSqrtPriceFromPrice(5499 ether);
        assertEq(newSqrtPriceX96, 5875030437023750975904034809688);

        (uint256 newAmount0, uint256 newAmount1) = CMathLib
            .getAmountsFromLiquiditySqrtPriceX96(
                newSqrtPriceX96,
                CMathLib.getSqrtPriceFromPrice(lp.priceUpper),
                CMathLib.getSqrtPriceFromPrice(lp.priceLower),
                liquidity
            );

        assertEq(amount0Provided, 998995580131581599);
        assertEq(amount1Provided, 4999999999999999999998);
        assertEq(newAmount0, 2047079670391420);
        assertEq(newAmount1, 10227380683092996436668);

        // @Notice: the sqrtPriceX96 goes up so price goes up. This means we will sell token0 for token1.
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
