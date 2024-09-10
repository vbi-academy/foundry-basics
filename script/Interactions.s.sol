// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Lottery} from "src/Lottery.sol";
import {Constants} from "./Constants.sol";

contract EnterLottery is Script, Constants {
    function enterLottery(address lotteryAddress) public {
        vm.startBroadcast();
        Lottery(lotteryAddress).enterLottery{value: ENTRANCE_FEE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Lottery", block.chainid);
        enterLottery(mostRecentlyDeployed);
    }
}
