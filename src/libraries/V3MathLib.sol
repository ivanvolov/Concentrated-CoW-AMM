// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {TickMath} from "@v4-core/libraries/TickMath.sol";
import {PRBMathUD60x18} from "@src/libraries/math/PRBMathUD60x18.sol";
import {FixedPointMathLib} from "@src/libraries/math/FixedPointMathLib.sol";

library V3MathLib {
    using FixedPointMathLib for uint256;

    function getSqrtPriceFromPrice(
        uint256 price
    ) internal view returns (uint160) {
        console.log(PRBMathUD60x18.sqrt(price));
        console.log(PRBMathUD60x18.sqrt(price) / 1e18);
        console.log(5314786713428871004159001755648);
        console.log((PRBMathUD60x18.sqrt(price) * 2 ** 96) / 1e18);
        console.log(PRBMathUD60x18.sqrt(price).mul(2 ** 96));
        return toUint160(PRBMathUD60x18.sqrt(price) * 2 ** 96);
    }

    function getTickFromPrice(uint256 price) internal pure returns (int24) {
        return
            toInt24(
                (
                    (int256(PRBMathUD60x18.ln(price * 1e18)) -
                        int256(41446531673892820000))
                ) / 99995000333297
            );
    }

    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "MH1");
        return int24(value);
    }

    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "MH2");
        return uint160(value);
    }
}
