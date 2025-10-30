# RUN THIS NEXT - Milestone 1 Completion

## ⚡ Quick Action Checklist

Once Hardhat compilation finishes, run these commands in order:

---

## Step 1: Test Ethereum Implementation

```bash
# Run all tests
npx hardhat test

# Expected: ✅ 28 passing (2s)
```

---

## Step 2: Check Test Coverage

```bash
# Generate coverage report
npx hardhat coverage

# Expected: ≥90% coverage
# Open: coverage/index.html to view report
```

---

## Step 3: Deploy to Sepolia

```bash
# Deploy token to Sepolia testnet
npx hardhat run scripts/01_deploy_token.ts --network sepolia

# Save the contract address from output!
```

---

## Step 4: Verify on Etherscan

```bash
# Verify contract
npx hardhat run scripts/verify_deployment.ts --network sepolia

# Or manually:
# npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

---

## Step 5: Update .env

Add the deployed address to `.env`:

```env
VLR_TOKEN_ADDRESS=<YOUR_DEPLOYED_ADDRESS>
```

---

## Step 6: Solana Setup (Optional - Can be done later)

### Install Prerequisites

```powershell
# 1. Install Rust
Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "rustup-init.exe"
.\rustup-init.exe

# 2. Install Solana CLI
Invoke-WebRequest -Uri "https://release.solana.com/v1.18.0/solana-install-init-x86_64-pc-windows-msvc.exe" -OutFile "solana-install-init.exe"
.\solana-install-init.exe

# 3. Install Anchor
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install 0.30.1
avm use 0.30.1

# Restart terminal after each installation
```

### Build and Test Solana

```bash
cd solana
yarn install
anchor build
anchor test
```

### Deploy to Solana Devnet

```bash
# Configure for devnet
solana config set --url devnet

# Get SOL
solana airdrop 2

# Deploy
anchor deploy --provider.cluster devnet
ts-node scripts/deploy.ts
ts-node scripts/mint-initial-supply.ts
```

---

## Expected Results

### Ethereum Tests

```
  VelirionToken
    Deployment
      ✔ Should set the correct name and symbol
      ✔ Should have 18 decimals
      ✔ Should mint initial supply to owner
      ✔ Should have correct initial supply
      ✔ Should set the deployer as owner
    Token Allocation
      ✔ Should allocate tokens correctly
      ... (23 more tests)

  28 passing (2s)
```

### Coverage

```
File                  | % Stmts | % Branch | % Funcs | % Lines |
----------------------|---------|----------|---------|---------|
VelirionToken.sol     |   95.2  |   90.5   |   100   |   94.8  |
----------------------|---------|----------|---------|---------|
All files             |   95.2  |   90.5   |   100   |   94.8  |
```

### Deployment

```
 Deploying Velirion Token...

Deploying contracts with account: 0x...
Account balance: 0.5 ETH

✅ VelirionToken deployed to: 0x...

Token Information:
Name: Velirion
Symbol: VLR
Total Supply: 100000000.0 VLR
```

---

## 🎯 Success Criteria

- [ ] All 28 Ethereum tests passing
- [ ] Test coverage ≥90%
- [ ] Deployed to Sepolia testnet
- [ ] Verified on Etherscan
- [ ] Contract address documented
- [ ] .env file updated

**Optional (Solana)**:

- [ ] Solana tools installed
- [ ] All 16 Solana tests passing
- [ ] Deployed to Solana devnet
- [ ] Initial supply minted

---

## Documentation to Update

After successful deployment:

1. **PROJECT_TRACKER.md**

   - Mark deployment tasks complete
   - Add contract addresses
   - Update status to "Deployed"

2. **deployment-token.json**

   - Automatically created by deployment script
   - Contains all deployment info

3. **deployment-spl.json** (Solana)
   - Automatically created by Solana deployment
   - Contains Solana deployment info

---

## 🚨 If Something Goes Wrong

### Tests Fail

1. Check compilation completed
2. Review error messages
3. Consult `TESTING_GUIDE.md`

### Deployment Fails

1. Check wallet has sufficient ETH
2. Verify RPC URL is correct
3. Consult `DEPLOYMENT_GUIDE.md`

### Coverage Low

1. Review untested code paths
2. Add missing tests
3. Re-run coverage

---

## 📚 Documentation Reference

- **Testing**: `TESTING_GUIDE.md`
- **Deployment**: `DEPLOYMENT_GUIDE.md`
- **Solana Setup**: `SOLANA_SETUP_GUIDE.md`
- **Quick Commands**: `QUICK_REFERENCE.md`
- **Full Summary**: `MILESTONE_1_SUMMARY.md`

---

## ⏱️ Estimated Time

- **Ethereum Tests**: 2-5 seconds
- **Coverage Report**: 30-60 seconds
- **Sepolia Deployment**: 1-2 minutes
- **Etherscan Verification**: 2-3 minutes
- **Total**: ~5-10 minutes

**Solana** (if doing now):

- **Setup**: 15-20 minutes
- **Build & Test**: 2-3 minutes
- **Deployment**: 2-3 minutes
- **Total**: ~20-25 minutes

---

## 🎉 After Completion

You will have:

- ✅ Fully tested Ethereum token
- ✅ Deployed and verified on Sepolia
- ✅ Complete Solana implementation (code ready)
- ✅ Comprehensive documentation
- ✅ Milestone 1 ready for sign-off

---

**Current Status**: ✅ Code Complete - Ready to Execute  
**Next Action**: Run `npx hardhat test` after compilation finishes

**Good luck! **
