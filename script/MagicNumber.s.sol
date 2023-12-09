// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {MagicNum} from "../src/MagicNumber.sol";

contract MagicNumberSolution is Script {
    // $ forge script script/MagicNumber.s.sol --tc MagicNumberSolution -vvvv

    function run() external {
        MagicNum magicNumberInstance = new MagicNum();
        MagicNumberAttack attackContract = new MagicNumberAttack();

        // --- SOLUTION STARTS ---

        // NOTE: we will discuss how to get the bytecode of the contract in breif, so it may be hard and complicated for beginners to understand it.
        // We prefer to go to the following resources to understand how OPCODES works in EVM blockchains.

        // https://medium.com/coinmonks/ethernaut-lvl-19-magicnumber-walkthrough-how-to-deploy-contracts-using-raw-assembly-opcodes-c50edb0f71a2
        // https://www.youtube.com/watch?v=gUVS4EcrQQQ&list=PLO5VPQH6OWdWh5ehvlkFX-H3gRObKvSL6&index=18

        // - To solve this challenge, we need to make a contract `solver` with runtime opcode <= 10 opcodes, and it should return 42 whenever it is being called.
        // - So we must go to the OPCODE level and code the contract OPCODEs ourselves.
        //
        // - Each contract has `runtime opcodes` and `initialization opcodes`.
        // - We will start by implementing the `runtime opcodes`
        // -
        //    - We will store number 42 in memory first
        //    6042    // value: push1 0x42 (value is 0x42)
        //    6080    // position in memory: push1 0x80 (memory slot is 0x80)
        //    52      // mstore (store the value in memory)
        //
        //    - Then we need to return the value
        //    6020    // data size (1 byte): push1 0x20
        //    6080    // position in memory: push1 0x80 (value was stored in slot 0x80)
        //    f3      // return (return the data in the 0x80 slot, whici is 42)
        //
        // - Then we need to make the `initialization opcodes`, to deploy the contract.
        //   The `initialization opcodes` will be placed before `runtime opcodes`
        //
        //    600a    // data size: push1 0x0a (10 bytes to store `runtime opcodes` length)
        //    600c    // data position: push1 0x0c (current position of runtime opcodes, it comes after `initialization opcodes`)
        //    6000    // distination position (where to store data): push1 0x00 (destination memory index 0)
        //    39      // CODECOPY
        //
        //
        // After completing this sequence we will get out solver contract byte codes as following:
        // [initialization opcodes][runtime opcodes]:
        // "600a600c600039600a6000f3602a60005260206000f3"
        //
        // - We will deploy this bytecode into EVM and get the address.
        // - Then, we will set the solver address in the `MagicNumber` contract to it.
        // - If you fired any function in the solver address, you will get the number 42

        address solver = attackContract.createSolver();
        magicNumberInstance.setSolver(solver);
        console.log(Solver(magicNumberInstance.solver()).whatIsTheMeaningOfLife()); // This should return `42`
    }
}

contract MagicNumberAttack {
    function createSolver() public returns (address) {
        // The contract bytecodes to be deployed
        bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3";

        address solver;

        // deploy the contract, and get its address
        assembly {
            //        create2(value (ETH sent), offset, size, salt)
            solver := create2(0, add(bytecode, 0x20), mload(bytecode), 0)
        }

        // return the address of the contract
        return solver;
    }
}

interface Solver {
    function whatIsTheMeaningOfLife() external returns (uint256);
}
