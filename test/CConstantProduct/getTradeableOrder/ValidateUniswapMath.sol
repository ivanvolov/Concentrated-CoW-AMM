// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {CConstantProduct, GPv2Order} from "src/CConstantProduct.sol";

import {CConstantProductTestHarness} from "../CConstantProductTestHarness.sol";
import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract ValidateUniswapV3Math is CConstantProductTestHarness {
    function testReturnedTradeValues() public {
        CConstantProduct.TradingParams
            memory defaultTradingParams = setUpDefaultTradingParams();

        (, uint256 oReserve0, uint256 oReserve1) = calculateProvideLiquidity(
            defaultLpFixture
        );

        assertEq(oReserve0, 998995580131581599);
        assertEq(oReserve1, 4999999999999999999998);

        setUpReserves(address(constantProduct), oReserve0, oReserve1);

        setUpDefaultOracleResponse();
        GPv2Order.Data memory order = checkedGetTradeableOrder(
            defaultTradingParams
        );

        assertEq(address(order.sellToken), address(constantProduct.token1()));
        assertEq(address(order.buyToken), address(constantProduct.token0()));

        // Assert explicit amounts to see that the trade is reasonable.
        assertEq(order.sellAmount, 4779728434348080898426);
        assertEq(order.buyAmount, 1000512716629909196);
    }

    function testReturnedTradeValuesOtherSide() public {
        CConstantProduct.TradingParams
            memory defaultTradingParams = setUpDefaultTradingParams();

        (, uint256 oReserve0, uint256 oReserve1) = calculateProvideLiquidity(
            defaultLpFixture
        );

        assertEq(oReserve0, 998995580131581599);
        assertEq(oReserve1, 4999999999999999999998);

        setUpReserves(address(constantProduct), oReserve0, oReserve1);

        setUpDefaultOracleResponseOtherSide();
        GPv2Order.Data memory order = checkedGetTradeableOrder(
            defaultTradingParams
        );

        assertEq(address(order.sellToken), address(constantProduct.token0()));
        assertEq(address(order.buyToken), address(constantProduct.token1()));

        // Assert explicit amounts to see that the trade is reasonable.
        assertEq(order.sellAmount, 996948500461190179);
        assertEq(order.buyAmount, 5227380683092996435572);
    }
}
