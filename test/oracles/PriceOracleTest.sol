// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {V3MathLib} from "@src/libraries/V3MathLib.sol";
import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {LiquidityAmounts} from "@v4-core-test/utils/LiquidityAmounts.sol";
import {TickMath} from "@v4-core/libraries/TickMath.sol";

import {IUniswapV3Factory} from "@forks/uniswap-v3/IUniswapV3Factory.sol";
import {PriceOracle} from "src/oracles/PriceOracle.sol";
import {OracleLibrary} from "@forks/uniswap-v3/OracleLibrary.sol";

contract PriceOracleTest is Test {
    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    address oracleV3pool;
    PriceOracle internal oracle;

    address private ORACLE_V3_FACTORY =
        0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address private USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        vm.rollFork(19_955_703);

        oracle = new PriceOracle();

        IUniswapV3Factory oracleFactory = IUniswapV3Factory(ORACLE_V3_FACTORY);
        oracleV3pool = oracleFactory.getPool(WETH, USDC, 3000);
    }

    function test_get_arithmeticMeanTick_from_pool() public {
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(oracleV3pool, 1);
        assertEq(arithmeticMeanTick, 193756);
    }

    function testReturnsExpectedPrice() public {
        uint256 sqrtPriceX96 = oracle.getSqrtPriceX96(
            USDC,
            WETH,
            abi.encode(oracleV3pool, 1)
        );

        assertEq(sqrtPriceX96, 1276519083233114681625590680468888);
    }
}
