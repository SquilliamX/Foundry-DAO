// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// Importing all required OpenZeppelin governance contracts
// Governor - Core contract that handles proposal lifecycle
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
// GovernorCountingSimple - Handles vote counting with For, Against, and Abstain options
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
// GovernorSettings - Manages configurable governance parameters
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
// GovernorTimelockControl - Adds delay between proposal passing and execution
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
// GovernorVotes - Connects governance to an ERC20Votes or ERC721Votes token
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
// GovernorVotesQuorumFraction - Adds quorum as a fraction of total token supply
import {GovernorVotesQuorumFraction} from
    "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
// IVotes - Interface for voting power tracking
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
// TimelockController - Enforces delay before execution
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

// MyGovernor contract inherits from multiple governance-related contracts
contract MyGovernor is
    Governor, // Base governance functionality, tracks all proposes
    GovernorSettings, // Configurable voting delay, period, and proposal threshold
    GovernorCountingSimple, // Basic vote counting (For, Against, Abstain)
    GovernorVotes, // Links governance to a token for voting power
    GovernorVotesQuorumFraction, // Sets quorum as percentage of total supply
    GovernorTimelockControl // Adds timelock delay for security
{
    // Constructor takes two parameters:
    // _token: The token used for voting power (must implement IVotes)
    // _timelock: The timelock controller that will execute passed proposals
    constructor(IVotes _token, TimelockController _timelock)
        /* Initialize Governor with name "MyGovernor" */
        Governor("MyGovernor")
        /* Initialize GovernorSettings with: */
        /* - votingDelay: 7200 blocks (≈1 day) - time between proposal creation and voting start */
        /* - votingPeriod: 50400 blocks (≈1 week) - duration of voting */
        /* - proposalThreshold: 0 tokens required to create proposal */
        GovernorSettings(7200, /* 1 day */ 50400, /* 1 week */ 0)
        /* Initialize GovernorVotes with token that tracks voting power */
        GovernorVotes(_token)
        /* Initialize GovernorVotesQuorumFraction with 4% quorum */
        GovernorVotesQuorumFraction(4)
        /* Initialize GovernorTimelockControl with timelock controller */
        GovernorTimelockControl(_timelock)
    {}

    // The following functions are required overrides by Solidity.
    // They resolve conflicts between inherited contracts by specifying which version to use.

    // Returns how long after a proposal is created that voting begins
    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    // Returns how long voting lasts once it begins
    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    // Returns the minimum number of votes required for a proposal to pass
    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    // Returns the current state of a proposal (Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed)
    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    // Checks if a proposal needs to be queued in the timelock
    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    // Returns the number of votes required to create a proposal
    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    // Internal function to queue operations in the timelock
    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    // Internal function to execute queued operations
    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    // Internal function to cancel operations
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    // Returns the address that will execute proposals (the timelock)
    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}

// Learn more about this contract @ https://updraft.cyfrin.io/courses/advanced-foundry/daos/create-governor-contract
