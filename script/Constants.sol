// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

abstract contract Constants {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    // ========== Chain IDs ==========
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 public constant ANVIL_CHAIN_ID = 31337;
}
