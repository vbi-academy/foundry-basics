// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployCrowdfunding is Script {
    Crowdfunding crowdfunding;
    HelperConfig helperConfig;

    function run() external returns (Crowdfunding, HelperConfig) {
        helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.getNetworkConfig(block.chainid).ethUsdPriceFeed;

        console.log("ETH/USD price feed address: ", ethUsdPriceFeed);

        vm.startBroadcast();
        crowdfunding = new Crowdfunding(ethUsdPriceFeed);
        vm.stopBroadcast();

        return (crowdfunding, helperConfig);
    }
}
