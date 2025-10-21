# Velirion SPL Token

## Overview

Velirion SPL Token is a deflationary token on Solana with an automatic 0.5% burn mechanism on every transfer. Built using Anchor framework for security and efficiency.

### Key Features

- ✅ **SPL Token Standard**: Fully compliant with Solana's token standard
- ✅ **0.5% Automatic Burn**: Every transfer burns 0.5% of the amount
- ✅ **Manual Burn**: Token holders can burn their tokens manually
- ✅ **Mint Authority**: Controlled minting for initial supply
- ✅ **Event Emissions**: All operations emit events for tracking
- ✅ **Comprehensive Tests**: 20+ test cases covering all scenarios

---

## Token Specifications

| Property         | Value                   |
| ---------------- | ----------------------- |
| **Name**         | Velirion                |
| **Symbol**       | VLR                     |
| **Decimals**     | 9                       |
| **Total Supply** | 100,000,000 VLR         |
| **Burn Rate**    | 0.5% per transfer       |
| **Network**      | Solana (Devnet/Mainnet) |

---

## Prerequisites

### Required Tools

```bash
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rustfmt

# Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Anchor
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install 0.30.1
avm use 0.30.1

# Node.js & Yarn
node --version  # >= 18.x
yarn --version
```

---

## Installation

```bash
cd solana

# Install dependencies
yarn install

# Build the program
anchor build

# Run tests
anchor test
```

---

## Development

### Build Program

```bash
anchor build
```

### Run Tests

```bash
# Run all tests
anchor test

# Run tests without building
anchor test --skip-build

# Run tests with logs
anchor test -- --nocapture
```

### Deploy to Devnet

```bash
# Configure Solana CLI for devnet
solana config set --url devnet

# Get devnet SOL
solana airdrop 2

# Deploy program
anchor deploy --provider.cluster devnet

# Initialize token
ts-node scripts/deploy.ts

# Mint initial supply
ts-node scripts/mint-initial-supply.ts
```

---

## Program Architecture

### Instructions

#### 1. `initialize`

Initializes the token mint with specified decimals.

```rust
pub fn initialize(ctx: Context<Initialize>, decimals: u8) -> Result<()>
```

**Parameters:**

- `decimals`: Number of decimal places (9 for VLR)

#### 2. `mint_tokens`

Mints new tokens to a specified account.

```rust
pub fn mint_tokens(ctx: Context<MintTokens>, amount: u64) -> Result<()>
```

**Parameters:**

- `amount`: Number of tokens to mint (with decimals)

**Access Control:** Only mint authority

#### 3. `transfer_with_burn`

Transfers tokens with automatic 0.5% burn.

```rust
pub fn transfer_with_burn(ctx: Context<TransferWithBurn>, amount: u64) -> Result<()>
```

**Parameters:**

- `amount`: Total amount to transfer

**Behavior:**

- Burns 0.5% of amount
- Transfers 99.5% to recipient
- Emits `TransferEvent`

**Example:**

```
Transfer 1,000,000 tokens:
- Burn: 5,000 tokens (0.5%)
- Recipient receives: 995,000 tokens (99.5%)
```

#### 4. `burn_tokens`

Manually burns tokens from an account.

```rust
pub fn burn_tokens(ctx: Context<BurnTokens>, amount: u64) -> Result<()>
```

**Parameters:**

- `amount`: Number of tokens to burn

**Access Control:** Token owner

---

## Testing

### Test Suite

The test suite includes 20+ comprehensive tests:

**Initialization Tests (2)**

- ✅ Initialize token mint
- ✅ Create token accounts

**Minting Tests (3)**

- ✅ Mint initial supply
- ✅ Fail with zero amount
- ✅ Fail without authority

**Transfer with Burn Tests (6)**

- ✅ Transfer with 0.5% burn
- ✅ Calculate burn correctly
- ✅ Fail with amount too small
- ✅ Fail with zero amount
- ✅ Emit transfer event
- ✅ Handle different amounts

**Manual Burning Tests (4)**

- ✅ Burn tokens manually
- ✅ Fail with zero amount
- ✅ Fail with insufficient balance
- ✅ Emit burn event

