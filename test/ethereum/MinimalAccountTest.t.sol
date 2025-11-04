//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "../../script/DeployMinimalAccount.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {SendPackedUserOp} from "../../script/SendPackedUserOp.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
contract MinimalAccountTest is Test {
    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    SendPackedUserOp sendPackedUserOp;
    ERC20Mock usdc;
    uint256 constant AMOUNT = 1e18;
    address randomUser = makeAddr("randomUser");
    function setUp() public {
        DeployMinimalAccount deployMinimal = new DeployMinimalAccount();
        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    //USDC mint
    //msg.sender ->MinimalAccount
    //Approve the amount
    //USDC contract
    //come from the entrypoint

    function testOwnerCanExecuteCommands() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            AMOUNT
        );

        //Act
        vm.prank(minimalAccount.owner());
        minimalAccount.executeCall(dest, value, functionData);

        //Assert
        assertEq(
            usdc.balanceOf(address(minimalAccount)),
            AMOUNT,
            "USDC balance should be equal to AMOUNT"
        );
    }

    function testNonOwnerCannotExecuteCommands() public {
        //Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            AMOUNT
        );
        //Act
        vm.prank(randomUser);
        vm.expectRevert(
            MinimalAccount.MinimalAccount_NotCalledByEntryPointOrOwner.selector
        );
        minimalAccount.executeCall(dest, value, functionData);
    }

    function testUserOpSigningIsCorrect() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            AMOUNT
        );
        // This is what the EntryPoint will use to call our smart account.
        bytes memory executeCallData = abi.encodeWithSelector(
            minimalAccount.executeCall.selector,
            address(usdc), // dest: the USDC contract
            0, // value: no ETH sent with this call
            functionData // data: the encoded call to usdc.mint
        );
        PackedUserOperation memory packedUserOp = sendPackedUserOp
            .generateUserSignedOperation(
                executeCallData,
                helperConfig.getConfigByChainId(block.chainid)
            );
        bytes32 userOpHash = IEntryPoint(
            helperConfig.getConfigByChainId(block.chainid).entryPoint
        ).getUserOpHash(packedUserOp);

        //Act

        address signer = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(userOpHash),
            packedUserOp.signature
        );

        //Assert
        assertEq(signer, minimalAccount.owner(), "Signer should be the owner");
    }

    function testValidationOfUserOps() public {
        //Arrange
        //Act
        //Assert
    }
}
