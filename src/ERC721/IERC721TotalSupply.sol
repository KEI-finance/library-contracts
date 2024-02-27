// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @title IERC721TotalSupply
 * @dev This interface represents a contract that reports the total supply of ERC721 tokens.
 */
interface IERC721TotalSupply {
    /**
     * @dev Get the current total supply of tokens.
     * @return uint256 The total supply of tokens.
     */
    function totalSupply() external view returns (uint256);
}
