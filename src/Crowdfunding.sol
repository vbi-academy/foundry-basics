// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PriceConverter} from "./lib/PriceConverter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Crowdfunding is Ownable {
    using PriceConverter for address;

    error InsufficientFunding();

    uint256 public constant MINIMUM_USD = 5e18; // 5 USD in Wei
    address public immutable i_ethUsdPriceFeed;

    mapping(address => bool) public s_isFunders;
    mapping(address => uint256) public s_funderToAmount;
    address[] public s_funders;

    event Funded(address indexed funder, uint256 value);
    event Withdrawn(uint256 value);

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    constructor(address ethUsdPriceFeed) Ownable(msg.sender) {
        i_ethUsdPriceFeed = ethUsdPriceFeed;
    }

    function fund() public payable {
        if (i_ethUsdPriceFeed.getConversionRate(msg.value) < MINIMUM_USD) {
            revert InsufficientFunding();
        }

        s_funderToAmount[msg.sender] += msg.value;
        bool isFunded = s_isFunders[msg.sender];

        if (!isFunded) {
            s_funders.push(msg.sender);
            s_isFunders[msg.sender] = true;
        }

        emit Funded(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        uint256 withdrawBal = address(this).balance;
        (bool sent,) = payable(owner()).call{value: withdrawBal}("");
        require(sent, "Failed to send Ether");

        emit Withdrawn(withdrawBal);
    }

    // Tìm ra có bao nhiêu người đã đóng góp
    function getFundersLength() public view returns (uint256) {
        return s_funders.length;
    }
}
