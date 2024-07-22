// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20} from "src/ConstantProductFactory.sol";

import {ConstantProductFactoryTestHarness} from "./ConstantProductFactoryTestHarness.sol";

abstract contract Params is ConstantProductFactoryTestHarness {
    function testAnyoneCanDeposit() public {
        address anyone = makeAddr("Deposit: an arbitrary address");
        uint256 amount0 = 1234;
        uint256 amount1 = 5678;

        address token0 = address(constantProduct.token0());
        address token1 = address(constantProduct.token1());
        vm.expectCall(
            token0,
            abi.encodeCall(
                IERC20.transferFrom,
                (anyone, address(constantProduct), amount0)
            ),
            1
        );
        vm.expectCall(
            token1,
            abi.encodeCall(
                IERC20.transferFrom,
                (anyone, address(constantProduct), amount1)
            ),
            1
        );
        vm.prank(anyone);
        constantProductFactory.deposit(constantProduct, amount0, amount1);
    }
}
