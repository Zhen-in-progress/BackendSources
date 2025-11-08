// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
contract roman_to_integer {
    mapping(bytes1 => uint256) private romanValue;
    constructor() {
        romanValue["I"] = 1;
        romanValue["V"] = 5;
        romanValue["X"] = 10;
        romanValue["L"] = 50;
        romanValue["C"] = 100;
        romanValue["D"] = 500;
        romanValue["M"] = 1000;
    }

    function romanToInteger(string memory str) public view returns (uint) {
        uint res = 0;

        bytes memory strBytes = bytes(str);

        for (uint i = 0; i < strBytes.length; i++) {
            if (
                i + 1 < strBytes.length &&
                romanValue[strBytes[i]] < romanValue[strBytes[i + 1]]
            ) {
                res -= romanValue[strBytes[i]];
            } else {
                res += romanValue[strBytes[i]];
            }
        }
        return res;
    }
}
