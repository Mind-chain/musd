// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Updatable {
    function updateUsdPrice(uint256 _newPrice) external;
}
