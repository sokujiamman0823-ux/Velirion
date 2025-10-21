# Milestone 3: Referral System Integration Guide

## Overview

This guide explains how to integrate the VelirionReferral contract with the existing presale system and prepare for future staking integration.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     VelirionToken (ERC-20)                   │
│                  100M Supply, Burnable                       │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               │                              │
    ┌──────────▼──────────┐        ┌─────────▼──────────┐
    │ PresaleContractV2   │◄──────►│ VelirionReferral   │
    │ - 10 Phases         │        │ - 4 Tiers          │
    │ - Vesting           │        │ - Bonus Distribution│
    │ - Multi-token       │        │ - Reward Claiming  │
    └─────────────────────┘        └────────────────────┘
                                            │
                                            │
                                   ┌────────▼──────────┐
                                   │ VelirionStaking   │
                                   │ (Future M4)       │
                                   └───────────────────┘
```

---

## Integration Steps

### Step 1: Deploy Referral Contract

```bash
# Deploy referral contract
npx hardhat run scripts/03_deploy_referral.ts --network localhost

# This will:
# - Deploy VelirionReferral
# - Allocate 5M VLR tokens
# - Set presale as authorized contract
# - Save deployment info
```

### Step 2: Update Presale Contract

The presale contract needs to be updated to work with the external referral system. Here are the required changes:

#### Add Referral Contract Reference

```solidity
// In PresaleContractV2.sol

import "../interfaces/IVelirionReferral.sol";

contract VelirionPresaleV2 {
    // Add state variable
    IVelirionReferral public referralContract;
    
    // Add setter function
    function setReferralContract(address _referralContract) external onlyOwner {
        require(_referralContract != address(0), "Invalid address");
        referralContract = IVelirionReferral(_referralContract);
    }
}
```

#### Update Purchase Flow

```solidity
// Modify _processPurchase function

function _processPurchase(
    address buyer,
    uint256 usdValue,
    address paymentToken,
    address referrer
) internal returns (uint256) {
    // ... existing validation and calculation ...
    
    // Setup vesting
    _setupVesting(buyer, tokenAmount);
    
    // NEW: Register referral if needed
    if (referrer != address(0) && referrer != buyer) {
        _handleReferral(buyer, referrer, tokenAmount);
    }
    
    return tokenAmount;
}

function _handleReferral(
    address buyer,
    address referrer,
    uint256 tokenAmount
) internal {
    if (address(referralContract) == address(0)) return;
    
    // Check if buyer needs to register
    address existingReferrer = referralContract.getReferrer(buyer);
    
    if (existingReferrer == address(0)) {
        // Register buyer with referrer
        try referralContract.register(referrer) {
            // Registration successful
        } catch {
            // Registration failed, continue without referral
            return;
        }
    }
    
    // Distribute purchase bonus
    try referralContract.distributePurchaseBonus(buyer, tokenAmount) {
        // Bonus distributed
    } catch {
        // Failed to distribute, continue
    }
}
```

#### Remove Internal Referral Logic

The old internal referral logic can be removed or deprecated:

```solidity
// DEPRECATED: Old referral system
// struct Referral { ... }
// mapping(address => Referral) public referrals;
// function _processReferral(...) { ... }
```

### Step 3: Test Integration

Create integration tests to verify the connection:

```typescript
// test/Integration_Presale_Referral.test.ts

describe("Presale + Referral Integration", function () {
  it("Should register and distribute bonus on purchase", async function () {
    // 1. User1 registers with referrer
    await referralContract.connect(user1).register(referrer.address);
    
    // 2. User1 makes purchase
    await presaleContract.connect(user1).buyWithETH(referrer.address, {
      value: ethers.parseEther("1")
    });
    
    // 3. Verify referrer received bonus
    const pending = await referralContract.getPendingRewards(referrer.address);
    expect(pending).to.be.gt(0);
  });
});
```

---

## Usage Flows

### Flow 1: New User Purchase with Referral

```
1. User visits site with referral link: https://velirion.io?ref=0x123...
2. Frontend extracts referrer address from URL
3. User connects wallet and initiates purchase
4. Frontend calls: presale.buyWithETH(referrerAddress)
5. Presale contract:
   a. Validates purchase
   b. Calls referralContract.register(referrer) if needed
   c. Calls referralContract.distributePurchaseBonus(buyer, amount)
