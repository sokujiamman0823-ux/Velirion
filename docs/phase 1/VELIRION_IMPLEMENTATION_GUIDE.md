# Velirion (VLR) Smart Contract - Implementation Guide

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites & Setup](#prerequisites--setup)
3. [Smart Contract Architecture](#smart-contract-architecture)
4. [Milestone Implementation](#milestone-implementation)
5. [Testing & Security](#testing--security)
6. [Deployment Guide](#deployment-guide)
7. [Integration Checklist](#integration-checklist)

---

## Project Overview

### Token Specifications

- **Name**: Velirion (VLR)
- **Networks**: Ethereum (ERC-20) + Solana (SPL)
- **Total Supply**: 100,000,000 VLR
- **Presale**: 30M VLR (30%) over 90 days + 30-day extension
- **Phases**: 10 progressive pricing phases

### Token Distribution

| Category          | %   | Amount (VLR) |
| ----------------- | --- | ------------ |
| Presale           | 30% | 30,000,000   |
| Staking & Bonuses | 20% | 20,000,000   |
| Marketing         | 15% | 15,000,000   |
| Team              | 15% | 15,000,000   |
| Liquidity         | 10% | 10,000,000   |
| Referral          | 5%  | 5,000,000    |
| DAO Treasury      | 5%  | 5,000,000    |

### Development Timeline

| Milestone             | Duration       | Cost     | Status |
| --------------------- | -------------- | -------- | ------ |
| M1: Token + Core      | 5-6 days       | $120     | ⏳     |
| M2: Presale           | 5 days         | $120     | ⏳     |
| M3: Referral          | 4 days         | $100     | ⏳     |
| M4: Staking           | 7-8 days       | $150     | ⏳     |
| M5: DAO + Integration | 6-7 days       | $110     | ⏳     |
| **Total**             | **27-31 days** | **$600** |        |

---

## Prerequisites & Setup

### Required Tools

```bash
# Core Development
Node.js >= 18.x
Hardhat 3.x
Rust 1.70+ (Solana)
Anchor 0.28+ (Solana)
Git

# Testing & Deployment
TypeScript
Ethers.js v6
Mocha/Chai
```

### Environment Setup

#### 1. Initialize Project

```bash
cd velirion-sc
npm install

# Install additional dependencies
npm install --save-dev @nomicfoundation/hardhat-verify
npm install @chainlink/contracts  # For price oracles
```

#### 2. Configure Environment Variables

Create `.env` file:

```env
# Ethereum Networks
ETHEREUM_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
PRIVATE_KEY=your_deployer_private_key
ETHERSCAN_API_KEY=your_etherscan_key

# Solana Networks
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
SOLANA_DEVNET_RPC=https://api.devnet.solana.com

# Multisig Addresses
GNOSIS_SAFE_ADDRESS=0x...
FOUNDER_1_ADDRESS=0x...
FOUNDER_2_ADDRESS=0x...

# Payment Tokens
USDT_ADDRESS=0xdAC17F958D2ee523a2206206994597C13D831ec7
USDC_ADDRESS=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

# Contract Addresses (fill after deployment)
VLR_TOKEN_ADDRESS=
PRESALE_CONTRACT=
REFERRAL_CONTRACT=
STAKING_CONTRACT=
DAO_CONTRACT=
```

#### 3. Update Hardhat Config

```typescript
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      viaIR: true, // For complex contracts
    },
  },
  networks: {
    hardhat: { chainId: 31337 },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY!],
    },
    mainnet: {
      url: process.env.ETHEREUM_RPC_URL,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: true,
    coinmarketcap: process.env.CMC_API_KEY,
  },
};

export default config;
```

---

## Smart Contract Architecture

### Contract Structure

```
contracts/
├── core/
│   ├── VelirionToken.sol           # ERC-20 with burning
│   ├── VelirionPresale.sol         # 10-phase presale
│   ├── VelirionReferral.sol        # 4-level referral system
│   ├── VelirionStaking.sol         # 4-tier staking
│   └── VelirionDAO.sol             # Governance & burning votes
├── interfaces/
│   ├── IVelirionToken.sol
│   ├── IVelirionPresale.sol
│   ├── IVelirionReferral.sol
│   └── IVelirionStaking.sol
└── libraries/
    ├── PresalePhases.sol
    └── VestingSchedule.sol
```

### Key Features by Contract

#### VelirionToken.sol

- ✅ ERC-20 standard implementation
- ✅ Burnable (manual + automatic)
- ✅ Pausable for emergencies
- ✅ Token allocation tracking
- ✅ Owner controls

#### VelirionPresale.sol

- ✅ 10 phases with progressive pricing
- ✅ Time restrictions (90+30 days)
- ✅ Multi-token payments (ETH, USDT, USDC)
- ✅ Antibot mechanisms
- ✅ Whale protection
- ✅ Vesting schedule (40% initial, 30% monthly)

#### VelirionReferral.sol

- ✅ 4-level referral system
- ✅ Purchase bonuses (5%-12%)
- ✅ Staking reward bonuses (2%-5%)
- ✅ NFT rewards for top tiers
- ✅ Direct referral tracking

#### VelirionStaking.sol

- ✅ 4 staking tiers (Flexible, Medium, Long, Elite)
- ✅ APR: 6%-30%
- ✅ Lock periods: None to 2 years
- ✅ Early withdrawal penalties
- ✅ Renewal bonuses
- ✅ Manual claim system

#### VelirionDAO.sol

- ✅ Burn voting mechanism
- ✅ Treasury management
- ✅ Multisig integration (Gnosis Safe)
- ✅ Proposal creation & voting
- ✅ Timelock for execution

---

## Milestone Implementation

## Milestone 1: Token + Core Logic (Days 1-6)

### Deliverables

- [x] Deploy ERC-20 token
- [x] Deploy Solana SPL token
- [x] Implement burning functions
- [x] Setup ownership controls
- [x] Test coverage ≥90%

### Implementation

#### VelirionToken.sol (Core Contract)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract VelirionToken is ERC20, ERC20Burnable, Ownable, Pausable {
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18;

    mapping(address => bool) public isAllocator;
    mapping(string => uint256) public allocationTracking;

    event TokensAllocated(string category, address to, uint256 amount);
    event UnsoldBurned(uint256 amount);

    constructor() ERC20("Velirion", "VLR") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function allocate(string memory category, address to, uint256 amount)
        external onlyOwner
    {
        require(to != address(0), "Invalid address");
        allocationTracking[category] += amount;
        _transfer(owner(), to, amount);
        emit TokensAllocated(category, to, amount);
    }

    function burnUnsold(uint256 amount) external onlyOwner {
        _burn(owner(), amount);
        emit UnsoldBurned(amount);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal override whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
```

#### Deployment Script

```typescript
// scripts/01_deploy_token.ts
import { ethers } from "hardhat";

async function main() {
  const VLR = await ethers.deployContract("VelirionToken");
  await VLR.waitForDeployment();

  console.log("✅ VelirionToken deployed:", await VLR.getAddress());
  console.log("Total Supply:", ethers.formatEther(await VLR.totalSupply()));
}

main().catch(console.error);
```

#### Testing

```typescript
// test/01_Token.test.ts
import { expect } from "chai";
import { ethers } from "hardhat";

describe("VelirionToken", () => {
  let token, owner, addr1;

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();
    token = await ethers.deployContract("VelirionToken");
  });

  it("Should deploy with correct supply", async () => {
    expect(await token.totalSupply()).to.equal(ethers.parseEther("100000000"));
  });

  it("Should allocate tokens", async () => {
    const amount = ethers.parseEther("1000000");
    await token.allocate("presale", addr1.address, amount);
    expect(await token.balanceOf(addr1.address)).to.equal(amount);
  });

  it("Should burn tokens", async () => {
    const burnAmt = ethers.parseEther("1000000");
    await token.burn(burnAmt);
    expect(await token.totalSupply()).to.equal(ethers.parseEther("99000000"));
  });
});
```

---

## Milestone 2: Presale System (Days 7-11)

### Key Features

- 10 phases with automatic progression
- Price range: $0.005 - $0.015 per VLR
- Max per tx: 50,000 VLR
- Max per wallet: 500,000 VLR
- Minimum delay: 5 minutes between purchases
- Vesting: 40% TGE, 30% monthly (2 months)

### Presale Phase Pricing

| Phase     | Price (USD) | Tokens Available | Target Raise |
| --------- | ----------- | ---------------- | ------------ |
| 1         | $0.005      | 3,000,000        | $15,000      |
| 2         | $0.006      | 3,000,000        | $18,000      |
| 3         | $0.007      | 3,000,000        | $21,000      |
| 4         | $0.008      | 3,000,000        | $24,000      |
| 5         | $0.009      | 3,000,000        | $27,000      |
| 6         | $0.010      | 3,000,000        | $30,000      |
| 7         | $0.011      | 3,000,000        | $33,000      |
| 8         | $0.012      | 3,000,000        | $36,000      |
| 9         | $0.013      | 3,000,000        | $39,000      |
| 10        | $0.015      | 3,000,000        | $45,000      |
| **Total** |             | **30,000,000**   | **$288,000** |

### Implementation Notes

```solidity
// Key functions to implement:
- startPresale()
- extendPresale() // One-time 30-day extension
- buyWithETH()
- buyWithUSDT(uint256)
- buyWithUSDC(uint256)
- claimTokens()
- calculateClaimable(address)
- finalize() // Burn unsold tokens
```

---

## Milestone 3: Referral System (Days 12-15)

### Referral Levels

| Level | Requirements  | Purchase Bonus | Staking Bonus | Rewards             |
| ----- | ------------- | -------------- | ------------- | ------------------- |
| 1     | 0 referrals   | 5%             | 2%            | Base rewards        |
| 2     | 10+ referrals | 7%             | 3%            | Special NFT         |
| 3     | 25+ referrals | 10%            | 4%            | Exclusive bonuses   |
| 4     | 50+ referrals | 12%            | 5%            | Private pool access |

### Implementation Structure

```solidity
contract VelirionReferral {
    struct Referrer {
        address addr;
        uint256 level;
        uint256 directReferrals;
        uint256 totalEarned;
    }

    mapping(address => address) public referredBy;
    mapping(address => Referrer) public referrers;
    mapping(address => address[]) public referralTree;

    // Key functions:
    - register(address referrer)
    - upgradeTier(address user)
    - distributePurchaseBonus(address buyer, uint256 amount)
    - distributeStakingBonus(address staker, uint256 rewards)
    - claimReferralRewards()
}
```

---

## Milestone 4: Staking Module (Days 16-23)

### Staking Tiers

| Tier         | APR    | Lock Period | Min. Amount | Penalty | Benefits             |
| ------------ | ------ | ----------- | ----------- | ------- | -------------------- |
| **Flexible** | 6%     | None        | 100 VLR     | -       | Anytime withdrawal   |
| **Medium**   | 12-15% | 90-180 days | 1,000 VLR   | 5%      | +2% renewal bonus    |
| **Long**     | 20-22% | 1 year      | 5,000 VLR   | 7%      | x2 DAO voting weight |
| **Elite**    | 30%    | 2 years     | 250,000 VLR | 10%     | Guardian NFT         |

### Implementation

```solidity
contract VelirionStaking {
    enum Tier { Flexible, Medium, Long, Elite }

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 lockDuration;
        Tier tier;
        bool renewed;
        uint256 lastClaimTime;
    }

    mapping(address => Stake[]) public stakes;

    // Key functions:
    - stake(uint256 amount, Tier tier)
    - unstake(uint256 stakeId) // With penalty if early
    - claimRewards(uint256 stakeId)
    - calculateRewards(address user, uint256 stakeId)
    - renewStake(uint256 stakeId) // Get 2% bonus
}
```

---

## Milestone 5: DAO + Integration (Days 24-31)

### DAO Features

- **Burn Proposals**: Monthly & quarterly voting
- **Treasury Management**: Multisig control (2-of-2)
- **Voting Weight**: Based on Long/Elite staking
- **Proposal Types**:
  - Burn amount decisions
  - Treasury fund allocation
  - Protocol parameter changes

### Gnosis Safe Configuration

**Signers**: 2 required

- Founder 1 Address
- Founder 2 Address

**Wallets to Create**:

1. **DAO Treasury** (2-of-2): 5% of supply
2. **Marketing Funds** (2-of-2): 15% of supply
3. **Team Wallet** (2-of-2): 15% with vesting
4. **Liquidity Reserve** (2-of-2): 10% of supply

---

## Testing & Security

### Testing Checklist

#### Unit Tests

- [ ] Token minting and burning
- [ ] Presale phase transitions
- [ ] Antibot mechanisms
- [ ] Referral bonus calculations
- [ ] Staking APR calculations
- [ ] Vesting schedule accuracy
- [ ] DAO voting logic

#### Integration Tests

- [ ] Presale → Referral flow
- [ ] Presale → Staking flow
- [ ] Referral → Staking rewards
- [ ] DAO → Treasury operations
- [ ] Multi-token payments

#### Security Tests

- [ ] Reentrancy attacks
- [ ] Integer overflow/underflow
- [ ] Access control bypasses
- [ ] Front-running scenarios
- [ ] Flash loan attacks

### Running Tests

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/01_Token.test.ts

# Test with gas reporting
REPORT_GAS=true npx hardhat test

# Test coverage
npx hardhat coverage
```

### Security Audit Checklist

- [ ] OpenZeppelin Contracts used where possible
- [ ] ReentrancyGuard on all external functions
- [ ] Input validation on all functions
- [ ] Access control properly implemented
- [ ] Events emitted for all state changes
- [ ] No use of `tx.origin`
- [ ] Safe math operations
- [ ] Emergency pause functionality

---

## Deployment Guide

### Pre-Deployment Checklist

- [ ] All tests passing (100% coverage)
- [ ] Contracts compiled without warnings
- [ ] Environment variables configured
- [ ] Deployer wallet funded
- [ ] Gnosis Safe wallets created
- [ ] Audit completed (if budget allows)

### Deployment Sequence

#### Step 1: Deploy Token

```bash
npx hardhat run scripts/01_deploy_token.ts --network sepolia
# Save contract address to .env
```

#### Step 2: Deploy Presale

```bash
npx hardhat run scripts/02_deploy_presale.ts --network sepolia
# Requires: VLR token address, USDT, USDC addresses
```

#### Step 3: Deploy Referral

```bash
npx hardhat run scripts/03_deploy_referral.ts --network sepolia
# Requires: VLR token, Presale addresses
```

#### Step 4: Deploy Staking

```bash
npx hardhat run scripts/04_deploy_staking.ts --network sepolia
# Requires: VLR token, Referral addresses
```

#### Step 5: Deploy DAO

```bash
npx hardhat run scripts/05_deploy_dao.ts --network sepolia
# Requires: VLR token, Gnosis Safe address
```

#### Step 6: Initialize Contracts

```bash
npx hardhat run scripts/06_initialize.ts --network sepolia
```

### Post-Deployment Tasks

1. **Verify Contracts on Etherscan**

```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```

2. **Allocate Tokens**

```typescript
// Allocate 30% to Presale contract
await vlrToken.allocate("presale", presaleAddress, parseEther("30000000"));

// Allocate 20% to Staking contract
await vlrToken.allocate("staking", stakingAddress, parseEther("20000000"));

// Allocate 5% to Referral contract
await vlrToken.allocate("referral", referralAddress, parseEther("5000000"));
```

3. **Configure Multisig Wallets**

- Transfer team tokens to Gnosis Safe
- Setup 2-of-2 signature requirement
- Document recovery procedures

4. **Start Presale**

```typescript
await presaleContract.startPresale();
```

---

## Integration Checklist

### Frontend Integration

- [ ] Connect to wallet (MetaMask, WalletConnect)
- [ ] Display presale phase and price
- [ ] Purchase with ETH/USDT/USDC
- [ ] Show referral link and stats
- [ ] Staking interface (4 tiers)
- [ ] Claim vested tokens
- [ ] DAO voting interface

### Backend Requirements

- [ ] Track referral conversions
- [ ] Monitor presale progress
- [ ] Calculate staking APRs
- [ ] Generate analytics reports
- [ ] Send notification emails
- [ ] Update NFT metadata

### Solana SPL Integration

- [ ] Deploy SPL token program
- [ ] Implement 0.5% burn on transfer
- [ ] Bridge mechanism (Ethereum ↔ Solana)
- [ ] Cross-chain price synchronization

### API Endpoints Needed

```
GET  /api/presale/status
GET  /api/presale/phase
POST /api/referral/register
GET  /api/referral/:address/stats
GET  /api/staking/:address/positions
GET  /api/dao/proposals
POST /api/dao/vote
```

---

## Appendix

### Useful Commands

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to testnet
npx hardhat run scripts/deploy.ts --network sepolia

# Verify contract
npx hardhat verify --network sepolia ADDRESS ARGS

# Console (interact with contracts)
npx hardhat console --network sepolia

# Get gas estimates
REPORT_GAS=true npx hardhat test

# Clean build artifacts
npx hardhat clean
```

### Contract Addresses (Update After Deployment)

```
## Testnet (Sepolia)
VLR Token:
Presale Contract:
Referral Contract:
Staking Contract:
DAO Contract:

## Mainnet (Ethereum)
VLR Token:
Presale Contract:
Referral Contract:
Staking Contract:
DAO Contract:
Gnosis Safe:
```

### Important Links

- **GitHub Repo**: [Link to repository]
- **Documentation**: [Link to docs]
- **Audit Report**: [Link when available]
- **Gnosis Safe**: https://app.safe.global/
- **Etherscan**: https://etherscan.io/
- **Solscan**: https://solscan.io/

---

## Support & Contact

For technical questions or issues during implementation:

- **Email**: dev@velirion.io
- **Discord**: [Link to developer channel]
- **Telegram**: [Link to group]

---

**Last Updated**: [Current Date]  
**Document Version**: 1.0  
**Status**: Ready for Implementation
