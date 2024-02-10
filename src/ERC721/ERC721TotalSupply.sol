// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./IERC721TotalSupply.sol";

abstract contract ERC721TotalSupply is IERC721TotalSupply, ERC721 {
    uint256 private $totalSupply;

    function totalSupply() public view virtual override returns (uint256) {
        return $totalSupply;
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        unchecked {
            ++$totalSupply;
        }
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        unchecked {
            --$totalSupply;
        }
    }
}
