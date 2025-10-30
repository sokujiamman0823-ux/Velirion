# Velirion Milestone 1 - Quick Reference Card

## 🎯 Current Status

- ✅ Code fixed and ready
- ✅ Tests written (28 tests)
- ✅ Coverage plugin installed
- ✅ Documentation complete
- ⏳ Compilation in progress
- ⏳ Awaiting test execution

---

## ⚡ Quick Commands

### Essential Commands

```bash
# Compile contracts
npx hardhat compile

# Run all tests
npx hardhat test

# Check coverage
npx hardhat coverage

# Deploy to Sepolia
npx hardhat run scripts/01_deploy_token.ts --network sepolia

# Verify contract
npx hardhat verify --network sepolia <ADDRESS>
```

### Automated Check Script

```powershell
# Run all checks at once
.\scripts\run_milestone1_checks.ps1
```

---

## 📁 Key Files

### Contracts

- `contracts/core/VelirionToken.sol` - Main token contract

### Tests

- `test/01_VelirionToken.test.ts` - 28 comprehensive tests

### Scripts

- `scripts/01_deploy_token.ts` - Deployment script
- `scripts/verify_deployment.ts` - Verification script
- `scripts/run_milestone1_checks.ps1` - Automated checks

### Documentation

- `NEXT_STEPS.md` - What to do next
- `TESTING_GUIDE.md` - Testing instructions
- `DEPLOYMENT_GUIDE.md` - Deployment walkthrough
- `MILESTONE_1_COMPLETION.md` - Progress tracking

### Configuration

- `.env` - Environment variables
- `hardhat.config.ts` - Hardhat configuration
- `package.json` - Dependencies

---

## ✅ Fixes Applied

1. **OpenZeppelin v5 Compatibility**

   - Changed `_beforeTokenTransfer` → `_update`
   - Location: Line 108 in VelirionToken.sol

2. **TypeScript Imports**

   - Fixed test file imports for Hardhat 3.x
   - Location: Lines 1-5 in 01_VelirionToken.test.ts

3. **Coverage Plugin**
   - Installed solidity-coverage
   - Added to hardhat.config.ts

---

## 🎯 Success Metrics

### Tests

- **Target**: 28/28 passing
- **Time**: < 5 seconds
- **Coverage**: ≥90%

### Deployment

- **Network**: Sepolia testnet
- **Gas**: ~2M gas (~0.05 ETH)
- **Time**: 1-2 minutes

### Verification

- **Platform**: Etherscan
- **Time**: 2-3 minutes
- **Result**: Green checkmark

---

## 🚨 Quick Troubleshooting

### Compilation Issues

```bash
npx hardhat clean
npx hardhat compile
```

### Test Failures

```bash
# Check specific test
npx hardhat test test/01_VelirionToken.test.ts
```

### Deployment Issues

```bash
# Check balance
npx hardhat console --network sepolia
# Then: await ethers.provider.getBalance("<YOUR_ADDRESS>")
```

---

## Milestone 1 Checklist

### Ethereum (Current)

- [x] VelirionToken.sol created
- [x] Burning mechanism implemented
- [x] Ownership controls added
- [x] Pause functionality added
- [x] Tests written (28 tests)
- [ ] Tests passing (pending)
- [ ] Coverage ≥90% (pending)
- [ ] Deployed to Sepolia (pending)
- [ ] Verified on Etherscan (pending)
- [ ] Documentation updated (pending)

### Solana (Not Started)

- [ ] SPL token project initialized
- [ ] SPL token with 0.5% burn
- [ ] Solana tests written
- [ ] Deployed to devnet
- [ ] Documentation updated

---

## 🔗 Important Links

### Testnet Resources

- Sepolia Faucet: https://sepoliafaucet.com/
- Sepolia Explorer: https://sepolia.etherscan.io/

### Documentation

- Hardhat: https://hardhat.org/docs
- OpenZeppelin: https://docs.openzeppelin.com/
- Ethers.js: https://docs.ethers.org/

---

## 💡 Pro Tips

1. **Always compile before testing**

   ```bash
   npx hardhat compile && npx hardhat test
   ```

2. **Check gas costs**

   ```bash
   REPORT_GAS=true npx hardhat test
   ```

3. **Interactive testing**

   ```bash
   npx hardhat console --network sepolia
   ```

4. **Clean build**
   ```bash
   npx hardhat clean && npx hardhat compile
   ```

---

## 📞 Need Help?

1. Check `NEXT_STEPS.md` for detailed instructions
2. Review `TESTING_GUIDE.md` for test issues
3. Consult `DEPLOYMENT_GUIDE.md` for deployment problems
4. Read error messages carefully
5. Check Hardhat documentation

---

**Quick Start After Compilation**:

```bash
npx hardhat test && npx hardhat coverage
```

**Then Deploy**:

```bash
npx hardhat run scripts/01_deploy_token.ts --network sepolia
```

**Status**: ✅ Ready to Execute  
**Last Updated**: October 21, 2025
