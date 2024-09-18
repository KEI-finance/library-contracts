// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC721Describable} from "./IERC721Describable.sol";
import {IERC721Descriptor} from "./IERC721Descriptor.sol";
import {IERC721DescribableErrors} from "./IERC721DescribableErrors.sol";

abstract contract ERC721DescribableUpgradeable is Initializable, IERC721Describable, IERC721DescribableErrors, ERC721Upgradeable {
    /// @custom:storage-location erc7201:erc721.describable.storage
    struct ERC721DescribableStorage {
        address descriptor;
    }

    // keccak256(abi.encode(uint256(keccak256("kei.fi.library-contracts.ERC721Describable.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721DescribableStorageLocation = 0xcf189a18a8ae61fbae2662579cfcd20e95a66ed1b3b4d51cded982607bcc9b00;

    function _getERC721DescribableStorage() private pure returns (ERC721DescribableStorage storage $) {
        assembly {
            $.slot := ERC721DescribableStorageLocation
        }
    }

    function __ERC721Describable_init() internal initializer {
        __ERC721Describable_init_unchained();
    }

    function __ERC721Describable_init_unchained() internal initializer {
        ERC721DescribableStorage storage $ = _getERC721DescribableStorage();
        $.descriptor = address(0);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, IERC721Describable) returns (bool) {
        return interfaceId == type(IERC721Describable).interfaceId || super.supportsInterface(interfaceId);
    }

    function descriptor() external view override returns (address) {
        return _getERC721DescribableStorage().descriptor;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);
        ERC721DescribableStorage storage $ = _getERC721DescribableStorage();
        IERC721Descriptor _descriptor = IERC721Descriptor($.descriptor);

        if (address(_descriptor) == address(0)) {
            revert ERC721DescribableMissingDescriptor();
        }

        return _descriptor.tokenURI(tokenId, _tokenURIData(tokenId));
    }

    function _updateDescriptor(address newDescriptor) internal virtual {
        if (newDescriptor == address(0)) {
            revert ERC721DescribableInvalidDescriptor(newDescriptor);
        }
        ERC721DescribableStorage storage $ = _getERC721DescribableStorage();
        emit DescriptorUpdate($.descriptor, newDescriptor, _msgSender());
        $.descriptor = newDescriptor;
    }

    function _tokenURIData(uint256 tokenId) internal view virtual returns (bytes memory);

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
