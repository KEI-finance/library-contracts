// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2, stdJson} from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    using stdJson for string;

    struct DeployConfig {
        bytes32 salt;
    }

    address public deployer;
    DeployConfig internal config;
    mapping(string => address) public deployment;

    function setUp() public {
        uint256 privateKey = vm.envUint(string.concat("PRIVATE_KEY_", vm.toString(block.chainid)));
        deployer = vm.rememberKey(privateKey);
        loadConfig();
    }

    function getConfig() public view returns (DeployConfig memory) {
        return config;
    }

    function getAddress(string memory name) internal view returns (address) {
        return getAddress(name, "");
    }

    function getAddress(string memory name, bytes memory args) internal view returns (address) {
        bytes32 hash = hashInitCode(vm.getCode(name), args);
        return computeCreate2Address(config.salt, hash);
    }

    function deploy(string memory name) internal returns (address addr) {
        return deploy(name, "", true);
    }

    function deploy(string memory name, bool deployIfMissing) internal returns (address addr) {
        return deploy(name, "", deployIfMissing);
    }

    function deploy(string memory name, bytes memory args) internal returns (address addr) {
        return deploy(name, args, true);
    }

    function deploy(string memory name, bytes memory args, bool deployIfMissing) internal returns (address addr) {
        addr = getAddress(name, args);
        deployment[name] = addr;

        if (addr.code.length == 0) {
            require(deployIfMissing, string.concat("MISSING_CONTRACT_", name));

            bytes memory bytecode = abi.encodePacked(vm.getCode(name), args);
            bytes32 salt = config.salt;

            assembly {
                addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
                if iszero(extcodesize(addr)) { revert(0, 0) }
            }
        }
    }

    function loadConfig() internal {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config.json");
        string memory json = vm.readFile(path);

        string memory key = string.concat(".", vm.toString(block.chainid));

        //        config.salt = bytes32(json.readUint(string.concat(key, ".salt")));
    }
}
