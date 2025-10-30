# 🚀 Velirion Phase 2: Complete Deployment & Integration Guide

**Document Version**: 2.0  
**Created**: October 27, 2025  
**Status**: 📋 **COMPREHENSIVE DEPLOYMENT PLAN**  
**Phase**: Production Deployment to Testnet & Mainnet

---

## 📊 Executive Summary

This document provides a complete roadmap for deploying the Velirion smart contract ecosystem from current state (100% complete on localhost) to production deployment on both Ethereum and Solana networks.

### Current Status
- ✅ **All 5 Milestones Complete** (180+ tests passing)
- ✅ **10 Core Contracts** deployed and tested on localhost
- ✅ **Complete Integration** verified
- ⏳ **Testnet Deployment** - Ready to begin
- ⏳ **Mainnet Deployment** - Pending audit

---

## 🎯 Phase 2 Objectives

### Primary Goals
1. **Deploy to Sepolia Testnet** - Full ecosystem testing
2. **Deploy to Solana Devnet** - SPL token testing
3. **Community Testing Period** - 2-4 weeks
4. **Security Audit** - External professional audit
5. **Mainnet Deployment** - Production launch
6. **Backend Integration** - API and frontend connectivity

### Success Metrics
- ✅ All contracts verified on Etherscan/Solscan
- ✅ 100+ community test transactions
- ✅ Zero critical vulnerabilities found
- ✅ Complete API documentation
- ✅ Frontend integration complete

---

## 📁 Project Architecture Overview

### Ethereum Contracts (10 Contracts)

```
contracts/
├── core/
│   ├── VelirionToken.sol           ✅ ERC-20 Token (100M supply)
│   ├── VelirionReferral.sol        ✅ 4-tier referral system
│   └── VelirionStaking.sol         ✅ 4-tier staking (6%-32% APR)
│
├── presale/
│   └── PresaleContractV2.sol       ✅ 10-phase presale with vesting
│
├── governance/
│   ├── VelirionDAO.sol             ✅ Burn-to-vote governance
│   ├── VelirionTimelock.sol        ✅ 2-day execution delay
│   └── VelirionTreasury.sol        ✅ Multi-sig treasury
│
├── nft/
│   ├── VelirionReferralNFT.sol     ✅ Tiered referral badges
│   └── VelirionGuardianNFT.sol     ✅ Elite staker NFT
│
└── mocks/
    └── MockERC20.sol               ✅ Test USDT/USDC
```

### Solana Program (1 Program)

```
solana/programs/velirion-spl/
└── src/
    └── lib.rs                      ✅ SPL token with 0.5% burn
```

---

## 🗓️ Phase 2 Timeline (8 Weeks)

### Week 1-2: Testnet Preparation & Deployment
- Days 1-2: Environment setup & wallet creation
- Days 3-4: Sepolia deployment
- Days 5-7: Solana Devnet deployment
- Days 8-14: Initial testing & bug fixes

### Week 3-4: Community Testing
- Days 15-21: Public testnet testing
- Days 22-28: Feedback collection & fixes

### Week 5-6: Security Audit
- Days 29-35: External security audit
- Days 36-42: Audit fixes & re-testing

### Week 7-8: Mainnet Preparation & Launch
- Days 43-49: Mainnet deployment prep
- Days 50-56: Mainnet deployment & launch

---

## 📋 STEP 1: Pre-Deployment Preparation

### 1.1 Create Gnosis Safe Multi-Sig Wallets

**Required Wallets (4 total for Sepolia)**:

1. **DAO Treasury Wallet** - 5M VLR (3-of-5 signers)
2. **Marketing Wallet** - 15M VLR (2-of-3 signers)
3. **Team Wallet** - 15M VLR (3-of-5 signers)
4. **Liquidity Wallet** - 10M VLR (2-of-3 signers)

**Setup Instructions**:
```bash
# Visit: https://app.safe.global/
# Select Network: Sepolia
# Create New Safe
# Add Signer Addresses
# Set Threshold
# Deploy Safe
# Save Safe Address to .env
```

### 1.2 Prepare Deployer Wallet

