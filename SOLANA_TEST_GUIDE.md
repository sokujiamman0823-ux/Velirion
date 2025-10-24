# Velirion SPL Token - Build & Test Guide

## ✅ Current Setup (Working)

### Versions

- **Anchor CLI**: 0.32.1 (installed globally)
- **Anchor Framework**: 0.30.1 (in Cargo.toml)
- **Solana CLI**: 2.3.13
- **Node.js**: v24.10.0
- **Rust**: 1.90.0

### Project Location

- **Working Directory**: `~/velirion-sc/solana` (Linux filesystem - FAST ✨)
- **Original Location**: `/mnt/e/Charanos/Documents/...` (Windows filesystem - SLOW ⚠️)

**Important**: Always work from `~/velirion-sc/solana` for best performance!

---

## 🚀 Build Commands

```bash
# Navigate to project
cd ~/velirion-sc/solana

# Clean build
anchor clean
rm -rf target/

# Build program
anchor build

# Build output location
ls -lh target/deploy/velirion_spl.so
ls -lh target/idl/velirion_spl.json
```

---

## 🧪 Testing on Devnet

### 1. Configure Solana for Devnet

```bash
solana config set --url https://api.devnet.solana.com
solana config get
```

### 2. Check Wallet Balance

```bash
solana balance

# If balance is low, request airdrop
solana airdrop 2
```

### 3. Set Environment Variables

```bash
export ANCHOR_PROVIDER_URL=https://api.devnet.solana.com
export ANCHOR_WALLET=~/.config/solana/id.json
```

### 4. Run Tests

```bash
# Run all tests against Devnet
anchor test --skip-local-validator

# Run specific test file
anchor test --skip-local-validator tests/velirion-spl.ts
```

---

## 📋 Program Details

- **Program ID**: `CXf7sapvuMh9oK4D9HcSJDHqTjoo5yK1LsppTXeXMHzn`
- **Keypair Location**: `~/velirion-sc/solana/target/deploy/velirion_spl-keypair.json`

### Functions

1. `initialize(decimals)` - Initialize token mint
2. `mint_tokens(amount)` - Mint new tokens
3. `transfer_with_burn(amount)` - Transfer with 0.5% burn
4. `burn_tokens(amount)` - Manual burn

---

## 🔧 Troubleshooting

### Build Fails with Dependency Errors

```bash
# Clean everything
rm -rf target/ Cargo.lock
anchor build
```

### Network Timeouts

- Ensure you're working from `~/velirion-sc/` not `/mnt/e/`
- Check internet connection: `ping index.crates.io`

### Version Mismatch Warning

This is OK! CLI 0.32.1 works fine with framework 0.30.1.

### Tests Fail with "Connection Refused"

```bash
# Make sure environment variables are set
export ANCHOR_PROVIDER_URL=https://api.devnet.solana.com
export ANCHOR_WALLET=~/.config/solana/id.json

# Verify Devnet connectivity
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
  https://api.devnet.solana.com
```

---

## 📦 Deploy to Devnet

```bash
# Deploy program
anchor deploy --provider.cluster devnet

# Verify deployment
solana program show CXf7sapvuMh9oK4D9HcSJDHqTjoo5yK1LsppTXeXMHzn --url devnet
```

---

## 🎯 Next Steps After Build Completes

1. ✅ Wait for build to finish
2. Update JS dependencies: `yarn install`
3. Run tests: `anchor test --skip-local-validator`
4. Review test results
5. Deploy to Devnet (optional)

---

## 📝 Notes

- **Why mixed versions?** Anchor 0.32.1 has dependency conflicts, so we use CLI 0.32.1 with framework 0.30.1
- **Why Linux filesystem?** 10-100x faster compilation than Windows filesystem via WSL
- **Why skip local validator?** Your CPU doesn't support AVX2 required by solana-test-validator

---

Generated: 2025-10-25
