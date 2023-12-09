// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract RecoverySolution is Script {
    // $ forge script script/Recovery.s.sol --tc RecoverySolution -vvvv

    Recovery tokenFactory;

    function run() external {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);
        vm.deal(deployer, 0.1 ether);

        // - The deployer will deploy the Recovery contract, which is used as a Factory to generate new tokens
        tokenFactory = new Recovery();

        // - The deployer will generate new token
        tokenFactory.generateToken("My Token", 1_000_000 ether); // Generating 1 million tokens with 18 decimals

        // --- We will start solving ---

        // - `Recovery` contract is a TokenFactory contract, and there is a token deployed with it. One user made a TX to increase his balance, but the problem is that we forgot the deployed token address.
        // - In `Recovery::generateToken` function, we are not storing the token address. It seems we can't retrieves the token address. But since the blockchain is public in its nature, we can know what is the contract address.
        // - We can go to `Ethereum explorers` such as `etherscan` and view the Factory contract address `Recovery`.
        // - Then, We will go to the `generateToken()` function tx, which will be viewed in the address, internal transactions section.
        // - In the internal transactions section, we will see the internal transaction that occurred by this contract `Recovery`.
        // - You will find one of The token contract creation transactions. And If you click on it, you will see the token address.

        // We deployed this contract on sepolia network, this is not the deployment script on sepolia.
        // Recovery address: https://sepolia.etherscan.io/address/0x94fadfa47f78955b30a7d9be96961a3398cd8935
        // In the internal TXs section you will find a transactiion from `Recovery` to `contract creation`, if you clicked on it you will redirected to the generated token address.
        // Since the contract is deployed as internal tx, etherscan will not retreives its data, unless we verify it.
        // Token Address: https://sepolia.etherscan.io/address/0x083ebc875e86905d8d82746f397ad6e7101cb166

        // We got this address when we deployed the token first time.
        // And since Foundry uses the the same address, with the beginning blockchain state, the address will be the same.
        SimpleToken myToken = SimpleToken(payable(0x0d5C87e3905Da4B351d605a0d89953aF60eF667a));

        console.log("MyToken address:", address(myToken));
        console.log("deployer balance:", myToken.balances(deployer));

        // The address is with us, we can recover the user balance by calling `destroy` function.
        vm.stopPrank();
    }
}
