# ⚡ Quick Test Commands

**Network**: Sepolia Testnet

---

## 🚀 Run All Tests

```bash
npx hardhat run scripts/integration-test.js --network sepolia
```

This runs a comprehensive test suite checking all contracts.

---

## 🎯 Individual Tests

### Test Presale
```bash
npx hardhat run scripts/test-presale.js --network sepolia
```
Tests token purchases with ETH, USDT, and USDC.

### Test Staking
```bash
npx hardhat run scripts/test-staking.js --network sepolia
```
Tests staking across all 4 tiers (Flexible, Medium 90–180d, Long 365d, Elite 730d).

### Test Referral System
```bash
npx hardhat run scripts/test-referral.js --network sepolia
```
Tests user registration and multi-level referrals.

### Test DAO Governance
```bash
npx hardhat run scripts/test-dao.js --network sepolia
```
Tests proposal creation, voting, and execution.

---

## 📋 Prerequisites

1. **Sepolia ETH**: Get from [Sepolia Faucet](https://sepoliafaucet.com/)
2. **Private Key**: Set in `.env` file
3. **Node Modules**: Run `npm install` if needed

---

## 🔗 Contract Addresses

All addresses in `deployment-sepolia.json`:

- **VLR Token**: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`
- **Presale**: `0xAF8021201524b1E487350F48D5609dFE7ecBb529`
- **Staking**: `0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F`
- **Referral**: `0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8`
- **DAO**: `0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE`

---

## 📖 Full Documentation

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed instructions.

---

## ✅ Quick Checklist

- [ ] Run integration tests
- [ ] Test presale purchases
- [ ] Test staking functionality
- [ ] Test referral system
- [ ] Test DAO proposals
- [ ] Document any issues

---

**Happy Testing! 🎉**
