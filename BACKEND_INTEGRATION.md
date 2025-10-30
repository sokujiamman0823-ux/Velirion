# Backend Integration Guide

## 🌐 Network Configuration

### Ethereum Sepolia Testnet
- **RPC URL**: Use your Alchemy/Infura endpoint
- **Chain ID**: 11155111
- **Block Explorer**: https://sepolia.etherscan.io

### Solana Devnet
- **RPC URL**: https://api.devnet.solana.com
- **Cluster**: devnet
- **Explorer**: https://explorer.solana.com/?cluster=devnet

---

## 📝 Contract Addresses (Sepolia)

```json
{
  "vlrToken": "0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9",
  "presale": "0xAF8021201524b1E487350F48D5609dFE7ecBb529",
  "referral": "0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8",
  "staking": "0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F",
  "dao": "0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE",
  "treasury": "0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1",
  "referralNFT": "0x11aC4D9569a4F51C3c00529931b54d55335cE3b4",
  "guardianNFT": "0x0baF2aca6044dCb120034E278Ba651F048658C19",
  "usdt": "0x96f7e7bDc6d2403e5FeEa154591566469c6aCA13",
  "usdc": "0xF036E0Ce0f69C3ff6660C240619872f923e58ebc"
}
```

**ABIs**: Available on Etherscan (verified contracts) or in `artifacts/contracts/` after compilation.

---

## 🛒 Presale Integration

### Purchase Flow

#### 1. Check Phase Status
```javascript
const phaseActive = await presaleContract.isPhaseActive();
const currentPhase = await presaleContract.getCurrentPhaseInfo();

console.log('Phase Active:', phaseActive);
console.log('Price per VLR:', ethers.utils.formatEther(currentPhase.pricePerToken), 'USD');
console.log('Sold:', ethers.utils.formatEther(currentPhase.soldTokens), 'VLR');
console.log('Max:', ethers.utils.formatEther(currentPhase.maxTokens), 'VLR');
```

#### 2. Calculate Token Amount
```javascript
// For ETH payment
const ethAmount = ethers.utils.parseEther("0.1"); // 0.1 ETH
const tokenAmount = await presaleContract.calculateTokenAmountForETH(ethAmount);

// For USD stablecoins (USDT/USDC with 6 decimals)
const usdAmount = ethers.utils.parseUnits("100", 6); // 100 USDT/USDC
const usdValue = ethers.BigNumber.from(usdAmount).mul(ethers.BigNumber.from(10).pow(12)); // Convert to 18 decimals
const tokenAmount = await presaleContract.calculateTokenAmount(usdValue);
```

#### 3. Check Purchase Eligibility
```javascript
const [canPurchase, reason] = await presaleContract.canPurchase(userAddress);
if (!canPurchase) {
  console.log('Cannot purchase:', reason); // e.g., "Wait 300 seconds"
}

// Check wallet limits
const totalPurchased = await presaleContract.totalPurchasedVLR(userAddress);
const maxPerWallet = await presaleContract.MAX_PER_WALLET(); // 500,000 VLR
const remaining = maxPerWallet.sub(totalPurchased);
```

#### 4. Execute Purchase

**With ETH:**
```javascript
const tx = await presaleContract.buyWithETH(referrerAddress, {
  value: ethAmount,
  gasLimit: 500000
});
await tx.wait();
```

**With USDT:**
```javascript
// 1. Approve USDT
const usdtContract = new ethers.Contract(usdtAddress, erc20Abi, signer);
const approveTx = await usdtContract.approve(presaleAddress, usdtAmount);
await approveTx.wait();

// 2. Purchase
const tx = await presaleContract.buyWithUSDT(usdtAmount, referrerAddress, {
  gasLimit: 500000
});
await tx.wait();
```

