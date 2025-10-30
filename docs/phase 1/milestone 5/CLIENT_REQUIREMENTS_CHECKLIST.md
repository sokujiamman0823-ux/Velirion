# Milestone 5: Client-Provided Requirements Checklist

**Date**: October 22, 2025  
**Status**: Pre-Implementation Planning  
**Purpose**: Document all client-provided information needed for M5 deployment

---

## Overview

For Milestone 5 (DAO + Final Integration + Deployment), you will need to provide specific information for both **testnet** and **mainnet** deployments. This document outlines exactly what's needed and when.

---

## ✅ What You Already Have

Based on your current `.env` file:

- ✅ **Etherscan API Key**: `W1H3ZWBK8DSV4JUDJKXNJG3IA7D5YN3A6G`
- ✅ **Sepolia RPC URL**: Alchemy endpoint configured
- ✅ **Ethereum Mainnet RPC URL**: Alchemy endpoint configured
- ✅ **Private Key**: Deployer wallet configured (for testnet testing)

---

## 🔴 What You Need to Provide

### 1. Multi-Signature Wallet Addresses (CRITICAL)

For production deployment, you need **4 separate Gnosis Safe multi-sig wallets**:

#### A. DAO Treasury Wallet
- **Purpose**: Community governance funds (5M VLR = 5% of supply)
- **Configuration**: 2-of-2 or 3-of-5 multi-sig
- **Network**: Both Sepolia (testnet) and Ethereum Mainnet
- **Required**:
  - [ ] Testnet Gnosis Safe address: `0x...`
  - [ ] Mainnet Gnosis Safe address: `0x...`
  - [ ] Signer addresses (2-5 addresses)

#### B. Marketing Wallet
- **Purpose**: Marketing and growth initiatives (15M VLR = 15% of supply)
- **Configuration**: 2-of-2 or 3-of-5 multi-sig
- **Network**: Both Sepolia and Mainnet
- **Required**:
  - [ ] Testnet address: `0x...`
  - [ ] Mainnet address: `0x...`
  - [ ] Signer addresses

#### C. Team Wallet
- **Purpose**: Team allocation with vesting (15M VLR = 15% of supply)
- **Configuration**: 2-of-2 or 3-of-5 multi-sig
- **Network**: Both Sepolia and Mainnet
- **Required**:
  - [ ] Testnet address: `0x...`
  - [ ] Mainnet address: `0x...`
  - [ ] Signer addresses

#### D. Liquidity Reserve Wallet
- **Purpose**: Exchange liquidity provision (10M VLR = 10% of supply)
- **Configuration**: 2-of-2 or 3-of-5 multi-sig
- **Network**: Both Sepolia and Mainnet
- **Required**:
  - [ ] Testnet address: `0x...`
  - [ ] Mainnet address: `0x...`
  - [ ] Signer addresses

---

### 2. Deployment Wallet (Testnet & Mainnet)

#### Testnet Deployment
- **Current**: You have a private key in `.env` (for local testing)
- **Needed**: 
  - [ ] Confirm if same wallet should be used for Sepolia testnet
  - [ ] Ensure wallet has sufficient Sepolia ETH (~0.5 ETH for all deployments)
  - [ ] Wallet address for documentation: `0x...`

#### Mainnet Deployment
- **Needed**:
  - [ ] **NEW** secure private key for mainnet deployer (DO NOT reuse testnet key)
  - [ ] Wallet address: `0x...`
  - [ ] Sufficient mainnet ETH (~1-2 ETH for deployment + gas)
  - [ ] Confirmation that this wallet will be used ONLY for deployment

---

### 3. Solana Wallet Addresses (For Cross-Chain)

While full Solana integration is post-M5, we need to prepare:

#### Testnet (Devnet)
- [ ] Solana devnet wallet address: `...`
- [ ] Purpose: Testing Solana token deployment

#### Mainnet
- [ ] Solana mainnet wallet address: `...`
- [ ] Purpose: Production Solana token deployment

---

### 4. API Keys & Services

#### Already Configured ✅
- Etherscan API (for contract verification)
- Alchemy RPC endpoints (Ethereum)

#### May Need (Optional)
- [ ] IPFS/Pinata API key (for NFT metadata storage)
- [ ] OpenSea API key (for NFT marketplace integration)
- [ ] Solana RPC endpoint (Alchemy, QuickNode, or custom)

---

## 📋 Deployment Phases & Requirements

### Phase 1: Testnet Deployment (Sepolia)
**Timeline**: During M5 implementation (Days 1-5)  
**Purpose**: Testing and validation

**Required Before Testnet Deploy**:
1. ✅ Sepolia RPC URL (already have)
2. ✅ Etherscan API key (already have)
3. ✅ Deployer wallet with Sepolia ETH (confirm current wallet)
4. 🔴 **4 Gnosis Safe testnet addresses** (DAO, Marketing, Team, Liquidity)

**Not Critical for Testnet**:
- Real funds (using test ETH)
- Production security measures
- Final multi-sig signers

---

### Phase 2: Mainnet Deployment (Production)
**Timeline**: After M5 completion + security audit  
**Purpose**: Production launch

**Required Before Mainnet Deploy**:
1. ✅ Mainnet RPC URL (already have)
2. ✅ Etherscan API key (already have)
3. 🔴 **NEW secure deployer wallet** with mainnet ETH
4. 🔴 **4 Gnosis Safe mainnet addresses** (DAO, Marketing, Team, Liquidity)
5. 🔴 **All multi-sig signer addresses confirmed**
6. 🔴 **Security audit completed**
7. 🔴 **Legal/compliance review** (if applicable)

