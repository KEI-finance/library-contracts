// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

/**
 * @title ERC721 Descriptor Interface
 * @notice This interface is used for handling the token URI of an ERC721 token
 */
interface IERC721Descriptor {
    /**
     * @notice Function to retrieve the token URI
     * @param tokenId The unique identifier for the token
     * @param data Additional data, might be used for obtaining more information about the token URI
     * @return uri The URI of the token
     */
    function tokenURI(uint256 tokenId, bytes memory data) external view returns (string memory uri);
}
