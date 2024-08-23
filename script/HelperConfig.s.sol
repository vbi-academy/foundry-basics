// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {Constants} from "./Constants.sol";

contract HelperConfig is Constants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address ethUsdPriceFeed;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[SEPOLIA_ID] = getSepoliaNetworkConfig();
    }

    function getLocalNetworkConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(PRICE_FEED_DECIMALS, ETH_USD_INITIAL_PRICE);
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({ethUsdPriceFeed: address(mockV3Aggregator)});

        return localNetworkConfig;
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getNetworkConfig(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].ethUsdPriceFeed != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == ANVIL_ID) {
            return getLocalNetworkConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }
}
