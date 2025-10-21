# Milestone 4: Staking Module - Implementation Guide

**Status**: 🟡 Ready to Start  
**Budget**: $150  
**Duration**: 7-8 days  
**Dependencies**: M1 (Token), M3 (Referral)

---

## Table of Contents

1. [Overview](#overview)
2. [Staking Tier System](#staking-tier-system)
3. [Smart Contract Architecture](#smart-contract-architecture)
4. [Implementation Steps](#implementation-steps)
5. [Testing Strategy](#testing-strategy)
6. [Integration Guide](#integration-guide)
7. [Security Considerations](#security-considerations)
8. [Deployment Checklist](#deployment-checklist)

---

## Overview

### Objectives

Implement a sophisticated 4-tier staking system that:
- Offers flexible to long-term staking options (no lock to 2 years)
- Provides competitive APR (6%-30%)
- Integrates with referral bonus system
- Includes early withdrawal penalties
- Supports renewal bonuses
- Enables DAO voting weight for long-term stakers

### Key Features

✅ **4-Tier Staking System**: Flexible, Medium, Long, Elite  
✅ **Variable APR**: 6%-30% based on tier and duration  
✅ **Lock Periods**: None to 2 years  
✅ **Early Withdrawal Penalties**: 5%-10%  
✅ **Renewal Bonuses**: +2% APR for renewals  
✅ **Manual Claim System**: Gas-efficient reward claiming  
✅ **Referral Integration**: Bonus distribution to referrers  
✅ **DAO Voting Weight**: 2x weight for Long/Elite tiers

---

## Staking Tier System

### Tier Structure (Per Specification)

| Tier | APR | Lock Period | Min Amount | Penalty | Benefits |
|------|-----|-------------|------------|---------|----------|
| **Flexible** | 6% | None | 100 VLR | - | Anytime withdrawal |
| **Medium** | 12-15% | 90-180 days | 1,000 VLR | 5% | +2% renewal bonus |
| **Long** | 20-22% | 1 year | 5,000 VLR | 7% | x2 DAO voting weight |
| **Elite** | 30% | 2 years | 250,000 VLR | 10% | Guardian NFT |

### APR Calculation Details

**Flexible Tier**:
- Base APR: 6%
- No lock period
- Rewards accrue per second
- Can withdraw anytime

**Medium Tier**:
- 90 days: 12% APR
- 180 days: 15% APR
- Linear interpolation for periods in between
- 5% penalty if withdrawn early

**Long Tier**:
- 1 year lock: 20% APR
- Can renew for 22% APR (+2% bonus)
- 7% penalty if withdrawn early
- Grants 2x DAO voting weight

**Elite Tier**:
- 2 year lock: 30% APR
- Can renew for 32% APR (+2% bonus)
- 10% penalty if withdrawn early
- Grants 2x DAO voting weight
- Receives Guardian NFT (M5)

---

## Smart Contract Architecture

### Contract Structure

```
contracts/
├── core/
│   ├── VelirionToken.sol          ✅ (M1)
│   ├── VelirionReferral.sol       ✅ (M3)
│   └── VelirionStaking.sol        ⏳ (M4 - To Implement)
├── interfaces/
│   ├── IVelirionToken.sol
│   ├── IVelirionReferral.sol      ✅ (M3)
│   └── IVelirionStaking.sol       ⏳ (M4 - To Implement)
└── libraries/
    └── StakingCalculations.sol    ⏳ (M4 - Optional)
```

### Core Data Structures

```solidity
enum StakingTier {
    Flexible,  // 0: 6% APR, no lock
    Medium,    // 1: 12-15% APR, 90-180 days
    Long,      // 2: 20-22% APR, 1 year
    Elite      // 3: 30% APR, 2 years
}

struct Stake {
    uint256 amount;           // Amount staked
    uint256 startTime;        // When stake started
    uint256 lockDuration;     // Lock period in seconds
    uint256 lastClaimTime;    // Last reward claim
    StakingTier tier;         // Staking tier
    uint16 apr;               // APR in basis points (600 = 6%)
    bool renewed;             // Has been renewed
    bool active;              // Is stake active
}

struct UserStakingInfo {
    uint256 totalStaked;      // Total amount staked
    uint256 totalRewardsClaimed; // Total rewards claimed
    uint256 activeStakes;     // Number of active stakes
    uint256 stakingPower;     // For DAO voting (M5)
}
```

### Key Constants

```solidity
// Minimum stake amounts
uint256 public constant MIN_FLEXIBLE_STAKE = 100 * 10**18;
uint256 public constant MIN_MEDIUM_STAKE = 1000 * 10**18;
uint256 public constant MIN_LONG_STAKE = 5000 * 10**18;
uint256 public constant MIN_ELITE_STAKE = 250000 * 10**18;

// Lock durations
uint256 public constant MEDIUM_MIN_LOCK = 90 days;
uint256 public constant MEDIUM_MAX_LOCK = 180 days;
uint256 public constant LONG_LOCK = 365 days;
uint256 public constant ELITE_LOCK = 730 days;

// APR in basis points (10000 = 100%)
uint16 public constant FLEXIBLE_APR = 600;      // 6%
uint16 public constant MEDIUM_MIN_APR = 1200;   // 12%
uint16 public constant MEDIUM_MAX_APR = 1500;   // 15%
uint16 public constant LONG_APR = 2000;         // 20%
uint16 public constant LONG_RENEWED_APR = 2200; // 22%
uint16 public constant ELITE_APR = 3000;        // 30%
uint16 public constant ELITE_RENEWED_APR = 3200;// 32%

// Penalties in basis points
uint16 public constant MEDIUM_PENALTY = 500;    // 5%
uint16 public constant LONG_PENALTY = 700;      // 7%
uint16 public constant ELITE_PENALTY = 1000;    // 10%

// Renewal bonus
uint16 public constant RENEWAL_BONUS = 200;     // +2%

uint256 public constant BASIS_POINTS = 10000;
uint256 public constant SECONDS_PER_YEAR = 365 days;
```

---

## Implementation Steps

### Step 1: Create Interface

**File**: `contracts/interfaces/IVelirionStaking.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVelirionStaking {
    enum StakingTier { Flexible, Medium, Long, Elite }
    
    // Events
    event Staked(address indexed user, uint256 indexed stakeId, uint256 amount, StakingTier tier);
    event Unstaked(address indexed user, uint256 indexed stakeId, uint256 amount, uint256 penalty);
    event RewardsClaimed(address indexed user, uint256 indexed stakeId, uint256 rewards);
    event StakeRenewed(address indexed user, uint256 indexed stakeId, uint16 newApr);
    
    // Core functions
    function stake(uint256 amount, StakingTier tier, uint256 lockDuration) external;
    function unstake(uint256 stakeId) external;
    function claimRewards(uint256 stakeId) external;
    function renewStake(uint256 stakeId) external;
    
    // View functions
    function calculateRewards(address user, uint256 stakeId) external view returns (uint256);
    function getUserStakes(address user) external view returns (uint256[] memory);
    function getStakeInfo(address user, uint256 stakeId) external view returns (
        uint256 amount,
        uint256 startTime,
        uint256 lockDuration,
        StakingTier tier,
        uint16 apr,
        bool renewed,
        bool active
    );
}
```

### Step 2: Implement Main Contract

**File**: `contracts/core/VelirionStaking.sol`

Key functions to implement:

1. **stake()** - Create new stake
2. **unstake()** - Withdraw stake (with penalty if early)
3. **claimRewards()** - Claim accumulated rewards
4. **renewStake()** - Renew stake for bonus APR
5. **calculateRewards()** - Calculate pending rewards
6. **_calculateAPR()** - Determine APR based on tier and duration
7. **_calculatePenalty()** - Calculate early withdrawal penalty
8. **_distributeReferralBonus()** - Send bonus to referrer

### Step 3: APR Calculation Logic

```solidity
function _calculateAPR(
    StakingTier tier,
    uint256 lockDuration,
    bool renewed
) internal pure returns (uint16) {
    if (tier == StakingTier.Flexible) {
        return FLEXIBLE_APR; // 6%
    }
    
    if (tier == StakingTier.Medium) {
        // Linear interpolation between 12% and 15%
        if (lockDuration <= MEDIUM_MIN_LOCK) return MEDIUM_MIN_APR;
        if (lockDuration >= MEDIUM_MAX_LOCK) return MEDIUM_MAX_APR;
        
        uint256 range = MEDIUM_MAX_LOCK - MEDIUM_MIN_LOCK;
        uint256 position = lockDuration - MEDIUM_MIN_LOCK;
        uint256 aprRange = MEDIUM_MAX_APR - MEDIUM_MIN_APR;
        
        return uint16(MEDIUM_MIN_APR + (aprRange * position) / range);
    }
    
    if (tier == StakingTier.Long) {
        return renewed ? LONG_RENEWED_APR : LONG_APR; // 20% or 22%
    }
    
    if (tier == StakingTier.Elite) {
        return renewed ? ELITE_RENEWED_APR : ELITE_APR; // 30% or 32%
    }
    
    revert("Invalid tier");
}
```

### Step 4: Reward Calculation

```solidity
function calculateRewards(
    address user,
    uint256 stakeId
) public view returns (uint256) {
    Stake memory userStake = stakes[user][stakeId];
    
    if (!userStake.active) return 0;
    
    uint256 stakingDuration = block.timestamp - userStake.lastClaimTime;
    
    // rewards = (amount * APR * time) / (BASIS_POINTS * SECONDS_PER_YEAR)
    uint256 rewards = (userStake.amount * userStake.apr * stakingDuration) 
                     / (BASIS_POINTS * SECONDS_PER_YEAR);
    
    return rewards;
}
```

### Step 5: Early Withdrawal Penalty

```solidity
function _calculatePenalty(
    Stake memory userStake
) internal view returns (uint256) {
    // Flexible tier has no penalty
    if (userStake.tier == StakingTier.Flexible) {
        return 0;
    }
    
    uint256 unlockTime = userStake.startTime + userStake.lockDuration;
    
    // No penalty if lock period completed
    if (block.timestamp >= unlockTime) {
        return 0;
    }
    
    // Calculate penalty based on tier
    uint16 penaltyRate;
    if (userStake.tier == StakingTier.Medium) {
        penaltyRate = MEDIUM_PENALTY; // 5%
    } else if (userStake.tier == StakingTier.Long) {
        penaltyRate = LONG_PENALTY; // 7%
    } else if (userStake.tier == StakingTier.Elite) {
        penaltyRate = ELITE_PENALTY; // 10%
    }
    
    return (userStake.amount * penaltyRate) / BASIS_POINTS;
}
```

### Step 6: Referral Integration

```solidity
function _distributeReferralBonus(
    address staker,
    uint256 rewardAmount
) internal {
    if (address(referralContract) == address(0)) return;
    
    try referralContract.distributeStakingBonus(staker, rewardAmount) {
        // Bonus distributed successfully
    } catch {
        // Failed silently, don't revert user's claim
    }
}
```

---

## Testing Strategy

### Unit Tests (Target: 25+ tests)

**File**: `test/04_Staking.test.js`

1. **Deployment Tests** (3)
   - Deploy with correct token
   - Initialize with correct parameters
   - Set referral contract

2. **Flexible Tier Tests** (4)
   - Stake minimum amount
   - Unstake anytime without penalty
   - Calculate rewards correctly
   - Claim rewards

3. **Medium Tier Tests** (5)
   - Stake with 90-day lock (12% APR)
   - Stake with 180-day lock (15% APR)
   - Calculate APR interpolation
   - Early withdrawal with 5% penalty
   - Withdraw after lock period

4. **Long Tier Tests** (4)
   - Stake for 1 year (20% APR)
   - Renew for 22% APR
   - Early withdrawal with 7% penalty
   - Check DAO voting weight (2x)

5. **Elite Tier Tests** (4)
   - Stake for 2 years (30% APR)
   - Renew for 32% APR
   - Early withdrawal with 10% penalty
   - Check DAO voting weight (2x)

6. **Reward Calculation Tests** (3)
   - Calculate rewards over time
   - Multiple claims
   - Compound staking

7. **Referral Integration Tests** (2)
   - Distribute staking bonus to referrer
   - Verify referrer receives correct percentage

---

## Integration Points

### With Referral Contract (M3)

```solidity
// In VelirionStaking.sol
IVelirionReferral public referralContract;

function claimRewards(uint256 stakeId) external {
    uint256 rewards = calculateRewards(msg.sender, stakeId);
    
    // Update stake
    stakes[msg.sender][stakeId].lastClaimTime = block.timestamp;
    
    // Distribute referral bonus (2%-5% based on referrer tier)
    _distributeReferralBonus(msg.sender, rewards);
    
    // Transfer rewards to user
    vlrToken.safeTransfer(msg.sender, rewards);
    
    emit RewardsClaimed(msg.sender, stakeId, rewards);
}
```

### With DAO Contract (M5)

```solidity
// Voting power calculation for DAO
function getVotingPower(address user) external view returns (uint256) {
    uint256 power = 0;
    
    for (uint256 i = 0; i < userStakes[user].length; i++) {
        Stake memory userStake = stakes[user][i];
        if (!userStake.active) continue;
        
        uint256 stakePower = userStake.amount;
        
        // 2x voting weight for Long and Elite tiers
        if (userStake.tier == StakingTier.Long || userStake.tier == StakingTier.Elite) {
            stakePower *= 2;
        }
        
        power += stakePower;
    }
    
    return power;
}
```

---

## Security Considerations

### Critical Security Measures

1. **ReentrancyGuard**: All external functions that transfer tokens
2. **Pausable**: Emergency stop functionality
3. **Access Control**: Owner-only administrative functions
4. **Input Validation**: All parameters validated
5. **SafeERC20**: All token transfers
6. **Overflow Protection**: Solidity 0.8+ automatic checks

### Specific Checks

```solidity
// Stake validation
require(amount >= getMinimumStake(tier), "Below minimum");
require(lockDuration >= getMinimumLock(tier), "Lock too short");
require(lockDuration <= getMaximumLock(tier), "Lock too long");

// Unstake validation
require(stakes[msg.sender][stakeId].active, "Stake not active");
require(stakes[msg.sender][stakeId].amount > 0, "No stake");

// Reward validation
require(rewards > 0, "No rewards");
require(contractBalance >= rewards, "Insufficient contract balance");
```

---

## Gas Optimization

### Strategies

1. **Pack struct variables** efficiently
2. **Use uint256** for counters (cheaper than smaller types)
3. **Cache storage variables** in memory
4. **Batch operations** where possible
5. **Minimize storage writes**

### Estimated Gas Costs

| Function | Estimated Gas | Notes |
|----------|--------------|-------|
| stake() | ~150,000 | First stake |
| unstake() | ~80,000 | With transfer |
| claimRewards() | ~70,000 | With referral bonus |
| renewStake() | ~50,000 | Update APR |
| calculateRewards() | <1,000 | View function |

---

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing (25+ tests)
- [ ] Contract compiled without warnings
- [ ] Gas optimization reviewed
- [ ] Security review completed
- [ ] Integration with referral tested

### Deployment Steps

1. Deploy VelirionStaking
2. Allocate 20M VLR tokens (20% of supply)
3. Set referral contract address
4. Authorize staking in referral contract
5. Verify contract on Etherscan
6. Test with small amounts first

### Post-Deployment

- [ ] Contract verified
- [ ] Token allocation confirmed
- [ ] Referral integration working
- [ ] First test stakes successful
- [ ] Monitoring setup

---

## Success Metrics

### KPIs to Track

1. **Total Value Locked (TVL)**
2. **Number of stakers**
3. **Average stake duration**
4. **Tier distribution**
5. **Renewal rate**
6. **Referral bonus distribution**

---

## Next Steps (Milestone 5)

After completing M4:

1. Implement DAO governance
2. Add Guardian NFT for Elite tier
3. Create private staking pools
4. Implement voting mechanisms
5. Deploy to mainnet

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Implementation  
**Dependencies**: M1 ✅, M3 ✅
