// Get fund from users
// Withdraw funds
// Set a minimum funding value in USd

// SPDX-License-Identifier: MIT
// Pragma
pragma solidity ^0.8.0;
// Import
import "./PriceConverter.sol";
// Error
error FundMe__NotOwner();

// Interface, Library, Contract

/** @title A contract for crowd funding
 *  @author Brian Tam
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // 21,371 constant
    // 23471 not constant

    // State Variables!
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    uint256 public constant minimumUsd = 50 * 1e18;

    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // All the code in the function, has to be after require
    }

    constructor(address s_priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     *  @notice This function funds this contract
     *  @dev This implements price feeds as our library
     *
     */

    // 837,393
    function fund() public payable {
        // want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract
        // the value would be in *** wei ***
        // conversion from wei (18 dec.)  to usd (18dec.）
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUsd,
            "You need to spend more ETH!"
        ); // 1e18 = 1*10**18 == 1000000000000000000 == ethereum
        // msg value will have 18 decimals
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mapping cant be in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