---

## 🎯 Immediate Action Items

### For Testnet (Needed Soon - Days 1-3 of M5)

1. **Create Gnosis Safe Wallets on Sepolia**:
   - Go to https://app.safe.global/
   - Switch to Sepolia network
   - Create 4 separate Safe wallets
   - Configure 2-of-2 or 3-of-5 multi-sig
   - Share addresses with dev team

2. **Confirm Deployer Wallet**:
   - Verify current testnet wallet is acceptable
   - Ensure it has ~0.5 Sepolia ETH
   - Get Sepolia ETH from faucets if needed

3. **Optional: IPFS Setup**:
   - Create Pinata account (free tier is fine)
   - Get API key for NFT metadata

---

### For Mainnet (Needed Later - After M5 Testing)

1. **Create Production Gnosis Safe Wallets**:
   - Same process as testnet, but on Ethereum mainnet
   - Use production signer addresses
   - Document all signers and their roles

2. **Secure Deployer Wallet**:
   - Generate NEW wallet specifically for mainnet deployment
   - Fund with 1-2 ETH for deployment costs
   - Store private key securely (hardware wallet recommended)
   - **NEVER** reuse testnet private keys

3. **Security Preparations**:
   - Schedule external security audit
   - Prepare incident response plan
   - Set up monitoring and alerts

---

## 💡 Recommendations

### Multi-Sig Configuration

**For Testnet**:
- 2-of-2 is fine for testing
- Can use team member wallets

**For Mainnet**:
- Recommend 3-of-5 for better security
- Distribute signers across:
  - Core team members (2-3)
  - Trusted advisors (1-2)
  - Community representatives (0-1)

### Wallet Security Best Practices

1. **Hardware Wallets**: Use Ledger/Trezor for mainnet signers
2. **Separate Wallets**: Never mix testnet and mainnet keys
3. **Backup**: Secure backup of all seed phrases
4. **Access Control**: Limit who has access to private keys
5. **Testing**: Test all multi-sig operations on testnet first

---

## 📊 Token Allocation Summary

Once deployed, tokens will be distributed as follows:

| Wallet Type | Amount | Percentage | Multi-Sig Required |
|-------------|--------|------------|-------------------|
| Presale Contract | 30M VLR | 30% | No (smart contract) |
| Staking Rewards | 20M VLR | 20% | No (smart contract) |
| Marketing Wallet | 15M VLR | 15% | ✅ Yes |
| Team Wallet | 15M VLR | 15% | ✅ Yes (vested) |
| Liquidity Wallet | 10M VLR | 10% | ✅ Yes |
| Referral Rewards | 5M VLR | 5% | No (smart contract) |
| DAO Treasury | 5M VLR | 5% | ✅ Yes |
| **Total** | **100M VLR** | **100%** | |

---

## ✅ Quick Checklist

### Before Starting M5 Implementation:
- [ ] Confirm current testnet deployer wallet is acceptable
- [ ] Ensure testnet wallet has sufficient Sepolia ETH

### During M5 Implementation (Days 1-5):
- [ ] Create 4 Gnosis Safe wallets on Sepolia testnet
- [ ] Provide testnet wallet addresses to dev team
- [ ] (Optional) Set up IPFS/Pinata for NFT metadata

### Before Mainnet Deployment (After M5):
- [ ] Create 4 Gnosis Safe wallets on Ethereum mainnet
- [ ] Generate NEW secure deployer wallet for mainnet
- [ ] Fund mainnet deployer wallet with 1-2 ETH
- [ ] Confirm all multi-sig signers
- [ ] Complete security audit
- [ ] Review and approve deployment plan

---

## 🔐 Security Notes

### What NOT to Share Publicly:
- ❌ Private keys (NEVER share these)
- ❌ Seed phrases
- ❌ API keys (except Etherscan, which is public)

### What CAN Be Shared:
- ✅ Public wallet addresses (0x...)
- ✅ Gnosis Safe addresses
- ✅ Deployed contract addresses
- ✅ Transaction hashes

---

## 📞 Questions to Answer

Please provide answers to these questions:

1. **Testnet Deployment**:
   - Can we use the current wallet in `.env` for Sepolia testnet deployment?
   - Who should be the signers for testnet Gnosis Safe wallets?

2. **Mainnet Deployment**:
   - Who will be the signers for each mainnet Gnosis Safe?
   - Do you want 2-of-2, 3-of-5, or 4-of-7 multi-sig configuration?
   - Do you have hardware wallets (Ledger/Trezor) for mainnet signers?

3. **Timeline**:
   - When do you want testnet deployment? (Can start during M5)
   - When do you want mainnet deployment? (After M5 + audit)

4. **Additional Services**:
   - Do you want NFT metadata on IPFS or centralized storage?
   - Do you need OpenSea integration for NFTs?

---

## 📝 Summary

**For Testnet (Needed Soon)**:
- ✅ Already have: RPC URLs, API keys, deployer wallet
- 🔴 Need: 4 Gnosis Safe testnet addresses

**For Mainnet (Needed Later)**:
- ✅ Already have: RPC URLs, API keys
- 🔴 Need: NEW deployer wallet, 4 Gnosis Safe mainnet addresses, multi-sig signers confirmed

**Bottom Line**: You can start M5 implementation with what you have, but you'll need the testnet Gnosis Safe addresses within the first few days for integration testing.

---

**Document Version**: 1.0  
**Created**: October 22, 2025  
**Next Review**: Before testnet deployment
