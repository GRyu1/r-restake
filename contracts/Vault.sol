// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "./Pool.sol";

contract Vault is ERC4626 {
    mapping(address => uint256) private balances;
    IERC20 public token;
    Pool pool = new Pool(address(this));

    event Deposit(address indexed user, uint256 amount);

    constructor(address _aUSDC) ERC4626(IERC20(_aUSDC)) ERC20("Shared aUSDC","saUSDC") {
        token=IERC20(_aUSDC);
    }

    function getBalanceOf() public view returns (uint256) {
        return balances[msg.sender];
    }

    function wrap(uint256 amount) public {
        require(amount > 0, "Vault: Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        //pool address
        _mint(address(pool), amount);
        pool.wrap(amount, msg.sender);
        emit Deposit(msg.sender, amount);
    }
}