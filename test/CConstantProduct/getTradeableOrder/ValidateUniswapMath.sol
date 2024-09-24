// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, GPv2Order} from "src/CConstantProduct.sol";
import {CConstantProductTestHarness} from "../CConstantProductTestHarness.sol";
import {CMathLib} from "src/libraries/CMathLib.sol";
import {TradingParams} from "src/interfaces/ICConstantProduct.sol";

abstract contract ValidateUniswapV3Math is CConstantProductTestHarness {
    function testReturnedTradeValues() public {
        TradingParams memory defaultTradingParams = setUpDefaultTradingParams();
        (
            ,
            uint256 oReserve0,
            uint256 oReserve1
        ) = calculateProvidedLiquidityDefault();
        assertEq(oReserve0, 998995580131581599);
        assertEq(oReserve1, 4999999999999999999998);
        setUpReserves(address(constantProduct), oReserve0, oReserve1);
        setUpDefaultDeposit();
        GPv2Order.Data memory order = checkedGetTradeableOrder(
            defaultTradingParams,
            WETH,
            DEFAULT_AMOUNT_IN_SWAP
        );
        assertEq(address(order.sellToken), address(constantProduct.token1()));
        assertEq(address(order.buyToken), address(constantProduct.token0()));
        // Assert explicit amounts to see that the trade is reasonable.
        assertEq(order.sellAmount, 2443057171472315338741);
        assertEq(order.buyAmount, 500000000000000000);
    }

    function testReturnedTradeValuesOtherSide() public {
        TradingParams memory defaultTradingParams = setUpDefaultTradingParams();
        (
            ,
            uint256 oReserve0,
            uint256 oReserve1
        ) = calculateProvidedLiquidityDefault();
        assertEq(oReserve0, 998995580131581599);
        assertEq(oReserve1, 4999999999999999999998);
        setUpReserves(address(constantProduct), oReserve0, oReserve1);
        setUpDefaultDeposit();
        GPv2Order.Data memory order = checkedGetTradeableOrder(
            defaultTradingParams,
            USDC,
            DEFAULT_AMOUNT_IN_SWAP_OTHER_SIDE
        );
        assertEq(address(order.sellToken), address(constantProduct.token0()));
        assertEq(address(order.buyToken), address(constantProduct.token1()));
        // Assert explicit amounts to see that the trade is reasonable.
        assertEq(order.sellAmount, 488629832159843988);
        assertEq(order.buyAmount, 2500000000000000000000);
    }
}