6. Referrer's pending rewards updated
7. User receives vested tokens
```

### Flow 2: Referrer Claims Rewards

```
1. Referrer checks pending rewards: referralContract.getPendingRewards(address)
2. Referrer calls: referralContract.claimRewards()
3. Contract transfers VLR tokens to referrer
4. Pending rewards reset to 0
```

### Flow 3: Tier Upgrade

```
1. Referrer accumulates direct referrals
2. On each new referral registration:
   a. Contract increments directReferrals count
   b. Contract checks tier thresholds
   c. If threshold met, tier automatically upgrades
   d. TierUpgraded event emitted
3. Future bonuses calculated at new tier rate
```

---

## Frontend Integration

### React/TypeScript Example

```typescript
import { ethers } from 'ethers';

// Contract ABIs
import ReferralABI from './abis/VelirionReferral.json';
import PresaleABI from './abis/PresaleContractV2.json';

// Contract addresses
const REFERRAL_ADDRESS = "0x...";
const PRESALE_ADDRESS = "0x...";

// Initialize contracts
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

const referralContract = new ethers.Contract(
  REFERRAL_ADDRESS,
  ReferralABI,
  signer
);

const presaleContract = new ethers.Contract(
  PRESALE_ADDRESS,
  PresaleABI,
  signer
);

// Get referrer from URL
function getReferrerFromURL(): string | null {
  const params = new URLSearchParams(window.location.search);
  return params.get('ref');
}

// Register with referrer
async function registerReferral(referrerAddress: string) {
  try {
    const tx = await referralContract.register(referrerAddress);
    await tx.wait();
    console.log('Registered with referrer:', referrerAddress);
  } catch (error) {
    console.error('Registration failed:', error);
  }
}

// Purchase with referral
async function purchaseWithReferral(ethAmount: string, referrer: string) {
  try {
    const tx = await presaleContract.buyWithETH(referrer, {
      value: ethers.parseEther(ethAmount)
    });
    await tx.wait();
    console.log('Purchase successful');
  } catch (error) {
    console.error('Purchase failed:', error);
  }
}

// Get referrer info
async function getReferrerInfo(address: string) {
  const [level, directReferrals, totalEarned] = 
    await referralContract.getReferrerInfo(address);
  
  return {
    tier: level.toString(),
    referrals: directReferrals.toString(),
    earned: ethers.formatEther(totalEarned)
  };
}

// Get pending rewards
async function getPendingRewards(address: string) {
  const pending = await referralContract.getPendingRewards(address);
  return ethers.formatEther(pending);
}

// Claim rewards
async function claimRewards() {
  try {
    const tx = await referralContract.claimRewards();
    await tx.wait();
    console.log('Rewards claimed successfully');
  } catch (error) {
    console.error('Claim failed:', error);
  }
}

// Generate referral link
function generateReferralLink(userAddress: string): string {
  return `https://velirion.io/presale?ref=${userAddress}`;
}
```

### React Component Example

```tsx
import React, { useState, useEffect } from 'react';

