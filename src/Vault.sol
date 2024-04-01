// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRCUSD is IERC20 {
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
    uint8 LTV = 70;

    uint256 public constant ANNUAL_INTEREST_RATE = 10; // 10% annual interest rate
    uint256 public constant INTEREST_RATE_DIVISOR = 100; // Used for calculation, to avoid floating points
    uint256 public constant SECONDS_IN_A_YEAR = 31_557_600;

    struct Loan {
        uint256 principal; // The original amount of the loan
        uint256 balance; // Current loan balance, including interest
        uint256 interestRate; // Interest rate for this loan
        uint256 lastInterestCalculationTime; // When was the interest last calculated
    }

    mapping(address => Loan) public loans;


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

        Loan storage loan = loans[msg.sender];

        uint256 loanAmountWithDecimals = loan.balance * 10 ** valuationDecimals;

        require(valuation >= loanAmountWithDecimals + (amount * 10 ** valuationDecimals), "Requested amount exceeds collateral valuation");

        require(LTV * valuation >= 100 * (loanAmountWithDecimals + (amount * 10 ** valuationDecimals)), "Requested amount exceeds credit line");

        if (loan.principal == 0) { // Check if the loan doesn't exist
            // Create the loan
            loans[msg.sender] = Loan({
                principal: amount,
                balance: amount,
                interestRate: ANNUAL_INTEREST_RATE,
                lastInterestCalculationTime: block.timestamp
            });
        } else {
            uint256 interestAmount = getInterest(msg.sender);
            loan.balance += interestAmount;
            loan.balance += amount;
            loan.principal += amount;
            loan.lastInterestCalculationTime = block.timestamp;
        }

        rcUSDToken.mint(msg.sender, amount);
    }

    function getInterest(address borrower) public view returns (uint256) {
        Loan memory loan = loans[borrower];
        require(loan.principal > 0, "Loan does not exist");

        uint256 timeElapsed = block.timestamp - loan.lastInterestCalculationTime;
        uint256 interestAmount = 0;
        if (timeElapsed > 0) {
            interestAmount = (loan.balance * loan.interestRate * timeElapsed) / (SECONDS_IN_A_YEAR * INTEREST_RATE_DIVISOR);
        }
        return interestAmount;
    }

    function fullyRepayLoan() external {
        address borrower = msg.sender;
        Loan storage loan = loans[borrower]; // Use storage to modify the loan state
        uint256 interestAmount = getInterest(msg.sender);
        uint256 totalRepaymentAmount = loan.balance + interestAmount;
        require(rcUSDToken.balanceOf(borrower) >= totalRepaymentAmount, "Insufficient rcUSD to repay the loan");

        require(rcUSDToken.transferFrom(msg.sender, address(this), totalRepaymentAmount), "Transfer failed");

        // Consider updating state (deleting loan) after external calls
        delete loans[borrower];
    }




    // Future implementations can add withdrawal and other functionalities.
}
