// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

interface Oracle {
    function getUsdPrice() external view returns (uint256);
}

contract MindChainUSD is ERC20, ERC20Burnable, Ownable, ERC20FlashMint {
    Oracle public oracle;
    uint256 public targetPrice = 1e18; // Target USD price with 18 decimals

    constructor(address _oracle)
        ERC20("MindChain USD", "MUSD")
        Ownable()
    {
        oracle = Oracle(_oracle);
        _mint(msg.sender, 50000000000 * 10**decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function setOracle(address _oracle) external onlyOwner {
        oracle = Oracle(_oracle);
    }

    function setTargetPrice(uint256 _targetPrice) external onlyOwner {
        targetPrice = _targetPrice;
    }

    function adjustSupply() external {
        uint256 currentPrice = oracle.getUsdPrice();
        uint256 totalSupply = totalSupply();
        uint256 deviation = (currentPrice > targetPrice) ? currentPrice - targetPrice : targetPrice - currentPrice;

        // Adjust supply if the price deviation is more than 1%
        if (deviation > targetPrice / 100) {
            if (currentPrice > targetPrice) {
                // Mint new tokens to decrease the price
                uint256 mintAmount = (deviation * totalSupply) / (2 * targetPrice);
                _mint(owner(), mintAmount);
            } else {
                // Burn tokens to increase the price
                uint256 burnAmount = (deviation * totalSupply) / (2 * targetPrice);
                _burn(owner(), burnAmount);
            }
        }
    }
}