**Edge Cases (2)**

- ✅ Handle large amounts
- ✅ Verify supply decreases

### Run Tests

```bash
# All tests
anchor test

# With coverage
anchor test --coverage

# Specific test
anchor test --test velirion-spl
```

---

## Deployment Guide

### Step 1: Configure Wallet

```bash
# Generate new keypair (if needed)
solana-keygen new --outfile ~/.config/solana/id.json

# Check wallet address
solana address

# Check balance
solana balance
```

### Step 2: Get Devnet SOL

```bash
# Airdrop SOL for testing
solana airdrop 2

# Or use faucet: https://faucet.solana.com/
```

### Step 3: Build and Deploy

```bash
# Build program
anchor build

# Deploy to devnet
anchor deploy --provider.cluster devnet

# Note the Program ID from output
```

### Step 4: Initialize Token

```bash
# Run deployment script
ts-node scripts/deploy.ts
```

**Output:**

```
 Deploying Velirion SPL Token...

📋 Deployment Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Network: devnet
Program ID: VLRxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Deployer: <your-wallet>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Token initialized successfully!
💾 Deployment info saved to deployment-spl.json
```

### Step 5: Mint Initial Supply

```bash
ts-node scripts/mint-initial-supply.ts
```

---

## Usage Examples

### TypeScript/JavaScript

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { VelirionSpl } from "./target/types/velirion_spl";

// Initialize
const provider = anchor.AnchorProvider.env();
const program = anchor.workspace.VelirionSpl as Program<VelirionSpl>;

// Transfer with burn
await program.methods
  .transferWithBurn(new anchor.BN(1_000_000))
  .accounts({
    mint: mintAddress,
    from: fromTokenAccount,
    to: toTokenAccount,
    authority: wallet.publicKey,
    tokenProgram: TOKEN_PROGRAM_ID,
  })
  .rpc();

// Manual burn
await program.methods
  .burnTokens(new anchor.BN(50_000))
  .accounts({
    mint: mintAddress,
    from: tokenAccount,
    authority: wallet.publicKey,
    tokenProgram: TOKEN_PROGRAM_ID,
  })
  .rpc();
```

---

## Security Considerations

### Implemented Security Features

- ✅ **Overflow Protection**: All math operations checked
- ✅ **Access Control**: Mint authority required for minting
- ✅ **Input Validation**: All inputs validated
- ✅ **Minimum Amount**: 200 tokens minimum for burn calculation
- ✅ **Event Emissions**: All operations emit events
- ✅ **Anchor Framework**: Built-in security features

### Best Practices

1. **Never share private keys**
2. **Test on devnet first**
3. **Use hardware wallet for mainnet**
4. **Verify all transactions**
5. **Monitor token supply**

---

## Troubleshooting

### Build Errors

```bash
# Clean and rebuild
anchor clean
anchor build
```

### Test Failures

```bash
# Check Solana version
solana --version

# Update Anchor
avm update

# Rebuild
anchor build && anchor test
```

### Deployment Issues

```bash
# Check balance
solana balance

# Check network
solana config get

# Increase compute budget if needed
```

---

## Project Structure

```
solana/
├── Anchor.toml              # Anchor configuration
├── Cargo.toml               # Workspace configuration
├── package.json             # Node dependencies
├── tsconfig.json            # TypeScript configuration
├── programs/
│   └── velirion-spl/
│       ├── Cargo.toml       # Program dependencies
│       ├── Xargo.toml       # Build configuration
│       └── src/
│           └── lib.rs       # Main program code
├── tests/
│   └── velirion-spl.ts      # Test suite
└── scripts/
    ├── deploy.ts            # Deployment script
    └── mint-initial-supply.ts  # Minting script
```

---

## Resources

- **Anchor Docs**: https://www.anchor-lang.com/
- **Solana Docs**: https://docs.solana.com/
- **SPL Token**: https://spl.solana.com/token
- **Solana Explorer**: https://explorer.solana.com/

---

## License

MIT

---

**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Last Updated**: October 21, 2025
