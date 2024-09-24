// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC1271} from "lib/openzeppelin/contracts/interfaces/IERC1271.sol";
import {IConditionalOrder} from "lib/composable-cow/src/BaseConditionalOrder.sol";

import {CConstantProduct, GPv2Order} from "src/CConstantProductFactory.sol";

import {CConstantProductFactoryTestHarness} from "./CConstantProductFactoryTestHarness.sol";

abstract contract GetTradeableOrderWithSignature is
    CConstantProductFactoryTestHarness
{
    // Notice: This function will be moved to the Helper contract in the future.
}
