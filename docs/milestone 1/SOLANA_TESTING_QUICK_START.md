# 🚀 Solana Testing Quick Start Guide

**Quick reference for testing the Velirion SPL token**

---

## ⚡ Prerequisites Check

```bash
# Check Solana CLI
solana --version
# Expected: solana-cli 1.18.x or higher

# Check Anchor CLI
anchor --version
# Expected: anchor-cli 0.30.1

# Check Rust
rustc --version
# Expected: rustc 1.75.x or higher

# Check Node.js
node --version
# Expected: v18.x or higher
```

### Install Missing Tools

```bash
# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Install Anchor CLI
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install 0.30.1
avm use 0.30.1

# Install Node dependencies
cd solana
npm install
```

---

## 🧪 Running Tests

### 1. Quick Test (Original Suite - 16 tests)

```bash
cd solana
anchor test
```

**Expected Output:**
```
✔ Initializes the Velirion SPL token mint
✔ Creates token accounts for users
✔ Mints initial supply to user
✔ Fails to mint with zero amount
✔ Fails to mint without authority
✔ Transfers tokens with 0.5% burn
✔ Calculates burn correctly for different amounts
✔ Fails with amount too small for burn
✔ Fails with zero amount
✔ Emits transfer event
✔ Burns tokens manually
✔ Fails to burn zero amount
✔ Fails to burn more than balance
✔ Emits burn event
✔ Handles large transfer amounts
✔ Verifies total supply decreases with burns

16 passing (Xs)
```

---

### 2. Comprehensive Test (30+ tests)

```bash
cd solana
anchor test tests/velirion-spl-comprehensive.ts
```

**Expected Output:**
```
1. Initialization & Setup
  ✔ Should initialize the Velirion SPL token mint
  ✔ Should create associated token accounts
  ✔ Should verify zero balances initially

2. Minting Operations
  ✔ Should mint initial supply
  ✔ Should fail to mint with zero amount
  ✔ Should fail without proper authority
  ✔ Should allow minting to multiple accounts

3. Transfer with 0.5% Burn Mechanism
  ✔ Should transfer with exact 0.5% burn
  ✔ Should calculate burn correctly for various amounts
  ✔ Should fail below minimum threshold (200)
  ✔ Should accept minimum valid amount (200)
  ✔ Should fail with zero transfer amount
  ✔ Should fail when transferring more than balance
  ✔ Should handle multiple sequential transfers

4. Manual Burning
  ✔ Should burn tokens manually
  ✔ Should fail to burn zero amount
  ✔ Should fail to burn more than balance
  ✔ Should allow burning entire balance

5. Security & Access Control
  ✔ Should prevent unauthorized minting
  ✔ Should prevent unauthorized transfers
  ✔ Should prevent unauthorized burns

6. Supply Management
  ✔ Should track total supply correctly
  ✔ Should verify supply decreases only through burns
  ✔ Should maintain supply conservation

7. Test Summary
  ✔ Should generate comprehensive test report

30+ passing (Xs)
```

---

### 3. Run Specific Test Categories

```bash
# Test only initialization
anchor test --grep "Initialization"

# Test only minting
anchor test --grep "Minting"

# Test only burn mechanism
anchor test --grep "Burn"

# Test only security
anchor test --grep "Security"

# Test only supply management
anchor test --grep "Supply"
```

---

### 4. Verbose Testing (with logs)

```bash
# Show all program logs
ANCHOR_LOG=true anchor test

# Show Solana logs
anchor test --skip-local-validator -- --show-logs
```

---

## 🔍 Manual Testing Checklist

### Test 1: Initialize Mint
```bash
# Start local validator
solana-test-validator

# In another terminal
cd solana
anchor build
anchor deploy --provider.cluster localnet

# Verify deployment
solana program show <PROGRAM_ID>
```

**Expected:**
- ✅ Program deployed successfully
- ✅ Program ID matches Anchor.toml

---

### Test 2: Create Token Accounts
```bash
# Create associated token account
spl-token create-account <MINT_ADDRESS>

# Verify account created
spl-token accounts
```

**Expected:**
- ✅ Token account created
- ✅ Balance = 0

---

### Test 3: Mint Tokens
```bash
# Mint 100M tokens
spl-token mint <MINT_ADDRESS> 100000000

# Check balance
spl-token balance <MINT_ADDRESS>
```

**Expected:**
- ✅ Balance = 100,000,000
- ✅ Total supply = 100,000,000

---

### Test 4: Transfer with Burn
```typescript
// Use the test script
anchor run test-transfer
```

**Verify:**
- ✅ Sender deducted full amount
- ✅ Recipient received 99.5%
- ✅ 0.5% burned from supply

