// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "src/Lottery.sol";
import {DeployLottery} from "script/DeployLottery.s.sol";
import {Constants} from "script/Constants.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract LotteryTest is Test, Constants {
    Lottery public lottery;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig public config;
    MockLinkToken public linkToken;

    address public constant USER = address(1);
    uint256 public constant INITIAL_USER_BALANCE = 10 ether;

    event LotteryEntered(address player);

    function setUp() external {
        DeployLottery deployer = new DeployLottery();
        (lottery, helperConfig) = deployer.run();
        config = helperConfig.getConfig();
        linkToken = MockLinkToken(config.linkToken);

        vm.deal(USER, INITIAL_USER_BALANCE);

        // Đã tạo sẵn Subscription trong HelperConfig
        // bây giờ nạp LINK vào để thanh toán phí lấy random number nếu đang là local anvil chain
        if (block.chainid == ANVIL_CHAIN_ID) {
            vm.startPrank(msg.sender); // Default sender
            linkToken.setBalance(msg.sender, 10 ether); // 10 LINK
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).fundSubscription(config.subscriptionId, 10 ether);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).addConsumer(config.subscriptionId, address(lottery));
            vm.stopPrank();
        }
    }

    // ================================================================
    // │                        Enter Lottery                         │
    // ================================================================
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

    // ================================================================
    // │                         Automation                           │
    // ================================================================
    function test_can_checkUpkeep() public {
        // Return false because time not passed
        (bool upkeepNeeded,) = lottery.checkUpkeep("");
        assert(!upkeepNeeded);

        // Return false because has no player
        vm.warp(block.timestamp + config.automationInterval + 1);
        vm.roll(block.number + 1);
        (bool upkeepNeeded2,) = lottery.checkUpkeep("");
        assert(!upkeepNeeded2);

        // Return true because all condition passed
        vm.prank(USER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
        (bool upkeepNeeded3,) = lottery.checkUpkeep("");
        assert(upkeepNeeded3);

        // Return false because lottery is closed
        lottery.performUpkeep("");
        (bool upkeepNeeded4,) = lottery.checkUpkeep("");
        assert(!upkeepNeeded4);
    }

    function test_can_performUpkeep() public {
        // Revert if conditions not pass
        vm.expectRevert(Lottery.Lottery__UpkeepNotNeeded.selector);
        lottery.performUpkeep("");

        vm.warp(block.timestamp + config.automationInterval + 1);
        vm.roll(block.number + 1);
        vm.prank(USER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        lottery.performUpkeep("");

        assert(Lottery.LotteryState.CLOSE == lottery.getLoteryState());
    }

    // ================================================================
    // │                         Automation                           │
    // ================================================================
}
