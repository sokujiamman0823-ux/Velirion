# 🔧 Velirion Phase 2: Technical Specifications & Integration Details

**Document Version**: 2.0  
**Created**: October 27, 2025  
**Companion to**: PHASE_2_COMPLETE_IMPLEMENTATION_GUIDE.md

---

## 📋 Table of Contents

1. [Network Specifications](#network-specifications)
2. [Smart Contract Details](#smart-contract-details)
3. [Token Economics](#token-economics)
4. [API Specifications](#api-specifications)
5. [Frontend Integration](#frontend-integration)
6. [Testing Requirements](#testing-requirements)
7. [Security Requirements](#security-requirements)
8. [Performance Benchmarks](#performance-benchmarks)

---

## 🌐 Network Specifications

### Ethereum Networks

| Network | Chain ID | RPC URL | Block Explorer | Status |
|---------|----------|---------|----------------|--------|
| **Localhost** | 31337 | http://127.0.0.1:8545 | N/A | ✅ Complete |
| **Sepolia** | 11155111 | Alchemy/Infura | sepolia.etherscan.io | ⏳ Next |
| **Mainnet** | 1 | Alchemy/Infura | etherscan.io | ⏳ Future |

### Solana Networks

| Network | Cluster | RPC URL | Block Explorer | Status |
|---------|---------|---------|----------------|--------|
| **Localnet** | Local | http://127.0.0.1:8899 | N/A | ✅ Complete |
| **Devnet** | Devnet | https://api.devnet.solana.com | explorer.solana.com | ⏳ Next |
| **Mainnet** | Mainnet-beta | https://api.mainnet-beta.solana.com | explorer.solana.com | ⏳ Future |

---

## 📜 Smart Contract Details

### 1. VelirionToken.sol

**Type**: ERC-20 Token  
**Standard**: OpenZeppelin ERC20, Burnable, Pausable, Ownable  
**Solidity Version**: 0.8.20

**Key Parameters**:
```solidity
string public constant name = "Velirion";
string public constant symbol = "VLR";
uint8 public constant decimals = 18;
uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18; // 100M tokens
```

**Functions**:
- `transfer(address to, uint256 amount)` - Standard ERC-20 transfer
- `burn(uint256 amount)` - Burn tokens from caller
- `pause()` / `unpause()` - Emergency controls (owner only)

**Events**:
- `Transfer(address indexed from, address indexed to, uint256 value)`
- `Burn(address indexed burner, uint256 amount)`

**Gas Estimates**:
- Deploy: ~2,000,000 gas
- Transfer: ~50,000 gas
- Burn: ~30,000 gas

---

### 2. PresaleContractV2.sol

**Type**: Multi-Phase Token Sale  
**Dependencies**: VelirionToken, IERC20 (USDT/USDC)

**Key Parameters**:
```solidity
uint256 public constant TOTAL_PHASES = 10;
uint256 public constant TOKENS_PER_PHASE = 3_000_000 * 10**18;
uint256 public constant MIN_PURCHASE = 100 * 10**18; // 100 VLR
uint256 public constant MAX_PURCHASE_PER_WALLET = 500_000 * 10**18; // 500K VLR
uint256 public constant COOLDOWN_PERIOD = 5 minutes;
```

**Phase Configuration**:
```solidity
struct Phase {
    uint256 startTime;
    uint256 endTime;
    uint256 pricePerToken;      // USD with 18 decimals
    uint256 maxTokens;
    uint256 soldTokens;
    bool isActive;
}
```

**Pricing Schedule**:
| Phase | Price (USD) | Tokens Available | Duration |
|-------|-------------|------------------|----------|
| 1 | $0.005 | 3,000,000 | 7 days |
| 2 | $0.006 | 3,000,000 | 7 days |
| 3 | $0.007 | 3,000,000 | 7 days |
| 4 | $0.008 | 3,000,000 | 7 days |
| 5 | $0.009 | 3,000,000 | 7 days |
| 6 | $0.010 | 3,000,000 | 7 days |
| 7 | $0.011 | 3,000,000 | 7 days |
| 8 | $0.012 | 3,000,000 | 7 days |
| 9 | $0.013 | 3,000,000 | 7 days |
| 10 | $0.015 | 3,000,000 | 7 days |

**Vesting Schedule**:
- 40% released at TGE (Token Generation Event)
- 30% released after 1 month
- 30% released after 2 months

**Functions**:
- `buyWithETH(address referrer)` payable - Purchase with ETH
- `buyWithUSDT(uint256 amount, address referrer)` - Purchase with USDT
- `buyWithUSDC(uint256 amount, address referrer)` - Purchase with USDC
- `claimVestedTokens()` - Claim vested tokens
- `startPhase(uint256 phaseId)` - Start a phase (owner)
- `endPhase(uint256 phaseId)` - End a phase (owner)

**Gas Estimates**:
- Deploy: ~3,500,000 gas
- Buy with ETH: ~150,000 gas
- Buy with USDT/USDC: ~200,000 gas
- Claim vested: ~80,000 gas

---

### 3. VelirionReferral.sol

**Type**: Multi-Tier Referral System  
**Dependencies**: VelirionToken

**Tier Structure**:
```solidity
enum ReferralTier {
    Tier1,  // Starter: 5% purchase, 2% staking
    Tier2,  // Bronze: 7% purchase, 3% staking (10+ referrals)
    Tier3,  // Silver: 10% purchase, 4% staking (25+ referrals)
    Tier4   // Gold: 12% purchase, 5% staking (50+ referrals)
}
```

**Data Structure**:
```solidity
struct ReferrerData {
    address referrer;
    ReferralTier level;
    uint256 directReferrals;
    uint256 totalEarned;
    uint256 pendingRewards;
    bool isActive;
}
```

**Functions**:
- `register(address referrer)` - Register with referrer
- `distributePurchaseBonus(address buyer, uint256 amount)` - Distribute purchase bonus
- `distributeStakingBonus(address staker, uint256 amount)` - Distribute staking bonus
- `claimRewards()` - Claim pending rewards
- `getReferrerInfo(address user)` - Get referrer information
- `getTierBonuses(ReferralTier tier)` - Get bonus percentages

**Gas Estimates**:
- Deploy: ~2,500,000 gas
- Register: ~100,000 gas
- Distribute bonus: ~80,000 gas
- Claim rewards: ~70,000 gas

---

### 4. VelirionStaking.sol

**Type**: Multi-Tier Staking System  
**Dependencies**: VelirionToken, VelirionReferral

**Tier Configuration**:
```solidity
enum StakingTier {
    Flexible,  // 6% APR, no lock, 100 VLR min
    Medium,    // 12-15% APR, 90-180 days, 1K VLR min
    Long,      // 20-22% APR, 1 year, 5K VLR min, 2x DAO vote
    Elite      // 30-32% APR, 2 years, 250K VLR min, 2x DAO vote
}
```

**Stake Structure**:
```solidity
struct Stake {
    uint256 amount;
    uint256 startTime;
    uint256 lockDuration;
    uint256 lastClaimTime;
    StakingTier tier;
    uint16 apr;              // Basis points (600 = 6%)
    bool renewed;
    bool active;
}
```

**APR Calculation**:
- Flexible: 6% (600 BPS)
- Medium: 12-15% (1200-1500 BPS) - Linear interpolation
- Long: 20% base, 22% renewed (2000-2200 BPS)
- Elite: 30% base, 32% renewed (3000-3200 BPS)

**Penalties**:
- Flexible: 0% (no lock)
- Medium: 5% (500 BPS)
- Long: 7% (700 BPS)
- Elite: 10% (1000 BPS)

**Functions**:
- `stake(uint256 amount, StakingTier tier, uint256 lockDuration)` - Create stake
- `unstake(uint256 stakeId)` - Withdraw stake
- `claimRewards(uint256 stakeId)` - Claim rewards
- `renewStake(uint256 stakeId)` - Renew for bonus APR
- `calculateRewards(address user, uint256 stakeId)` - View pending rewards
- `getVotingPower(address user)` - Get DAO voting power

**Gas Estimates**:
- Deploy: ~3,000,000 gas
- Stake: ~150,000 gas
- Unstake: ~100,000 gas
- Claim rewards: ~90,000 gas

---

### 5. VelirionDAO.sol

**Type**: Burn-to-Vote Governance  
**Dependencies**: VelirionToken, VelirionTimelock, VelirionStaking

**Governance Parameters**:
```solidity
uint256 public constant PROPOSAL_THRESHOLD = 10_000 * 10**18; // 10K VLR to propose
uint256 public constant VOTING_DELAY = 1 days;
uint256 public constant VOTING_PERIOD = 7 days;
uint256 public constant QUORUM = 100_000 * 10**18; // 100K VLR minimum votes
```

**Proposal Structure**:
```solidity
struct Proposal {
    uint256 id;
    address proposer;
    string description;
    uint256 startTime;
    uint256 endTime;
    uint256 forVotes;
    uint256 againstVotes;
    uint256 abstainVotes;
    bool executed;
    bool canceled;
    address[] targets;
    uint256[] values;
    bytes[] calldatas;
}
```

**Voting Multipliers**:
- No stake / Flexible / Medium: 1x voting power
- Long / Elite tier stakers: 2x voting power

**Functions**:
- `propose(address[] targets, uint256[] values, bytes[] calldatas, string description)` - Create proposal
- `castVote(uint256 proposalId, uint8 support, uint256 voteAmount)` - Vote on proposal
- `queue(uint256 proposalId)` - Queue for execution
- `execute(uint256 proposalId)` - Execute proposal
- `cancel(uint256 proposalId)` - Cancel proposal
- `getProposalState(uint256 proposalId)` - Get proposal status

**Gas Estimates**:
- Deploy: ~4,000,000 gas
- Propose: ~200,000 gas
- Vote: ~100,000 gas
- Execute: Varies by action

---

### 6. VelirionTimelock.sol

**Type**: Execution Delay Contract  
**Standard**: OpenZeppelin TimelockController

**Parameters**:
```solidity
uint256 public constant MIN_DELAY = 2 days;
uint256 public constant GRACE_PERIOD = 14 days;
```

**Functions**:
- `schedule(address target, uint256 value, bytes data, bytes32 predecessor, bytes32 salt, uint256 delay)` - Schedule transaction
- `execute(address target, uint256 value, bytes data, bytes32 predecessor, bytes32 salt)` - Execute transaction
- `cancel(bytes32 id)` - Cancel transaction

---

### 7. VelirionTreasury.sol

**Type**: Multi-Wallet Fund Management  
**Dependencies**: VelirionToken, VelirionDAO

**Wallet Types**:
```solidity
enum WalletType {
    DAO,        // DAO treasury
    Marketing,  // Marketing initiatives
    Team,       // Team allocation
    Liquidity   // DEX liquidity
}
```

**Functions**:
- `allocate(WalletType walletType, uint256 amount)` - Allocate funds (DAO only)
- `batchAllocate(WalletType[] walletTypes, uint256[] amounts)` - Batch allocation
- `emergencyWithdraw(address token, uint256 amount)` - Emergency withdrawal (owner)

---

### 8. VelirionReferralNFT.sol

**Type**: ERC-721 Tiered Badges  
**Standard**: OpenZeppelin ERC721, ERC721URIStorage

**Tiers**:
- Tier 2 (Bronze): 10+ referrals
- Tier 3 (Silver): 25+ referrals
- Tier 4 (Gold): 50+ referrals

**Features**:
- Auto-minting on tier upgrade
- Automatic tier progression
- Dynamic metadata
- Optional soulbound

**Functions**:
- `mint(address to, uint8 tier)` - Mint NFT (authorized only)
- `upgradeTier(address owner, uint8 newTier)` - Upgrade tier
- `updateMetadata(uint256 tokenId, string uri)` - Update metadata
- `setSoulbound(bool _soulbound)` - Toggle soulbound

---

### 9. VelirionGuardianNFT.sol

**Type**: ERC-721 Elite Staker NFT  
**Standard**: OpenZeppelin ERC721, ERC721URIStorage

**Requirements**:
- 250,000+ VLR staked
- Elite tier (2-year lock)
- Always soulbound (non-transferable)

**Functions**:
- `mint(address to, uint256 stakedAmount)` - Mint Guardian NFT
- `updateStakedAmount(uint256 tokenId, uint256 newAmount)` - Update stake
- `deactivate(uint256 tokenId)` - Deactivate on unstake
- `reactivate(uint256 tokenId)` - Reactivate on restake

---

## 💰 Token Economics

### Total Supply Distribution

| Allocation | Amount | Percentage | Vesting | Recipient |
|------------|--------|------------|---------|-----------|
| **Presale** | 30,000,000 | 30% | 40% TGE, 30% M1, 30% M2 | Presale Contract |
| **Staking Rewards** | 20,000,000 | 20% | Released over time | Staking Contract |
| **Marketing** | 15,000,000 | 15% | 6-month linear | Marketing Wallet |
| **Team** | 15,000,000 | 15% | 12-month cliff, 24-month linear | Team Wallet |
| **Liquidity** | 10,000,000 | 10% | Immediate | Liquidity Wallet |
| **Referral Rewards** | 5,000,000 | 5% | Released on claims | Referral Contract |
| **DAO Treasury** | 5,000,000 | 5% | DAO controlled | Treasury Contract |
| **TOTAL** | **100,000,000** | **100%** | - | - |

### Deflationary Mechanisms

1. **Solana Auto-Burn**: 0.5% on every SPL transfer
2. **DAO Voting Burn**: Tokens burned to vote
3. **Proposal Creation Burn**: 10,000 VLR burned to propose
4. **Unsold Presale Burn**: Unsold tokens burned after presale
5. **Quarterly Community Burns**: DAO-voted burns

### Price Projections

**Presale Phases**:
- Phase 1: $0.005 per VLR
- Phase 10: $0.015 per VLR
- Average: $0.010 per VLR

**Post-Launch Targets**:
- Listing Price: $0.020 (2x Phase 10)
- 3-Month Target: $0.050 (5x Phase 10)
- 6-Month Target: $0.100 (10x Phase 10)
- 1-Year Target: $0.250 (25x Phase 10)

---

## 🔌 API Specifications

### REST API Endpoints

#### Contract Addresses
```http
GET /api/v1/contracts
Response: {
  "network": "sepolia",
  "contracts": {
    "vlrToken": "0x...",
    "presale": "0x...",
    "referral": "0x...",
    "staking": "0x...",
    "dao": "0x...",
    "treasury": "0x...",
    "referralNFT": "0x...",
    "guardianNFT": "0x..."
  }
}
```

#### Presale Information
```http
GET /api/v1/presale/current
Response: {
  "phase": 1,
  "pricePerToken": "0.005",
  "tokensAvailable": 3000000,
  "tokensSold": 150000,
  "startTime": "2025-11-01T00:00:00Z",
  "endTime": "2025-11-08T00:00:00Z",
  "isActive": true
}
```

#### User Referral Stats
```http
GET /api/v1/referral/:address
Response: {
  "address": "0x...",
  "tier": 2,
  "tierName": "Bronze",
  "directReferrals": 15,
  "totalEarned": "5000.50",
  "pendingRewards": "250.75",
  "purchaseBonus": "7%",
  "stakingBonus": "3%",
  "referralLink": "https://velirion.io?ref=0x...",
  "nextTier": {
    "tier": 3,
    "name": "Silver",
    "referralsNeeded": 10
  }
}
```

#### User Staking Info
```http
GET /api/v1/staking/:address
Response: {
  "address": "0x...",
  "totalStaked": "50000",
  "totalRewardsClaimed": "1250.50",
  "activeStakes": [
    {
      "id": 0,
      "amount": "10000",
      "tier": "Medium",
      "tierName": "Medium",
      "apr": "12",
      "startTime": "2025-10-15T00:00:00Z",
      "lockDuration": 7776000,
      "unlockTime": "2026-01-13T00:00:00Z",
      "pendingRewards": "120.50",
      "canUnstake": false,
      "earlyWithdrawalPenalty": "5%"
    }
  ],
  "votingPower": "20000"
}
```

#### DAO Proposals
```http
GET /api/v1/dao/proposals
Response: {
  "proposals": [
    {
      "id": 1,
      "title": "Increase staking rewards",
      "description": "Proposal to increase...",
      "proposer": "0x...",
      "status": "Active",
      "startTime": "2025-10-28T00:00:00Z",
      "endTime": "2025-11-04T00:00:00Z",
      "votesFor": "150000",
      "votesAgainst": "50000",
      "votesAbstain": "10000",
      "quorum": "100000",
      "quorumReached": true,
      "passing": true
    }
  ]
}
```

### WebSocket Events

```javascript
// Real-time updates
ws://api.velirion.io/ws

// Events
{
  "event": "presale:purchase",
  "data": {
    "buyer": "0x...",
    "amount": "1000",
    "phase": 1,
    "timestamp": "2025-10-27T12:00:00Z"
  }
}

{
  "event": "staking:new",
  "data": {
    "staker": "0x...",
    "amount": "5000",
    "tier": "Long",
    "timestamp": "2025-10-27T12:05:00Z"
  }
}

{
  "event": "dao:proposal:created",
  "data": {
    "proposalId": 5,
    "proposer": "0x...",
    "title": "...",
    "timestamp": "2025-10-27T12:10:00Z"
  }
}
```

---

## 🎨 Frontend Integration

### Web3 Provider Setup

```typescript
// providers/Web3Provider.tsx
import { WagmiConfig, createClient, configureChains } from 'wagmi';
import { sepolia, mainnet } from 'wagmi/chains';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';

const { chains, provider } = configureChains(
  [sepolia, mainnet],
  [
    alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_KEY }),
    publicProvider()
  ]
);

const client = createClient({
  autoConnect: true,
  provider
});

export function Web3Provider({ children }) {
  return (
    <WagmiConfig client={client}>
      {children}
    </WagmiConfig>
  );
}
```

### Contract Hooks

```typescript
// hooks/useVelirionContracts.ts
import { useContract, useSigner } from 'wagmi';
import VLR_ABI from '../abis/VelirionToken.json';
import PRESALE_ABI from '../abis/PresaleContractV2.json';

export function useVelirionContracts() {
  const { data: signer } = useSigner();
  
  const vlrToken = useContract({
    address: process.env.NEXT_PUBLIC_VLR_TOKEN_ADDRESS,
    abi: VLR_ABI,
    signerOrProvider: signer
  });
  
  const presale = useContract({
    address: process.env.NEXT_PUBLIC_PRESALE_ADDRESS,
    abi: PRESALE_ABI,
    signerOrProvider: signer
  });
  
  return { vlrToken, presale };
}
```

### Component Examples

```typescript
// components/Presale/BuyTokens.tsx
import { useState } from 'react';
import { useVelirionContracts } from '@/hooks/useVelirionContracts';
import { ethers } from 'ethers';

export function BuyTokens() {
  const { presale } = useVelirionContracts();
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);
  
  const handleBuy = async () => {
    setLoading(true);
    try {
      const tx = await presale.buyWithETH(ethers.constants.AddressZero, {
        value: ethers.utils.parseEther(amount)
      });
      await tx.wait();
      alert('Purchase successful!');
    } catch (error) {
      console.error(error);
      alert('Purchase failed');
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div>
      <input 
        type="number" 
        value={amount} 
        onChange={(e) => setAmount(e.target.value)}
        placeholder="ETH amount"
      />
      <button onClick={handleBuy} disabled={loading}>
        {loading ? 'Processing...' : 'Buy VLR'}
      </button>
    </div>
  );
}
```

---

## 🧪 Testing Requirements

### Unit Test Coverage

**Minimum Requirements**:
- Code coverage: ≥95%
- Branch coverage: ≥90%
- Function coverage: 100%

**Test Categories**:
1. Deployment tests (10%)
2. Core functionality tests (40%)
3. Access control tests (15%)
4. Integration tests (20%)
5. Edge case tests (10%)
6. Gas optimization tests (5%)

### Integration Test Scenarios

1. **Complete Presale Flow**
   - User registers with referrer
   - User purchases tokens
   - Referrer receives bonus
   - User claims vested tokens

2. **Staking Lifecycle**
   - User stakes tokens
   - Time passes
   - User claims rewards
   - Referrer receives staking bonus
   - User unstakes

3. **DAO Governance Flow**
   - User creates proposal
   - Users vote
   - Proposal passes
   - Timelock delay
   - Proposal executes

### Performance Benchmarks

**Gas Limits**:
- Token transfer: <60,000 gas
- Presale purchase: <180,000 gas
- Stake creation: <170,000 gas
- Claim rewards: <100,000 gas
- Vote on proposal: <120,000 gas

**Transaction Times** (Sepolia):
- Average: 15-30 seconds
- Maximum acceptable: 2 minutes

---

## 🔒 Security Requirements

### Smart Contract Security

**Required Protections**:
- ✅ Reentrancy guards on all external calls
- ✅ Access control on admin functions
- ✅ Input validation on all parameters
- ✅ SafeMath operations (Solidity 0.8+)
- ✅ Pausable functionality
- ✅ Emergency withdrawal mechanisms

### Audit Requirements

**Pre-Audit Checklist**:
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Slither analysis clean
- [ ] Mythril analysis clean
- [ ] Manual code review complete

**Audit Deliverables**:
- Comprehensive audit report
- Severity classifications
- Remediation recommendations
- Re-audit after fixes

### Operational Security

**Multi-Sig Requirements**:
- Minimum 2-of-3 for operational wallets
- Minimum 3-of-5 for treasury wallets
- Hardware wallet signers
- Geographic distribution of signers

**Key Management**:
- No private keys in code
- Environment variables only
- Hardware wallet for mainnet
- Regular key rotation

---

## 📊 Performance Benchmarks

### Expected Metrics

**Testnet (Sepolia)**:
- Block time: ~12 seconds
- Gas price: 1-5 gwei
- Transaction confirmation: 1-2 blocks

**Mainnet**:
- Block time: ~12 seconds
- Gas price: 20-100 gwei (variable)
- Transaction confirmation: 2-3 blocks recommended

### Scalability Targets

**Year 1**:
- 10,000+ token holders
- 1,000+ daily active users
- 100,000+ transactions
- $10M+ TVL

**Year 2**:
- 50,000+ token holders
- 5,000+ daily active users
- 500,000+ transactions
- $50M+ TVL

---

**Document Version**: 2.0  
**Last Updated**: October 27, 2025  
**Status**: Complete Technical Specifications  
**Next Review**: Before testnet deployment
