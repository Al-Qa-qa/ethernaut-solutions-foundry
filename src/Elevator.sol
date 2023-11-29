// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
  - Reach the top of the building to path the challenge.
  - The Elevator should prevent you from reaching the top of the buiding.
*/

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
