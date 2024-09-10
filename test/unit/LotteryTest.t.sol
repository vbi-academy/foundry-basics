// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
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
            linkToken.setBalance(msg.sender, 100 ether); // 10 LINK
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).fundSubscription(config.subscriptionId, 100 ether);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).addConsumer(config.subscriptionId, address(lottery));
            vm.stopPrank();
        }
    }

    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
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
    // │                     Automation & VRF                         │
    // ================================================================
    function test_can_checkUpkeep() public skipFork {
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

    function test_can_performUpkeep() public skipFork {
        // Revert if conditions not pass
        vm.expectRevert(Lottery.Lottery__UpkeepNotNeeded.selector);
        lottery.performUpkeep("");

        vm.warp(block.timestamp + config.automationInterval + 1);
        vm.roll(block.number + 1);
        vm.prank(USER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        vm.recordLogs();
        lottery.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 2);
        bytes32 requestId = entries[1].topics[1];
        console2.logUint(uint256(requestId));

        assert(Lottery.LotteryState.CLOSE == lottery.getLoteryState());

        VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(uint256(requestId), address(lottery));

        assert(Lottery.LotteryState.OPEN == lottery.getLoteryState());
        assertEq(ENTRANCE_FEE, lottery.getWinnerBalance(USER));
        assertEq(USER, lottery.getRecentWinner());
        assertEq(0, lottery.getPlayerLength());
        assertEq(0, lottery.getRewardBalance());
    }
}
