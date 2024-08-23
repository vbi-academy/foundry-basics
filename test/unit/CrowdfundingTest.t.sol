// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {DeployCrowdfunding} from "script/DeployCrowdfunding.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CrowdfundingTest is Test {
    Crowdfunding public crowdfunding;

    address public constant USER = address(1);
    uint256 public constant INITIAL_USER_BALANCE = 100 ether;
    uint256 public constant USER_AMOUNT_FUNDING = 5 ether;

    event Funded(address indexed funder, uint256 value);
    event Withdrawn(uint256 value);

    function setUp() external {
        DeployCrowdfunding deployCrowdfunding = new DeployCrowdfunding();
        (crowdfunding,) = deployCrowdfunding.run();

        vm.deal(USER, INITIAL_USER_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        crowdfunding.fund{value: USER_AMOUNT_FUNDING}();
        _;
    }

    function test_revert_fund() public {
        // Revert if not send ETH
        vm.expectRevert(Crowdfunding.InsufficientFunding.selector);
        vm.prank(USER);
        crowdfunding.fund();
    }

    function test_can_fund() public {
        uint256 beforeUserBal = USER.balance;
        uint256 beforeContractBal = address(crowdfunding).balance;

        vm.expectEmit();
        emit Crowdfunding.Funded(USER, USER_AMOUNT_FUNDING);
        vm.prank(USER);
        crowdfunding.fund{value: USER_AMOUNT_FUNDING}();

        uint256 afterUserBal = USER.balance;
        uint256 afterContractBal = address(crowdfunding).balance;

        assertEq(beforeUserBal - USER_AMOUNT_FUNDING, afterUserBal);
        assertEq(beforeContractBal + USER_AMOUNT_FUNDING, afterContractBal);
        assertEq(crowdfunding.s_funderToAmount(USER), USER_AMOUNT_FUNDING);
        assertTrue(crowdfunding.s_isFunders(USER));
        assertEq(crowdfunding.s_funders(0), USER);
        assertEq(crowdfunding.getFundersLength(), 1);
    }

    function test_revert_withdraw() public {
        // Revert if not owner
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        vm.prank(USER);
        crowdfunding.withdraw();
    }

    function test_can_withdraw() public funded {
        address owner = crowdfunding.owner();

        uint256 beforeOwnerBal = owner.balance;
        uint256 beforeContractBal = address(crowdfunding).balance;

        vm.expectEmit();
        emit Crowdfunding.Withdrawn(beforeContractBal);
        vm.prank(owner);
        crowdfunding.withdraw();

        uint256 afterOwnerBal = owner.balance;
        uint256 afterContractBal = address(crowdfunding).balance;

        assertEq(beforeOwnerBal + beforeContractBal, afterOwnerBal);
        assertEq(afterContractBal, 0);
    }
}
