# Velirion Solana SPL Token - Setup Guide

## Quick Start

This guide will help you set up and deploy the Velirion SPL token on Solana in under 30 minutes.

---

## Prerequisites Installation

### 1. Install Rust

```powershell
# Download and install Rust
Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "rustup-init.exe"
.\rustup-init.exe

# Restart terminal, then verify
rustc --version
cargo --version

# Add rustfmt component
rustup component add rustfmt
```

### 2. Install Solana CLI

```powershell
# Download Solana installer
Invoke-WebRequest -Uri "https://release.solana.com/v1.18.0/solana-install-init-x86_64-pc-windows-msvc.exe" -OutFile "solana-install-init.exe"
.\solana-install-init.exe

# Add to PATH (restart terminal after)
# Verify installation
solana --version
```

### 3. Install Anchor

```powershell
# Install Anchor Version Manager
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force

# Install Anchor 0.30.1
avm install 0.30.1
avm use 0.30.1

# Verify
anchor --version
```

### 4. Install Node Dependencies

```powershell
cd solana
yarn install
```

---

## Configuration

### 1. Configure Solana CLI

```powershell
# Set to devnet
solana config set --url devnet

# Generate wallet (if you don't have one)
solana-keygen new --outfile ~/.config/solana/id.json

# Check your address
solana address

# Check balance
solana balance
```

### 2. Get Devnet SOL

```powershell
# Airdrop 2 SOL
solana airdrop 2

# Or use web faucet: https://faucet.solana.com/
```

### 3. Update Anchor.toml

The `Anchor.toml` file is pre-configured. After deployment, update the program IDs:

```toml
[programs.devnet]
velirion_spl = "<YOUR_PROGRAM_ID_HERE>"
```

---

## Build and Test

### 1. Build the Program

```powershell
cd solana
anchor build
```

**Expected Output:**

```
Compiling velirion-spl v1.0.0
Finished release [optimized] target(s) in 45.23s
```

### 2. Run Tests

```powershell
anchor test
```

**Expected Output:**

```
  velirion-spl
    Initialization
      ✔ Initializes the Velirion SPL token mint (523ms)
      ✔ Creates token accounts for users (412ms)
    Minting
      ✔ Mints initial supply to user (387ms)
      ✔ Fails to mint with zero amount (156ms)
      ✔ Fails to mint without authority (143ms)
    Transfer with 0.5% Burn
      ✔ Transfers tokens with 0.5% burn (445ms)
      ✔ Calculates burn correctly for different amounts (1234ms)
      ✔ Fails with amount too small for burn (167ms)
      ✔ Fails with zero amount (145ms)
      ✔ Emits transfer event (398ms)
    Manual Burning
      ✔ Burns tokens manually (367ms)
      ✔ Fails to burn zero amount (154ms)
      ✔ Fails to burn more than balance (178ms)
      ✔ Emits burn event (345ms)
    Edge Cases
      ✔ Handles large transfer amounts (423ms)
      ✔ Verifies total supply decreases with burns (234ms)

  16 passing (6s)
```

---

## Deployment

### 1. Deploy Program to Devnet

```powershell
anchor deploy --provider.cluster devnet
```

**Expected Output:**

```
Deploying cluster: https://api.devnet.solana.com
Upgrade authority: <your-wallet>
Deploying program "velirion_spl"...
Program Id: VLRxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Deploy success
```

**Important**: Copy the Program ID!

### 2. Update Anchor.toml

Replace the program ID in `Anchor.toml`:

```toml
[programs.devnet]
velirion_spl = "VLRxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 3. Initialize Token

```powershell
ts-node scripts/deploy.ts
```

**Expected Output:**

```
 Deploying Velirion SPL Token...

📋 Deployment Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Network: devnet
Program ID: VLRxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Deployer: <your-wallet>
Deployer Balance: 1.5 SOL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🪙 Token Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mint Address: <mint-address>
Mint Authority: <your-wallet>
Decimals: 9
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏳ Initializing token mint...
✅ Token initialized successfully!
Transaction signature: <tx-signature>

💾 Deployment info saved to deployment-spl.json
```

### 4. Mint Initial Supply

```powershell
ts-node scripts/mint-initial-supply.ts
```

**Expected Output:**

```
🪙 Minting Velirion Initial Supply...

📋 Minting Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mint Address: <mint-address>
Authority: <your-wallet>
Initial Supply: 100,000,000 VLR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏳ Creating associated token account...
✅ Token account created: <token-account>

