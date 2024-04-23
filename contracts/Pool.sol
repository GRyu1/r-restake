// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Pool is ERC20 {
    IERC20 public satoken;

    modifier auth() {
        require(address(satoken) == msg.sender, "Sender is Not Wrapper");
        _;
    }

    constructor(address _satoken) ERC20("R-shared aUSDC","rsaUSDC") {
        satoken = IERC20(_satoken);
    }

    function wrap(uint amount, address _address) auth public {
        require(amount > 0, "Pool: Amount must be greater than 0");
        _mint(_address, amount);
    } 
}