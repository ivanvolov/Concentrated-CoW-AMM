// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20, ICPriceOracle, CConstantProduct, CConstantProductFactory, ComposableCoW, IConditionalOrder} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "../CConstantProductFactoryTestHarness.sol";

abstract contract CreateAMM is CConstantProductFactoryTestHarness {
    // uint256 private amount0 = 1234;
    // uint256 private amount1 = 5678;
    // uint256 private minTradedToken0 = 42;
    // ICPriceOracle private priceOracle =
    //     ICPriceOracle(makeAddr("Create: price oracle"));
    // bytes private priceOracleData = bytes("some price oracle data");
    // bytes32 private appData = keccak256("Create: app data");
    // function testNewAMMHasExpectedTokens() public {
    //     mocksForTokenCreation(
    //         constantProductFactory.ammDeterministicAddress(
    //             address(this),
    //             mockableToken0,
    //             mockableToken1
    //         )
    //     );
    //     CConstantProduct amm = constantProductFactory.create(
    //         mockableToken0,
    //         amount0,
    //         mockableToken1,
    //         amount1,
    //         minTradedToken0,
    //         priceOracle,
    //         priceOracleData,
    //         appData
    //     );
    //     assertEq(address(amm.token0()), address(mockableToken0));
    //     assertEq(address(amm.token1()), address(mockableToken1));
    //     CConstantProduct.TradingParams memory params = CConstantProduct
    //         .TradingParams({
    //             minTradedToken0: minTradedToken0,
    //             priceOracle: priceOracle,
    //             priceOracleData: priceOracleData,
    //             appData: appData
    //         });
    //     assertEq(amm.tradingParamsHash(), amm.hash(params));
    // }
    // function testNewAMMEnablesTrading() public {
    //     mocksForTokenCreation(
    //         constantProductFactory.ammDeterministicAddress(
    //             address(this),
    //             mockableToken0,
    //             mockableToken1
    //         )
    //     );
    //     CConstantProduct amm = constantProductFactory.create(
    //         mockableToken0,
    //         amount0,
    //         mockableToken1,
    //         amount1,
    //         minTradedToken0,
    //         priceOracle,
    //         priceOracleData,
    //         appData
    //     );
    //     CConstantProduct.TradingParams memory params = CConstantProduct
    //         .TradingParams({
    //             minTradedToken0: minTradedToken0,
    //             priceOracle: priceOracle,
    //             priceOracleData: priceOracleData,
    //             appData: appData
    //         });
    //     assertEq(amm.tradingParamsHash(), amm.hash(params));
    // }
    // function testCreationTransfersInExpectedAmounts() public {
    //     address expectedAMM = constantProductFactory.ammDeterministicAddress(
    //         address(this),
    //         mockableToken0,
    //         mockableToken1
    //     );
    //     mocksForTokenCreation(expectedAMM);
    //     vm.expectCall(
    //         address(mockableToken0),
    //         abi.encodeCall(
    //             IERC20.transferFrom,
    //             (address(this), expectedAMM, amount0)
    //         ),
    //         1
    //     );
    //     vm.expectCall(
    //         address(mockableToken1),
    //         abi.encodeCall(
    //             IERC20.transferFrom,
    //             (address(this), expectedAMM, amount1)
    //         ),
    //         1
    //     );
    //     constantProductFactory.create(
    //         mockableToken0,
    //         amount0,
    //         mockableToken1,
    //         amount1,
    //         minTradedToken0,
    //         priceOracle,
    //         priceOracleData,
    //         appData
    //     );
    // }
    // function testCreationSetsOwner() public {
    //     CConstantProduct expectedAMM = CConstantProduct(
    //         constantProductFactory.ammDeterministicAddress(
    //             address(this),
    //             mockableToken0,
    //             mockableToken1
    //         )
    //     );
    //     mocksForTokenCreation(address(expectedAMM));
    //     require(
    //         constantProductFactory.owner(expectedAMM) == address(0),
    //         "Initial owner is expected to be unset"
    //     );
    //     constantProductFactory.create(
    //         mockableToken0,
    //         amount0,
    //         mockableToken1,
    //         amount1,
    //         minTradedToken0,
    //         priceOracle,
    //         priceOracleData,
    //         appData
    //     );
    //     assertFalse(constantProductFactory.owner(expectedAMM) == address(0));
    //     assertEq(constantProductFactory.owner(expectedAMM), address(this));
    // }
    // function testCreationEmitsEvents() public {
    //     address expectedAMM = constantProductFactory.ammDeterministicAddress(
    //         address(this),
    //         mockableToken0,
    //         mockableToken1
    //     );
    //     mocksForTokenCreation(address(expectedAMM));
    //     CConstantProduct.TradingParams memory params = CConstantProduct
    //         .TradingParams({
    //             minTradedToken0: minTradedToken0,
    //             priceOracle: priceOracle,
    //             priceOracleData: priceOracleData,
    //             appData: appData
    //         });
    //     vm.expectEmit();
    //     emit CConstantProductFactory.Deployed(
    //         CConstantProduct(expectedAMM),
    //         address(this),
    //         mockableToken0,
    //         mockableToken1
    //     );
    //     vm.expectEmit();
    //     emit ComposableCoW.ConditionalOrderCreated(
    //         expectedAMM,
    //         IConditionalOrder.ConditionalOrderParams(
    //             IConditionalOrder(address(constantProductFactory)),
    //             bytes32(0),
    //             abi.encode(params)
    //         )
    //     );
    //     constantProductFactory.create(
    //         mockableToken0,
    //         amount0,
    //         mockableToken1,
    //         amount1,
    //         minTradedToken0,
    //         priceOracle,
    //         priceOracleData,
    //         appData
    //     );
    // }
}
