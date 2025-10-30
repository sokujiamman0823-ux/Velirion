# Solana Devnet Deployment Guide

**Status**: ✅ **DEPLOYED & INITIALIZED**  
**Last Updated**: October 31, 2025  
**Network**: Devnet  
**Anchor Version**: 0.30.1

---

## Deployment Summary

**Program Deployed**: ✅ Complete

- **Program ID**: `CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr`
- **Network**: Solana Devnet
- **Authority**: `JCoP8cPACMY6aj4fYybZ6e6vLfHi2WSzsGaY98UMLskX`

**SPL Token Initialized**: ✅ Complete

- **Mint Address**: `CFfZ1KGxiywpSzuU1VizsxVDh8Efrb2hTyVZZvFjgyXM`
- **Decimals**: 9
- **Mint Authority**: `JCoP8cPACMY6aj4fYybZ6e6vLfHi2WSzsGaY98UMLskX`
- **Transaction**: `5grzyvGxBDscrdUSEpF41xU1xKnGoVXGoGQTcXaRgZy7M1ELUZX2RE81UThi3obarrwRN7WGLkL7AzsMkwBbzaK4`

**Explorer Links**:

- Program: https://explorer.solana.com/address/CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr?cluster=devnet
- Mint: https://explorer.solana.com/address/CFfZ1KGxiywpSzuU1VizsxVDh8Efrb2hTyVZZvFjgyXM?cluster=devnet

---

## Prerequisites

### Required Tools

- **Solana CLI**: 2.3.13+
- **Anchor CLI**: 0.30.1 (pinned per requirement)
- **Rust**: 1.90.0+
- **Node.js**: v24.10.0+

### Installation (WSL/Linux recommended for speed)

```bash
# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/v2.3.13/install)"

# Install Anchor CLI 0.30.1
cargo install --git https://github.com/coral-xyz/anchor --tag v0.30.1 anchor-cli --locked

# Verify versions
solana --version  # Should be 2.3.13
anchor --version  # Should be 0.30.1
```

---

## Deployment Steps

### 1. Setup Solana Configuration

```bash
cd solana

# Set cluster to devnet
solana config set --url https://api.devnet.solana.com

# Create/check wallet
solana-keygen new --outfile ~/.config/solana/id.json
# Or use existing: solana-keygen recover

# Check wallet address
solana address

# Get devnet SOL (airdrop)
solana airdrop 2
solana balance
```

### 2. Build the Program

```bash
# Clean previous builds
anchor clean
rm -rf target/

# Build (this may take 5-10 minutes)
anchor build

# Verify build
ls -lh target/deploy/
# Should see: velirion_spl.so and velirion_spl-keypair.json
```

### 3. Get Program ID

```bash
# The program ID is pre-configured in Anchor.toml
# CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr

# Verify it matches the keypair
solana address -k target/deploy/velirion_spl-keypair.json
```

### 4. Deploy to Devnet

```bash
# Set environment variables
export ANCHOR_PROVIDER_URL=https://api.devnet.solana.com
export ANCHOR_WALLET=~/.config/solana/id.json

# Deploy
anchor deploy --provider.cluster devnet

# Verify deployment
solana program show CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr --url devnet
```

**Expected Output:**

```
Program Id: CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr
Owner: BPFLoaderUpgradeab1e11111111111111111111111
ProgramData Address: <address>
Authority: <your wallet>
Last Deployed In Slot: <slot>
Data Length: <bytes>
```

### 5. Initialize SPL Token

The program needs to be initialized to create the SPL token mint. Run the initialization script:

```bash
# Run tests to initialize (includes initialization)
anchor test --skip-local-validator

# Or use custom initialization script
ts-node scripts/initialize-devnet.ts
```

---

## Verification

### Check Program on Explorer

https://explorer.solana.com/address/CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr?cluster=devnet

### Check Program Logs

```bash
solana logs CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr --url devnet
```

### Get SPL Mint Address

After initialization, the mint address will be displayed. You can also query it:

```bash
# The mint address is derived from the program
# Check program accounts
solana program show CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr --url devnet --accounts
```

---

## Program Details

### Features

- **0.5% burn on transfer**: Automatic deflationary mechanism
- **SPL Token Standard**: Compatible with all Solana wallets
- **Decimals**: 9 (standard for Solana)
- **Total Supply**: Configurable on initialization

### Program Functions

- `initialize(decimals)`: Create mint and initialize program
- `transfer(amount)`: Transfer with 0.5% burn
- `burn(amount)`: Manual burn function
- `get_supply()`: Query current supply

---

## Troubleshooting

### Build Errors

**"Anchor version mismatch"**

```bash
# Ensure CLI is 0.30.1
anchor --version

# Reinstall if needed
cargo install --git https://github.com/coral-xyz/anchor --tag v0.30.1 anchor-cli --locked --force
```

**"Cargo dependency errors"**

```bash
# Clean and rebuild
rm -rf target/ Cargo.lock
anchor build
```

### Deployment Errors

**"Insufficient funds"**

```bash
# Get more SOL
solana airdrop 2
solana balance
```

**"Program already deployed"**

```bash
# Upgrade existing program
anchor upgrade target/deploy/velirion_spl.so --program-id CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr --provider.cluster devnet
```

**"Network timeout"**

```bash
# Use faster RPC (if available)
export ANCHOR_PROVIDER_URL=https://api.devnet.solana.com

# Or retry with increased timeout
anchor deploy --provider.cluster devnet --provider.timeout 120
```

### Test Errors

**"Connection refused"**

```bash
# Ensure devnet is accessible
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
  https://api.devnet.solana.com

# Set environment variables
export ANCHOR_PROVIDER_URL=https://api.devnet.solana.com
export ANCHOR_WALLET=~/.config/solana/id.json
```

---

## 📊 Post-Deployment Checklist

- [ ] Program deployed to devnet
- [ ] Program ID verified: `CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr`
- [ ] SPL mint initialized
- [ ] Mint address recorded
- [ ] Explorer link accessible
- [ ] Transfer test successful (0.5% burn verified)
- [ ] IDL generated and saved
- [ ] Backend integration docs updated

---

## 🌐 Integration Info

### Program ID

```
CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr
```

### Devnet RPC

```
https://api.devnet.solana.com
```

### Explorer

```
https://explorer.solana.com/address/CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr?cluster=devnet
```

### IDL Location

```
target/idl/velirion_spl.json
```

---

## 📞 Next Steps

1. **Record Mint Address**: Save the SPL mint address after initialization
2. **Update Backend Docs**: Add Solana integration to `BACKEND_INTEGRATION.md`
3. **Test Transfers**: Verify 0.5% burn mechanism
4. **Multichain Sync**: Document cross-chain token tracking strategy
5. **Mainnet Prep**: Plan mainnet deployment with proper supply allocation

---

**Deployment Date**: TBD
**Network**: Solana Devnet
**Anchor Version**: 0.30.1
**Status**: Ready for Deployment