function ReferralDashboard({ userAddress }) {
  const [referrerInfo, setReferrerInfo] = useState(null);
  const [pendingRewards, setPendingRewards] = useState('0');
  const [referralLink, setReferralLink] = useState('');

  useEffect(() => {
    loadReferrerData();
  }, [userAddress]);

  async function loadReferrerData() {
    const info = await getReferrerInfo(userAddress);
    const pending = await getPendingRewards(userAddress);
    const link = generateReferralLink(userAddress);

    setReferrerInfo(info);
    setPendingRewards(pending);
    setReferralLink(link);
  }

  async function handleClaim() {
    await claimRewards();
    await loadReferrerData(); // Refresh data
  }

  return (
    <div className="referral-dashboard">
      <h2>Referral Dashboard</h2>
      
      <div className="tier-info">
        <h3>Tier {referrerInfo?.tier}</h3>
        <p>Direct Referrals: {referrerInfo?.referrals}</p>
        <p>Total Earned: {referrerInfo?.earned} VLR</p>
      </div>

      <div className="pending-rewards">
        <h3>Pending Rewards</h3>
        <p>{pendingRewards} VLR</p>
        <button onClick={handleClaim}>Claim Rewards</button>
      </div>

      <div className="referral-link">
        <h3>Your Referral Link</h3>
        <input type="text" value={referralLink} readOnly />
        <button onClick={() => navigator.clipboard.writeText(referralLink)}>
          Copy Link
        </button>
      </div>
    </div>
  );
}
```

---

## Testing Checklist

### Unit Tests
- [x] Referral registration
- [x] Tier upgrades
- [x] Bonus calculations
- [x] Reward claiming
- [x] Access control

### Integration Tests
- [ ] Presale purchase triggers bonus
- [ ] Multiple purchases accumulate
- [ ] Tier upgrade affects bonus rate
- [ ] Claim after multiple bonuses
- [ ] Error handling

### Manual Testing
- [ ] Deploy to localhost
- [ ] Register referral relationship
- [ ] Make test purchase
- [ ] Verify bonus distributed
- [ ] Claim rewards
- [ ] Check tier progression

---

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Gas optimization reviewed
- [ ] Security audit completed
- [ ] Documentation updated

### Deployment Sequence
1. [ ] Deploy VelirionReferral
2. [ ] Allocate 5M VLR tokens
3. [ ] Set presale as authorized
4. [ ] Update presale with referral address
5. [ ] Verify contracts on Etherscan
6. [ ] Test integration on testnet

### Post-Deployment
- [ ] Monitor first transactions
- [ ] Verify bonus distributions
- [ ] Check tier upgrades
- [ ] Update frontend
- [ ] Announce to community

---

## Troubleshooting

### Issue: Bonus not distributed

**Symptoms**: Purchase completes but referrer receives no bonus

**Solutions**:
1. Check presale has referral contract set
2. Verify referral contract is authorized
3. Check referral contract has VLR balance
4. Verify referrer is registered and active

### Issue: Cannot register referral

**Symptoms**: Registration transaction reverts

**Solutions**:
1. Check referrer address is valid (not zero)
2. Verify referrer is active (has registered)
3. Ensure user hasn't already registered
4. Check user isn't trying to self-refer

### Issue: Cannot claim rewards

**Symptoms**: Claim transaction reverts

**Solutions**:
1. Check pending rewards > 0
2. Verify contract has sufficient VLR balance
3. Ensure contract isn't paused
4. Check for reentrancy issues

---

## Gas Optimization Tips

1. **Batch Operations**: Register multiple users in one transaction if possible
2. **Claim Timing**: Wait to accumulate rewards before claiming
3. **View Functions**: Use view functions for UI updates (no gas cost)
4. **Event Listening**: Listen to events instead of polling state

---

## Security Considerations

### Critical Checks
- ✅ Only authorized contracts can distribute bonuses
- ✅ Reentrancy protection on claims
- ✅ No self-referral allowed
- ✅ One-time referrer assignment
- ✅ Pausable in emergency

### Best Practices
- Always validate referrer address
- Check contract balance before transfers
- Use SafeERC20 for token transfers
- Emit events for all state changes
- Implement emergency pause

---

## Future Enhancements (Milestone 4+)

### Staking Integration
```solidity
// In VelirionStaking.sol

function claimRewards(uint256 stakeId) external {
    uint256 rewards = _calculateRewards(msg.sender, stakeId);
    
    // Notify referral contract
    if (address(referralContract) != address(0)) {
        referralContract.distributeStakingBonus(msg.sender, rewards);
    }
    
    // Transfer rewards
    vlrToken.safeTransfer(msg.sender, rewards);
}
```

### NFT Rewards
- Tier 2+: Automatic NFT minting
- Special artwork for each tier
- NFT marketplace integration
- Staking NFTs for extra benefits

### Analytics Dashboard
- Real-time referral tracking
- Tier progression visualization
- Earnings breakdown
- Leaderboard system

---

## Support & Resources

- **Documentation**: `/docs/milestone 3/`
- **Tests**: `/test/03_Referral.test.ts`
- **Deployment**: `/scripts/03_deploy_referral.ts`
- **Contract**: `/contracts/core/VelirionReferral.sol`

---

**Last Updated**: October 21, 2025  
**Version**: 1.0  
**Status**: Ready for Integration ✅
