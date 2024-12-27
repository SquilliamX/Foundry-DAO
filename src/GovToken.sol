// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// Importing required OpenZeppelin contracts
// ERC20 - Base implementation of the ERC20 token standard
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// ERC20Permit - Allows approvals to be made via signatures (gasless approvals)
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
// ERC20Votes - Adds voting and delegation capabilities to the token
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
// Nonces - Provides tracking nonces for addresses (used for signature validation)
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

// from OpenZeppelin wizard, with ERC20 "voting" features turned on: https://wizard.openzeppelin.com/
// GovToken contract inherits from three OpenZeppelin contracts:
// 1. ERC20 - Basic token functionality (transfers, balances)
// 2. ERC20Permit - Gasless approval functionality
// 3. ERC20Votes - Governance functionality (voting power, delegation)
contract GovToken is ERC20, ERC20Permit, ERC20Votes {
    // Constructor is called when the contract is deployed
    // It sets up the token with:
    // - Name: "GovToken"
    // - Symbol: "GTK"
    // The constructor also initializes ERC20Permit with the token name
    constructor() ERC20("GovToken", "GTK") ERC20Permit("GovToken") {}

    // only for testing purposes
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    /**
     * @dev Internal function that is called on all token transfers, mints, and burns
     * Must override both ERC20 and ERC20Votes versions to maintain voting power tracking
     *
     * @param from The address tokens are being transferred from
     * @param to The address tokens are being transferred to
     * @param value The amount of tokens being transferred
     */
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        // Calls both ERC20 and ERC20Votes _update functions
        // This ensures both standard token transfers work AND voting power is updated
        super._update(from, to, value);
    }

    /**
     * @dev Returns the next unused nonce for an address
     * Must override both ERC20Permit and Nonces versions to maintain consistent nonce tracking
     * Nonces are used to prevent signature replay attacks in the permit function
     *
     * @param owner The address to get the nonce for
     * @return The next nonce for the address
     */
    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        // Uses the nonce tracking from the parent contracts
        return super.nonces(owner);
    }
}

// This token can be used for:
// 1. Regular transfers (from ERC20)
// 2. Gasless approvals (from ERC20Permit)
// 3. Governance voting (from ERC20Votes)
//    - Token holders can delegate their voting power
//    - Voting power is tracked with checkpoints for accurate historical queries
//    - Supports both direct voting and voting by signature

// Learn more about this contract @ https://updraft.cyfrin.io/courses/advanced-foundry/daos/governance-tokens
