// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRCUSD {
    function mint(address to, uint256 amount) external;
}

interface IRealTProperty is IERC20 {
    function valuationDecimals() external  view returns (uint8);
    function getValuation(uint256 amount) external view returns (uint256);
}

contract PersonalVault is Ownable {
    IRealTProperty public realTPropertyToken; // The ERC20 token for RealT properties

    IRCUSD public rcUSDToken;

    uint256 public realTTokenBalance;
    uint256 public loanAmount = 0;
    uint8 LTV = 70;

    event Deposit(address indexed owner, uint256 amount);

    constructor(address _realTPropertyTokenAddress, address _rcUSDAddress) Ownable(msg.sender) {
        realTPropertyToken = IRealTProperty(_realTPropertyTokenAddress);
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

        uint256 valuation = realTPropertyToken.getValuation(realTTokenBalance);
        uint8 valuationDecimals = realTPropertyToken.valuationDecimals();

        uint256 loanAmountWithDecimals = loanAmount * 10 ** valuationDecimals;

        require(valuation >= loanAmountWithDecimals + (amount * 10 ** valuationDecimals), "Requested amount exceeds collateral valuation");

        require(LTV * valuation >= 100 * (loanAmountWithDecimals + (amount * 10 ** valuationDecimals)), "Requested amount exceeds credit line");

        loanAmount += amount;

        rcUSDToken.mint(msg.sender, amount);
    }

    // Future implementations can add withdrawal, borrowing, and other functionalities.
}
