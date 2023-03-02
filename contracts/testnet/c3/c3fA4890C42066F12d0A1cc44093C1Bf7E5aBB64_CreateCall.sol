/**
 *Submitted for verification at Arbiscan on 2023-02-28
*/

/**
 *Submitted for verification at Arbiscan on 2023-01-19
*/

// SPDX-License-Identifier: MIT
// File: github/safe-global/safe-contracts/contracts/libraries/CreateCall.sol


pragma solidity =0.8.17;

/// @title Create Call - Allows to use the different create opcodes to deploy a contract
/// @author Richard Meissner - <[email protected]>
contract CreateCall {
    event ContractCreation(address newContract);

    function performCreate2(
        uint256 value,
        bytes memory deploymentData,
        bytes32 salt
    ) public returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            newContract := create2(value, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreation(newContract);
    }

    function performCreate(uint256 value, bytes memory deploymentData) public returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            newContract := create(value, add(deploymentData, 0x20), mload(deploymentData))
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreation(newContract);
    }
}