**With USDC:**
```javascript
// Same as USDT
const usdcContract = new ethers.Contract(usdcAddress, erc20Abi, signer);
const approveTx = await usdcContract.approve(presaleAddress, usdcAmount);
await approveTx.wait();

const tx = await presaleContract.buyWithUSDC(usdcAmount, referrerAddress, {
  gasLimit: 500000
});
await tx.wait();
```

#### 5. Check Vesting Schedule
```javascript
const schedule = await presaleContract.getVestingSchedule(userAddress);

console.log('Total Purchased:', ethers.utils.formatEther(schedule.totalAmount), 'VLR');
console.log('TGE (40%):', ethers.utils.formatEther(schedule.tgeAmount), 'VLR');
console.log('Month 1 (30%):', ethers.utils.formatEther(schedule.month1Amount), 'VLR');
console.log('Month 2 (30%):', ethers.utils.formatEther(schedule.month2Amount), 'VLR');
console.log('Already Claimed:', ethers.utils.formatEther(schedule.claimedAmount), 'VLR');
```

#### 6. Claim Vested Tokens
```javascript
// Check claimable amount
const claimable = await presaleContract.getClaimableAmount(userAddress);
console.log('Claimable now:', ethers.utils.formatEther(claimable), 'VLR');

// Claim
if (claimable.gt(0)) {
  const tx = await presaleContract.claimTokens({ gasLimit: 300000 });
  await tx.wait();
  console.log('Claimed!');
}
```

### Vesting Schedule
- **TGE (Immediate)**: 40% available immediately after purchase
- **Month 1 (+30 days)**: 30% unlocks 30 days after presale starts
- **Month 2 (+60 days)**: 30% unlocks 60 days after presale starts

### Antibot Protection
- **5-minute delay** between purchases per wallet
- **Max 50,000 VLR** per transaction
- **Max 500,000 VLR** per wallet across all purchases

---

## 👥 Referral Integration

### Register User with Referrer
```javascript
const referralContract = new ethers.Contract(referralAddress, referralAbi, signer);

// Check if already registered
const existingReferrer = await referralContract.getReferrer(userAddress);
if (existingReferrer === ethers.constants.AddressZero) {
  // Not registered, register with referrer
  const tx = await referralContract.register(referrerAddress, { gasLimit: 200000 });
  await tx.wait();
}
```

### Get Referral Stats
```javascript
const stats = await referralContract.getReferralStats(userAddress);

console.log('Direct Referrals:', stats.directReferrals.length);
console.log('Total Volume:', ethers.utils.formatEther(stats.totalVolume), 'VLR');
console.log('Total Staking Volume:', ethers.utils.formatEther(stats.totalStakingVolume), 'VLR');

// Get referrer info
const referrerData = await referralContract.getReferrerData(userAddress);
console.log('Tier:', referrerData.level); // 1=Starter, 2=Bronze, 3=Silver, 4=Gold
console.log('Direct Referrals Count:', referrerData.directReferrals.toString());
console.log('Total Earned:', ethers.utils.formatEther(referrerData.totalEarned), 'VLR');
```

### Tier Thresholds
- **Starter (Tier 1)**: 0 referrals → 5% purchase, 2% staking bonus
- **Bronze (Tier 2)**: 10+ referrals → 7% purchase, 3% staking bonus
- **Silver (Tier 3)**: 25+ referrals → 10% purchase, 4% staking bonus
- **Gold (Tier 4)**: 50+ referrals → 12% purchase, 5% staking bonus

### Claim Referral Rewards
```javascript
const pending = await referralContract.getPendingRewards(userAddress);
console.log('Pending Rewards:', ethers.utils.formatEther(pending), 'VLR');

if (pending.gt(0)) {
  const tx = await referralContract.claimRewards({ gasLimit: 200000 });
  await tx.wait();
}
```

---

## 🔒 Staking Integration

