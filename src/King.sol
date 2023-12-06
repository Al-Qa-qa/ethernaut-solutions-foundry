// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    The contract below represents a very simple game:
    whoever sends it an amount of ether that is larger than the current prize becomes the new king.
    On such an event, the overthrown king gets paid the new prize, making a bit of ether in the process!
    As ponzi as it gets xD

    Such a fun game. Your goal is to break it.

    When you submit the instance back to the level, the level is going to reclaim kingship.
    You will beat the level if you can avoid such a self proclamation.
*/

contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}