⏳ Minting initial supply...
✅ Tokens minted successfully!

Token Information:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Token Account: <token-account>
Balance: 100,000,000 VLR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Initial supply minted successfully!
```

---

## Verification

### 1. View on Solana Explorer

```
https://explorer.solana.com/address/<MINT_ADDRESS>?cluster=devnet
```

### 2. Check Token Balance

```powershell
spl-token accounts
```

### 3. Test Transfer with Burn

Create a test script or use the Anchor console:

```typescript
// Transfer 1M tokens (will burn 5,000, transfer 995,000)
await program.methods
  .transferWithBurn(new anchor.BN(1_000_000))
  .accounts({
    mint: mintAddress,
    from: fromAccount,
    to: toAccount,
    authority: wallet.publicKey,
    tokenProgram: TOKEN_PROGRAM_ID,
  })
  .rpc();
```

---

## Project Files Created

```
solana/
├── Anchor.toml                          # ✅ Created
├── Cargo.toml                           # ✅ Created
├── package.json                         # ✅ Created
├── tsconfig.json                        # ✅ Created
├── README.md                            # ✅ Created
├── .gitignore                           # ✅ Created
├── programs/
│   └── velirion-spl/
│       ├── Cargo.toml                   # ✅ Created
│       ├── Xargo.toml                   # ✅ Created
│       └── src/
│           └── lib.rs                   # ✅ Created (250+ lines)
├── tests/
│   └── velirion-spl.ts                  # ✅ Created (400+ lines, 16 tests)
└── scripts/
    ├── deploy.ts                        # ✅ Created
    └── mint-initial-supply.ts           # ✅ Created
```

---

## Common Issues & Solutions

### Issue 1: "anchor: command not found"

**Solution:**

```powershell
# Reinstall Anchor
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install 0.30.1
avm use 0.30.1

# Restart terminal
```

### Issue 2: "Insufficient SOL"

**Solution:**

```powershell
# Get more SOL from faucet
solana airdrop 2

# Or use web faucet: https://faucet.solana.com/
```

### Issue 3: Build Errors

**Solution:**

```powershell
# Clean and rebuild
anchor clean
rm -rf target
anchor build
```

### Issue 4: Test Failures

**Solution:**

```powershell
# Ensure local validator is running (if testing locally)
solana-test-validator

# Or test on devnet
anchor test --provider.cluster devnet
```

### Issue 5: "Program ID mismatch"

**Solution:**

1. Run `anchor keys list` to get your program ID
2. Update `Anchor.toml` with the correct ID
3. Update `lib.rs` `declare_id!` macro
4. Rebuild: `anchor build`

---

## Next Steps

After successful deployment:

1. ✅ Update `.env` in root project:

   ```env
   SOLANA_MINT_ADDRESS=<your-mint-address>
   SOLANA_PROGRAM_ID=<your-program-id>
   ```

2. ✅ Update `PROJECT_TRACKER.md`:

   - Mark Solana tasks as complete
   - Add deployment addresses
   - Update status to deployed

3. ✅ Test the burn mechanism:

   - Transfer tokens between accounts
   - Verify 0.5% burn occurs
   - Check total supply decreases

4. ✅ Document deployment:
   - Save `deployment-spl.json`
   - Record transaction signatures
   - Note any issues encountered

---

## Mainnet Deployment (Future)

### Prerequisites

- [ ] Complete security audit
- [ ] Thorough testing on devnet
- [ ] Sufficient SOL for deployment (~5 SOL)
- [ ] Backup of all keys
- [ ] Team approval

### Steps

```powershell
# Configure for mainnet
solana config set --url mainnet-beta

# Deploy
anchor deploy --provider.cluster mainnet

# Initialize and mint
ts-node scripts/deploy.ts
ts-node scripts/mint-initial-supply.ts
```

---

## Resources

- **Anchor Book**: https://book.anchor-lang.com/
- **Solana Cookbook**: https://solanacookbook.com/
- **SPL Token Guide**: https://spl.solana.com/token
- **Solana Discord**: https://discord.gg/solana

---

## Support

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review Anchor documentation
3. Check Solana Discord for help
4. Review test output for clues

---

**Estimated Setup Time**: 20-30 minutes  
**Difficulty**: Intermediate  
**Status**: ✅ Ready for Deployment

**Last Updated**: October 21, 2025
