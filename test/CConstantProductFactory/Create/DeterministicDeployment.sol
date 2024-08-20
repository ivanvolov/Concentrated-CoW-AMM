// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {ICPriceOracle, CConstantProduct, IERC20} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "../CConstantProductFactoryTestHarness.sol";

import {V3MathLib} from "src/libraries/V3MathLib.sol";

abstract contract DeterministicDeployment is
    CConstantProductFactoryTestHarness
{
    uint256 private amount0 = 1999508296761490795;
    uint256 private amount1 = 220271565651919101572;

    function testDeploysAtExpectedAddress() public {
        address constantProductAddress = constantProductFactory
            .ammDeterministicAddress(
                address(this),
                mockableToken0,
                mockableToken1
            );
        require(
            constantProductAddress.code.length == 0,
            "no AMM should be deployed at the start"
        );
        mocksForTokenCreation(constantProductAddress);
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(defaultPriceOracle),
            address(mockableToken0),
            address(mockableToken1)
        );
        CConstantProduct deployed = constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
        assertEq(address(deployed), constantProductAddress);
        assertTrue(constantProductAddress.code.length > 0);
    }

    function testSameOwnerCannotDeployAMMWithSameParametersTwice() public {
        address constantProductAddress = constantProductFactory
            .ammDeterministicAddress(
                address(this),
                mockableToken0,
                mockableToken1
            );
        mocksForTokenCreation(constantProductAddress);
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(defaultPriceOracle),
            address(mockableToken0),
            address(mockableToken1)
        );
        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
        vm.expectRevert(bytes(""));
        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
    }

    function testSameOwnerCanDeployAMMWithDifferentTokens() public {
        address ammAddress1 = constantProductFactory.ammDeterministicAddress(
            address(this),
            mockableToken0,
            mockableToken1
        );
        mocksForTokenCreation(ammAddress1);
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(defaultPriceOracle),
            address(mockableToken0),
            address(mockableToken1)
        );
        // Same setup as in `mocksForTokenCreation`, but for newly created tokens.
        IERC20 extraToken0 = IERC20(
            makeAddr("DeterministicDeployment: extra token 0")
        );
        IERC20 extraToken1 = IERC20(
            makeAddr("DeterministicDeployment: extra token 1")
        );
        address ammAddress2 = constantProductFactory.ammDeterministicAddress(
            address(this),
            extraToken0,
            extraToken1
        );
        setUpTokenForDeployment(
            extraToken0,
            ammAddress2,
            address(constantProductFactory)
        );
        setUpTokenForDeployment(
            extraToken1,
            ammAddress2,
            address(constantProductFactory)
        );
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(defaultPriceOracle),
            address(extraToken0),
            address(extraToken1)
        );

        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );

        constantProductFactory.create(
            extraToken0,
            extraToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
    }

    function testDifferentOwnersCanDeployAMMWithSameParameters() public {
        address owner1 = makeAddr("DeterministicDeployment: owner 1");
        address owner2 = makeAddr("DeterministicDeployment: owner 2");
        address ammOwner1 = constantProductFactory.ammDeterministicAddress(
            owner1,
            mockableToken0,
            mockableToken1
        );
        address ammOwner2 = constantProductFactory.ammDeterministicAddress(
            owner2,
            mockableToken0,
            mockableToken1
        );
        mocksForTokenCreation(ammOwner1);
        mocksForTokenCreation(ammOwner2);
        setUpOracleResponse(
            DEFAULT_NEW_PRICE_X96,
            address(defaultPriceOracle),
            address(mockableToken0),
            address(mockableToken1)
        );
        vm.prank(owner1);
        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
        vm.prank(owner2);
        constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultPriceOracle,
            DEFAULT_PRICE_ORACLE_DATA,
            defaultAppData,
            DEFAULT_PRICE_UPPER_X96,
            DEFAULT_PRICE_LOWER_X96
        );
    }
}
