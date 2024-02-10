// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "../ERC20/IERC20Partition.sol";

import "./IVotesContainer.sol";

contract VotesContainer is IVotesContainer, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize() external initializer {
        __Ownable_init();
        __Context_init_unchained();
    }

    function getVotes(address token) external view override returns (uint256) {
        return IVotesUpgradeable(token).getVotes(address(this));
    }

    function getPastVotes(address token, uint256 blockNumber) external view override returns (uint256) {
        return IVotesUpgradeable(token).getPastVotes(address(this), blockNumber);
    }

    function delegates(address token) external view override returns (address) {
        return IVotesUpgradeable(token).delegates(address(this));
    }

    function delegate(address token, address target) external override onlyOwner {
        IVotesUpgradeable(token).delegate(target);
    }

    function transfer(address token, bytes32 id, address to, uint256 amount, bytes memory data)
        external
        override
        onlyOwner
    {
        bool result = IERC20Partition(token).transfer(to, id, amount, data);
        require(result, "IVotesContainer: FAILED_TRANSFER");
    }

    function transfer(address token, address to, uint256 amount) external override onlyOwner {
        IERC20Upgradeable(token).safeTransfer(to, amount);
    }
}
