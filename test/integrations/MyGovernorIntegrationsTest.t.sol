// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "src/MyGovernor.sol";
import {GovToken} from "src/GovToken.sol";
import {TimeLock} from "src/TimeLock.sol";
import {Box} from "src/Box.sol";
import {DeployBox} from "script/DeployBox.s.sol";

contract MyGovernorTest is Test {
    // The main contracts we'll interact with
    Box box; // The contract we want to govern (stores a number)
    GovToken token; // The token used for voting (like shares in a company)
    TimeLock timelock; // Enforces waiting periods for security
    MyGovernor governor; // Manages the entire governance process

    // Arrays used when creating proposals
    address[] proposers; // List of addresses that can make proposals
    address[] executors; // List of addresses that can execute proposals

    // These three arrays work together to define what a proposal will do:
    bytes[] functionCalls; // The encoded function calls to make (what to do)
    address[] addressesToCall; // The contract addresses to call (where to do it)
    uint256[] values; // How much ETH to send with each call (if any)

    // Test address that will act as our voter
    address public constant VOTER = address(1); // Using address(1) for simplicity

    function setUp() public {
        // Create a new instance of the deployment script
        DeployBox deployer = new DeployBox();

        // Run the deployment script which returns all our contracts
        // box: The contract we want to govern (stores a number)
        // token: The governance token used for voting
        // governor: The contract that manages proposals and voting
        // timelock: The contract that enforces delays before execution
        (box, token, governor, timelock) = deployer.run();

        // Setup the test voter:
        // Mint 100 governance tokens to our test voter address
        // 100e18 means 100 tokens (with 18 decimal places)
        token.mint(VOTER, 100e18);

        // Switch to acting as the VOTER address
        vm.prank(VOTER);
        // Delegate voting power to themselves
        // This is required - you must delegate before you can vote
        token.delegate(VOTER);

        // Initialize empty arrays that will be used later for proposals
        functionCalls = new bytes[](0); // Will store encoded function calls
        addressesToCall = new address[](0); // Will store target contract addresses
        values = new uint256[](0); // Will store ETH amounts to send
    }

    function testGovernanceUpdateBox() public {
        // 1. Create a proposal to store the number 777 in the Box contract
        uint256 valueToStore = 777;
        string memory description = "Store 777 in Box";
        // Convert the function call into bytes that can be executed later
        // We're calling the "store(uint256)" function with valueToStore as the argument
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        // Set up arrays required for the proposal:
        addressesToCall.push(address(box)); // Which contract to call (Box)
        values.push(0); // How much ETH to send (0)
        functionCalls.push(encodedFunctionCall); // What function to call (store)

        // Submit the proposal to the governor contract
        // Returns a unique ID that we'll use to track this proposal
        uint256 proposalId = governor.propose(addressesToCall, values, functionCalls, description);

        // 2. Fast forward time past the voting delay period
        // This is when people can start voting
        vm.warp(block.timestamp + governor.votingDelay() + 1); // Move time forward
        vm.roll(block.number + governor.votingDelay() + 1); // Move blocks forward

        // 3. Cast a vote as the VOTER address
        vm.prank(VOTER); // Pretend to be the voter
        governor.castVote(proposalId, 1); // Vote "For" the proposal (1 = For, 0 = Against)

        // 4. Fast forward time past the voting period
        // This is when voting ends
        vm.warp(block.timestamp + governor.votingPeriod() + 1);
        vm.roll(block.number + governor.votingPeriod() + 1);

        // 5. Queue the proposal in the timelock
        // The description hash is used to verify the proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);

        // 6. Fast forward time past the timelock delay
        // This is the mandatory waiting period before execution
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        vm.roll(block.number + timelock.getMinDelay() + 1);

        // 7. Execute the proposal
        // This actually calls the Box contract's store function
        governor.execute(addressesToCall, values, functionCalls, descriptionHash);

        // 8. Verify that the number was actually stored in the Box contract
        assertEq(box.getNumber(), valueToStore);
    }

    function testCantUpdateBoxWithoutGovernance() public {
        // Tell Foundry to expect the next transaction to revert (fail)
        vm.expectRevert();

        // Try to directly call store(1) on the Box contract
        // This should fail because only the DAO (through governance) can call store()
        box.store(1);

        // If the function didn't revert (fail), the test would fail
        // This verifies that the Box contract is properly protected by governance
    }
}
