// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {IERC20} from "ICelo.sol";

contract RentalAgreement {
    
    IERC20 public MPXToken;

    address owner;

    struct Item {
        uint256 itemId;
        string description;
        uint256 rentalFee;
        uint256 securityDeposit;
        bool available;
    }
    
    // Mapping of item ID to Item struct
    mapping(uint256 => Item) public items;
    // Mapping of renter address to deposited amount
    mapping(address => uint256) public deposits;

    // Event definitions
    event ItemAdded(uint256 itemId, string description, uint256 rentalFee, uint256 securityDeposit);
    event ItemRented(uint256 itemId, address renter);
    event ItemReturned(uint256 itemId, address renter);
    event DepositReleased(uint256 itemId, address renter, uint256 amount);
    
    // Modifier to restrict function access to item owner

    modifier onlyOwner(uint256 itemId) {
        require(msg.sender != address(0), "Zero not allowed");
        require(owner == msg.sender, "Not the item owner");
        _;
    }
    
    // Modifier to check item availability
    modifier isAvailable(uint256 itemId) {
        require(msg.sender != address(0), "Zero not allowed");
        require(items[itemId].available, "Item is not available for rent");
        _;
    }

    // Constructor to set the ERC-20 token address
    constructor(address tokenAddress) {
        MPXToken = IERC20(tokenAddress);
        owner = msg.sender;
    }

    // Function to add a new item for rent
    function addItem(uint256 _itemId, string memory _description, uint256 _rentalFee, uint256 _securityDeposit) public onlyOwner {

        // items[itemId] = Item({
        //     itemId: itemId,
        //     description: description,
        //     rentalFee: rentalFee,
        //     securityDeposit: securityDeposit,
        //     available: true,
        //     owner: msg.sender
        // });

        Item memory newItem;

        newItem.itemId = _itemId;
        newItem.description = _description;
        newItem.rentalFee = _rentalFee;
        newItem.securityDeposit = _securityDeposit;
        newItem.available = true;

        items[_itemId] = newItem;
        
        emit ItemAdded(itemId, description, rentalFee, securityDeposit);
    }

    // Function to set item availability
    function setAvailability(uint256 itemId, bool availability) public onlyOwner(itemId) {
        items[itemId].available = availability;
    }

    // Function for renting an item with ERC-20 tokens
    function rentItem(uint256 itemId) public isAvailable(itemId) {
        Item storage item = items[itemId];
        uint256 totalPayment = item.rentalFee + item.securityDeposit;
        
        uint256 amountApproved = MPXToken.allowance(msg.sender, address(this));

        require(amountApproved >= totalPayment, "Amount is too low");
        
        address renter = msg.sender;


        bool deducted = token.transferFrom(renter, address(this), totalPayment);

        require(deducted, "Token transfer failed");

        // Record the deposit amount for the renter

        deposits[msg.sender] += item.securityDeposit;
        item.available = false; // Mark the item as rented

        emit ItemRented(itemId, renter);
    }

    // Function for returning an item
    function returnItem(uint256 itemId) public {
        Item storage item = items[itemId];
        require(deposits[msg.sender] >= item.securityDeposit, "No deposit found for renter");
        
        item.available = true; // Mark the item as available again

        emit ItemReturned(itemId, msg.sender);
    }

    // Function for releasing the security deposit in ERC-20 tokens

    function releaseDeposit(uint256 itemId, address renter) public onlyOwner(itemId) {
        Item storage item = items[itemId];
        uint256 depositAmount = item.securityDeposit;
        require(deposits[renter] >= depositAmount, "Insufficient deposit to release");

        deposits[renter] -= depositAmount; // Update deposit balance

        // Transfer the deposit back to the renter in ERC-20 tokens
        require(token.transfer(renter, depositAmount), "Token transfer failed");

        emit DepositReleased(itemId, renter, depositAmount);
    }
}
