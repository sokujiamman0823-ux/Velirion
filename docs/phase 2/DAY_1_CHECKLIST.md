# ✅ Day 1 Checklist: Phase 2 Kickoff

**Date**: October 27, 2025  
**Goal**: Verify environment and prepare for Sepolia deployment  
**Duration**: 2-4 hours

---

## 🎯 Objectives

1. Verify all development tools are working
2. Test Sepolia RPC connection
3. Get testnet ETH
4. Identify multi-sig signers
5. Plan NFT assets

---

## ✅ Task List

### 1. Environment Verification

**Check Node.js & npm**:
```bash
node --version  # Should be v16+ 
npm --version   # Should be v8+
```
- [ ] Node.js installed and working
- [ ] npm installed and working

**Check Hardhat**:
```bash
cd "e:\Charanos\Documents\Andishi Software LTD\Docs\Clients\velirion-sc"
npx hardhat --version
```
- [ ] Hardhat installed (v2.26.3)
- [ ] All dependencies installed

**Check TypeScript**:
```bash
npx tsc --version
```
- [ ] TypeScript installed (v5.8.0)

---

### 2. Sepolia RPC Connection Test

**Test RPC URL**:
```bash
# In Hardhat console
npx hardhat console --network sepolia

# Then run:
const blockNumber = await ethers.provider.getBlockNumber();
console.log("Current block:", blockNumber);

const network = await ethers.provider.getNetwork();
console.log("Network:", network.name, "Chain ID:", network.chainId);
```

**Expected Output**:
- Network: sepolia
- Chain ID: 11155111
- Block number: Current block (should be > 5,000,000)

**Checklist**:
- [ ] Sepolia RPC URL working
- [ ] Can connect to network
- [ ] Can read blockchain data

---

### 3. Deployer Wallet Check

**Check wallet balance**:
```bash
# In Hardhat console
const [deployer] = await ethers.getSigners();
console.log("Deployer address:", deployer.address);

const balance = await ethers.provider.getBalance(deployer.address);
console.log("Balance:", ethers.utils.formatEther(balance), "ETH");
```

**Current Deployer**: 
- Address: (derived from PRIVATE_KEY in .env)
- Balance: ? ETH

**Required**: 0.5 ETH for deployment

**Checklist**:
- [ ] Deployer wallet accessible
- [ ] Balance checked
- [ ] Need to get testnet ETH: YES/NO

---

### 4. Get Sepolia Testnet ETH

**If balance < 0.5 ETH, use faucets**:

**Faucet #1: Alchemy**
- URL: https://sepoliafaucet.com/
- Amount: 0.1-0.5 ETH
- Requirements: Alchemy account
- [ ] Requested from Alchemy

**Faucet #2: Infura**
- URL: https://www.infura.io/faucet/sepolia
- Amount: 0.1 ETH
- Requirements: Infura account
- [ ] Requested from Infura

**Faucet #3: Chainlink**
- URL: https://faucets.chain.link/sepolia
- Amount: 0.1 ETH
- Requirements: Twitter/GitHub
- [ ] Requested from Chainlink

**Faucet #4: QuickNode**
- URL: https://faucet.quicknode.com/ethereum/sepolia
- Amount: 0.05 ETH
- [ ] Requested from QuickNode

**Alternative**: Transfer from another wallet
- [ ] Transferred from: _____________

**Final Balance Check**:
- [ ] Have at least 0.5 ETH
- Current balance: _______ ETH

---

### 5. Etherscan API Verification

**Test Etherscan API**:
```bash
# Check if API key works
curl "https://api-sepolia.etherscan.io/api?module=block&action=getblocknobytime&timestamp=1578638524&closest=before&apikey=W1H3ZWBK8DSV4JUDJKXNJG3IA7D5YN3A6G"
```

**Expected**: JSON response with block data

**Checklist**:
- [ ] Etherscan API key working
- [ ] Can verify contracts

---

### 6. Multi-Sig Signer Identification

**Need to identify 5-7 trusted addresses for Gnosis Safe wallets**:

**DAO Treasury Safe (3-of-5)**:
1. [ ] Signer 1: _________________ (Name: _________)
2. [ ] Signer 2: _________________ (Name: _________)
3. [ ] Signer 3: _________________ (Name: _________)
4. [ ] Signer 4: _________________ (Name: _________)
5. [ ] Signer 5: _________________ (Name: _________)

**Marketing Safe (2-of-3)**:
1. [ ] Signer 1: _________________ (Name: _________)
2. [ ] Signer 2: _________________ (Name: _________)
3. [ ] Signer 3: _________________ (Name: _________)

**Team Safe (3-of-5)**:
1. [ ] Signer 1: _________________ (Name: _________)
2. [ ] Signer 2: _________________ (Name: _________)
3. [ ] Signer 3: _________________ (Name: _________)
4. [ ] Signer 4: _________________ (Name: _________)
5. [ ] Signer 5: _________________ (Name: _________)

