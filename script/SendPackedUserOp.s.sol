//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;
    uint256 ANVIL_DEFAULT_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // Default Anvil key 0
    function run() external {}

    function generateUserSignedOperation(
        bytes memory callData,
        HelperConfig.NetworkConfig memory networkConfig
    ) public returns (PackedUserOperation memory) {
        //Generate the unsigned user operation
        // Sign the user operation
        uint256 nonce = vm.getNonce(networkConfig.account);

        PackedUserOperation memory userOp = _generateUnsignedUserOperation(
            callData,
            networkConfig.account,
            nonce
        );

        //get userOp hash
        bytes32 userOpHash = IEntryPoint(networkConfig.entryPoint)
            .getUserOpHash(userOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();
        //Sign it
        uint8 v;
        bytes32 r;
        bytes32 s;

        if (block.chainid == 31337) {
            // Anvil's default chain ID
            (v, r, s) = vm.sign(ANVIL_DEFAULT_PRIVATE_KEY, digest);
        } else {
            // For scripts or other networks where config.account is unlocked
            (v, r, s) = vm.sign(networkConfig.account, digest);
        }

        userOp.signature = abi.encodePacked(r, s, v); //IMPORTANT: signature is in the format r,s,v
        return userOp;
    }

    function _generateUnsignedUserOperation(
        bytes memory callData,
        address sender,
        uint256 nonce
    ) internal pure returns (PackedUserOperation memory) {
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
