// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import {Script} from "forge-std/Script.sol";
import {Box} from "src/Box.sol";
import {GovToken} from "src/GovToken.sol";
import {MyGovernor} from "src/MyGovernor.sol";
import {TimeLock} from "src/TimeLock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployBox is Script {
    // Main entry point for deployment
    function run() external returns (Box, GovToken, MyGovernor, TimeLock) {
        return deployBox();
    }

    function deployBox() public returns (Box, GovToken, MyGovernor, TimeLock) {
        // Get network-specific configuration (Sepolia or Anvil)
        HelperConfig helperConfig = new HelperConfig();
        // Destructure the config into the individual variable we need
        (,,, uint256 minDelay) = helperConfig.activeNetworkConfig();

        // Start recording real transactions to broadcast
        vm.startBroadcast();

        // 1. Deploy governance token
        GovToken govToken = new GovToken();
        // Give deployer some initial tokens
        govToken.mint(msg.sender, 100e18); // 100 tokens with 18 decimals

        // 2. Deploy timelock (handles delay between vote & execution)
        address[] memory proposers = new address[](0); // Start with empty proposers
        address[] memory executors = new address[](0); // Start with empty executors
        TimeLock timelock = new TimeLock(minDelay, proposers, executors);

        // 3. Deploy governor contract (handles voting logic)
        MyGovernor governor = new MyGovernor(govToken, timelock);

        // 4. Setup roles for governance system
        bytes32 proposerRole = timelock.PROPOSER_ROLE(); // Role that can propose
        bytes32 executorRole = timelock.EXECUTOR_ROLE(); // Role that can execute
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE(); // Admin role

        // Give governor contract permission to propose
        timelock.grantRole(proposerRole, address(governor));
        // Allow anyone to execute passed proposals
        timelock.grantRole(executorRole, address(0));
        // Remove admin role from deployer for security
        timelock.revokeRole(adminRole, msg.sender);

        // 5. Deploy Box contract with timelock as owner
        Box box = new Box(address(timelock));

        vm.stopBroadcast();

        return (box, govToken, governor, timelock);
    }
}
