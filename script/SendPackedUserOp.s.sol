//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract SendPackedUserOp is Script {
    function run() external {}

    function generateUserSignedOperation(
        bytes memory callData,
        address sender
    ) public returns (PackedUserOperation calldata) {
        //Generate the unsigned user operation
        // Sign the user operation
        uint256 nonce = vm.getNonce(sender);

        PackedUserOperation unsignedUserOp = _generateUnsignedUserOperation(
            callData,
            sender,
            nonce
        );
    }

    function _generateUnsignedUserOperation(
        bytes memory callData,
        address sender,
        uint256 nonce
    ) internal pure returns (PackedUserOperation calldata) {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;

        bytes32 accountGasLimits = bytes32(
            (uint256(verificationGasLimit) << 128) | uint256(callGasLimit)
        );
        bytes32 gasFees = bytes32(
            (uint256(maxFeePerGas) << 128) | uint256(maxPriorityFeePerGas)
        );
        return
            PackedUserOperation({
                sender: sender,
                nonce: nonce,
                initCode: hex"",
                callData: callData,
                accountGasLimits: accountGasLimits,
                preVerificationGas: verificationGasLimit,
                gasFees: gasFees,
                paymasterAndData: hex"",
                signature: hex"" // the signature will be added later, so it is empty for now
            });
    }
}
