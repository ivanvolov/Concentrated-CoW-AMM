// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
 * @title CoW AMM Price Oracle Interface
 * @author CoW Protocol Developers
 * @dev A contract that can be used by the CoW AMM as as a price oracle.
 * The price source depends on the actual implementation; it could rely for
 * example on Uniswap, Balancer, Chainlink...
 */
interface ICPriceOracle {
    function getSqrtPriceX96(
        address token0,
        address token1,
        bytes calldata data
    ) external view returns (uint160 sqrtPriceX96);
}
