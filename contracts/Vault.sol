// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "./Pool.sol";

contract Vault is ERC4626 {
    mapping(address => uint256) private balances;
    uint256 public abc = 10;
    IERC20 public token;
    Pool private pool = new Pool(address(this));

    event Deposit(address indexed user, uint256 amount);

    error DEPRECATED_FUNCTION();
    error OUT_OF_BALANCE(address owner, uint256 balance);

    constructor(address _aUSDC) ERC4626(IERC20(_aUSDC)) ERC20("Shared aUSDC","saUSDC") {
        token=IERC20(_aUSDC);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }


    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        require(receiver == msg.sender, "Only the msg.sender can deposit for themselves");
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }
        uint256 shares = previewDeposit(assets);

        require(assets > 0, "Amount must be greater than 0");
        require(token.transferFrom(_msgSender(), address(this), assets), "Transfer failed");
        _mint(address(pool), assets);
        shares = pool.deposit(assets, receiver);
        balances[receiver] += assets;

        return shares;
    }

    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        require(receiver == msg.sender && receiver == owner, "Only the msg.sender can withdraw for themselves");
        uint256 shares = pool.withdraw(assets, receiver, owner);
        
        _burn(address(pool), assets);
        token.transfer( _msgSender(), assets);
        balances[owner] -= assets;

        return shares;
    }

    function mint(uint256 shares, address receiver) public override returns (uint256) {
        revert DEPRECATED_FUNCTION();
    }
    
    /////////////////////////////
    // Test functions
    /////////////////////////////

    function getPoolTotalAssets() public view returns (uint256) {
        return pool.totalAssets();
    }

    function getPoolTotalSupply() public view returns (uint256) {
        return pool.totalSupply();
    }
}