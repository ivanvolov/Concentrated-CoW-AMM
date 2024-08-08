// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

import {V3MathLib} from "@src/libraries/V3MathLib.sol";
import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {LiquidityAmounts} from "@v4-core-test/utils/LiquidityAmounts.sol";
import {TickMath} from "@v4-core/libraries/TickMath.sol";

import {IUniswapV3Factory} from "@forks/uniswap-v3/IUniswapV3Factory.sol";
import {OracleLibrary} from "@forks/uniswap-v3/OracleLibrary.sol";

contract V3OracleTest is CConstantProductFactoryTestHarness {
    address oracleV3pool;

    function setUp() public override {
        super.setUp();

        IUniswapV3Factory oracleFactory = IUniswapV3Factory(
            0x1F98431c8aD98523631AE4a59f267346ea31F984
        );
        oracleV3pool = oracleFactory.getPool(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, //WETH
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, //USDC
            3000
        );
    }

    function test_get_oracle_price() public {
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(oracleV3pool, 1);
        // console.logInt(arithmeticMeanTick);
        // console.log(TickMath.getSqrtPriceAtTick(arithmeticMeanTick));

        assertEq(arithmeticMeanTick, 193756);
    }
}
