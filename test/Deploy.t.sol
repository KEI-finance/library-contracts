// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "@kei.fi/testing-lib/BaseTest.sol";

import {DeployScript} from "script/Deploy.s.sol";

contract DeployTest is BaseTest {
    struct ExpectDeployment {
        string name;
        address addr;
    }

    ExpectDeployment[] internal expected;

    function setUp() external {
        expected.push(ExpectDeployment("AccountSetup.sol", 0x0b0f227Ba880F5781a40e05AeA3981D9bc4260FE));
    }

    function test_deploy() external {
        vm.chainId(5);

        DeployScript script = new DeployScript();

        script.setUp();
        script.run();

        for (uint256 i; i < expected.length; i++) {
            ExpectDeployment memory expectedDeployment = expected[i];
            address deployment = script.deployment(expectedDeployment.name);
            assertEq(
                deployment,
                expectedDeployment.addr,
                string.concat(
                    expectedDeployment.name,
                    " address has changed. Current Address: ",
                    vm.toString(deployment),
                    ". Expected address: ",
                    vm.toString(expectedDeployment.addr)
                )
            );
        }
    }
}
