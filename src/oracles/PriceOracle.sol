// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {ICPriceOracle} from "../interfaces/ICPriceOracle.sol";

import {TickMath} from "@v4-core/libraries/TickMath.sol";
import {OracleLibrary} from "@forks/uniswap-v3/OracleLibrary.sol";

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
        address,
        address,
        bytes calldata data
    ) external view returns (uint160 sqrtPriceX96) {
        Data memory oracleData = abi.decode(data, (Data));
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(
            oracleData.pool,
            oracleData.secondsAgo
        );

        //TODO: add token check with pool tokens

        return TickMath.getSqrtPriceAtTick(arithmeticMeanTick);
    }
}
