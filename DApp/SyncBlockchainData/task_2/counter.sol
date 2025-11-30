// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


contract Counter{

    uint256 private num = 0;
    function addOne() public returns (uint256){
        num ++;
        return num; 
    }
    function get() public view returns (uint256){
        return num;
    }
}