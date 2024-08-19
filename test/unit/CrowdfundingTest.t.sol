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
    HelperConfig public helperConfig;

    address public constant USER = address(2);

    uint256 public constant INITIAL_ETHER_AMOUNT = 100 ether;
    uint256 public constant ACCEPTABLE_FUND_AMOUNT = 0.1 ether;

    event Funded(address indexed funder, uint256 value);
    event Withdrawn(uint256 value);

    function setUp() external {
        DeployCrowdfunding deployCrowdfunding = new DeployCrowdfunding();
        (crowdfunding, helperConfig) = deployCrowdfunding.run();

        vm.deal(USER, INITIAL_ETHER_AMOUNT);
    }

    function test_priceFeedSetCorrectly() public {
        address retreivedPriceFeed = address(crowdfunding.i_ethPriceFeed());
        address expectedPriceFeed = helperConfig.getConfigByChainId(block.chainid).priceFeed;
        assertEq(retreivedPriceFeed, expectedPriceFeed);
    }

    function test_revert_fund() public {
        // Revert if not send ETH
        vm.expectRevert(Crowdfunding.InsufficientFunding.selector);
        vm.prank(USER);
        crowdfunding.fund();
    }

    function test_can_fund() public {
        vm.expectEmit();
        emit Crowdfunding.Funded(USER, ACCEPTABLE_FUND_AMOUNT);

        uint256 contractBalBeforeFund = address(crowdfunding).balance;
        console.log("Crowdfunding contract balance before fund", contractBalBeforeFund);

        vm.prank(USER);
        crowdfunding.fund{value: ACCEPTABLE_FUND_AMOUNT}();

        console.log("User funded to crowdfunding contract", ACCEPTABLE_FUND_AMOUNT);

        uint256 contractBalAfterFund = address(crowdfunding).balance;
        console.log("Crowdfunding contract balance after fund", contractBalAfterFund);

        assertEq(crowdfunding.s_funderToAmount(USER), ACCEPTABLE_FUND_AMOUNT);
        assertEq(crowdfunding.s_funders(0), USER);
        assertTrue(crowdfunding.s_isFunders(USER));
        assertEq(contractBalBeforeFund + ACCEPTABLE_FUND_AMOUNT, contractBalAfterFund);
    }

    function test_revert_withdraw() public {
        // Revert if not owner
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        vm.prank(USER);
        crowdfunding.withdraw();
    }

    function test_can_withdraw() public {
        // Fund before withdraw
        test_can_fund();

        uint256 ownerBalBeforeWithdraw = crowdfunding.owner().balance;
        console.log("Owner balance before withdraw", ownerBalBeforeWithdraw);

        vm.expectEmit();
        emit Crowdfunding.Withdrawn(ACCEPTABLE_FUND_AMOUNT);

        vm.prank(crowdfunding.owner());
        crowdfunding.withdraw();

        uint256 ownerBalAfterWithdraw = crowdfunding.owner().balance;
        console.log("Owner balance after withdraw", ownerBalAfterWithdraw);

        assertEq(ownerBalBeforeWithdraw + ACCEPTABLE_FUND_AMOUNT, ownerBalAfterWithdraw);
    }
}
