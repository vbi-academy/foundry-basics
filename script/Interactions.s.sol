// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract FundCrowdfunding is Script {
    function fundToCrowdfunding(address crowdfundingAddress) public {
        vm.startBroadcast();
        Crowdfunding(payable(crowdfundingAddress)).fund{value: 0.01 ether}();
        vm.stopBroadcast();

        console.log("Fund to Crowdfunding contract success!");
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Crowdfunding", block.chainid);
        fundToCrowdfunding(contractAddress);
    }
}

contract WithdrawCrowdfunding is Script {
    function withdrawFromCrowdfunding(address crowdfundingAddress) public {
        vm.startBroadcast();
        Crowdfunding(payable(crowdfundingAddress)).withdraw();
        vm.stopBroadcast();

        console.log("Withdraw from Crowdfunding contract success!");
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Crowdfunding", block.chainid);
        withdrawFromCrowdfunding(contractAddress);
    }
}
