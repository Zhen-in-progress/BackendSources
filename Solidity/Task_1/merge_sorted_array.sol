// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract merge_sorted_array{

    function mergeSortedArray(uint[] memory arr1, uint[] memory arr2) public pure returns(uint[] memory){
        uint[] memory res = new uint[](arr1.length + arr2.length);

        for (uint i=0; i <arr1.length;i++){
            res[i]=arr1[i];
        }
        for (uint i=0; i <arr2.length;i++){
            res[arr1.length+i]=arr2[i];
        }
        
        bool sorted = false;
        while (!sorted){
            sorted = true;
            for (uint i=0; i<res.length-1;i++){
                if (res[i]>res[i+1]){
                    sorted = false;
                    (res[i],res[i+1])=(res[i+1],res[i]);
                }
            }
        }
        return res;
    }
}