/// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title Utility contract
/// @author Dilum Bandara, CSIRO's Data61

contract Util{
    int public lastSum;         // Remember last result
    address public lastCaller;  // Remember last address that called

    /**
     * @dev Get sum of 2 numbers while remembering the last caller & sum
     *
     * @param a First value (integer)
     * @param b Second value (integer)
     * @return Sum of 2 values (integer)
     */
    function sum(int a, int b) public returns (int){
        int total = a + b;
        lastSum = total;
        lastCaller = msg.sender;
        return total;
    }
}