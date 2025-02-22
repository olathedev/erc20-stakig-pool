// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import 'lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';

contract Bead is ERC20("BeadToken", "BDT"){
    address public owner;

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 100000e18);
    }

    function mint(uint256 _amount)  external {
        require(msg.sender == owner, "Only owner can mint");
        _mint(owner, _amount);
    }   
}   
