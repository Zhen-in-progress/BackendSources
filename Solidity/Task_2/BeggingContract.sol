// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


 contract BeggingContract{
    address public receiver;
    mapping(address=>uint256)public donation;

    constructor(){
        receiver = msg.sender; 
    }
    modifier onlyOwner() {
        require(msg.sender == receiver, "Not authorized");
        _;
    }
    event Donate(address donor, uint value);
    event Withdraw(uint value);
    function donate()external payable{
        require(msg.value>0,"sent ETH to donate");
        donation[msg.sender]+=msg.value;
        emit Donate(msg.sender, msg.value);
    }
    function withdraw()external onlyOwner{

        uint256 amount = address(this).balance;

        require( amount >0, "Nothing to withdraw");

        (bool success, ) =receiver.call{value: amount}("");

        require(success,"Withdraw failed");
        emit Withdraw(amount);
    }
    function getDonation(address donor)public view returns (uint256){
        return donation[donor];
    }




 }