**Get Sepolia ETH (~0.5 ETH needed)**:
- Alchemy Faucet: https://sepoliafaucet.com/
- Infura Faucet: https://www.infura.io/faucet/sepolia
- Chainlink Faucet: https://faucets.chain.link/sepolia

### 1.3 Environment Configuration

**Update `.env` file**:
```env
# Network RPCs
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
ETHEREUM_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY

# Deployer (NEW SECURE WALLET)
PRIVATE_KEY=your_new_secure_private_key_here

# API Keys
ETHERSCAN_API_KEY=your_etherscan_api_key

# Multi-Sig Wallets (Sepolia)
DAO_TREASURY_SAFE=0x...
MARKETING_WALLET_SAFE=0x...
TEAM_WALLET_SAFE=0x...
LIQUIDITY_WALLET_SAFE=0x...

# Chainlink Price Feed (Sepolia)
ETH_USD_PRICE_FEED=0x694AA1769357215DE4FAC081bf1f309aDC325306
```

### 1.4 IPFS Setup for NFT Metadata

**Create Pinata Account**: https://pinata.cloud/

**Prepare NFT Metadata**:
- Bronze Badge (10+ referrals)
- Silver Badge (25+ referrals)
- Gold Badge (50+ referrals)
- Guardian NFT (250K+ VLR Elite stake)

Upload images and metadata to IPFS, save base URIs for deployment.

---

## 📋 STEP 2: Sepolia Testnet Deployment

### 2.1 Pre-Deployment Checks

```bash
# Verify environment
npx hardhat console --network sepolia

# Check deployer balance
const [deployer] = await ethers.getSigners();
console.log("Deployer:", deployer.address);
console.log("Balance:", ethers.utils.formatEther(await ethers.provider.getBalance(deployer.address)));
```

### 2.2 Deploy Complete Ecosystem

```bash
# Run complete deployment script
npx hardhat run scripts/deploy_complete.ts --network sepolia

# This deploys all 10 contracts in order:
# 1. VelirionToken
# 2. Mock USDT & USDC
# 3. PresaleContractV2
# 4. VelirionReferral
# 5. VelirionStaking
# 6. VelirionTimelock
# 7. VelirionDAO
# 8. VelirionTreasury
# 9. VelirionReferralNFT
# 10. VelirionGuardianNFT

# Expected duration: 10-15 minutes
# Gas cost: ~0.3-0.4 ETH
```

### 2.3 Verify All Contracts on Etherscan

```bash
# Verify each contract
npx hardhat verify --network sepolia <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>

# Or use automated verification script
npx hardhat run scripts/verify_all.ts --network sepolia
```

### 2.4 Document Deployment

Create `SEPOLIA_DEPLOYMENT.md` with all contract addresses and Etherscan links.

---

## 📋 STEP 3: Solana Devnet Deployment

### 3.1 Install Solana Tools

**Windows Installation**:
```powershell
# Install Solana CLI
curl https://release.solana.com/v1.17.0/solana-install-init-x86_64-pc-windows-msvc.exe --output solana-install.exe
.\solana-install.exe

# Add to PATH
$env:PATH += ";$env:USERPROFILE\.local\share\solana\install\active_release\bin"

# Verify
solana --version
```

**Install Anchor CLI (version 0.30.1)**:
```bash
# Install AVM
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force

# Install Anchor 0.30.1
avm install 0.30.1
avm use 0.30.1

# Verify
anchor --version
```

### 3.2 Configure Solana

```bash
# Set to devnet
solana config set --url devnet

# Create keypair
solana-keygen new --outfile ~/.config/solana/id.json

# Request airdrop (2 SOL)
solana airdrop 2

# Check balance
solana balance
```

### 3.3 Deploy Solana Program

```bash
cd solana

# Build program
anchor build

# Get program ID
solana address -k target/deploy/velirion_spl-keypair.json

# Update program ID in lib.rs and Anchor.toml
# Then rebuild
anchor build

# Deploy to devnet
anchor deploy --provider.cluster devnet

# Verify deployment
solana program show <PROGRAM_ID> --url devnet
```

### 3.4 Initialize SPL Token

