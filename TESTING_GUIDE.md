# 🧪 Velirion Integration Testing Guide

**Network**: Sepolia Testnet  
**Status**: Ready for Testing  
**Last Updated**: October 29, 2025

---

## 📋 Overview

This guide provides step-by-step instructions for testing all Velirion smart contracts deployed on Sepolia testnet.

### Deployed Contracts

All contracts are verified on Sepolia Etherscan:

| Contract | Address | Etherscan |
|----------|---------|-----------|
| VLR Token | `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9` | [View](https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9) |
| Presale | `0xAF8021201524b1E487350F48D5609dFE7ecBb529` | [View](https://sepolia.etherscan.io/address/0xAF8021201524b1E487350F48D5609dFE7ecBb529) |
| Referral | `0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8` | [View](https://sepolia.etherscan.io/address/0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8) |
| Staking | `0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F` | [View](https://sepolia.etherscan.io/address/0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F) |
| DAO | `0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE` | [View](https://sepolia.etherscan.io/address/0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE) |
| Treasury | `0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1` | [View](https://sepolia.etherscan.io/address/0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1) |
| Referral NFT | `0x11aC4D9569a4F51C3c00529931b54d55335cE3b4` | [View](https://sepolia.etherscan.io/address/0x11aC4D9569a4F51C3c00529931b54d55335cE3b4) |
| Guardian NFT | `0x0baF2aca6044dCb120034E278Ba651F048658C19` | [View](https://sepolia.etherscan.io/address/0x0baF2aca6044dCb120034E278Ba651F048658C19) |

---

## 🚀 Quick Start

### Prerequisites

1. **Sepolia ETH**: Get testnet ETH from [Sepolia Faucet](https://sepoliafaucet.com/)
2. **MetaMask**: Configure for Sepolia network
3. **Node.js**: Ensure you have Node.js installed

### Run All Tests

```bash
# Run comprehensive integration tests
npx hardhat run scripts/integration-test.js --network sepolia
```

This will test:
- ✅ Token functionality
- ✅ Presale operations
- ✅ Referral system
- ✅ Staking tiers
- ✅ DAO governance
- ✅ Treasury
- ✅ NFT contracts

---

## 🧪 Individual Test Scripts

### 1. Presale Testing

Test token purchases with ETH, USDT, and USDC:

```bash
npx hardhat run scripts/test-presale.js --network sepolia
```

**What it tests:**
- ✅ Purchase with ETH
- ✅ Purchase with USDT
- ✅ Purchase with USDC
- ✅ Token distribution
- ✅ Referral bonus distribution

**Expected Results:**
- Tokens received in buyer's wallet
- Correct token amounts based on price
- Referral bonuses distributed (if referrer provided)

---

### 2. Staking Testing

Test staking functionality across all tiers:

```bash
npx hardhat run scripts/test-staking.js --network sepolia
```

**What it tests:**
- ✅ Stake tokens (30/90/180/365 days)
- ✅ Reward calculation
- ✅ Tier information
- ✅ Total staked tracking

**Staking Tiers:**
- **Flexible**: 6% APR, No lock, Min: 100 VLR
- **Medium**: 12–15% APR, 90–180 days, Min: 1,000 VLR
- **Long**: 20–22% APR, 365 days, Min: 5,000 VLR
- **Elite**: 30–32% APR, 730 days, Min: 250,000 VLR

**Expected Results:**
- Tokens locked in staking contract
- Rewards calculated correctly
- Can unstake after period ends

---

### 3. Referral Testing

Test referral registration and bonus system:

```bash
npx hardhat run scripts/test-referral.js --network sepolia
```

**What it tests:**
- ✅ User registration
- ✅ Referral code generation
- ✅ Multi-level referrals (2 levels)
- ✅ Referral statistics
- ✅ NFT tier eligibility

**Referral Tiers:**
- **Bronze**: 10+ referrals
- **Silver**: 50+ referrals
- **Gold**: 100+ referrals

**Expected Results:**
- Users registered with unique codes
- Referral relationships tracked
- Stats updated correctly

---

### 4. DAO Testing

Test governance proposal and voting:

```bash
npx hardhat run scripts/test-dao.js --network sepolia
```

**What it tests:**
- ✅ Proposal creation
- ✅ Voting mechanism
- ✅ Quorum calculation
- ✅ Proposal execution
- ✅ Proposal states

**DAO Parameters:**
- **Voting Period**: 7 days
- **Quorum**: 100,000 VLR
- **Proposal Threshold**: 10,000 VLR

**Expected Results:**
- Proposals created successfully
- Votes counted correctly
- Quorum tracked accurately
- Proposals executable after voting period

---

## 🔍 Manual Testing via Etherscan

You can also test directly through Etherscan's contract interface:

### Token Transfer Test

1. Go to [VLR Token on Etherscan](https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9#writeContract)
2. Connect your wallet
3. Use `transfer` function to send tokens
4. Verify transfer succeeds (note: no automatic burn on Ethereum VLR; 0.5% auto-burn applies to the Solana SPL token)

### Presale Purchase Test

1. Go to [Presale Contract](https://sepolia.etherscan.io/address/0xAF8021201524b1E487350F48D5609dFE7ecBb529#writeContract)
2. Connect your wallet
3. Use `buyWithETH` with some ETH value
4. Check your VLR balance increases

### Staking Test

1. First approve tokens: Go to [VLR Token](https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9#writeContract)
2. Call `approve` with Staking address and amount
3. Go to [Staking Contract](https://sepolia.etherscan.io/address/0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F#writeContract)
4. Call `stake` with amount and duration (30/90/180/365)

---

## ✅ Testing Checklist

### Phase 1: Basic Functionality
- [ ] Token transfers work
- [ ] 0.5% burn on transfers
- [ ] Presale purchases (ETH)
- [ ] Presale purchases (USDT)
- [ ] Presale purchases (USDC)

### Phase 2: Advanced Features
- [ ] Referral registration
- [ ] Referral bonus distribution
- [ ] Multi-level referrals
- [ ] Staking (30 days)
- [ ] Staking (90 days)
- [ ] Staking (180 days)
- [ ] Staking (365 days)
- [ ] Reward calculations

### Phase 3: Governance
- [ ] DAO proposal creation
- [ ] Voting on proposals
- [ ] Quorum tracking
- [ ] Proposal execution
- [ ] Treasury operations

### Phase 4: NFTs
- [ ] Referral NFT minting
- [ ] Guardian NFT minting
- [ ] NFT tier upgrades
- [ ] NFT metadata display

---

## 🐛 Common Issues & Solutions

### Issue: "Insufficient balance"
**Solution**: Get Sepolia ETH from faucet or purchase VLR tokens from presale first.

### Issue: "Presale not active"
**Solution**: Owner needs to call `startPresale(durationSeconds)` (or `startPhase(phaseId, durationSeconds)`) to activate a phase.

### Issue: "Insufficient allowance"
**Solution**: Approve tokens before staking or other operations that transfer tokens.

### Issue: "Voting period not ended"
**Solution**: Wait for the 7-day voting period to complete before executing proposals.

### Issue: "Below minimum stake"
**Solution**: Check tier requirements and stake at least the minimum amount.

---

## 📊 Test Results Template

Use this template to document your test results:

```markdown
## Test Session: [Date]
**Tester**: [Your Name]
**Network**: Sepolia
**Wallet**: [Your Address]

### Token Tests
- [ ] Transfer: ✅/❌ [Tx Hash]
- [ ] Burn: ✅/❌ [Tx Hash]

### Presale Tests
- [ ] Buy with ETH: ✅/❌ [Tx Hash]
- [ ] Buy with USDT: ✅/❌ [Tx Hash]
- [ ] Buy with USDC: ✅/❌ [Tx Hash]

### Staking Tests
- [ ] Stake 30d: ✅/❌ [Tx Hash]
- [ ] Stake 90d: ✅/❌ [Tx Hash]
- [ ] Rewards: ✅/❌ [Amount]

### Referral Tests
- [ ] Register: ✅/❌ [Tx Hash]
- [ ] Refer user: ✅/❌ [Tx Hash]
- [ ] Bonus received: ✅/❌ [Amount]

### DAO Tests
- [ ] Create proposal: ✅/❌ [Tx Hash]
- [ ] Vote: ✅/❌ [Tx Hash]
- [ ] Execute: ✅/❌ [Tx Hash]

### Issues Found
1. [Issue description]
2. [Issue description]

### Notes
[Any additional observations]
```

---

## 🔗 Useful Links

- **Sepolia Faucet**: https://sepoliafaucet.com/
- **Sepolia Explorer**: https://sepolia.etherscan.io/
- **Deployment Info**: `deployment-sepolia.json`
- **Project Docs**: `docs/` folder

---

## 📞 Support

If you encounter any issues during testing:

1. Check the error message in the transaction
2. Review the contract on Etherscan
3. Check the test script logs
4. Document the issue with transaction hash

---

## 🎯 Next Steps After Testing

1. **Document Issues**: Record all bugs and issues found
2. **Fix Critical Bugs**: Address any critical issues
3. **Community Testing**: Invite community members to test
4. **Security Audit**: Prepare for professional audit
5. **Mainnet Deployment**: Plan mainnet launch

---

**Happy Testing! 🚀**