### Stake Tokens
```javascript
const stakingContract = new ethers.Contract(stakingAddress, stakingAbi, signer);
const vlrContract = new ethers.Contract(vlrAddress, erc20Abi, signer);

// Tier enum: 0=Flexible, 1=Medium, 2=Long, 3=Elite
const tier = 1; // Medium
const amount = ethers.utils.parseEther("1000"); // 1000 VLR
const lockDuration = 90 * 24 * 60 * 60; // 90 days in seconds

// 1. Approve VLR
const approveTx = await vlrContract.approve(stakingAddress, amount);
await approveTx.wait();

// 2. Stake
const tx = await stakingContract.stake(amount, tier, lockDuration, { gasLimit: 400000 });
await tx.wait();
```

### Get Stake Info
```javascript
const stakeIds = await stakingContract.getUserStakes(userAddress);

for (const stakeId of stakeIds) {
  const info = await stakingContract.getStakeInfo(userAddress, stakeId);
  const [amount, startTime, lockDuration, tier, apr, renewed, active] = info;
  
  console.log('Stake ID:', stakeId.toString());
  console.log('Amount:', ethers.utils.formatEther(amount), 'VLR');
  console.log('APR:', apr.toString(), 'bps'); // e.g., 1200 = 12%
  console.log('Lock:', lockDuration.toNumber() / 86400, 'days');
  console.log('Active:', active);
}
```

### Calculate and Claim Rewards
```javascript
const stakeId = stakeIds[0];
const rewards = await stakingContract.calculateRewards(userAddress, stakeId);
console.log('Pending Rewards:', ethers.utils.formatEther(rewards), 'VLR');

// Claim rewards
const tx = await stakingContract.claimRewards(stakeId, { gasLimit: 300000 });
await tx.wait();
```

### Staking Tiers
| Tier | APR | Lock Period | Min Stake |
|------|-----|-------------|-----------|
| Flexible | 6% | No lock | 100 VLR |
| Medium | 12-15% | 90-180 days | 1,000 VLR |
| Long | 20-22% | 365 days | 5,000 VLR |
| Elite | 30-32% | 730 days | 250,000 VLR |

**Special**: Long/Elite tiers get +2% APR on renewal and 2× DAO voting power.

---

## 🏛️ DAO Integration

### Create Proposal
```javascript
const daoContract = new ethers.Contract(daoAddress, daoAbi, signer);
const vlrContract = new ethers.Contract(vlrAddress, erc20Abi, signer);

// Burn 10,000 VLR to create proposal
const threshold = await daoContract.PROPOSAL_THRESHOLD(); // 10,000 VLR

// 1. Approve DAO to burn
const approveTx = await vlrContract.approve(daoAddress, threshold);
await approveTx.wait();

// 2. Create proposal
const targets = [someContractAddress];
const values = [0];
const calldatas = [encodedFunctionCall];
const description = "Proposal description";

const tx = await daoContract.propose(targets, values, calldatas, description, {
  gasLimit: 500000
});
await tx.wait();
```

### Vote on Proposal
```javascript
const proposalId = 1;
const burnAmount = ethers.utils.parseEther("100"); // Burn 100 VLR to vote

// 1. Approve burn
const approveTx = await vlrContract.approve(daoAddress, burnAmount);
await approveTx.wait();

// 2. Cast vote (0=against, 1=for, 2=abstain)
const tx = await daoContract.castVote(proposalId, 1, burnAmount, "I support this", {
  gasLimit: 400000
});
await tx.wait();
```

### Check Proposal Status
```javascript
const proposal = await daoContract.getProposal(proposalId);
const state = await daoContract.state(proposalId);

// States: 0=Pending, 1=Active, 2=Defeated, 3=Succeeded, 4=Queued, 5=Executed, 6=Canceled
const stateNames = ["Pending", "Active", "Defeated", "Succeeded", "Queued", "Executed", "Canceled"];
console.log('State:', stateNames[state]);

console.log('For Votes:', ethers.utils.formatEther(proposal.forVotes), 'VLR');
console.log('Against Votes:', ethers.utils.formatEther(proposal.againstVotes), 'VLR');

const quorumReached = await daoContract.quorumReached(proposalId);
console.log('Quorum Reached:', quorumReached); // Needs 100,000 VLR total votes
```

