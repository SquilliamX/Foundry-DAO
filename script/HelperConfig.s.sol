// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

// Import required contracts
import {Script} from "forge-std/Script.sol";
import {MyGovernor} from "src/MyGovernor.sol";

contract HelperConfig is Script {
    // Define a struct to hold all our governance parameters
    struct NetworkConfig {
        uint256 votingDelay; // How long to wait before voting begins
        uint256 votingPeriod; // How long voting lasts
        uint256 quorumPercentage; // % of total supply needed for quorum
        uint256 minDelay; // Timelock delay before execution
    }

    // Store the active network configuration
    NetworkConfig public activeNetworkConfig;

    constructor() {
        // If we're on Sepolia testnet (chainid 11155111)
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            // Otherwise use local Anvil settings
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    // Settings for Sepolia testnet
    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            votingDelay: 7200, // ~1 day (assuming 12s block time)
            votingPeriod: 50400, // ~1 week
            quorumPercentage: 4, // 4% of token holders must vote
            minDelay: 3600 // 1 hour delay after vote passes
        });
    }

    // Settings for local testing
    function getOrCreateAnvilConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            votingDelay: 1, // 1 block
            votingPeriod: 50400, // Same as Sepolia
            quorumPercentage: 4, // 4% quorum
            minDelay: 1 // 1 second delay
        });
    }
}
