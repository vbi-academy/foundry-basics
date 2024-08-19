// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {Constants} from "./Constants.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Constants, Script {
    // ========== Errors ==========
    error HelperConfig__InvalidChainId();

    // ========== Types ==========
    struct NetworkConfig {
        address priceFeed;
    }

    // ========== State Variables ==========
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    // ========== Functions ==========
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].priceFeed != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == ANVIL_CHAIN_ID) {
            return getOrCreateAnvilETHConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    // ========== On-Chain Configs ==========
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH/USD
        });
    }

    // ========== Local Config ==========
    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.priceFeed != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return localNetworkConfig;
    }
}
