// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {
    DoubleEntryPoint,
    LegacyToken,
    CryptoVault,
    Forta,
    DelegateERC20,
    IDetectionBot,
    IForta
} from "../src/DoubleEntryPoint.sol";

contract DoubleEntryPointSolution is Script {
    // $ forge script script/DoubleEntryPoint.s.sol --tc DoubleEntryPointSolution

    function run() external {
        // --- Configure the instance ---
        address player = makeAddr("player");
        vm.deal(player, 1 ether);
        vm.startPrank(player);

        LegacyToken oldToken = new LegacyToken();
        Forta forta = new Forta();
        CryptoVault vault = new CryptoVault(player);

        DoubleEntryPoint newToken = new DoubleEntryPoint(address(oldToken), address(vault), address(forta), player);
        vault.setUnderlying(address(newToken));

        oldToken.delegateToNewContract(DelegateERC20(address(newToken)));

        oldToken.mint(address(vault), 100 ether);

        // --- Attack Starts From Here ---

        // - The contract `CryptoVault` simply transfers any ERC20 token to any address except the underlying token address.
        // - This underlying token address is the `DoubleEntryPoint` ERC20 token.
        // - `DoubleEntryPoint` is an update of `LegacyToken` contract, where when calling `LegacyToken` it will be forwarded to `DoubleEntryPoint`. NOTE: both of them are ERC20.
        // - When making a transfer in `LegacyToken` it forwards the trasnfer to the `DoubleEntryPoint`, which is the underlying asset in the `CryptoVault`
        // - So, If we call `CryptoVault::sweepToken(legacyToken)`, the transferring will get forwarded to `DoubleEntryPoint`, and we will drain all the underlying assets in `CryptoVault`.
        // - This is the bug that existed in the `CryptoVault`. Now we need to handle this, by making a bot that prevents this bug from happening.
        // - `DoubleEntryPoint::delegateTransfer()`, which is called by the LegacyToken to drain `CryptoVault` underlying tokens, has a modifier `fortaNotify`. This modifier checks the bot of the caller bot and calls `handleTransaction` with `msg.data` to check tx.
        // - We can read `msg.data`, and if the original sender is the `CryptoVault`, we will raise an Alert, which will revert the transaction.
        // - `original sender` is the address we will take his tokens, and `CryptoVault` can not transfer any DET token `underlying tokens` from the `Cryptovault`.
        // - So we will prevent this bug from occurring as if the player sets the LegacyToken address in `CryptoVault::sweepToken()` it will get detected from `fortaNotify` modifier and the transaction will get reverted.

        //

        // --- How DET token (Vault underlying token), can get reverted ---
        // You can run this code, and comment the other code `Preventing bug by implementing FortaBot`, to check the bug
        //
        // console.log("Vault DET balance:", newToken.balanceOf(address(vault)));
        // console.log("player DET balance:", newToken.balanceOf(player));
        // console.log("attacking...");
        // vault.sweepToken(oldToken);
        // console.log("vault DET balance:", newToken.balanceOf(address(vault)));
        // console.log("player DET balance:", newToken.balanceOf(player));
        // console.log("------------------");

        // --- Preventing bug by implementing FortaBot ---
        FortaBot fortaBot = new FortaBot(address(forta), address(vault));
        forta.setDetectionBot(address(fortaBot));

        console.log("Vault DET balance:", newToken.balanceOf(address(vault)));
        console.log("player DET balance:", newToken.balanceOf(player));
        console.log("attacking...");
        try vault.sweepToken(oldToken) {
            console.log("Failed to prevent bug occuarance");
        } catch Error(string memory reason) {
            console.log("Bug catched, we reverted the transaction");
            console.log("Error message:", reason);
        }

        console.log("vault DET balance:", newToken.balanceOf(address(vault)));
        console.log("player DET balance:", newToken.balanceOf(player));
        console.log("------------------");
    }
}

contract FortaBot is IDetectionBot {
    IForta immutable forta;
    address immutable cryptoVault;

    constructor(address _fotra, address _cryptoVault) {
        forta = IForta(_fotra);
        cryptoVault = _cryptoVault;
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        (,, address from) = abi.decode(msgData[4:], (address, uint256, address));

        if (from == cryptoVault) {
            // Raising Alert by one to revert the transaction, if the original sender is the Crypto Vault
            forta.raiseAlert(user);
        }
    }
}
