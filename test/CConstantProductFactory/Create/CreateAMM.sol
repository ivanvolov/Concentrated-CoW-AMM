// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20, CConstantProduct, CConstantProductFactory, ComposableCoW, IConditionalOrder} from "src/CConstantProductFactory.sol";
import {CConstantProductFactoryTestHarness, TradingParams} from "../CConstantProductFactoryTestHarness.sol";
import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract CreateAMM is CConstantProductFactoryTestHarness {
    function testNewAMMHasExpectedTokens() public {
        mocksForTokenCreation(
            constantProductFactory.ammDeterministicAddress(
                address(this),
                mockableToken0,
                mockableToken1
            )
        );
        CConstantProduct amm = constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultAppData,
            DEFAULT_PRICE_CURRENT_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
        assertEq(address(amm.token0()), address(mockableToken0));
        assertEq(address(amm.token1()), address(mockableToken1));
        TradingParams memory params = TradingParams({
            minTradedToken0: minTradedToken0,
            appData: defaultAppData,
            sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
            sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
            sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96,
            liquidity: DEFAULT_LIQUIDITY
        });
    }

    function testCreationSetsOwner() public {
        CConstantProduct expectedAMM = CConstantProduct(
            constantProductFactory.ammDeterministicAddress(
                address(this),
                mockableToken0,
                mockableToken1
            )
        );
        mocksForTokenCreation(address(expectedAMM));
        require(
            constantProductFactory.owner(expectedAMM) == address(0),
            "Initial owner is expected to be unset"
        );
        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultAppData,
            DEFAULT_PRICE_CURRENT_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
        assertFalse(constantProductFactory.owner(expectedAMM) == address(0));
        assertEq(constantProductFactory.owner(expectedAMM), address(this));
    }

    function testCreationEmitsEvents() public {
        address expectedAMM = constantProductFactory.ammDeterministicAddress(
            address(this),
            mockableToken0,
            mockableToken1
        );
        mocksForTokenCreation(address(expectedAMM));
        TradingParams memory params = TradingParams({
            minTradedToken0: minTradedToken0,
            appData: defaultAppData,
            sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
            sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
            sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96,
            liquidity: DEFAULT_LIQUIDITY
        });
        vm.expectEmit();
        emit CConstantProductFactory.Deployed(
            CConstantProduct(expectedAMM),
            address(this),
            mockableToken0,
            mockableToken1
        );
        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultAppData,
            DEFAULT_PRICE_CURRENT_X96,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
    }
}
