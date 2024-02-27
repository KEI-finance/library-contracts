// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

/**
 * @title IERC721Describable
 * @author Anonymous
 * @notice This interface is used for ERC721 tokens which have descriptiveness functionality.
 */
interface IERC721Describable {
    /**
     * @notice This event is emmited when the descriptor is updated.
     * @param prevValue This is the previous address of the descriptor.
     * @param newValue This is the new address of the descriptor.
     * @param sender This is the address of the sender who updated the descriptor.
     */
    event DescriptorUpdate(address prevValue, address newValue, address indexed sender);

    /**
     * @notice This function is used to get the current address of the descriptor.
     * @return Returns the current address of the descriptor.
     */
    function descriptor() external view returns (address);
}
