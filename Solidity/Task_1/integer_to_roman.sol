// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract roman_to_integer {
    mapping(bytes2 => uint256) private romanValue;
      uint[] private values;
      string[] private symbols;

      constructor() {
          values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
          symbols = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
      }

    function integerToRoman(uint num) public view returns(string memory){
        string memory res = "";

        for(uint i = 0; i<values.length;i++){
            while (num >= values[i]){
                res = string(abi.encodePacked(res, symbols[i]));
                num -= values[i];
            }
        }
        return res;
    }
}