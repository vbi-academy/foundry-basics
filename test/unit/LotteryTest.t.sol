// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "src/Lottery.sol";
import {DeployLottery} from "script/DeployLottery.s.sol";
import {Constants} from "script/Constants.sol";

contract LotteryTest is Test, Constants {
    Lottery public lottery;
    address public constant USER = address(1);
    uint256 public constant INITIAL_USER_BALANCE = 10 ether;

    event LotteryEntered(address player);

    function setUp() external {
        DeployLottery deployer = new DeployLottery();
        (lottery) = deployer.run();

        vm.deal(USER, INITIAL_USER_BALANCE);
    }

    function test_revert_enterLottery() public {
        // Revert if not send enough entranceFee
        vm.expectRevert(Lottery.Lottery__SendMoreToEnter.selector);
        lottery.enterLottery();

        // Revert if raffle not open
        vm.prank(USER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
    }

    function test_can_enterLottery() public {
        vm.expectEmit();
        emit Lottery.LotteryEntered(USER);
        vm.prank(USER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        assertEq(ENTRANCE_FEE, lottery.getRewardBalance());
        assertEq(USER, lottery.getPlayer(0));
    }
}