```bash
# Run initialization script
cd solana/scripts
ts-node deploy.ts

# This will:
# - Initialize token mint
# - Mint 100M tokens
# - Set up burn mechanism
```

### 3.5 Test Solana Integration

```bash
cd solana
anchor test --skip-local-validator

# Expected: 16 tests passing
```

---

## 📋 STEP 4: Integration Testing

### 4.1 Test Scenarios

**Ethereum Testnet Testing**:

1. **Token Operations** - Transfer, burn, check balances
2. **Presale Flow** - Buy with ETH/USDT/USDC, check vesting, claim tokens
3. **Referral System** - Register, purchase with referral, claim rewards, tier upgrades
4. **Staking System** - Stake all tiers, claim rewards, test penalties, test renewals
5. **DAO Governance** - Create proposal, vote, execute, test timelock
6. **NFT Rewards** - Mint referral NFTs, mint Guardian NFT, verify metadata

### 4.2 Create Test Scripts

Create `scripts/test_integration.ts` to automate testing of all flows.

---

## 📋 STEP 5: Backend Integration

### 5.1 API Endpoints Required

**Contract Interaction API**:
- `GET /api/contracts/addresses` - Get all contract addresses
- `GET /api/presale/current-phase` - Get current presale phase info
- `POST /api/presale/buy` - Execute presale purchase
- `GET /api/referral/stats/:address` - Get referral statistics
- `GET /api/staking/user/:address` - Get user staking info
- `GET /api/dao/proposals` - Get all DAO proposals

### 5.2 Web3 Integration

**React/Next.js Integration**:
- Create hooks for contract interactions
- Implement wallet connection (MetaMask, WalletConnect)
- Build UI components for presale, staking, governance
- Integrate Web3 libraries (ethers.js, wagmi, etc.)

### 5.3 Subgraph (Optional)

Deploy The Graph subgraph for efficient data querying and indexing.

---

## 📋 STEP 6: Security Audit

### 6.1 Internal Security Review

**Checklist**:
- [ ] All 180+ tests passing
- [ ] No compiler warnings
- [ ] Gas optimization reviewed
- [ ] Access control verified
- [ ] Reentrancy protection confirmed
- [ ] Emergency pause tested

### 6.2 External Security Audit

**Recommended Audit Firms**:
1. **OpenZeppelin** - $30K-$50K, 3-4 weeks
2. **Trail of Bits** - $40K-$60K, 4-6 weeks
3. **Consensys Diligence** - $35K-$55K, 3-5 weeks
4. **CertiK** - $25K-$45K, 2-4 weeks

**Audit Scope**: All 10 smart contracts, integration points, economic model

### 6.3 Bug Bounty Program

Launch post-audit with rewards:
- Critical: $10K-$50K
- High: $5K-$10K
- Medium: $1K-$5K
- Low: $100-$1K

---

## 📋 STEP 7: Mainnet Deployment

### 7.1 Pre-Mainnet Checklist

**Critical Requirements**:
- [ ] Security audit complete
- [ ] All audit issues resolved
- [ ] Testnet testing complete (2+ weeks)
- [ ] Community feedback addressed
- [ ] Legal compliance reviewed
- [ ] Multi-sig wallets created (mainnet)
- [ ] Emergency procedures documented
- [ ] Monitoring systems ready

### 7.2 Mainnet Multi-Sig Setup

**Create NEW Gnosis Safe wallets on Ethereum Mainnet**:
1. DAO Treasury Safe (5 signers, 3-of-5)
2. Marketing Safe (3 signers, 2-of-3)
3. Team Safe (5 signers, 3-of-5)
4. Liquidity Safe (3 signers, 2-of-3)

### 7.3 Mainnet Deployment

```bash
# ⚠️ CRITICAL: Use NEW secure wallet
# Fund with ~2-3 ETH for gas

# Update .env with mainnet settings
ETHEREUM_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
PRIVATE_KEY=your_new_mainnet_deployer_key

# Deploy to mainnet
npx hardhat run scripts/deploy_complete.ts --network mainnet

# Expected gas cost: ~0.8-1.2 ETH
# Duration: 15-20 minutes
```

