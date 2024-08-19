// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract FundCrowdfunding is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundToCrowdfunding(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Crowdfunding(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded to Crowdfunding with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Crowdfunding", block.chainid);
        fundToCrowdfunding(mostRecentlyDeployed);
    }
}

contract WithdrawCrowdfunding is Script {
    function withdrawFromCrowdfunding(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Crowdfunding(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Crowdfunding", block.chainid);
        withdrawFromCrowdfunding(mostRecentlyDeployed);
    }
}
