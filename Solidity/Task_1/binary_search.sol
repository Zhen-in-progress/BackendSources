// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract binary_search{

    function binarySearch(int[] memory nums, int target) public pure returns(int){
        uint l = 0;
        uint r = nums.length-1;
        while(l <=r ){
            uint m = uint(l+r)/2;
            if( nums[m]<target){
                l=m+1;
            }else if (nums[m]>target){
                r=m-1;
            }else{
                return int(m);
            }
        }
        return -1;
    }
}