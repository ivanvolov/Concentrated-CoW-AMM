// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProductTestHarness, CConstantProduct} from "./CConstantProductTestHarness.sol";
import {TradingParams} from "src/interfaces/ICConstantProduct.sol";

abstract contract DisableTrading is CConstantProductTestHarness {
    function testDisableTradingDoesNotRevert() public {
        setUpDisableTrading();
        constantProduct.disableTrading();
    }

    function testDisableTradingRevertsIfCalledByNonManager() public {
        setUpDisableTrading();
        vm.prank(makeAddr("this is not the owner"));
        vm.expectRevert(
            abi.encodeWithSelector(CConstantProduct.OnlyManagerCanCall.selector)
        );
        constantProduct.disableTrading();
    }

    function testDisableTradingEmitsEvent() public {
        setUpDisableTrading();
        vm.expectEmit();
        emit CConstantProduct.TradingDisabled();
        constantProduct.disableTrading();
    }

    function testDisableTradingUnsetsState() public {
        setUpDisableTrading();
        assertFalse(
            constantProduct.tradingParamsHash() == constantProduct.NO_TRADING()
        );
        constantProduct.disableTrading();
        assertTrue(
            constantProduct.tradingParamsHash() == constantProduct.NO_TRADING()
        );
    }

    // By default, trading is disabled on a newly deployed contract. Calling
    // this function enables some trade that can be disabled in a test.
    function setUpDisableTrading() private {
        setUpDefaultReserves(address(constantProduct));
        setUpDefaultDeposit();
        TradingParams memory defaultTradingParams = getDefaultTradingParams();
        constantProduct.enableTrading(defaultTradingParams);
    }
}
