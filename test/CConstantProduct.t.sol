// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {VerifyTest} from "./CConstantProduct/VerifyTest.sol";
import {GetTradeableOrderTest} from "./CConstantProduct/GetTradeableOrderTest.sol";
import {CommitTest} from "./CConstantProduct/CommitTest.sol";
import {DeploymentParamsTest} from "./CConstantProduct/DeploymentParamsTest.sol";
import {EnableTrading} from "./CConstantProduct/EnableTrading.sol";
import {DisableTrading} from "./CConstantProduct/DisableTrading.sol";
import {IsValidSignature} from "./CConstantProduct/IsValidSignature.sol";

contract CCConstantProduct is
    VerifyTest,
    GetTradeableOrderTest,
    CommitTest,
    DeploymentParamsTest,
    EnableTrading,
    DisableTrading,
    IsValidSignature
{}
