# EIP-4337 Account Abstraction Implementation

A minimal, gas-optimized smart contract wallet implementing the EIP-4337 Account Abstraction standard using Foundry.

## ⚠️ Status: Work in Progress

This implementation is under active development. Not audited. Not production-ready.

## Architecture

### Core Components

- **MinimalAccount.sol** - ERC-4337 compliant smart contract account with:
  - `validateUserOp()` - UserOperation validation against EntryPoint
  - `execute()` - Arbitrary contract call execution
  - Signature verification (ECDSA)
  - Nonce management for replay protection

- **EntryPoint Integration** - Singleton contract handling:
  - UserOperation mempool simulation
  - Gas fee abstraction
  - Bundler transaction execution
  - Paymaster support (planned)

## EIP-4337 Specification Compliance

| Component | Status |
|-----------|--------|
| IAccount interface | 🚧 In Progress |
| validateUserOp | 🚧 In Progress |
| Signature validation | 🚧 In Progress |
| Nonce management | ⏳ Planned |
| Paymaster support | ⏳ Planned |
| Aggregator support | ⏳ Planned |

## Technical Stack

- **Solidity ^0.8.0** - Smart contracts
- **Foundry** - Build, test, deployment framework
- **OpenZeppelin Contracts** - Security primitives (ECDSA, ERC-165)
- **Forge-std** - Testing utilities

## Development

```bash
# Install dependencies
forge install

# Compile contracts
forge build

# Run test suite
forge test -vvv

# Gas reporting
forge test --gas-report

# Deploy (testnet)
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

## Security Considerations

- [ ] Signature replay protection via nonces
- [ ] Reentrancy guards on execute()
- [ ] Gas griefing mitigation
- [ ] Front-running protection
- [ ] Storage collision prevention (EIP-1967 proxy patterns)
- [ ] Formal verification (planned)

## UserOperation Flow

```
1. User signs UserOperation off-chain
2. Bundler receives UserOp → sends to EntryPoint
3. EntryPoint calls validateUserOp() on MinimalAccount
4. Signature + nonce verification
5. EntryPoint executes UserOp via handleOps()
6. Gas accounting & payment to bundler
```

## References

- [EIP-4337: Account Abstraction via Entry Point Contract](https://eips.ethereum.org/EIPS/eip-4337)
- [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)
- [Vitalik's AA Roadmap](https://notes.ethereum.org/@vbuterin/account_abstraction_roadmap)

## License

MIT
