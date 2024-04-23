// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Wrapper.sol";

contract Router{
    mapping(address => uint256) private balances;
    IERC20 public token;

    event DepositMade(address indexed accountAddress, uint amount);

    modifier auth(address _address) {
        require(_address == msg.sender, "Router: Not authorized");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
    }

    function balanceOf(address _address) auth(_address) public view returns (uint256) {
        return balances[_address];
    }

    function approve(address _address, uint256 _amount) auth(_address) public {
        balances[_address] = _amount;
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Router: Amount must be greater than 0");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        balances[msg.sender] += _amount;
        emit DepositMade(msg.sender, _amount);
    }

   

}