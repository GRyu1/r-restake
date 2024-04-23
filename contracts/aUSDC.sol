// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract aUSDC is ERC20 {
    constructor() ERC20("Test aUSDC","aUSDC") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}