// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {AlienCodex} from "../src/AlienCodex.sol";

contract AlienCodexSolution is Script {
    // $ forge script script/AlienCodex.s.sol --tc AlienCodexSolution -vvvv

    function run() external view {
        console.log("You can't test this contrant as it requires solidity v0.5, and Foundry tools works at >= v0.6");

        // - It seems that the contract is robust and we can't change the owner variable, but the good thing is that we can.
        // - In solidity v0.5, you can decrease the length of the array directly using `array.length--`.
        // - The problem is if the array length is 0 and you subtracted 1, it will result in 2 ** 256 - 1.
        // - In EVM, the storage space contains 2 ** 256 - 1 slots, and our array also has 2 ** 256 - 1 slots too.
        // - Let's go for the `AlienCodex` contract, it inherits from the Owner contract (20bytes address). And we have bool `contact` (1byte), then our array comes.
        //
        // - slot0 (owner address, contract boolean variable)
        // - slot1 (codex array length (2 ** 256))
        // -
        // - So it seems that we are exceeding storage slots by 1, and in that case rewrite in storage will occuar.
        // - We are using 1 slot + 2 ** 256, and our storage is 2 ** 256, so the last storage slot will take the place of slot0, which stores the owner address. Seems interesting!
        // -
        // - The first slot stores the array length, and array elements are stored as keccak256 of the array slot adding the index to it.

        // slot[keccak256(1)]: codex[0]
        // slot[keccak256(1)] + 1: codex[1]
        // slot[keccak256(1)] + 2: codex[2]
        // ....
        // ....
        // ....
        // When the slot + index exceeds 2 ** 256 - 1, overflow occuars, and signs reverses
        // ...
        // type(uint256).max: codex[type(uint256).max - uint(keccack256(1))
        // 0: codex[type(uint256).max - uint(keccack256(1) + 1) => where we need to make the attack
        //
        // - So the 0slot element index in the codex array equals `type(uint256).max - uint(keccack256(1) + 1`.
        // - We calculated this value and we get `35707666377435648211887908874984608119992236509074197713628505308453184860938`.

        //
        // - We got the array index that will change the slot0 storage value, but before setting it, we need to make the array have 2 ** 256 lengths in `AlienCodex` contract.
        //
        // -  We will fire `makeContact` function first. Then, we will call `retract`.
        // - Since the length was 0 subtracting it will make the array length equal 2 ** 256 - 1.
        // - After this, we can call `revise` function. The first parameter will be the array index which we calculated, and the second parameter will be the bytes32 value you want to put.
    }
}
