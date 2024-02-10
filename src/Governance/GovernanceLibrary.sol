// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "./IVotesContainer.sol";

library GovernanceLibrary {
    address internal constant CONTAINER_IMPLEMENTATION = 0x0DCd0F06cc37aece7dcbEB035A8bd5AdDA16bFd1;

    function createVotesContainer() internal returns (address instance) {
        instance = Clones.clone(CONTAINER_IMPLEMENTATION);
        IVotesContainer(instance).initialize();
    }
}
