// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library NumberFormatter {
    using Strings for uint256;

    function formatFloat(uint256 source, uint256 decimals) internal pure returns (string memory) {
        return format(source, decimals, "");
    }

    function format(uint256 source, uint256 decimals) internal pure returns (string memory) {
        return format(source, decimals, ",");
    }

    function format(uint256 source, uint256 decimals, bytes memory separator) internal pure returns (string memory) {
        bytes memory buffer = "";
        uint256 nonFractional = source / 10 ** decimals;
        uint256 fractional = source % 10 ** decimals;

        if (fractional > 0 && decimals > 0) {
            uint256 places = 8;
            if (nonFractional >= 1e4) places = 0;
            else if (nonFractional >= 1e3) places = 1;
            else if (nonFractional >= 1e2) places = 2;
            else if (nonFractional >= 1e1) places = 3;
            else if (nonFractional >= 1) places = 4;
            else if (decimals >= 1 && fractional > 10 ** (decimals - 1)) places = 5;
            else if (decimals >= 2 && fractional > 10 ** (decimals - 2)) places = 6;
            else if (decimals >= 3 && fractional > 10 ** (decimals - 3)) places = 7;

            if (places > decimals) places = decimals;
            if (places > 0) {
                uint256 visiblePlaces = fractional / 10 ** (decimals - places);
                if (visiblePlaces > 0) {
                    buffer = bytes(visiblePlaces.toString());
                    uint256 nb = 10 ** places;
                    while (nb > 0) {
                        nb /= 10;
                        if (nb > visiblePlaces) buffer = abi.encodePacked("0", buffer);
                        else break;
                    }
                    nb = visiblePlaces % 10;
                    while (nb == 0) {
                        visiblePlaces /= 10;
                        nb = visiblePlaces % 10;
                    }
                    buffer = abi.encodePacked(".", buffer);
                }
            }
        }

        source = nonFractional;
        if (source == 0) {
            buffer = abi.encodePacked("0", buffer);
        } else if (separator.length == 0) {
            buffer = abi.encodePacked(source.toString(), buffer);
        } else {
            bool initial = true;
            while (source > 0) {
                uint256 part = source % 1e3;
                buffer = abi.encodePacked(part.toString(), initial ? "" : string(separator), buffer);
                source = source / 1e3;
                if (source > 0) {
                    if (part < 10) buffer = abi.encodePacked("00", buffer);
                    else if (part < 100) buffer = abi.encodePacked("0", buffer);
                }
                initial = false;
            }
        }

        return string(buffer);
    }
}
