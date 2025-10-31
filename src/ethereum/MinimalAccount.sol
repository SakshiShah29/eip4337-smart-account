//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    /*//////////////////////////////////////////////////////////////
                           State
    //////////////////////////////////////////////////////////////*/
    IEntryPoint private immutable i_entryPoint;

    /*//////////////////////////////////////////////////////////////
                          Errors
    //////////////////////////////////////////////////////////////*/
    error MissingFundsPayer();
    error MinimalAccount_validateUserOp_NotCalledByEntryPoint();
    error MinimalAccount_NotCalledByEntryPointOrOwner();
    error MinimalAccount_CallFailed(bytes);

    /*//////////////////////////////////////////////////////////////
                          Events
    //////////////////////////////////////////////////////////////*/
    event Received(address, uint256);

    /*//////////////////////////////////////////////////////////////
                         Modifiers
    //////////////////////////////////////////////////////////////*/
    modifier onlyEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount_validateUserOp_NotCalledByEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount_NotCalledByEntryPointOrOwner();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                         Functions
    //////////////////////////////////////////////////////////////*/
    constructor(
        address initialOwner,
        address entryPoint
    ) Ownable(initialOwner) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /*//////////////////////////////////////////////////////////////
                           External functions
    //////////////////////////////////////////////////////////////*/
    //This
    function excequteCall(
        address target,
        uint256 value,
        bytes calldata functionData
    ) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = target.call{value: value}(
            functionData
        );
        if (!success) {
            revert MinimalAccount_CallFailed(result);
        }
    }

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external onlyEntryPoint returns (uint256 validationData) {
        validationData = _validateSignature(userOp, userOpHash);
        //Here if you require you can do some nonce validatio n check
        // Now we require to payback to the entrypoint or the paymaster the rest of the funds
        _paymasterOrEntrypoint(missingAccountFunds);
    }
    /*//////////////////////////////////////////////////////////////
                           Internal functions
    //////////////////////////////////////////////////////////////*/

    //The userOpHash is in the EIP-191 FORMAT
    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view returns (uint256 validationData) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(
            userOpHash
        );
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function _paymasterOrEntrypoint(uint256 missingAccountFunds) internal {
        if (missingAccountFunds > 0) {
            (bool success, ) = payable(msg.sender).call{
                value: missingAccountFunds,
                gas: type(uint256).max
            }("");
            if (!success) {
                revert MissingFundsPayer();
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                           Getters
    //////////////////////////////////////////////////////////////*/
    function getEntryPoint() public view returns (IEntryPoint) {
        return i_entryPoint;
    }
}
