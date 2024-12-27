// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "src/MyGovernor.sol";
import {GovToken} from "src/GovToken.sol";
import {TimeLock} from "src/TimeLock.sol";
import {Box} from "src/Box.sol";

contract MyGovernorTest is Test {
    // Core contracts that make up our DAO system
    Box box; // A simple contract that stores a number - this is what we'll control through governance
    GovToken token; // Our governance token - holders can vote (like shares in a company)
    TimeLock timelock; // Security layer - enforces waiting period between vote passing and execution
    MyGovernor governor; // Main governance contract - handles proposals and voting process

    // Constants for governance configuration
    uint256 public constant MIN_DELAY = 3600; // 1 hour - after a vote passes, you must wait this long before executing
    uint256 public constant QUORUM_PERCENTAGE = 4; // 4% of total token holders must vote for proposal to pass
    uint256 public constant VOTING_PERIOD = 50400; // How many blocks voting remains open (about 1 week)
    uint256 public constant VOTING_DELAY = 1; // How many blocks to wait before voting starts

    // Arrays for managing timelock permissions
    address[] proposers; // List of addresses allowed to make proposals (empty = governance only)
    address[] executors; // List of addresses allowed to execute passed proposals (empty = anyone)

    // Arrays used when creating proposals - these three always work together:
    bytes[] functionCalls; // What functions to call (encoded as bytes)
    address[] addressesToCall; // Which contracts to call those functions on
    uint256[] values; // How much ETH to send with each call

    // Test address that will act as our voter
    address public constant VOTER = address(1); // Using a simple address for testing

    function setUp() public {
        // Create a new governance token (ERC20 with voting capabilities)
        token = new GovToken();

        // Mint 100 tokens to our test voter address
        // 100e18 means 100 tokens (since ERC20 tokens have 18 decimal places)
        token.mint(VOTER, 100e18);

        // Switch our next transaction to be from the VOTER address
        vm.prank(VOTER);
        // The voter delegates their voting power to themselves
        // This is required before they can vote on proposals
        token.delegate(VOTER);

        // Create new timelock contract with:
        // - MIN_DELAY: How long to wait before executing passed proposals
        // - proposers: List of addresses that can propose (empty array for now)
        // - executors: List of addresses that can execute (empty array for now)
        timelock = new TimeLock(MIN_DELAY, proposers, executors);

        // Create the main governance contract, connecting it to:
        // - token: Used to track voting power
        // - timelock: Used to enforce waiting periods
        governor = new MyGovernor(token, timelock);

        // Get the special roles from the timelock contract
        bytes32 proposerRole = timelock.PROPOSER_ROLE(); // Role that can queue proposals
        bytes32 executorRole = timelock.EXECUTOR_ROLE(); // Role that can execute proposals
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE(); // Role that can manage other roles

        // Set up permissions:
        // 1. Only the governor can propose actions
        timelock.grantRole(proposerRole, address(governor));
        // 2. Anyone can execute (address(0) means any address)
        timelock.grantRole(executorRole, address(0));
        // 3. Remove the deployer's admin powers for security
        timelock.revokeRole(adminRole, msg.sender);

        // Create the Box contract that we'll govern
        // The timelock will be its owner, so only governance can modify it
        box = new Box(address(timelock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        // STEP 1: Setup the test expectation
        // Tell Foundry (our testing framework) that we expect the next transaction to fail
        // This is like saying "the next thing we try should not work"
        vm.expectRevert();

        // STEP 2: Try to update the Box directly
        // Attempt to call store(1) on the Box contract without going through governance
        // This should fail because:
        // - Box is owned by the timelock contract
        // - Only the owner (timelock) can call store()
        // - We're calling it from a random address
        box.store(1);

        // STEP 3: Verify the test
        // If box.store(1) didn't fail (revert), then this whole test would fail
        // This is good! We want the Box to be protected and only controllable through governance
        // No explicit verification needed because expectRevert does the check for us
    }

    function testGovernanceUpdateBox() public {
        // Step 1: Proposal Creation
        uint256 valueToStore = 777; // The number we want to store in the Box contract
        string memory description = "Store 777 in Box"; // Human-readable description of what this proposal does

        // Convert the function we want to call (store) into bytes
        // This is like preparing a message that says "call store(777)"
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        // Prepare the proposal details using arrays:
        addressesToCall.push(address(box)); // Which contract to call (Box)
        values.push(0); // How much ETH to send (none)
        functionCalls.push(encodedFunctionCall); // What function to call (store)

        // Submit the proposal and get back an ID to track it
        uint256 proposalId = governor.propose(addressesToCall, values, functionCalls, description);

        // Step 2: Voting Delay
        // Fast forward time past the voting delay period so voting can begin
        vm.warp(block.timestamp + governor.votingDelay() + 1); // Move timestamp forward
        vm.roll(block.number + governor.votingDelay() + 1); // Move block number forward

        // Step 3: Vote
        vm.prank(VOTER); // Act as the voter
        governor.castVote(proposalId, 1); // Vote in favor (1=Yes, 0=No)

        // Step 4: Voting Period
        // Fast forward time past the voting period
        vm.warp(block.timestamp + governor.votingPeriod() + 1);
        vm.roll(block.number + governor.votingPeriod() + 1);

        // Step 5: Queue
        // After vote passes, queue it in the timelock
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);

        // Step 6: Timelock Delay
        // Wait for timelock delay to pass
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        vm.roll(block.number + timelock.getMinDelay() + 1);

        // Step 7: Execute
        // Finally execute the proposal
        governor.execute(addressesToCall, values, functionCalls, descriptionHash);

        // Step 8: Verify
        // Check if our number was actually stored
        assertEq(box.getNumber(), valueToStore);
    }
}
