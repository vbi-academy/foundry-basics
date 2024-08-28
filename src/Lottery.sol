// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/// @title Lottery Contract
/// @author terrancrypt
/// @notice Used for users to open lottery game, a random player will get all rewards
/// @dev Use Chainlink Oracle for random number generation and automatic prize drawing operations.
contract Lottery is VRFConsumerBaseV2Plus {
    // ================================================================
    // │                           Errors                             │
    // ================================================================
    error Lottery__SendMoreToEnter();
    error Lottery__NotOpen();

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
    uint256 private immutable i_entranceFee;
    LotteryState private s_lotteryState;
    uint256 private s_rewardBalance;
    address payable[] private s_players;

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

    // ================================================================
    // │                          Constructor                         │
    // ================================================================
    constructor(
        uint256 entranceFee,
        uint256 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        s_lotteryState = LotteryState.OPEN; // Lottery will be open on deploy
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
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

    function requestLottery() public returns (uint256 requestId) {
        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery__NotOpen();
        }

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
    // │                    Internal Functions                        │
    // ================================================================
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 winnerIndex = (randomWords[0] % s_players.length);
        address winnerAddr = s_players[winnerIndex];
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
}
