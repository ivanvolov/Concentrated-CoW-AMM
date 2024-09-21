// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {ICPriceOracle, CConstantProduct, CConstantProductFactory, ComposableCoW, IConditionalOrder} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract UpdateParameters is CConstantProductFactoryTestHarness {
    // uint256 private initMinTradedToken0 = 42;
    // uint256 private newMinTradedToken0 = 1337;
    // ICPriceOracle private initPriceOracle = ICPriceOracle(makeAddr("UpdateParameters: price oracle"));
    // ICPriceOracle private newPriceOracle = ICPriceOracle(makeAddr("UpdateParameters: updated price oracle"));
    // bytes private initPriceOracleData = bytes("some price oracle data");
    // bytes private newPriceOracleData = bytes("some updated price oracle data");
    // bytes32 private initAppData = keccak256("UpdateParameters: app data");
    // bytes32 private newAppData = keccak256("UpdateParameters: updated app data");
    // function testOnlyOwnerCanUpdateParams() public {
    //     address notTheOwner = makeAddr("some address that isn't the owner");
    //     CConstantProduct amm = setupInitialAMM();
    //     require(constantProductFactory.owner(amm) != notTheOwner, "bad test setup");
    //     vm.expectRevert(abi.encodeWithSelector(CConstantProductFactory.OnlyOwnerCanCall.selector, address(this)));
    //     vm.prank(notTheOwner);
    //     constantProductFactory.updateParameters(
    //         amm,
    //         newMinTradedToken0,
    //         newPriceOracle,
    //         newPriceOracleData,
    //         newAppData,
    //         DEFAULT_NEW_PRICE_X96,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    // }
    // function testUpdatesTradingParamsHash() public {
    //     CConstantProduct amm = setupInitialAMM();
    //     CConstantProduct.TradingParams memory params = CConstantProduct.TradingParams({
    //         minTradedToken0: newMinTradedToken0,
    //         priceOracle: newPriceOracle,
    //         priceOracleData: newPriceOracleData,
    //         appData: newAppData,
    //         sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
    //         sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
    //         sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96
    //     });
    //     bytes32 newParamsHash = amm.hash(params);
    //     require(amm.tradingParamsHash() != newParamsHash, "bad test setup");
    //     constantProductFactory.updateParameters(
    //         amm,
    //         newMinTradedToken0,
    //         newPriceOracle,
    //         newPriceOracleData,
    //         newAppData,
    //         DEFAULT_NEW_PRICE_X96,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    //     assertEq(amm.tradingParamsHash(), newParamsHash);
    // }
    // function testUpdatingEmitsExpectedEvents() public {
    //     CConstantProduct amm = setupInitialAMM();
    //     CConstantProduct.TradingParams memory params = CConstantProduct.TradingParams({
    //         minTradedToken0: newMinTradedToken0,
    //         priceOracle: newPriceOracle,
    //         priceOracleData: newPriceOracleData,
    //         appData: newAppData,
    //         sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
    //         sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
    //         sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96
    //     });
    //     vm.expectEmit();
    //     emit CConstantProductFactory.TradingDisabled(amm);
    //     vm.expectEmit();
    //     emit ComposableCoW.ConditionalOrderCreated(
    //         address(amm),
    //         IConditionalOrder.ConditionalOrderParams(
    //             IConditionalOrder(address(constantProductFactory)), bytes32(0), abi.encode(params)
    //         )
    //     );
    //     constantProductFactory.updateParameters(
    //         amm,
    //         newMinTradedToken0,
    //         newPriceOracle,
    //         newPriceOracleData,
    //         newAppData,
    //         DEFAULT_NEW_PRICE_X96,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    // }
    // function setupInitialAMM() private returns (CConstantProduct) {
    //     mocksForTokenCreation(
    //         constantProductFactory.ammDeterministicAddress(address(this), mockableToken0, mockableToken1)
    //     );
    //     setUpOracleResponse(
    //         DEFAULT_PRICE_CURRENT_X96,
    //         address(initPriceOracle),
    //         address(mockableToken0),
    //         address(mockableToken1),
    //         initPriceOracleData
    //     );
    //     return constantProductFactory.create(
    //         mockableToken0,
    //         mockableToken1,
    //         DEFAULT_LIQUIDITY,
    //         initMinTradedToken0,
    //         initPriceOracle,
    //         initPriceOracleData,
    //         initAppData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    // }
}
