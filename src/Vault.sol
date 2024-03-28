// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PersonalVault is Ownable {
    IERC20 public realTPropertyToken; // The ERC20 token for RealT properties

    uint256 public realTTokenBalance;

    event Deposit(address indexed owner, uint256 amount);

    constructor(address _realTPropertyTokenAddress) Ownable(msg.sender) { // Pass the owner's address here if required
        realTPropertyToken = IERC20(_realTPropertyTokenAddress);
    }

    /**
     * @dev Allows the vault owner to deposit RealT property tokens into their vault.
     * @param amount The amount of RealT property tokens to deposit.
     */
    function deposit(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(realTPropertyToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        realTTokenBalance += amount;

        emit Deposit(msg.sender, amount);
    }

    // Future implementations can add withdrawal, borrowing, and other functionalities.
}