**Liquidity Safe (2-of-3)**:
1. [ ] Signer 1: _________________ (Name: _________)
2. [ ] Signer 2: _________________ (Name: _________)
3. [ ] Signer 3: _________________ (Name: _________)

**Note**: Can use same addresses across different Safes if needed

---

### 7. NFT Asset Planning

**Need 4 NFT images**:

**Referral NFT Badges**:
- [ ] Bronze Badge design (10+ referrals)
  - Style: _________________
  - Designer: _________________
  - Status: Not started / In progress / Complete
  
- [ ] Silver Badge design (25+ referrals)
  - Style: _________________
  - Designer: _________________
  - Status: Not started / In progress / Complete
  
- [ ] Gold Badge design (50+ referrals)
  - Style: _________________
  - Designer: _________________
  - Status: Not started / In progress / Complete

**Guardian NFT**:
- [ ] Guardian NFT design (Elite stakers)
  - Style: _________________
  - Designer: _________________
  - Status: Not started / In progress / Complete

**Options**:
1. Design in-house
2. Commission from designer
3. Use AI generation (Midjourney, DALL-E)
4. Use placeholder images for testnet

**Decision**: _________________

---

### 8. Pinata Account Setup

**Create IPFS hosting account**:
- [ ] Go to https://pinata.cloud/
- [ ] Sign up for free account
- [ ] Verify email
- [ ] Get API keys
- [ ] Save credentials securely

**Account Details**:
- Email: _________________
- API Key: _________________
- API Secret: _________________

---

### 9. Review Deployment Scripts

**Check deployment script**:
```bash
# Review the main deployment script
code scripts/deploy_complete.ts
```

**Verify**:
- [ ] Script exists
- [ ] Constructor parameters correct
- [ ] Multi-sig addresses configurable
- [ ] IPFS URIs configurable
- [ ] Chainlink price feed correct for Sepolia

**Sepolia Chainlink ETH/USD Price Feed**:
- Address: `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- [ ] Confirmed in script

---

### 10. Gas Estimation

**Estimate deployment costs**:

**Expected Gas Usage** (per contract):
- VelirionToken: ~2,000,000 gas
- PresaleContractV2: ~3,500,000 gas
- VelirionReferral: ~2,500,000 gas
- VelirionStaking: ~3,000,000 gas
- VelirionTimelock: ~1,500,000 gas
- VelirionDAO: ~4,000,000 gas
- VelirionTreasury: ~2,000,000 gas
- VelirionReferralNFT: ~2,500,000 gas
- VelirionGuardianNFT: ~2,500,000 gas
- Mock USDT/USDC: ~1,000,000 gas each

**Total**: ~26,000,000 gas

**At 2 gwei** (Sepolia typical): ~0.052 ETH
**At 5 gwei** (safe estimate): ~0.13 ETH
**At 10 gwei** (high): ~0.26 ETH

**Plus verification**: ~0.05 ETH

**Total Estimated**: 0.3-0.4 ETH

**Checklist**:
- [ ] Gas estimation reviewed
- [ ] Have sufficient ETH (0.5+ recommended)

---

### 11. Documentation Review

**Read Phase 2 docs**:
- [ ] PHASE_2_COMPLETE_IMPLEMENTATION_GUIDE.md
- [ ] PHASE_2_TECHNICAL_SPECIFICATIONS.md
- [ ] PHASE_2_EXECUTIVE_SUMMARY.md
- [ ] PHASE_2_IMPLEMENTATION_TRACKER.md

**Understand**:
- [ ] Deployment process
- [ ] Testing requirements
- [ ] Timeline expectations
- [ ] Success criteria

---

### 12. Communication Setup

**Prepare for updates**:
- [ ] Identify stakeholders to update
- [ ] Set up communication channel (Discord/Slack/Email)
- [ ] Prepare daily update template
- [ ] Schedule check-in times

**Stakeholders**:
1. _________________
2. _________________
3. _________________

---

## 🎯 End of Day 1 Goals

**Must Complete**:
- [x] Environment verified
- [ ] Sepolia RPC working
- [ ] Have 0.5+ ETH in deployer wallet
- [ ] Multi-sig signers identified
- [ ] NFT asset plan decided

**Nice to Have**:
- [ ] Pinata account created
- [ ] NFT designs started
- [ ] Deployment script reviewed
- [ ] Team briefed on timeline

---

## 📊 Day 1 Summary

**Completed Tasks**: _____ / 12

**Blockers Identified**:
1. _________________
2. _________________
3. _________________

**Ready for Day 2**: YES / NO

**Notes**:
_________________
_________________
_________________

---

## 🚀 Next Steps (Day 2)

If Day 1 complete:
1. Create 4 Gnosis Safe wallets on Sepolia
2. Test Safe functionality
3. Document Safe addresses
4. Update .env file
5. Begin NFT asset creation

---

**Checklist Created**: October 27, 2025  
**Status**: Ready to execute  
**Estimated Time**: 2-4 hours
