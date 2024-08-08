// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, CConstantProductFactory, ICPriceOracle} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

abstract contract DisableTrading is CConstantProductFactoryTestHarness {
    function testOnlyOwnerCanDisableTrading() public {
        address notTheOwner = makeAddr("some address that isn't the owner");
        CConstantProduct amm = setupAndCreateAMM();
        require(
            constantProductFactory.owner(amm) != notTheOwner,
            "bad test setup"
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                CConstantProductFactory.OnlyOwnerCanCall.selector,
                address(this)
            )
        );
        vm.prank(notTheOwner);
        constantProductFactory.disableTrading(amm);
    }

    function testResetsTradingParamsHash() public {
        CConstantProduct amm = setupAndCreateAMM();

        constantProductFactory.disableTrading(amm);
        assertEq(amm.tradingParamsHash(), amm.NO_TRADING());
    }

    function testDisableTradingEmitsExpectedEvents() public {
        CConstantProduct amm = setupAndCreateAMM();

        vm.expectEmit();
        emit CConstantProductFactory.TradingDisabled(amm);
        constantProductFactory.disableTrading(amm);
    }

    function setupAndCreateAMM() private returns (CConstantProduct) {
        uint256 amount0 = 1234;
        uint256 amount1 = 5678;
        uint256 minTradedToken0 = 42;
        ICPriceOracle priceOracle = ICPriceOracle(
            makeAddr("DisableTrading: price oracle")
        );
        bytes memory priceOracleData = bytes("some price oracle data");
        bytes32 appData = keccak256("DisableTrading: app data");

        mocksForTokenCreation(
            constantProductFactory.ammDeterministicAddress(
                address(this),
                mockableToken0,
                mockableToken1
            )
        );
        return
            constantProductFactory.create(
                mockableToken0,
                amount0,
                mockableToken1,
                amount1,
                minTradedToken0,
                priceOracle,
                priceOracleData,
                appData
            );
    }
}
