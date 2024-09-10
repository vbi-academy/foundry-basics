// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Constants} from "./Constants.sol";
import {Lottery} from "src/Lottery.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployLottery is Script, Constants {
    function run() external returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig(block.chainid);
        vm.startBroadcast();
        Lottery lottery = new Lottery(
            ENTRANCE_FEE,
            networkConfig.subscriptionId,
            networkConfig.vrfCoordinator,
            networkConfig.keyHash,
            CALLBACK_GAS_LIMIT,
            networkConfig.automationInterval
        );
        vm.stopBroadcast();
        return (lottery, helperConfig);
    }
}
