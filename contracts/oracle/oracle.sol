// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./update.sol";

contract PriceOracle is Ownable, Pausable {
    using SafeMath for uint256;

    uint256 public currentUsdPrice;
    uint256 public lastUpdateTime;
    uint256 public updateInterval = 300; // Update interval in seconds (adjust as needed)

    Updatable public targetContract;

    constructor(address _targetContract) {
        targetContract = Updatable(_targetContract);
    }

    function updatePrice() external whenNotPaused {
        require(block.timestamp - lastUpdateTime >= updateInterval, "Update interval not reached");
        try this.usdtPrice() returns (uint256 newPrice) {
            targetContract.updateUsdPrice(newPrice);
            currentUsdPrice = newPrice;
            lastUpdateTime = block.timestamp;
            emit PriceUpdated(newPrice);
        } catch (Error(string memory reason)) {
            emit PriceUpdateError(reason);
        } catch {
            emit PriceUpdateError("Unknown error");
        }
    }

    function setUpdateInterval(uint256 _updateInterval) external onlyOwner {
        updateInterval = _updateInterval;
    }

    function setTargetContract(address _targetContract) external onlyOwner {
        targetContract = Updatable(_targetContract);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    event PriceUpdated(uint256 newPrice);
    event PriceUpdateError(string reason);
}
