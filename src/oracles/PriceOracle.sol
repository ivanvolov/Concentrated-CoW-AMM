// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {ICPriceOracle} from "../interfaces/ICPriceOracle.sol";

import {TickMath} from "@forks/uniswap-v3/libraries/TickMath.sol";
import {OracleLibrary} from "@forks/uniswap-v3/libraries/OracleLibrary.sol";
import {IUniswapV3Pool} from "@forks/uniswap-v3/interfaces/IUniswapV3Pool.sol";

/**
 * @title CoW AMM UniswapV3 Price Oracle
 * @author CoW Protocol Developers
 * @dev This contract creates an oracle that is compatible with the ICPriceOracle
 * interface and can be used by a CoW AMM to determine the current price of the
 * traded tokens on specific Uniswap v2 pools.
 */
contract PriceOracle is ICPriceOracle {
    /**
     * Data required by the oracle to determine the current price.
     */
    struct Data {
        address pool;
        uint32 secondsAgo;
    }

    /**
     * @inheritdoc ICPriceOracle
     */
    function getSqrtPriceX96(
        address token0,
        address token1,
        bytes calldata data
    ) external view returns (uint160 sqrtPriceX96) {
        Data memory oracleData = abi.decode(data, (Data));
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(
            oracleData.pool,
            oracleData.secondsAgo
        );

        require(
            token0 == IUniswapV3Pool(oracleData.pool).token0(),
            "oracle: invalid token0"
        );
        require(
            token1 == IUniswapV3Pool(oracleData.pool).token1(),
            "oracle: invalid token1"
        );

        return TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
    }
}
