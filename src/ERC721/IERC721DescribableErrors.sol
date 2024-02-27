// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

interface IERC721DescribableErrors {
    error ERC721DescribableMissingDescriptor();
    error ERC721DescribableInvalidDescriptor(address descriptor);
}