### DAO Parameters
- **Proposal Threshold**: 10,000 VLR (burned)
- **Voting Period**: 7 days
- **Voting Delay**: 1 day before voting starts
- **Quorum**: 100,000 VLR total votes
- **Timelock**: 2 days before execution

---

## 🔧 Gas Configuration

### Recommended Settings (Sepolia)
```javascript
const gasConfig = {
  gasPrice: ethers.utils.parseUnits("2", "gwei"), // 2 gwei
  gasLimit: 500000 // 500k for most operations
};

// For complex operations (DAO proposals, multi-step)
const highGasConfig = {
  gasPrice: ethers.utils.parseUnits("3", "gwei"),
  gasLimit: 800000
};
```

### Mainnet (Production)
- Use dynamic gas pricing from provider
- Set max priority fee and max fee per gas
- Monitor gas prices via Etherscan Gas Tracker

---

## 🔐 Security Best Practices

1. **Never expose private keys**
   - Use environment variables
   - Use secure key management (AWS KMS, HashiCorp Vault)
   - Separate keys for testnet and mainnet

2. **Validate user inputs**
   - Check amounts are within limits
   - Verify addresses are valid
   - Sanitize all user-provided data

3. **Handle errors gracefully**
   - Catch and log transaction failures
   - Provide user-friendly error messages
   - Implement retry logic for network issues

4. **Monitor contract events**
   - Listen for `TokensPurchased`, `Staked`, `VoteCast` events
   - Update database on confirmed transactions
   - Handle chain reorganizations

5. **Rate limiting**
   - Respect antibot delays (5 minutes for presale)
   - Implement backend rate limiting
   - Queue transactions if needed

---

## 📊 Event Monitoring

### Listen for Presale Events
```javascript
presaleContract.on("TokensPurchased", (buyer, phaseId, amountPaid, tokenAmount, paymentToken, referrer, event) => {
  console.log('Purchase:', {
    buyer,
    phase: phaseId.toString(),
    paid: ethers.utils.formatEther(amountPaid),
    tokens: ethers.utils.formatEther(tokenAmount),
    paymentToken,
    referrer,
    txHash: event.transactionHash
  });
});

presaleContract.on("TokensClaimed", (user, amount, event) => {
  console.log('Claimed:', {
    user,
    amount: ethers.utils.formatEther(amount),
    txHash: event.transactionHash
  });
});
```

### Listen for Staking Events
```javascript
stakingContract.on("Staked", (user, stakeId, amount, tier, lockDuration, apr, event) => {
  console.log('Staked:', {
    user,
    stakeId: stakeId.toString(),
    amount: ethers.utils.formatEther(amount),
    tier: tier.toString(),
    lock: lockDuration.toNumber() / 86400 + ' days',
    apr: apr.toString() + ' bps'
  });
});
```

---

## 🌐 Etherscan Integration

### Verified Contracts
All contracts are verified on Sepolia Etherscan with:
- **Compiler**: v0.8.20
- **Optimization**: Yes (200 runs)
- **EVM Version**: paris

### Read Contract Data
Visit contract pages on Etherscan and use "Read Contract" tab:
- VLR Token: https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9#readContract
- Presale: https://sepolia.etherscan.io/address/0xAF8021201524b1E487350F48D5609dFE7ecBb529#readContract

### Write Contract (Testing)
Use "Write Contract" tab to test transactions directly from Etherscan (connect wallet required).

---

## 📞 Support & Resources

- **Documentation**: See `TESTING_GUIDE.md`, `DEPLOYMENT_SUMMARY.md`
- **Test Scripts**: `scripts/test-*.js`
- **Contract Source**: `contracts/`
- **Etherscan**: https://sepolia.etherscan.io

---

**Last Updated**: October 29, 2025
**Network**: Sepolia Testnet
**Status**: Ready for Integration
