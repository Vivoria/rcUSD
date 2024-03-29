// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title RealTPropertyMock
 * @dev Simple mock RealT Property token for development and testing purposes.
 * It extends the OpenZeppelin ERC20 implementation.
 */
contract RealTProperty is ERC20 {
    uint8 public valuationDecimals = uint8(6);
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Public function to mint tokens
     * This function allows for easy testing and mock token distribution.
     * In a real-world scenario, minting rights would be limited.
     *
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function getValuation(uint256 amount) public view returns (uint256) {
        uint256 tokenPrice = 50 * 10 ** (valuationDecimals);
        uint256 valuation = amount * tokenPrice;
        return valuation;
    }
}
