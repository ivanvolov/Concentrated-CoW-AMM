// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProductTestHarness, CConstantProduct} from "./CConstantProductTestHarness.sol";
import {TradingParams} from "src/interfaces/ICConstantProduct.sol";

abstract contract EnableTrading is CConstantProductTestHarness {
    function testEnableTradingDoesNotRevert() public {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        constantProduct.enableTrading(defaultTradingParams);
    }

    function testEnableTradingRevertsIfCalledByNonManager() public {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        vm.prank(makeAddr("this is not the owner"));
        vm.expectRevert(
            abi.encodeWithSelector(CConstantProduct.OnlyManagerCanCall.selector)
        );
        constantProduct.enableTrading(defaultTradingParams);
    }

    function testEnableTradingEmitsEvent() public {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        vm.expectEmit();
        emit CConstantProduct.TradingEnabled(
            constantProduct.hash(defaultTradingParams),
            defaultTradingParams
        );
        constantProduct.enableTrading(defaultTradingParams);
    }

    function testEnableTradingSetsState() public {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        constantProduct.enableTrading(defaultTradingParams);
        assertEq(
            constantProduct.tradingParamsHash(),
            constantProduct.hash(defaultTradingParams)
        );
    }
}
