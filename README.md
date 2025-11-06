# EIP-4337 Account Abstraction Implementation

[![Tests](https://github.com/SakshiShah29/eip4337-smart-account/actions/workflows/test.yml/badge.svg)](https://github.com/SakshiShah29/eip4337-smart-account/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.18-363636?logo=solidity)](https://docs.soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg)](https://getfoundry.sh/)

A minimal, gas-optimized smart contract wallet implementing the EIP-4337 Account Abstraction standard using Foundry.

## 🧪 Latest Test Results

![Tests](https://img.shields.io/badge/tests-5%20passed%2C%200%20failed-brightgreen)
![Total Tests](https://img.shields.io/badge/total%20tests-5-blue)
![Last Run](https://img.shields.io/badge/last%20run-2025---11---06_04:18_UTC-lightgrey)

**Last Updated:** 2025-11-06 04:18:05 UTC

### Test Summary
- ✅ **Passed:** 5
- ❌ **Failed:** 0
- 📊 **Total:** 5

### Coverage Report
```
| File                              | % Lines        | % Statements   | % Branches    | % Funcs        |
+======================================================================================================+
| script/DeployMinimalAccount.s.sol | 87.50% (7/8)   | 100.00% (9/9)  | 100.00% (0/0) | 50.00% (1/2)   |
|-----------------------------------+----------------+----------------+---------------+----------------|
| script/HelperConfig.s.sol         | 62.50% (15/24) | 70.00% (14/20) | 40.00% (2/5)  | 42.86% (3/7)   |
|-----------------------------------+----------------+----------------+---------------+----------------|
| script/SendPackedUserOp.s.sol     | 90.91% (20/22) | 95.65% (22/23) | 50.00% (1/2)  | 66.67% (2/3)   |
|-----------------------------------+----------------+----------------+---------------+----------------|
| src/ethereum/MinimalAccount.sol   | 73.33% (22/30) | 79.31% (23/29) | 33.33% (2/6)  | 77.78% (7/9)   |
|-----------------------------------+----------------+----------------+---------------+----------------|
| Total                             | 76.19% (64/84) | 83.95% (68/81) | 38.46% (5/13) | 61.90% (13/21) |
```



## ⚠️ Status: Work in Progress

This implementation is under active development. Not audited. Not production-ready.

## Architecture

### Core Components

- **MinimalAccount.sol** - ERC-4337 compliant smart contract account with:
  - `validateUserOp()` - ✅ UserOperation validation against EntryPoint
  - `executeCall()` - ✅ Arbitrary contract call execution
  - Signature verification - ✅ ECDSA with EIP-191 message hashing
  - EntryPoint-only modifier protection - ✅ Prevents unauthorized calls
  - Owner/EntryPoint authorization - ✅ Dual execution path security

- **EntryPoint Integration** - Singleton contract handling:
  - UserOperation mempool simulation
  - Gas fee abstraction
  - Bundler transaction execution
  - Paymaster support (planned)

- **SendPackedUserOp.sol** - Script for UserOperation generation:
  - ✅ Generates unsigned PackedUserOperation with gas parameters
  - ✅ Signs UserOp with ECDSA (EIP-191 message hashing)
  - ✅ Multi-network support (Anvil local testing + Sepolia)
  - ✅ Automatic private key handling per network

- **HelperConfig.sol** - Multi-chain configuration management:
  - ✅ Network-specific EntryPoint addresses
  - ✅ Account management (Anvil default key, Sepolia burner wallet)
  - ✅ Automatic EntryPoint deployment for local testing

## EIP-4337 Specification Compliance

| Component | Status |
|-----------|--------|
| IAccount interface | ✅ Complete |
| validateUserOp | ✅ Complete |
| Signature validation (ECDSA + EIP-191) | ✅ Complete |
| executeCall() function | ✅ Complete |
| EntryPoint integration | ✅ Complete |
| Gas payment to EntryPoint | ✅ Complete |
| Deployment scripts | ✅ Complete |
| **UserOperation signing & generation** | ✅ **Complete** |
| **Signature validation tests** | ✅ **Complete** |
| Basic ownership tests | ✅ Complete |
| Nonce management | 🚧 EntryPoint handles (manual validation possible) |
| Full EntryPoint execution tests | ⏳ In Progress |
| Paymaster support | ⏳ Planned |
| Aggregator support | ⏳ Planned |

## Technical Stack

- **Solidity ^0.8.18** - Smart contracts
- **Foundry** - Build, test, deployment framework
- **OpenZeppelin Contracts** - Security primitives (ECDSA, MessageHashUtils, ERC-165)
- **Forge-std** - Testing utilities with vm cheatcodes
- **eth-infinitism/account-abstraction** - Official EIP-4337 reference implementation

## Development

```bash
# Install dependencies
forge install

# Compile contracts
forge build

# Run test suite
forge test -vvv

# Run specific test
forge test --mt testUserOpSigningIsCorrect -vvv

# Gas reporting
forge test --gas-report

# Deploy to Sepolia testnet
forge script script/DeployMinimalAccount.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY

# Deploy to local Anvil
forge script script/DeployMinimalAccount.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

## Security Considerations

- [x] Signature replay protection via nonces (handled by EntryPoint)
- [x] Authorization checks (EntryPoint + Owner modifiers)
- [x] ECDSA signature validation with EIP-191
- [ ] Reentrancy guards on executeCall()
- [ ] Gas griefing mitigation
- [ ] Front-running protection
- [ ] Storage collision prevention (EIP-1967 proxy patterns)
- [ ] Formal verification (planned)

## UserOperation Flow

```
1. User creates unsigned PackedUserOperation (via SendPackedUserOp.sol)
2. UserOp hash computed by EntryPoint.getUserOpHash()
3. Hash wrapped with EIP-191 prefix: "\x19Ethereum Signed Message:\n32"
4. User signs digest with ECDSA (off-chain or vm.sign in tests)
5. Bundler receives signed UserOp → sends to EntryPoint
6. EntryPoint calls validateUserOp() on MinimalAccount
7. MinimalAccount verifies signature matches owner
8. EntryPoint executes UserOp via handleOps()
9. Gas accounting & payment to bundler
```

## Recent Updates (Latest Commit)

**Commit:** `feat: user operations signature validation complete`

### What's New:
- ✅ **SendPackedUserOp.sol**: Complete UserOperation signing implementation
  - Generates properly formatted PackedUserOperation
  - Signs with ECDSA using EIP-191 message hashing
  - Network-aware signing (Anvil vs Sepolia)

- ✅ **testUserOpSigningIsCorrect()**: New test validating end-to-end signing flow
  - Generates signed UserOperation
  - Computes userOpHash via EntryPoint
  - Recovers signer using ECDSA.recover
  - Asserts recovered signer matches MinimalAccount owner

- 🔧 **HelperConfig.sol**: Enhanced multi-network configuration
  - Caches EntryPoint deployment for Anvil to avoid re-deployment
  - Proper private key usage for Anvil (FOUNDRY_DEFAULT_ANVIL_KEY)



## References

- [EIP-4337: Account Abstraction via Entry Point Contract](https://eips.ethereum.org/EIPS/eip-4337)
- [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)
- [Vitalik's AA Roadmap](https://notes.ethereum.org/@vbuterin/account_abstraction_roadmap)

## License

MIT
