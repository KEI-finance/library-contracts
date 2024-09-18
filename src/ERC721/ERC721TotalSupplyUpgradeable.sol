// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC721TotalSupply} from "./IERC721TotalSupply.sol";

abstract contract ERC721TotalSupplyUpgradeable is Initializable, IERC721TotalSupply, ERC721Upgradeable {
    
    /// @custom:storage-location erc7201:erc721.totalsupply.storage
    struct ERC721TotalSupplyStorage {
        uint256 totalSupply;
    }

    // keccak256(abi.encode(uint256(keccak256("kei.fi.library-contracts.ERC721TotalSupply.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721TotalSupplyStorageLocation = 0xd2b1a1237816c446d8e1e0e72b974896a4c1c610c4a5d3262537006e4e650e00;

    function _getERC721TotalSupplyStorage() private pure returns (ERC721TotalSupplyStorage storage $) {
        assembly {
            $.slot := ERC721TotalSupplyStorageLocation
        }
    }

    function __ERC721TotalSupply_init() internal initializer {
        __ERC721TotalSupply_init_unchained();
    }

    function __ERC721TotalSupply_init_unchained() internal initializer {
        ERC721TotalSupplyStorage storage $ = _getERC721TotalSupplyStorage();
        $.totalSupply = 0;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return $totalSupply;
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address _from = _ownerOf(tokenId);
        if (_from == address(0)) {
            unchecked {
                ++$totalSupply;
            }
        } else if (to == address(0)) {
            unchecked {
                --$totalSupply;
            }
        }
        return super._update(to, tokenId, auth);
    }
}