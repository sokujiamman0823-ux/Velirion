# Velirion Quick Reference Card

## 🌐 Networks

### Ethereum Sepolia
- **RPC**: `https://eth-sepolia.g.alchemy.com/v2/...`
- **Chain ID**: `11155111`
- **Explorer**: https://sepolia.etherscan.io

### Solana Devnet
- **RPC**: `https://api.devnet.solana.com`
- **Program ID**: `CXf7sapvuMh9oK4D9HcSJDHqTjoo5yK1LsppTXeXMHzn`
- **Explorer**: https://explorer.solana.com/?cluster=devnet

---

## 📝 Contract Addresses (Sepolia)

```
VLR Token:     0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9
Presale:       0xAF8021201524b1E487350F48D5609dFE7ecBb529
Referral:      0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8
Staking:       0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F
DAO:           0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE
Treasury:      0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1
Referral NFT:  0x11aC4D9569a4F51C3c00529931b54d55335cE3b4
Guardian NFT:  0x0baF2aca6044dCb120034E278Ba651F048658C19
```

---

## 🛒 Presale Quick Facts

- **Phases**: 10 (0-9)
- **Price Range**: $0.005 → $0.015 per VLR
- **Tokens/Phase**: 3,000,000 VLR
- **Total**: 30,000,000 VLR
- **Vesting**: 40% TGE + 30% @ 30d + 30% @ 60d
- **Limits**: 50k/tx, 500k/wallet
- **Antibot**: 5-minute delay

---

## 👥 Referral Tiers

| Tier | Referrals | Purchase | Staking |
|------|-----------|----------|---------|
| Starter | 0 | 5% | 2% |
| Bronze | 10+ | 7% | 3% |
| Silver | 25+ | 10% | 4% |
| Gold | 50+ | 12% | 5% |

---

## 🔒 Staking Tiers

| Tier | APR | Lock | Min Stake |
|------|-----|------|-----------|
| Flexible | 6% | No lock | 100 VLR |
| Medium | 12-15% | 90-180d | 1,000 VLR |
| Long | 20-22% | 365d | 5,000 VLR |
| Elite | 30-32% | 730d | 250,000 VLR |

**Bonus**: Long/Elite get +2% APR on renewal + 2× DAO voting

---

## 🏛️ DAO Parameters

- **Proposal Threshold**: 10,000 VLR (burned)
- **Voting Period**: 7 days
- **Voting Delay**: 1 day
- **Quorum**: 100,000 VLR
- **Timelock**: 2 days

---

## ⚡ Quick Commands

### Test Presale
```bash
npx hardhat run scripts/test-presale.js --network sepolia
```

### Test Staking
```bash
npx hardhat run scripts/test-staking.js --network sepolia
```

### Test Referral
```bash
npx hardhat run scripts/test-referral.js --network sepolia
```

### Test DAO
```bash
npx hardhat run scripts/test-dao.js --network sepolia
```

### Deploy Solana
```bash
cd solana
./deploy-devnet.sh
```

---

## 🔧 Gas Settings (.env)

```env
GAS_LIMIT=500000
GAS_PRICE=2000000000  # 2 gwei
```

---

## 📚 Documentation

- `BACKEND_INTEGRATION.md` - Integration guide
- `TESTING_GUIDE.md` - Testing procedures
- `DEPLOYMENT_SUMMARY.md` - Contract details
- `COMPLIANCE_SUMMARY.md` - Full compliance report
- `SOLANA_DEPLOYMENT.md` - Solana deployment

---

## 🔗 Quick Links

### Etherscan (Sepolia)
- [VLR Token](https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9)
- [Presale](https://sepolia.etherscan.io/address/0xAF8021201524b1E487350F48D5609dFE7ecBb529)
- [Staking](https://sepolia.etherscan.io/address/0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F)
- [DAO](https://sepolia.etherscan.io/address/0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE)

### Solana Explorer (Devnet)
- [Program](https://explorer.solana.com/address/CXf7sapvuMh9oK4D9HcSJDHqTjoo5yK1LsppTXeXMHzn?cluster=devnet)

---

**Last Updated**: October 29, 2025
