// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {WithdrawCrowdfunding} from "script/Interactions.s.sol";
import {DeployCrowdfunding} from "script/DeployCrowdfunding.s.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract InteractionsTest is Test {
    Crowdfunding public crowdfunding;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether;
    address public constant USER = address(2);
    uint256 public constant INITIAL_ETHER_AMOUNT = 100 ether;

    function setUp() external {
        DeployCrowdfunding deployCrowdfunding = new DeployCrowdfunding();
        (crowdfunding, helperConfig) = deployCrowdfunding.run();

        vm.deal(USER, INITIAL_ETHER_AMOUNT);
    }

    function test_can_fundAndWithdraw() public {
        uint256 beforeUserBalance = address(USER).balance;
        uint256 beforeOwnerBalance = address(crowdfunding.owner()).balance;

        vm.prank(USER);
        crowdfunding.fund{value: SEND_VALUE}();

        WithdrawCrowdfunding withdrawCrowdfunding = new WithdrawCrowdfunding();
        withdrawCrowdfunding.withdrawFromCrowdfunding(address(crowdfunding));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(crowdfunding.owner()).balance;

        assert(address(crowdfunding).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, beforeUserBalance);
        assertEq(beforeOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