---

### Test 5: Manual Burn
```typescript
// Use the test script
anchor run test-burn
```

**Verify:**
- ✅ Balance decreased
- ✅ Supply decreased
- ✅ Event emitted

---

## 📊 Test Results Validation

### Check Test Coverage

```bash
# Run tests with coverage (if available)
anchor test --coverage

# Or manually verify:
# - All functions tested? ✅
# - All error cases tested? ✅
# - All edge cases tested? ✅
# - Security scenarios tested? ✅
```

### Validate Test Results

After running tests, verify:

1. **All tests passing** ✅
   ```
   X passing (Xs)
   0 failing
   ```

2. **No warnings** ✅
   ```
   warning: unused variable
   warning: unused import
   ```

3. **Correct balances** ✅
   - User balance > 0
   - Recipient balance > 0
   - Supply decreased after burns

4. **Events emitted** ✅
   - TransferEvent on transfers
   - BurnEvent on burns

---

## 🐛 Troubleshooting

### Issue: "anchor: command not found"

```bash
# Install Anchor CLI
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install 0.30.1
avm use 0.30.1

# Add to PATH
export PATH="$HOME/.avm/bin:$PATH"
```

---

### Issue: "solana: command not found"

```bash
# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Add to PATH
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
```

---

### Issue: Tests timeout

```bash
# Increase timeout in Anchor.toml
[scripts]
test = "yarn run ts-mocha -p ./tsconfig.json -t 1000000 tests/**/*.ts"
#                                              ↑ Increase this
```

---

### Issue: Airdrop failed

```bash
# Use local validator instead of devnet
anchor test --skip-deploy

# Or request airdrop manually
solana airdrop 2 <YOUR_ADDRESS> --url localhost
```

---

### Issue: Build failed

```bash
# Clean and rebuild
anchor clean
anchor build

# Check Rust version
rustc --version
# Should be 1.75.x or higher

# Update Rust if needed
rustup update
```

---

### Issue: "Program not deployed"

```bash
# Check program ID matches
anchor keys list
# Should match declare_id! in lib.rs

# Redeploy if needed
anchor build
anchor deploy
```

---

## 📈 Performance Benchmarks

### Expected Test Times

| Test Suite | Tests | Time | Status |
|------------|-------|------|--------|
| Original | 16 | ~10s | ✅ Fast |
| Comprehensive | 30+ | ~30s | ✅ Good |
| Full Suite | 46+ | ~40s | ✅ Acceptable |

### Compute Unit Usage

| Operation | CU Used | Status |
|-----------|---------|--------|
| Initialize | ~10,000 | ✅ Efficient |
| Mint | ~5,000 | ✅ Efficient |
| Transfer+Burn | ~15,000 | ✅ Good |
| Manual Burn | ~5,000 | ✅ Efficient |

---

## ✅ Success Criteria

### Before Considering Tests Complete

- [ ] All 16 original tests passing
- [ ] All 30+ comprehensive tests passing
- [ ] No compiler warnings
- [ ] No test timeouts
- [ ] Correct balance calculations
- [ ] Events emitted properly
- [ ] Supply conservation verified
- [ ] Security tests passing

### Test Quality Metrics

- [ ] **Coverage**: 100% of functions tested
- [ ] **Edge Cases**: All boundary conditions tested
- [ ] **Security**: All access control tested
- [ ] **Performance**: Tests complete in <1 minute
- [ ] **Reliability**: Tests pass consistently (10/10 runs)

---

## 🎯 Next Steps After Testing

### 1. Review Test Results
```bash
# Generate test report
anchor test > test-results.txt

# Review for any issues
cat test-results.txt
```

### 2. Deploy to Devnet
```bash
# Configure for devnet
anchor build
anchor deploy --provider.cluster devnet

# Verify deployment
solana program show <PROGRAM_ID> --url devnet
```

### 3. Integration Testing
```bash
# Test with real wallet
# Test with dApp integration
# Test with explorer
```

### 4. Security Audit
- [ ] Code review completed
- [ ] Security audit scheduled
- [ ] Penetration testing planned

---

## 📞 Support

### Documentation
- Full Test Report: `SOLANA_COMPREHENSIVE_TEST_REPORT.md`
- Code Analysis: `SOLANA_CODE_ANALYSIS.md`
- Milestone Summary: `MILESTONE_1_COMPLETE.md`

### Common Commands Reference

```bash
# Build
anchor build

# Test
anchor test

# Deploy
anchor deploy

# Clean
anchor clean

# Check
anchor check

# Verify
anchor verify
```

---

**Last Updated**: October 24, 2025  
**Version**: 1.0.0  
**Status**: ✅ Ready for Testing
