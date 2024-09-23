// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20, CConstantProduct, CConstantProductFactory, ComposableCoW, IConditionalOrder} from "src/CConstantProductFactory.sol";
import {CConstantProductFactoryTestHarness} from "../CConstantProductFactoryTestHarness.sol";
import {CMathLib} from "src/libraries/CMathLib.sol";

abstract contract CreateAMM is CConstantProductFactoryTestHarness {
    // uint256 private amount0 = 1999508296761490795;
    // uint256 private amount1 = 220271565651919101572;
    // function testNewAMMHasExpectedTokens() public {
    //     mocksForTokenCreation(
    //         constantProductFactory.ammDeterministicAddress(address(this), mockableToken0, mockableToken1)
    //     );
    //     setUpOracleResponse(
    //         DEFAULT_NEW_PRICE_X96, address(defaultPriceOracle), address(mockableToken0), address(mockableToken1)
    //     );
    //     CConstantProduct amm = constantProductFactory.create(
    //         mockableToken0,
    //         mockableToken1,
    //         DEFAULT_LIQUIDITY,
    //         minTradedToken0,
    //         defaultPriceOracle,
    //         DEFAULT_PRICE_ORACLE_DATA,
    //         defaultAppData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    //     assertEq(address(amm.token0()), address(mockableToken0));
    //     assertEq(address(amm.token1()), address(mockableToken1));
    //     TradingParams memory params = TradingParams({
    //         minTradedToken0: minTradedToken0,
    //         priceOracle: defaultPriceOracle,
    //         priceOracleData: DEFAULT_PRICE_ORACLE_DATA,
    //         appData: defaultAppData,
    //         sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
    //         sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
    //         sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96
    //     });
    //     assertEq(amm.tradingParamsHash(), amm.hash(params));
    // }
    // function testNewAMMEnablesTrading() public {
    //     mocksForTokenCreation(
    //         constantProductFactory.ammDeterministicAddress(address(this), mockableToken0, mockableToken1)
    //     );
    //     setUpOracleResponse(
    //         DEFAULT_NEW_PRICE_X96, address(defaultPriceOracle), address(mockableToken0), address(mockableToken1)
    //     );
    //     CConstantProduct amm = constantProductFactory.create(
    //         mockableToken0,
    //         mockableToken1,
    //         DEFAULT_LIQUIDITY,
    //         minTradedToken0,
    //         defaultPriceOracle,
    //         DEFAULT_PRICE_ORACLE_DATA,
    //         defaultAppData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    //     TradingParams memory params = TradingParams({
    //         minTradedToken0: minTradedToken0,
    //         priceOracle: defaultPriceOracle,
    //         priceOracleData: DEFAULT_PRICE_ORACLE_DATA,
    //         appData: defaultAppData,
    //         sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
    //         sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
    //         sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96
    //     });
    //     assertEq(amm.tradingParamsHash(), amm.hash(params));
    // }
    // function testCreationTransfersInExpectedAmounts() public {
    //     address expectedAMM =
    //         constantProductFactory.ammDeterministicAddress(address(this), mockableToken0, mockableToken1);
    //     mocksForTokenCreation(expectedAMM);
    //     setUpOracleResponse(
    //         DEFAULT_NEW_PRICE_X96, address(defaultPriceOracle), address(mockableToken0), address(mockableToken1)
    //     );
    //     vm.expectCall(
    //         address(mockableToken0), abi.encodeCall(IERC20.transferFrom, (address(this), expectedAMM, amount0)), 1
    //     );
    //     vm.expectCall(
    //         address(mockableToken1), abi.encodeCall(IERC20.transferFrom, (address(this), expectedAMM, amount1)), 1
    //     );
    //     constantProductFactory.create(
    //         mockableToken0,
    //         mockableToken1,
    //         DEFAULT_LIQUIDITY,
    //         minTradedToken0,
    //         defaultPriceOracle,
    //         DEFAULT_PRICE_ORACLE_DATA,
    //         defaultAppData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    // }
    // function testCreationSetsOwner() public {
    //     CConstantProduct expectedAMM = CConstantProduct(
    //         constantProductFactory.ammDeterministicAddress(address(this), mockableToken0, mockableToken1)
    //     );
    //     mocksForTokenCreation(address(expectedAMM));
    //     require(constantProductFactory.owner(expectedAMM) == address(0), "Initial owner is expected to be unset");
    //     setUpOracleResponse(
    //         DEFAULT_NEW_PRICE_X96, address(defaultPriceOracle), address(mockableToken0), address(mockableToken1)
    //     );
    //     constantProductFactory.create(
    //         mockableToken0,
    //         mockableToken1,
    //         DEFAULT_LIQUIDITY,
    //         minTradedToken0,
    //         defaultPriceOracle,
    //         DEFAULT_PRICE_ORACLE_DATA,
    //         defaultAppData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    //     assertFalse(constantProductFactory.owner(expectedAMM) == address(0));
    //     assertEq(constantProductFactory.owner(expectedAMM), address(this));
    // }
    // function testCreationEmitsEvents() public {
    //     address expectedAMM =
    //         constantProductFactory.ammDeterministicAddress(address(this), mockableToken0, mockableToken1);
    //     mocksForTokenCreation(address(expectedAMM));
    //     setUpOracleResponse(
    //         DEFAULT_NEW_PRICE_X96, address(defaultPriceOracle), address(mockableToken0), address(mockableToken1)
    //     );
    //     TradingParams memory params = TradingParams({
    //         minTradedToken0: minTradedToken0,
    //         priceOracle: defaultPriceOracle,
    //         priceOracleData: DEFAULT_PRICE_ORACLE_DATA,
    //         appData: defaultAppData,
    //         sqrtPriceDepositX96: DEFAULT_NEW_PRICE_X96,
    //         sqrtPriceUpperX96: DEFAULT_PRICE_UPPER_X96,
    //         sqrtPriceLowerX96: DEFAULT_PRICE_LOWER_X96
    //     });
    //     vm.expectEmit();
    //     emit CConstantProductFactory.Deployed(
    //         CConstantProduct(expectedAMM), address(this), mockableToken0, mockableToken1
    //     );
    //     vm.expectEmit();
    //     emit ComposableCoW.ConditionalOrderCreated(
    //         expectedAMM,
    //         IConditionalOrder.ConditionalOrderParams(
    //             IConditionalOrder(address(constantProductFactory)), bytes32(0), abi.encode(params)
    //         )
    //     );
    //     constantProductFactory.create(
    //         mockableToken0,
    //         mockableToken1,
    //         DEFAULT_LIQUIDITY,
    //         minTradedToken0,
    //         defaultPriceOracle,
    //         DEFAULT_PRICE_ORACLE_DATA,
    //         defaultAppData,
    //         DEFAULT_PRICE_UPPER_X96,
    //         DEFAULT_PRICE_LOWER_X96
    //     );
    // }
}
