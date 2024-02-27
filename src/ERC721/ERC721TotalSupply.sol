// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {IERC721TotalSupply} from "./IERC721TotalSupply.sol";

abstract contract ERC721TotalSupply is IERC721TotalSupply, ERC721 {
    uint256 private $totalSupply;

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
