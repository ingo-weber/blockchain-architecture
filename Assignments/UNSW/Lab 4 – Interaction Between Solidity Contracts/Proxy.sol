/// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Util.sol";

/// @title Proxy contract
/// @author Dilum Bandara, CSIRO's Data61

contract Proxy{
    Util public utilContract;   // Util contract
    address public utilAddress; // Address of Utility contract
    int public lastSum;         // Remember last result
    address public lastCaller;  // Remember last address that called

    /**
     * @dev Sets values for {addr} when the contract starts.
     *
     * @param addr Address of Utility contract (address)
     */
    constructor (address addr){
        utilAddress = addr;
        utilContract = Util(addr);
    }

    /**
     * @dev Get sum of 2 numbers using Utility contract
     *
     * @param a First numbers (integer)
     * @param b Second number (integer)
     * @return Sum of 2 numbers (integer)
     */
    function sum(int a, int b) public returns (int){
        return utilContract.sum(a,b);
    }

    /**
     * @dev Get sum of 2 numbers using Utility contract using a call
     *
     * @param a First numbers (integer)
     * @param b Second number (integer)
     * @return Sum of 2 numbers (integer)
     */
    function sumCall(int a, int b) public returns (int){
        (bool success, bytes memory result) = 
          utilAddress.call(abi.encodeWithSignature("sum(int256,int256)", a, b));
        require(success, "Call failed");
        return abi.decode(result, (int256));
    }

    /**
     * @dev Get sum of 2 numbers using Utility contract using a delegatecall
     *
     * @param a First numbers (integer)
     * @param b Second number (integer)
     * @return Sum of 2 numbers (integer)
     */
    function sumDelegateCall(int a, int b) public returns (int){
        (bool success, bytes memory result) = 
          utilAddress.delegatecall(abi.encodeWithSignature("sum(int256,int256)", a, b));
        require(success, "Deligatecall failed");
        return abi.decode(result, (int256));
    }
}