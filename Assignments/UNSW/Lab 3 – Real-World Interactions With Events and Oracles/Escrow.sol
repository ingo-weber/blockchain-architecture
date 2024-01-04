/// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title Escrow contract
/// This contract locks ETH until the delivery of asset
/// is confirmed or timeout is reached. To check the delivery
/// and wall clock time, we rely on an off-chain oracle.
/// @author Dilum Bandara, DFCRC

contract Escrow{
    address public funder;      // Owner address
    address public beneficiary; // Beneficiary address
    address public oracle;      // Oracle address
    uint256 public timeout;     // Timeout in AEST as UNIX timestamp
    bool private deliveryStatusPending;  //is delivery proof pending
    bool public inUse;         // Contract in use

    // Events informing contract activities
    event CheckDelivery(address funder, address beneficiary);
    event CheckTimeout(uint256 time);
    event DeliveryStatus(bool status);
    event TimeoutStatus(bool status);

    /**
     * @dev Constructor. Accept ETH as payment
     *
     * @param _beneficiary Beneficiary address
     * @param _oracle Oracle address 
     * @param _timeout Timeout in AEST as UNIX timestamp 
     */
    constructor (address _beneficiary, address _oracle, uint256 _timeout) payable{
        funder = msg.sender;    // Set escrow funder 
        beneficiary = _beneficiary;
        oracle = _oracle;
        timeout = _timeout;
        deliveryStatusPending = false;  // Proof not yet requested
        inUse = true;                   // Contract in use
    }

    /**
     * @dev Request to redeem as beneficiary. Once the request is made
     * oracle is informed to report status via CheckDelivery event
     */
    function redeem() public{
        require(inUse);  // Contract is still in use
        require(msg.sender == beneficiary, 'Only beneficiary can call');
        
        if(deliveryStatusPending)    // Ignore if proof is pending
            return;
        deliveryStatusPending = true;    // Mark as proof pending

        emit CheckDelivery(funder, beneficiary);   // Notify oracle
    }

    /**
     * @dev Request to release funds as funder. Once the notification 
     * is made oracle is informed via CheckTime event
     */
    function release() public{
        require(inUse);  // Contract is still in use
        require(msg.sender == funder, 'Only funder can call'); 
        
        if (deliveryStatusPending) // Ignore if proof is pending
            return;

        emit CheckTimeout(timeout);    // Notify oracle to check
    }

    /**
     * @dev Oracle submit asset delivery status. If asset is delivered
     * locked payment is released to the beneficiary and the 
     * contract is destroyed. Otherwise, do nothing
     *
     * @param isDelivered Is the asset delivered
     */
    function deliveryStatus(bool isDelivered) public{
        require(inUse);  // Contract is still in use
        require(msg.sender == oracle, 'Only oracle can call');

        emit DeliveryStatus(isDelivered);

        if (isDelivered){   // Asset delivered
            // Transfer all locked payment to beneficiary
            payable(beneficiary).transfer(address(this).balance);
            inUse = false; // Mark contract as no longer in use
        }
        deliveryStatusPending = false; // Delivery status check complete
    }

    /**
     * @dev Oracle submit timeout status. If timeout reached
     * locked payment is released to the funder and the 
     * contract is destroyed. Otherwise, do nothing
     *
     * @param isTimeout Is timeout reached
     */
    function timeoutStatus(bool isTimeout) public{
        require(inUse);  // Contract is still in use
        require(msg.sender == oracle, 'Only oracle can call');

        emit TimeoutStatus(isTimeout);

        if (isTimeout){ // Escrow timeout
            // Transfer all locked payment to funder
            payable(funder).transfer(address(this).balance);
            inUse = false; // Mark contract as no longer in use
        }
    }
}