// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// The DAO is the owner
contract Box is Ownable {
    // we will pass the DAO address in the deployment script
    constructor(address initialOwner) Ownable(initialOwner) {}

    // declaring a variable for a number that is set by the Owner(DAO)
    uint256 private s_number;

    event NumberChanged(uint256 number);

    // the owner(DAO) can call this function and update the number in storage
    function store(uint256 newNumber) public onlyOwner {
        s_number = newNumber;
        emit NumberChanged(newNumber);
    }

    // getter function to get the current number in storage
    function getNumber() external view returns (uint256) {
        return s_number;
    }
}