### 7.4 Post-Deployment Actions

**Immediate**:
1. Verify all contracts on Etherscan
2. Transfer ownership to multi-sigs
3. Renounce deployer privileges
4. Update website with addresses
5. Announce deployment

**Within 24 Hours**:
1. Initialize presale Phase 1
2. Enable staking
3. Set up monitoring alerts
4. Deploy frontend updates
5. Begin marketing campaign

**Within 1 Week**:
1. List on DEX (Uniswap)
2. Apply for CoinGecko listing
3. Apply for CoinMarketCap listing
4. Begin community onboarding
5. Launch referral program

---

## 📋 STEP 8: Monitoring & Maintenance

### 8.1 Monitoring Setup

**Tools**:
1. **Tenderly** - Real-time transaction monitoring
2. **OpenZeppelin Defender** - Automated security monitoring
3. **Custom Alerts** - Discord/Telegram notifications

### 8.2 Maintenance Tasks

**Daily**:
- Monitor contract activity
- Check for unusual transactions
- Review gas prices
- Update presale phases

**Weekly**:
- Review staking statistics
- Check DAO proposals
- Analyze referral program
- Update documentation

**Monthly**:
- Security review
- Performance optimization
- Community feedback review
- Token burn events

---

## 📊 Success Metrics & KPIs

### Phase 2 Success Criteria

**Testnet Phase**:
- [ ] 100+ test transactions
- [ ] 50+ unique testers
- [ ] All features tested
- [ ] Zero critical bugs

**Audit Phase**:
- [ ] Audit complete
- [ ] All issues resolved
- [ ] Re-audit passed
- [ ] Bug bounty launched

**Mainnet Phase**:
- [ ] Successful deployment
- [ ] All contracts verified
- [ ] Ownership transferred
- [ ] Monitoring active

### Long-term KPIs

**Token Metrics**:
- Total Value Locked (TVL)
- Token holders
- Daily active users
- Burn rate

**Presale Metrics**:
- Funds raised
- Participants
- Average purchase size
- Phase completion rate

**Staking Metrics**:
- Total staked
- Average stake duration
- Tier distribution
- Renewal rate

**Referral Metrics**:
- Active referrers
- Referral conversion rate
- Average referrals per user
- Bonus distribution

**DAO Metrics**:
- Proposals created
- Voting participation
- Proposal success rate
- Treasury balance

---

## 📚 Additional Resources

### Documentation
- [Project Progress](PROJECT_PROGRESS.md)
- [Milestone 5 Complete](MILESTONE_5_COMPLETE.md)
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- [Integration Guide](docs/milestone%203/INTEGRATION_GUIDE.md)

### Contract Addresses
- Localhost: `deployment-complete.json`
- Sepolia: `deployment-sepolia.json` (to be created)
- Mainnet: `deployment-mainnet.json` (to be created)

### Support
- Technical Issues: GitHub Issues
- Community: Discord/Telegram
- Security: security@velirion.io

---

## ✅ Phase 2 Completion Checklist

### Pre-Deployment
- [ ] Multi-sig wallets created
- [ ] Deployer wallet funded
- [ ] Environment configured
- [ ] IPFS metadata uploaded

### Testnet Deployment
- [ ] Sepolia deployment complete
- [ ] All contracts verified
- [ ] Solana Devnet deployed
- [ ] Integration testing passed

### Security
- [ ] Internal review complete
- [ ] External audit complete
- [ ] Bug bounty launched
- [ ] Emergency procedures tested

### Mainnet Deployment
- [ ] Mainnet multi-sigs created
- [ ] Mainnet deployment complete
- [ ] Ownership transferred
- [ ] Monitoring active

### Launch
- [ ] Frontend deployed
- [ ] API endpoints live
- [ ] Marketing campaign launched
- [ ] Community onboarding started

---

**Document Version**: 2.0  
**Last Updated**: October 27, 2025  
**Status**: Ready for Phase 2 Implementation  
**Estimated Completion**: 8 weeks from start

---

**🎉 All systems are GO for Phase 2 deployment!**
