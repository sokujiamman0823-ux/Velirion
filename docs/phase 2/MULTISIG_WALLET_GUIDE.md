# 🔐 Multi-Sig Wallet Setup Guide (Gnosis Safe)

**Network**: Sepolia Testnet  
**Date**: October 28, 2025  
**Status**: Ready to create

---

## 📋 Overview

We need to create 4 Gnosis Safe multi-signature wallets on Sepolia testnet for secure fund management:

1. **DAO Treasury Safe** - 5M VLR (5%)
2. **Marketing Safe** - 15M VLR (15%)
3. **Team Safe** - 15M VLR (15%)
4. **Liquidity Safe** - 10M VLR (10%)

**Total Managed**: 45M VLR (45% of total supply)

---

## 🎯 Safe #1: DAO Treasury

### Configuration
- **Purpose**: Community governance funds
- **Allocation**: 5,000,000 VLR (5%)
- **Threshold**: 3-of-5 (requires 3 signatures)
- **Signers Needed**: 5 addresses

### Recommended Signers
1. Core team member #1
2. Core team member #2
3. Core team member #3
4. Community leader #1
5. Community leader #2

### Signer Addresses (Fill in)
```
Signer 1: 0x________________________________
Signer 2: 0x________________________________
Signer 3: 0x________________________________
Signer 4: 0x________________________________
Signer 5: 0x________________________________
```

### Setup Steps
1. Go to https://app.safe.global/
2. Select "Sepolia" network
3. Click "Create New Safe"
4. Name: "Velirion DAO Treasury - Sepolia"
5. Add 5 signer addresses
6. Set threshold: 3
7. Review and deploy
8. Save Safe address: `0x________________________________`

---

## 🎯 Safe #2: Marketing Wallet

### Configuration
- **Purpose**: Marketing & growth initiatives
- **Allocation**: 15,000,000 VLR (15%)
- **Threshold**: 2-of-3 (requires 2 signatures)
- **Signers Needed**: 3 addresses

### Recommended Signers
1. Marketing lead
2. Project manager
3. Core team member

### Signer Addresses (Fill in)
```
Signer 1: 0x________________________________
Signer 2: 0x________________________________
Signer 3: 0x________________________________
```

### Setup Steps
1. Go to https://app.safe.global/
2. Select "Sepolia" network
3. Click "Create New Safe"
4. Name: "Velirion Marketing - Sepolia"
5. Add 3 signer addresses
6. Set threshold: 2
7. Review and deploy
8. Save Safe address: `0x________________________________`

---

## 🎯 Safe #3: Team Wallet

### Configuration
- **Purpose**: Team allocation (vested)
- **Allocation**: 15,000,000 VLR (15%)
- **Threshold**: 3-of-5 (requires 3 signatures)
- **Signers Needed**: 5 addresses

### Recommended Signers
1. Founder #1
2. Founder #2
3. Core developer #1
4. Core developer #2
5. Advisor

### Signer Addresses (Fill in)
```
Signer 1: 0x________________________________
Signer 2: 0x________________________________
Signer 3: 0x________________________________
Signer 4: 0x________________________________
Signer 5: 0x________________________________
```

### Setup Steps
1. Go to https://app.safe.global/
2. Select "Sepolia" network
3. Click "Create New Safe"
4. Name: "Velirion Team - Sepolia"
5. Add 5 signer addresses
6. Set threshold: 3
7. Review and deploy
8. Save Safe address: `0x________________________________`

---

## 🎯 Safe #4: Liquidity Wallet

### Configuration
- **Purpose**: DEX liquidity provision
- **Allocation**: 10,000,000 VLR (10%)
- **Threshold**: 2-of-3 (requires 2 signatures)
- **Signers Needed**: 3 addresses

### Recommended Signers
1. Treasury manager #1
2. Treasury manager #2
3. Core team member

### Signer Addresses (Fill in)
```
Signer 1: 0x________________________________
Signer 2: 0x________________________________
Signer 3: 0x________________________________
```

### Setup Steps
1. Go to https://app.safe.global/
2. Select "Sepolia" network
3. Click "Create New Safe"
4. Name: "Velirion Liquidity - Sepolia"
5. Add 3 signer addresses
6. Set threshold: 2
7. Review and deploy
8. Save Safe address: `0x________________________________`

---

## 📝 After Creating All Safes

### Update .env File
```env
# Multi-Sig Wallets (Sepolia Testnet)
DAO_TREASURY_SAFE=0x________________________________
MARKETING_WALLET_SAFE=0x________________________________
TEAM_WALLET_SAFE=0x________________________________
LIQUIDITY_WALLET_SAFE=0x________________________________
```

### Update Deployment Script
The `deploy_complete.ts` script will use these addresses for token allocation.

### Test Safe Functionality
1. Send small amount of testnet ETH to each Safe
2. Create test transaction
3. Approve with required signers
4. Execute transaction
5. Verify all Safes working correctly

---

## 🔒 Security Best Practices

### Signer Selection
- ✅ Use trusted individuals only
- ✅ Geographic distribution (different locations)
- ✅ Different devices/wallets
- ✅ Hardware wallets recommended
- ✅ Backup access methods

### Operational Security
- ✅ Never share private keys
- ✅ Use hardware wallets for mainnet
- ✅ Test on testnet first
- ✅ Document all signers
- ✅ Regular security reviews

### Emergency Procedures
- ✅ Document emergency contacts
- ✅ Backup signer access
- ✅ Recovery procedures
- ✅ Incident response plan

---

## 📊 Safe Summary Table

| Safe | Purpose | Allocation | Threshold | Signers | Address |
|------|---------|------------|-----------|---------|---------|
| DAO Treasury | Governance | 5M VLR | 3-of-5 | 5 | 0x... |
| Marketing | Growth | 15M VLR | 2-of-3 | 3 | 0x... |
| Team | Team funds | 15M VLR | 3-of-5 | 5 | 0x... |
| Liquidity | DEX LP | 10M VLR | 2-of-3 | 3 | 0x... |

---

## 🚀 Quick Start (If Using Test Addresses)

If you don't have signer addresses yet, you can use test addresses for Sepolia:

### Option 1: Use Deployer as All Signers (Testing Only)
```env
# WARNING: Only for testnet testing!
DAO_TREASURY_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62
MARKETING_WALLET_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62
TEAM_WALLET_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62
LIQUIDITY_WALLET_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62
```

### Option 2: Generate Test Addresses
```bash
# Generate 5 test addresses
npx hardhat run scripts/generate_test_addresses.ts
```

---

## 📋 Checklist

### Pre-Creation
- [ ] Identified all signer addresses
- [ ] Verified signers have Sepolia wallets
- [ ] Documented signer roles
- [ ] Reviewed threshold requirements

### Creation
- [ ] Created DAO Treasury Safe
- [ ] Created Marketing Safe
- [ ] Created Team Safe
- [ ] Created Liquidity Safe
- [ ] Documented all Safe addresses

### Post-Creation
- [ ] Updated .env file
- [ ] Tested Safe functionality
- [ ] Verified all signers can access
- [ ] Documented in project files

### Ready for Deployment
- [ ] All Safes created
- [ ] All addresses in .env
- [ ] All Safes tested
- [ ] Ready to deploy contracts

---

## 🔗 Resources

- Gnosis Safe App: https://app.safe.global/
- Gnosis Safe Docs: https://docs.safe.global/
- Sepolia Etherscan: https://sepolia.etherscan.io/

---

**Status**: Ready to create  
**Network**: Sepolia Testnet  
**Next Step**: Identify signer addresses and create Safes
