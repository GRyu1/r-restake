// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Pool is ERC4626 {
    IERC20 public satoken;
    bool private isDeposit = false;
    error DEPRECATED_FUNCTION();


    modifier auth() {
        require(address(satoken) == msg.sender, "Sender is Not Vaults");
        _;
    }

    constructor(address _satoken) ERC4626(IERC20(_satoken)) ERC20("R-shared aUSDC","rsaUSDC") {
        satoken = IERC20(_satoken);
    }

    function deposit(uint256 assets, address receiver) auth public override returns (uint256) {
        isDeposit = true;

        require(assets > 0, "Amount must be greater than 0");
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }
        
        uint256 shares = previewDeposit(assets);
        _mint(receiver, shares);
        isDeposit = false;
        return shares;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) auth public override returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _burn(owner, shares);

        return maxAssets;
    }



    function mint(uint256 shares, address receiver) public override returns (uint256) {
        revert DEPRECATED_FUNCTION();
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view override returns (uint256) {
        if (isDeposit) {
            return Math.mulDiv(assets, totalSupply() + 10 ** _decimalsOffset(), totalAssets() - assets + 1, rounding);
        } else {
            return Math.mulDiv(assets, totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
        }   
    }

}