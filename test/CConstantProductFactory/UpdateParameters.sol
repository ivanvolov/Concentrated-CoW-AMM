// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {ICPriceOracle, CConstantProduct, CConstantProductFactory, ComposableCoW, IConditionalOrder} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

abstract contract UpdateParameters is CConstantProductFactoryTestHarness {
    // uint256 private initMinTradedToken0 = 42;
    // uint256 private newMinTradedToken0 = 1337;
    // ICPriceOracle private initPriceOracle =
    //     ICPriceOracle(makeAddr("UpdateParameters: price oracle"));
    // ICPriceOracle private newPriceOracle =
    //     ICPriceOracle(makeAddr("UpdateParameters: updated price oracle"));
    // bytes private initPriceOracleData = bytes("some price oracle data");
    // bytes private newPriceOracleData = bytes("some updated price oracle data");
    // bytes32 private initAppData = keccak256("UpdateParameters: app data");
    // bytes32 private newAppData =
    //     keccak256("UpdateParameters: updated app data");
    // function testOnlyOwnerCanUpdateParams() public {
    //     address notTheOwner = makeAddr("some address that isn't the owner");
    //     CConstantProduct amm = setupInitialAMM();
    //     require(
    //         constantProductFactory.owner(amm) != notTheOwner,
    //         "bad test setup"
    //     );
    //     vm.expectRevert(
    //         abi.encodeWithSelector(
    //             CConstantProductFactory.OnlyOwnerCanCall.selector,
    //             address(this)
    //         )
    //     );
    //     vm.prank(notTheOwner);
    //     constantProductFactory.updateParameters(
    //         amm,
    //         newMinTradedToken0,
    //         newPriceOracle,
    //         newPriceOracleData,
    //         newAppData
    //     );
    // }
    // function testUpdatesTradingParamsHash() public {
    //     CConstantProduct amm = setupInitialAMM();
    //     CConstantProduct.TradingParams memory params = CConstantProduct
    //         .TradingParams({
    //             minTradedToken0: newMinTradedToken0,
    //             priceOracle: newPriceOracle,
    //             priceOracleData: newPriceOracleData,
    //             appData: newAppData
    //         });
    //     bytes32 newParamsHash = amm.hash(params);
    //     require(amm.tradingParamsHash() != newParamsHash, "bad test setup");
    //     constantProductFactory.updateParameters(
    //         amm,
    //         newMinTradedToken0,
    //         newPriceOracle,
    //         newPriceOracleData,
    //         newAppData
    //     );
    //     assertEq(amm.tradingParamsHash(), newParamsHash);
    // }
    // function testUpdatingEmitsExpectedEvents() public {
    //     CConstantProduct amm = setupInitialAMM();
    //     CConstantProduct.TradingParams memory params = CConstantProduct
    //         .TradingParams({
    //             minTradedToken0: newMinTradedToken0,
    //             priceOracle: newPriceOracle,
    //             priceOracleData: newPriceOracleData,
    //             appData: newAppData
    //         });
    //     vm.expectEmit();
    //     emit CConstantProductFactory.TradingDisabled(amm);
    //     vm.expectEmit();
    //     emit ComposableCoW.ConditionalOrderCreated(
    //         address(amm),
    //         IConditionalOrder.ConditionalOrderParams(
    //             IConditionalOrder(address(constantProductFactory)),
    //             bytes32(0),
    //             abi.encode(params)
    //         )
    //     );
    //     constantProductFactory.updateParameters(
    //         amm,
    //         newMinTradedToken0,
    //         newPriceOracle,
    //         newPriceOracleData,
    //         newAppData
    //     );
    // }
    // function setupInitialAMM() private returns (CConstantProduct) {
    //     uint256 amount0 = 12345;
    //     uint256 amount1 = 67890;
    //     mocksForTokenCreation(
    //         constantProductFactory.ammDeterministicAddress(
    //             address(this),
    //             mockableToken0,
    //             mockableToken1
    //         )
    //     );
    //     return
    //         constantProductFactory.create(
    //             mockableToken0,
    //             amount0,
    //             mockableToken1,
    //             amount1,
    //             initMinTradedToken0,
    //             initPriceOracle,
    //             initPriceOracleData,
    //             initAppData
    //         );
    // }
}
