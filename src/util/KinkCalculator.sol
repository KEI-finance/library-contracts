// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import "./Percent.sol";

library KinkCalculator {
    using Percent for uint256;

    struct Kink {
        uint128 position;
        uint128 value;
    }

    function calculate(
        uint256 position,
        uint256 minValue,
        uint256 maxValue,
        uint256 minPosition,
        uint256 maxPosition,
        Kink memory kink
    ) internal pure returns (uint256) {
        uint256 kinkPosition = (maxPosition - minPosition).applyPercent(kink.position) + minPosition;
        uint256 kinkValue = (maxValue - minValue).applyPercent(kink.value) + minValue;

        if (position >= maxPosition) {
            return maxValue;
        } else if (position <= minPosition) {
            return minValue;
        } else if (position == kinkPosition) {
            return kinkValue;
        }

        if (position < kinkPosition) {
            return _calculate(position, minValue, kinkValue, minPosition, kinkPosition);
        } else {
            return _calculate(position, kinkValue, maxValue, kinkPosition, maxPosition);
        }
    }

    function _calculate(uint256 position, uint256 minValue, uint256 maxValue, uint256 minPosition, uint256 maxPosition)
        private
        pure
        returns (uint256)
    {
        uint256 valueRange = maxValue - minValue;
        uint256 durationRange = maxPosition - minPosition;

        uint256 percentValue = (position - minPosition).percentValueOf(durationRange);
        return minValue + valueRange.applyPercent(percentValue);
    }
}
