// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {CConstantProductFactory, CConstantProduct, GPv2Order, IConditionalOrder, ISettlement, IERC20} from "src/CConstantProductFactory.sol";

import {CConstantProductTestHarness} from "test/CConstantProduct/CConstantProductTestHarness.sol";
import {TradingParams, ICConstantProduct} from "src/interfaces/ICConstantProduct.sol";

abstract contract CConstantProductFactoryTestHarness is
    CConstantProductTestHarness
{
    uint256 minTradedToken0 = 42;
    bytes32 defaultAppData = keccak256("Create: app data");
    CConstantProductFactory internal constantProductFactory;
    IERC20 internal mockableToken0 =
        IERC20(
            makeAddr("CConstantProductFactoryTestHarness: mockable token 0")
        );
    IERC20 internal mockableToken1 =
        IERC20(
            makeAddr("CConstantProductFactoryTestHarness: mockable token 1")
        );

    function setUp() public virtual override(CConstantProductTestHarness) {
        super.setUp();
        constantProductFactory = new CConstantProductFactory(solutionSettler);
    }

    function mocksForTokenCreation(address constantProductAddress) internal {
        setUpTokenForDeployment(
            mockableToken0,
            constantProductAddress,
            address(constantProductFactory)
        );
        vm.mockCall(
            address(mockableToken0),
            abi.encodeCall(IERC20.balanceOf, (constantProductAddress)),
            abi.encode(0)
        );
        setUpTokenForDeployment(
            mockableToken1,
            constantProductAddress,
            address(constantProductFactory)
        );
        vm.mockCall(
            address(mockableToken1),
            abi.encodeCall(IERC20.balanceOf, (constantProductAddress)),
            abi.encode(0)
        );
    }
}

contract EditableOwnerCConstantProductFactory is CConstantProductFactory {
    constructor(ISettlement s) CConstantProductFactory(s) {}

    function setOwner(CConstantProduct amm, address newOwner) external {
        owner[amm] = newOwner;
    }
}
