// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, CConstantProductFactory, ComposableCoW, IConditionalOrder} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness, TradingParams} from "./CConstantProductFactoryTestHarness.sol";

import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract UpdateParameters is CConstantProductFactoryTestHarness {
    uint256 private initMinTradedToken0 = 42;
    uint256 private newMinTradedToken0 = 1337;
    bytes private initPriceOracleData = bytes("some price oracle data");
    bytes private newPriceOracleData = bytes("some updated price oracle data");
    bytes32 private initAppData = keccak256("UpdateParameters: app data");
    bytes32 private newAppData =
        keccak256("UpdateParameters: updated app data");

    function testOnlyOwnerCanUpdateParams() public {
        address notTheOwner = makeAddr("some address that isn't the owner");
        CConstantProduct amm = setupInitialAMM();
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
        constantProductFactory.updateParameters(
            amm,
            newMinTradedToken0,
            newAppData,
            DEFAULT_NEW_PRICE_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96,
            DEFAULT_LIQUIDITY
        );
    }

    function testUpdatesTradingParamsHash() public {
        CConstantProduct amm = setupInitialAMM();
        TradingParams memory params = TradingParams({
            minTradedToken0: newMinTradedToken0,
            appData: newAppData,
            sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
            sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
            sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96,
            liquidity: DEFAULT_LIQUIDITY
        });
        bytes32 newParamsHash = amm.hash(params);
        require(amm.tradingParamsHash() != newParamsHash, "bad test setup");
        constantProductFactory.updateParameters(
            amm,
            newMinTradedToken0,
            newAppData,
            DEFAULT_NEW_PRICE_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96,
            DEFAULT_LIQUIDITY
        );
        assertEq(amm.tradingParamsHash(), newParamsHash);
    }

    function testUpdatingEmitsExpectedEvents() public {
        CConstantProduct amm = setupInitialAMM();
        TradingParams memory params = TradingParams({
            minTradedToken0: newMinTradedToken0,
            appData: newAppData,
            sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
            sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
            sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96,
            liquidity: DEFAULT_LIQUIDITY
        });
        vm.expectEmit();
        emit CConstantProductFactory.TradingDisabled(amm);
        vm.expectEmit();
        emit ComposableCoW.ConditionalOrderCreated(
            address(amm),
            IConditionalOrder.ConditionalOrderParams(
                IConditionalOrder(address(constantProductFactory)),
                bytes32(0),
                abi.encode(params)
            )
        );
        constantProductFactory.updateParameters(
            amm,
            newMinTradedToken0,
            newAppData,
            DEFAULT_NEW_PRICE_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96,
            DEFAULT_LIQUIDITY
        );
    }

    function setupInitialAMM() private returns (CConstantProduct) {
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
                mockableToken1,
                DEFAULT_LIQUIDITY,
                initMinTradedToken0,
                initAppData,
                DEFAULT_PRICE_CURRENT_X96,
                DEFAULT_PRICE_UPPER_X96,
                DEFAULT_PRICE_LOWER_X96
            );
    }
}
