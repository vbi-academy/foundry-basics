// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployCrowdfunding is Script {
    function run() external returns (Crowdfunding, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.getConfigByChainId(block.chainid).priceFeed;

        vm.startBroadcast();
        Crowdfunding crowdfunding = new Crowdfunding(priceFeed);
        vm.stopBroadcast();

        return (crowdfunding, helperConfig);
    }
}
