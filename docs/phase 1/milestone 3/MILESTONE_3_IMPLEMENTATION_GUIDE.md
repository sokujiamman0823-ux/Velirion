# Milestone 3: Referral System - Implementation Guide

**Status**: 🟡 In Progress  
**Budget**: $100  
**Duration**: 4 days  
**Start Date**: October 21, 2025

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Referral Tier System](#referral-tier-system)
4. [Smart Contract Design](#smart-contract-design)
5. [Implementation Steps](#implementation-steps)
6. [Testing Strategy](#testing-strategy)
7. [Integration Guide](#integration-guide)
8. [Security Considerations](#security-considerations)
9. [Deployment Checklist](#deployment-checklist)

---

## Overview

### Objectives

The Referral System (Milestone 3) implements a sophisticated 4-tier referral program that:

- **Rewards referrers** with bonuses on purchase and staking activities
- **Incentivizes growth** through automatic tier upgrades
- **Tracks referral trees** for multi-level attribution
- **Distributes rewards** fairly and transparently
- **Integrates seamlessly** with presale and staking contracts

### Key Features

✅ **4-Tier System**: Progressive rewards based on referral count  
✅ **Dual Bonus Structure**: Purchase bonuses (5%-12%) + Staking bonuses (2%-5%)  
✅ **Automatic Tier Upgrades**: Based on direct referral count  
✅ **NFT Rewards**: Special NFTs for top-tier referrers  
✅ **Referral Tree Tracking**: Complete genealogy of referrals  
✅ **Claim System**: Manual claiming of accumulated rewards  
✅ **Anti-Gaming**: Protection against self-referral and circular references

---

## System Architecture

### Contract Relationships

```
┌─────────────────┐
│  VelirionToken  │
└────────┬────────┘
         │
         ├──────────────────┬──────────────────┐
         │                  │                  │
┌────────▼────────┐  ┌─────▼──────────┐  ┌───▼──────────┐
│ PresaleContract │  │ ReferralSystem │  │StakingContract│
└────────┬────────┘  └─────┬──────────┘  └───┬──────────┘
         │                  │                  │
         └──────────────────┼──────────────────┘
                            │
                    ┌───────▼────────┐
                    │ NFT Rewards    │
                    │ (Future M5)    │
                    └────────────────┘
```

### Data Flow

1. **Registration**: User registers with referrer address
2. **Purchase Event**: Presale contract notifies referral system
3. **Bonus Calculation**: Referral system calculates tier-based bonus
4. **Distribution**: Tokens distributed to referrer
5. **Tier Check**: System checks if referrer qualifies for upgrade
6. **Staking Integration**: Staking bonuses applied based on referrer tier

---

## Referral Tier System

### Tier Structure

| Tier | Name       | Requirements  | Purchase Bonus | Staking Bonus | Special Rewards         |
|------|------------|---------------|----------------|---------------|-------------------------|
| 1    | Starter    | 0 referrals   | 5%             | 2%            | Base rewards            |
| 2    | Bronze     | 10+ referrals | 7%             | 3%            | Special NFT             |
| 3    | Silver     | 25+ referrals | 10%            | 4%            | Exclusive bonuses       |
| 4    | Gold       | 50+ referrals | 12%            | 5%            | Private pool access     |

### Tier Upgrade Logic

```solidity
function checkAndUpgradeTier(address user) internal {
    uint256 referralCount = referrers[user].directReferrals;
    uint256 currentTier = referrers[user].level;
    
    if (referralCount >= 50 && currentTier < 4) {
        _upgradeTier(user, 4); // Gold
    } else if (referralCount >= 25 && currentTier < 3) {
        _upgradeTier(user, 3); // Silver
    } else if (referralCount >= 10 && currentTier < 2) {
        _upgradeTier(user, 2); // Bronze
    }
}
```

### Bonus Calculation Examples

**Example 1: Purchase Bonus**
- User buys 10,000 VLR at $0.01 = $100
- Referrer is Tier 2 (Bronze) = 7% bonus
- Referrer receives: 10,000 × 7% = 700 VLR

**Example 2: Staking Bonus**
- User stakes 50,000 VLR
- Earns 5,000 VLR in rewards over time
- Referrer is Tier 3 (Silver) = 4% bonus
- Referrer receives: 5,000 × 4% = 200 VLR

---

## Smart Contract Design

### VelirionReferral.sol Structure

```solidity
contract VelirionReferral {
    // Core data structures
    struct Referrer {
        address addr;
        uint256 level;              // 1-4 tier
        uint256 directReferrals;    // Count of direct referrals
        uint256 totalEarned;        // Total VLR earned
        uint256 purchaseBonusEarned;
        uint256 stakingBonusEarned;
        uint256 registrationTime;
        bool isActive;
    }
    
    struct ReferralStats {
        uint256 totalVolume;        // Total purchase volume from referrals
        uint256 totalStakingVolume; // Total staking volume from referrals
        address[] directReferrals;  // Array of direct referral addresses
    }
    
    // Mappings
    mapping(address => address) public referredBy;
    mapping(address => Referrer) public referrers;
    mapping(address => ReferralStats) public referralStats;
    mapping(address => uint256) public pendingRewards;
    
    // Key functions
    function register(address referrer) external;
    function distributePurchaseBonus(address buyer, uint256 amount) external;
    function distributeStakingBonus(address staker, uint256 rewards) external;
    function claimRewards() external;
    function getTierBonuses(uint256 tier) external view returns (uint256, uint256);
}
```

### Key Functions Breakdown

#### 1. Registration System

```solidity
function register(address referrer) external {
    require(referrer != address(0), "Invalid referrer");
    require(referrer != msg.sender, "Cannot refer self");
    require(referredBy[msg.sender] == address(0), "Already referred");
    require(referrers[referrer].isActive || referrer == owner(), "Referrer not active");
    
    referredBy[msg.sender] = referrer;
    
    // Initialize referrer if first time
    if (!referrers[msg.sender].isActive) {
        referrers[msg.sender] = Referrer({
            addr: msg.sender,
            level: 1,
            directReferrals: 0,
            totalEarned: 0,
            purchaseBonusEarned: 0,
            stakingBonusEarned: 0,
            registrationTime: block.timestamp,
            isActive: true
        });
    }
    
    // Update referrer stats
    referrers[referrer].directReferrals++;
    referralStats[referrer].directReferrals.push(msg.sender);
    
    // Check for tier upgrade
    _checkAndUpgradeTier(referrer);
    
    emit ReferralRegistered(msg.sender, referrer);
}
```

#### 2. Purchase Bonus Distribution

```solidity
function distributePurchaseBonus(
    address buyer,
    uint256 tokenAmount
) external onlyAuthorized {
    address referrer = referredBy[buyer];
    if (referrer == address(0)) return;
    
    Referrer storage ref = referrers[referrer];
    (uint256 purchaseBonus, ) = getTierBonuses(ref.level);
    
    uint256 bonusAmount = (tokenAmount * purchaseBonus) / BASIS_POINTS;
    
    // Add to pending rewards
    pendingRewards[referrer] += bonusAmount;
    ref.totalEarned += bonusAmount;
    ref.purchaseBonusEarned += bonusAmount;
    
    // Update stats
    referralStats[referrer].totalVolume += tokenAmount;
    
    emit PurchaseBonusDistributed(referrer, buyer, bonusAmount);
}
```

#### 3. Staking Bonus Distribution

```solidity
function distributeStakingBonus(
    address staker,
    uint256 rewardAmount
) external onlyAuthorized {
    address referrer = referredBy[staker];
    if (referrer == address(0)) return;
    
    Referrer storage ref = referrers[referrer];
    (, uint256 stakingBonus) = getTierBonuses(ref.level);
    
    uint256 bonusAmount = (rewardAmount * stakingBonus) / BASIS_POINTS;
    
    // Add to pending rewards
    pendingRewards[referrer] += bonusAmount;
    ref.totalEarned += bonusAmount;
    ref.stakingBonusEarned += bonusAmount;
    
    // Update stats
    referralStats[referrer].totalStakingVolume += rewardAmount;
    
    emit StakingBonusDistributed(referrer, staker, bonusAmount);
}
```

#### 4. Reward Claiming

```solidity
function claimRewards() external nonReentrant {
    uint256 amount = pendingRewards[msg.sender];
    require(amount > 0, "No rewards to claim");
    
    pendingRewards[msg.sender] = 0;
    
    require(
        vlrToken.balanceOf(address(this)) >= amount,
        "Insufficient contract balance"
    );
    
    vlrToken.safeTransfer(msg.sender, amount);
    
    emit RewardsClaimed(msg.sender, amount);
}
```

---

## Implementation Steps

### Step 1: Create Interface

Create `contracts/interfaces/IVelirionReferral.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVelirionReferral {
    function register(address referrer) external;
    function distributePurchaseBonus(address buyer, uint256 amount) external;
    function distributeStakingBonus(address staker, uint256 rewards) external;
    function getReferrer(address user) external view returns (address);
    function getTierBonuses(uint256 tier) external view returns (uint256, uint256);
    function getReferrerInfo(address user) external view returns (
        uint256 level,
        uint256 directReferrals,
        uint256 totalEarned
    );
}
```

### Step 2: Implement Main Contract

Create `contracts/core/VelirionReferral.sol` with:
- Complete tier system
- Bonus distribution logic
- Reward claiming mechanism
- Anti-gaming protections
- Event emissions

### Step 3: Update Presale Integration

Modify `PresaleContractV2.sol` to:
- Accept referral contract address
- Call `distributePurchaseBonus()` on purchases
- Remove internal referral logic (delegate to ReferralContract)

### Step 4: Create Test Suite

Implement comprehensive tests in `test/03_Referral.test.ts`:
- Registration tests
- Tier upgrade tests
- Bonus calculation tests
- Claim mechanism tests
- Anti-gaming tests
- Integration tests with presale

### Step 5: Create Deployment Scripts

Create `scripts/03_deploy_referral.ts`:
- Deploy referral contract
- Allocate 5M VLR tokens
- Set authorized contracts (presale, staking)
- Verify deployment

---

## Testing Strategy

### Unit Tests (Target: 15+ tests)

1. **Registration Tests**
   - ✅ Register with valid referrer
   - ✅ Reject self-referral
   - ✅ Reject double registration
   - ✅ Reject invalid referrer

2. **Tier System Tests**
   - ✅ Start at Tier 1
   - ✅ Upgrade to Tier 2 at 10 referrals
   - ✅ Upgrade to Tier 3 at 25 referrals
   - ✅ Upgrade to Tier 4 at 50 referrals
   - ✅ Emit upgrade events

3. **Bonus Distribution Tests**
   - ✅ Calculate purchase bonus correctly
   - ✅ Calculate staking bonus correctly
   - ✅ Accumulate pending rewards
   - ✅ Track total earned

4. **Claim Tests**
   - ✅ Claim pending rewards
   - ✅ Reset pending after claim
   - ✅ Reject claim with no rewards
   - ✅ Handle insufficient contract balance

5. **Security Tests**
   - ✅ Only authorized contracts can distribute
   - ✅ Reentrancy protection on claims
   - ✅ Circular referral prevention

### Integration Tests

1. **Presale Integration**
   - ✅ Purchase triggers bonus distribution
   - ✅ Referrer receives correct bonus
   - ✅ Multiple purchases accumulate

2. **Staking Integration** (Future M4)
   - ✅ Staking rewards trigger bonus
   - ✅ Correct tier bonus applied

---

## Integration Guide

### Presale Contract Integration

```solidity
// In PresaleContractV2.sol

IVelirionReferral public referralContract;

function setReferralContract(address _referralContract) external onlyOwner {
    referralContract = IVelirionReferral(_referralContract);
}

function _processPurchase(...) internal {
    // ... existing logic ...
    
    // Notify referral contract
    if (address(referralContract) != address(0) && referrer != address(0)) {
        referralContract.distributePurchaseBonus(buyer, tokenAmount);
    }
}
```

### Staking Contract Integration (M4)

```solidity
// In VelirionStaking.sol

IVelirionReferral public referralContract;

function claimRewards(uint256 stakeId) external {
    uint256 rewards = _calculateRewards(msg.sender, stakeId);
    
    // Notify referral contract
    if (address(referralContract) != address(0)) {
        referralContract.distributeStakingBonus(msg.sender, rewards);
    }
    
    // ... transfer rewards ...
}
```

---

## Security Considerations

### Critical Security Measures

1. **Access Control**
   - Only authorized contracts can distribute bonuses
   - Owner can add/remove authorized addresses
   - Use OpenZeppelin's `AccessControl`

2. **Reentrancy Protection**
   - Use `ReentrancyGuard` on claim function
   - Follow checks-effects-interactions pattern

3. **Anti-Gaming Mechanisms**
   - Prevent self-referral
   - Prevent circular referrals
   - One-time referrer assignment
   - Require referrer to be active

4. **Input Validation**
   - Validate all addresses (non-zero)
   - Validate amounts (non-zero, reasonable limits)
   - Check contract balance before transfers

5. **Emergency Controls**
   - Pausable functionality
   - Emergency withdrawal for owner
   - Ability to update authorized contracts

### Audit Checklist

- [ ] All external functions have access control
- [ ] Reentrancy guards on state-changing functions
- [ ] Integer overflow/underflow protection (Solidity 0.8+)
- [ ] Events emitted for all state changes
- [ ] Gas optimization reviewed
- [ ] Edge cases tested
- [ ] Integration points secured

---

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing (100% coverage)
- [ ] Contract compiled without warnings
- [ ] Gas usage optimized
- [ ] Security review completed
- [ ] Documentation updated

### Deployment Steps

1. **Deploy Referral Contract**
   ```bash
   npx hardhat run scripts/03_deploy_referral.ts --network localhost
   ```

2. **Allocate Tokens**
   ```typescript
   await vlrToken.allocate("referral", referralAddress, parseEther("5000000"));
   ```

3. **Set Authorized Contracts**
   ```typescript
   await referralContract.setAuthorizedContract(presaleAddress, true);
   await referralContract.setAuthorizedContract(stakingAddress, true);
   ```

4. **Update Presale Contract**
   ```typescript
   await presaleContract.setReferralContract(referralAddress);
   ```

5. **Verify Contract**
   ```bash
   npx hardhat verify --network sepolia <REFERRAL_ADDRESS> <CONSTRUCTOR_ARGS>
   ```

### Post-Deployment

- [ ] Contract verified on Etherscan
- [ ] Token allocation confirmed
- [ ] Authorized contracts set
- [ ] Integration tested
- [ ] Documentation updated with addresses
- [ ] Monitoring setup

---

## Gas Optimization

### Estimated Gas Costs

| Function | Estimated Gas | Notes |
|----------|--------------|-------|
| register() | ~80,000 | First registration |
| distributePurchaseBonus() | ~50,000 | Called by presale |
| distributeStakingBonus() | ~50,000 | Called by staking |
| claimRewards() | ~45,000 | Token transfer |
| getTierBonuses() | ~500 | View function |

### Optimization Strategies

1. Use `uint256` for all counters (cheaper than smaller types)
2. Pack struct variables efficiently
3. Use mappings instead of arrays where possible
4. Cache storage variables in memory
5. Use events instead of storing historical data

---

## Frontend Integration

### Key Functions for Frontend

```typescript
// Get referrer info
const referrerInfo = await referralContract.getReferrerInfo(address);
// Returns: { level, directReferrals, totalEarned }

// Get pending rewards
const pending = await referralContract.pendingRewards(address);

// Register with referrer
await referralContract.register(referrerAddress);

// Claim rewards
await referralContract.claimRewards();

// Get tier bonuses
const [purchaseBonus, stakingBonus] = await referralContract.getTierBonuses(tier);
```

### Referral Link Generation

```typescript
// Generate referral link
const referralLink = `https://velirion.io/presale?ref=${userAddress}`;

// Parse referral from URL
const urlParams = new URLSearchParams(window.location.search);
const referrer = urlParams.get('ref');
```

---

## Success Metrics

### KPIs to Track

1. **Adoption Metrics**
   - Total registered referrers
   - Active referrers (with ≥1 referral)
   - Tier distribution (% in each tier)

2. **Performance Metrics**
   - Total bonuses distributed
   - Average bonus per referrer
   - Top referrers by volume

3. **Technical Metrics**
   - Gas costs per transaction
   - Contract balance utilization
   - Integration success rate

---

## Troubleshooting

### Common Issues

**Issue**: Registration fails with "Referrer not active"
- **Solution**: Ensure referrer has registered first or use owner address

**Issue**: Bonus not distributed
- **Solution**: Check presale contract has referral contract address set

**Issue**: Cannot claim rewards
- **Solution**: Verify contract has sufficient VLR token balance

**Issue**: Tier not upgrading
- **Solution**: Check referral count and tier upgrade thresholds

---

## Next Steps (Milestone 4)

After completing Milestone 3, proceed to:

1. **Staking Contract Development**
   - Integrate referral bonuses into staking rewards
   - Implement 4-tier staking system
   - Add staking bonus distribution calls

2. **NFT Rewards System**
   - Create NFT contract for tier rewards
   - Implement automatic NFT minting for Tier 2+
   - Design NFT metadata and artwork

3. **Analytics Dashboard**
   - Build referral tracking dashboard
   - Display tier progression
   - Show earnings breakdown

---

## Resources

- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts/
- **Hardhat Documentation**: https://hardhat.org/docs
- **Ethers.js v6**: https://docs.ethers.org/v6/
- **Solidity Style Guide**: https://docs.soliditylang.org/en/latest/style-guide.html

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Implementation Ready ✅
