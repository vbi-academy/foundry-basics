// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {WithdrawCrowdfunding} from "script/Interactions.s.sol";
import {DeployCrowdfunding} from "script/DeployCrowdfunding.s.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract InteractionsTest is Test {
    Crowdfunding public crowdfunding;
    WithdrawCrowdfunding public withdrawCrowdfunding;

    address public constant USER = address(1);
    uint256 public constant INITIAL_USER_BALANCE = 100 ether;
    uint256 public constant USER_AMOUNT_FUNDING = 5 ether;

    function setUp() external {
        DeployCrowdfunding deployCrowdfunding = new DeployCrowdfunding();
        (crowdfunding,) = deployCrowdfunding.run();

        withdrawCrowdfunding = new WithdrawCrowdfunding();

        vm.deal(USER, INITIAL_USER_BALANCE);
    }

    function test_can_fundAndWithdrawFromCrowdfunding() public {
        address owner = crowdfunding.owner();
        uint256 beforeUserBal = USER.balance;
        uint256 beforeOwnerBal = owner.balance;

        vm.prank(USER);
        crowdfunding.fund{value: USER_AMOUNT_FUNDING}();

        withdrawCrowdfunding.withdrawFromCrowdfunding(address(crowdfunding));

        uint256 afterUserBal = USER.balance;
        uint256 afterOwnerBal = owner.balance;

        assertEq(beforeUserBal - USER_AMOUNT_FUNDING, afterUserBal);
        assertEq(beforeOwnerBal + USER_AMOUNT_FUNDING, afterOwnerBal);
        assertEq(address(crowdfunding).balance, 0);
    }
}
