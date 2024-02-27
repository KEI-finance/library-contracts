// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {IERC721Describable} from "./IERC721Describable.sol";
import {IERC721Descriptor} from "./IERC721Descriptor.sol";
import {IERC721DescribableErrors} from "./IERC721DescribableErrors.sol";

abstract contract ERC721Describable is IERC721Describable, IERC721DescribableErrors, ERC721 {
    address private $descriptor;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721Describable).interfaceId || super.supportsInterface(interfaceId);
    }

    function descriptor() external view override returns (address) {
        return $descriptor;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);
        IERC721Descriptor _descriptor = IERC721Descriptor($descriptor);

        if (address(_descriptor) == address(0)) {
            revert ERC721DescribableMissingDescriptor();
        }

        return _descriptor.tokenURI(tokenId, _tokenURIData(tokenId));
    }

    function _updateDescriptor(address newDescriptor) internal virtual {
        if (newDescriptor == address(0)) {
            revert ERC721DescribableInvalidDescriptor(newDescriptor);
        }
        emit DescriptorUpdate($descriptor, newDescriptor, _msgSender());
        $descriptor = newDescriptor;
    }

    function _tokenURIData(uint256 tokenId) internal view virtual returns (bytes memory);
}
