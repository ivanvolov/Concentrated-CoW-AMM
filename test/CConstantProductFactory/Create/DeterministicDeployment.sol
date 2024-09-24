// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProduct, IERC20} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "../CConstantProductFactoryTestHarness.sol";

import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract DeterministicDeployment is
    CConstantProductFactoryTestHarness
{
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
        CConstantProduct deployed = constantProductFactory.create(
            mockableToken0,
            mockableToken1,
            DEFAULT_LIQUIDITY,
            minTradedToken0,
            defaultAppData,
            DEFAULT_PRICE_CURRENT_X96,
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
        vm.expectRevert(bytes(""));
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
        vm.prank(owner1);
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
        vm.prank(owner2);
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
