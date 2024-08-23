// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

abstract contract Constants {
    uint256 public constant SEPOLIA_ID = 11155111;
    uint256 public constant ANVIL_ID = 31337;
    uint8 public constant PRICE_FEED_DECIMALS = 8;
    int256 public constant ETH_USD_INITIAL_PRICE = 3000e8;
}
