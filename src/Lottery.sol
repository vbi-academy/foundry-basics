// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

/// @title Lottery Contract
/// @author terrancrypt
/// @notice Used for users to open lottery game, a random player will get all rewards
/// @dev Use Chainlink Oracle for random number generation and automatic prize drawing operations.
contract Lottery is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    // ================================================================
    // │                           Errors                             │
    // ================================================================
    error Lottery__SendMoreToEnter();
    error Lottery__NotOpen();
    error Lottery__TransferError();
    error Lottery__UpkeepNotNeeded();

    // ================================================================
    // │                       Type Declarations                      │
    // ================================================================
    enum LotteryState {
        CLOSE,
        OPEN
    }

    // ================================================================
    // │                       Storage Variables                      │
    // ================================================================
    LotteryState private s_lotteryState;
    uint256 private immutable i_entranceFee;
    uint256 private s_rewardBalance;
    address payable[] private s_players;
    address private s_recentWinner;
    mapping(address winner => uint256 balance) s_winnerBalance;

    // Chainlink Automation
    uint256 public immutable i_interval;
    uint256 public s_lastTimeStamp;

    // Chainlink VRF
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // ================================================================
    // │                            Events                            │
    // ================================================================
    event LotteryEntered(address player);
    event LotteryRequested(uint256 requestId);
    event WinnerPicked(address winner, uint256 rewardBal);
    event RewardReceived(address winner, uint256 rewardBal);

    // ================================================================
    // │                          Constructor                         │
    // ================================================================
    constructor(
        uint256 entranceFee,
        uint256 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        uint32 callbackGasLimit,
        uint256 automationInterval
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        s_lotteryState = LotteryState.OPEN; // Lottery will be open on deploy
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
        i_interval = automationInterval;
    }

    // ================================================================
    // │                       Public Functions                       │
    // ================================================================
    /// @notice help user enter an lottery game with entranceFee will be setted
    function enterLottery() public payable {
        if (msg.value != i_entranceFee) {
            revert Lottery__SendMoreToEnter();
        }

        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery__NotOpen();
        }

        s_rewardBalance += msg.value;
        s_players.push(payable(msg.sender));

        emit LotteryEntered(msg.sender);
    }

    function withdrawReward() public {
        uint256 winnerBal = s_winnerBalance[msg.sender];

        (bool sent,) = payable(msg.sender).call{value: winnerBal}("");
        if (!sent) {
            revert Lottery__TransferError();
        }

        s_winnerBalance[msg.sender] = 0;

        emit RewardReceived(msg.sender, winnerBal);
    }

    // ================================================================
    // │                    Automation Functions                      │
    // ================================================================
    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        bool timePassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool hasPlayer = s_players.length > 0;
        bool isLotteryOpen = s_lotteryState == LotteryState.OPEN;
        upkeepNeeded = (timePassed && hasPlayer && isLotteryOpen);

        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */ ) external override {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Lottery__UpkeepNotNeeded();
        }

        _requestLottery();
    }

    // ================================================================
    // │                    Internal Functions                        │
    // ================================================================
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        uint256 winnerIndex = (randomWords[0] % s_players.length);
        address winnerAddr = s_players[winnerIndex];
        uint256 rewardBal = s_rewardBalance;

        s_recentWinner = winnerAddr;
        delete s_players;
        s_lotteryState = LotteryState.OPEN;
        s_winnerBalance[winnerAddr] = rewardBal;
        s_rewardBalance = 0;

        emit WinnerPicked(winnerAddr, rewardBal);
    }

    function _requestLottery() internal returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        s_lotteryState = LotteryState.CLOSE;

        emit LotteryRequested(requestId);
    }

    // ================================================================
    // │                     Getter Functions                         │
    // ================================================================
    function getRewardBalance() public view returns (uint256) {
        return s_rewardBalance;
    }

    function getPlayer(uint256 index) public view returns (address payable) {
        return s_players[index];
    }

    function getLoteryState() public view returns (LotteryState) {
        return s_lotteryState;
    }
}
