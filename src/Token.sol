// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/*
  You are given 20 tokens to start with and you will beat the level
  if you somehow manage to get your hands on any additional tokens. 
  Preferably a very large amount of tokens.
*/

contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}
