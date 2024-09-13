// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {
    CConstantProductFactory,
    ICPriceOracle,
    CConstantProduct,
    GPv2Order,
    IConditionalOrder,
    ISettlement,
    IERC20
} from "src/CConstantProductFactory.sol";

import {CConstantProductTestHarness} from "test/CConstantProduct/CConstantProductTestHarness.sol";

abstract contract CConstantProductFactoryTestHarness is CConstantProductTestHarness {
    uint256 minTradedToken0 = 42;

    bytes32 defaultAppData = keccak256("Create: app data");

    ICPriceOracle defaultPriceOracle = ICPriceOracle(makeAddr("Create: price oracle"));

    CConstantProductFactory internal constantProductFactory;
    IERC20 internal mockableToken0 = IERC20(makeAddr("CConstantProductFactoryTestHarness: mockable token 0"));
    IERC20 internal mockableToken1 = IERC20(makeAddr("CConstantProductFactoryTestHarness: mockable token 1"));

    function setUp() public virtual override(CConstantProductTestHarness) {
        super.setUp();
        constantProductFactory = new CConstantProductFactory(solutionSettler);
    }

    // This function calls `getTradeableOrderWithSignature` while filling all
    // unused parameters with arbitrary data.
    function getTradeableOrderWithSignatureWrapper(
        CConstantProduct amm,
        CConstantProduct.TradingParams memory tradingParams
    ) internal view returns (GPv2Order.Data memory order, bytes memory signature) {
        IConditionalOrder.ConditionalOrderParams memory params = IConditionalOrder.ConditionalOrderParams(
            IConditionalOrder(address(constantProductFactory)),
            keccak256("CConstantProductFactoryTestHarness: some salt"),
            abi.encode(tradingParams)
        );
        return constantProductFactory.getTradeableOrderWithSignature(
            amm, params, bytes("CConstantProductFactoryTestHarness: offchainData"), new bytes32[](2)
        );
    }

    function mocksForTokenCreation(address constantProductAddress) internal {
        setUpTokenForDeployment(mockableToken0, constantProductAddress, address(constantProductFactory));
        setUpTokenForDeployment(mockableToken1, constantProductAddress, address(constantProductFactory));
    }
}

contract EditableOwnerCConstantProductFactory is CConstantProductFactory {
    constructor(ISettlement s) CConstantProductFactory(s) {}

    function setOwner(CConstantProduct amm, address newOwner) external {
        owner[amm] = newOwner;
    }
}
