// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRCUSD {
    function mint(address to, uint256 amount) external;
}

contract PersonalVault is Ownable {
    IERC20 public realTPropertyToken; // The ERC20 token for RealT properties

    IRCUSD public rcUSDToken;

    uint256 public realTTokenBalance;

    event Deposit(address indexed owner, uint256 amount);

    constructor(address _realTPropertyTokenAddress, address _rcUSDAddress) Ownable(msg.sender) {
        realTPropertyToken = IERC20(_realTPropertyTokenAddress);
        rcUSDToken = IRCUSD(_rcUSDAddress);
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

    function setRCUSDAddress(address _rcUSDAddress) external onlyOwner {
        rcUSDToken = IRCUSD(_rcUSDAddress);
    }

    function borrow(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(realTTokenBalance > 0, "Deposit property tokens before borrowing");

        // Placeholder for borrow limit logic
        // Ensure the requested amount does not exceed the allowable borrow limit
        // This requires a valuation of the deposited RealT tokens and any other relevant factors

        rcUSDToken.mint(msg.sender, amount);
    }

    // Future implementations can add withdrawal, borrowing, and other functionalities.
}
