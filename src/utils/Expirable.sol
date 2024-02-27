// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @title Expirable
 * @dev This abstract contract provides an expiry mechanism.
 */
abstract contract Expirable {
    /**
     * @dev Ensures the operation happens before a certain time.
     * @param expiresAt The timestamp to compare with `block.timestamp`.
     */
    modifier expires(uint256 expiresAt) {
        require(expiresAt >= block.timestamp, "EXPIRED");
        _;
    }
}
