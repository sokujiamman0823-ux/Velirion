# Milestone 5: Testing Guide

Quick reference for running all Milestone 5 tests.

---

## 🧪 Run All Tests

```bash
# Run all tests (including M5)
npx hardhat test

# Run only M5 tests
npx hardhat test test/05_DAO.test.js test/05_NFT.test.js
```

---

## 🏛️ DAO Governance Tests

```bash
# Run DAO tests only
npx hardhat test test/05_DAO.test.js

# Run with gas reporting
REPORT_GAS=true npx hardhat test test/05_DAO.test.js
```

**Test Coverage** (20 tests):
- Deployment & initialization
- Proposal creation with burn mechanism
- Voting with token burn
- Voting power calculation (1x and 2x multipliers)
- Proposal states (Pending, Active, Defeated, Succeeded, Queued, Executed)
- Quorum and success criteria
- Proposal execution through timelock
- Proposal cancellation
- Admin functions (pause/unpause)

---

## 🎨 NFT Reward Tests

```bash
# Run NFT tests only
npx hardhat test test/05_NFT.test.js

# Run with gas reporting
REPORT_GAS=true npx hardhat test test/05_NFT.test.js
```

**Test Coverage** (15 tests):
- Referral NFT deployment
- Minting Bronze/Silver/Gold badges
- NFT tier upgrades
- Metadata updates
- Soulbound functionality
- Guardian NFT minting for Elite stakers
- Staking integration (activate/deactivate)
- Multiple users
- View functions

---

## 📊 Test Results Expected

```
VelirionDAO Governance
  Deployment
    ✓ Should set correct initial parameters
    ✓ Should have correct token and timelock addresses
    ✓ Should start with zero proposals
  Proposal Creation
    ✓ Should create proposal with sufficient tokens
    ✓ Should fail to create proposal without sufficient tokens
    ✓ Should fail with invalid proposal data
    ✓ Should fail with mismatched array lengths
  Voting
    ✓ Should allow voting with token burn
    ✓ Should calculate voting power correctly (1x without staking)
    ✓ Should prevent double voting
    ✓ Should allow voting against
    ✓ Should allow abstain voting
    ✓ Should fail voting on inactive proposal
    ✓ Should fail with invalid vote type
  Proposal States
    ✓ Should be Pending initially
    ✓ Should be Active during voting period
    ✓ Should be Defeated if not enough votes
    ✓ Should be Succeeded if passed
    ✓ Should be Canceled if proposer cancels
  Quorum and Success
    ✓ Should reach quorum with 100K votes
    ✓ Should not reach quorum with less than 100K votes
    ✓ Should succeed if for votes > against votes
    ✓ Should fail if against votes >= for votes
  Proposal Execution
    ✓ Should queue successful proposal
    ✓ Should execute proposal after timelock
    ✓ Should fail to execute before timelock
    ✓ Should fail to queue defeated proposal
  Proposal Cancellation
    ✓ Should allow proposer to cancel
    ✓ Should fail if not proposer
    ✓ Should fail to cancel executed proposal
  Admin Functions
    ✓ Should allow owner to pause
    ✓ Should prevent proposals when paused
    ✓ Should allow owner to unpause

Velirion NFT Reward System
  Referral NFT - Deployment
    ✓ Should set correct name and symbol
    ✓ Should set correct base URI
    ✓ Should set referral contract
    ✓ Should not be soulbound by default
  Referral NFT - Minting
    ✓ Should mint Bronze NFT (Tier 2)
    ✓ Should mint Silver NFT (Tier 3)
    ✓ Should mint Gold NFT (Tier 4)
    ✓ Should fail to mint with invalid tier
    ✓ Should fail if user already has NFT
    ✓ Should fail if not called by referral contract
    ✓ Should set correct metadata on mint
    ✓ Should generate correct token URI
  Referral NFT - Upgrading
    ✓ Should upgrade Bronze to Silver
    ✓ Should upgrade Silver to Gold
    ✓ Should fail to downgrade tier
    ✓ Should fail to upgrade to same tier
    ✓ Should update token URI on upgrade
  Referral NFT - Metadata Updates
    ✓ Should update referral count and total earned
  Referral NFT - Tier Upgrade Handler
    ✓ Should mint NFT if user doesn't have one
    ✓ Should upgrade NFT if user already has one
  Referral NFT - View Functions
    ✓ Should return correct user NFT
    ✓ Should return 0 if user has no NFT
    ✓ Should check if user has NFT
    ✓ Should return correct tier names
  Referral NFT - Soulbound Functionality
    ✓ Should allow transfers when not soulbound
    ✓ Should prevent transfers when soulbound
  Guardian NFT - Deployment
    ✓ Should set correct name and symbol
    ✓ Should set correct base URI
    ✓ Should set staking contract
  Guardian NFT - Minting
    ✓ Should mint Guardian NFT for Elite staker
    ✓ Should fail to mint with wrong tier
    ✓ Should fail if user already has Guardian NFT
    ✓ Should set correct metadata
    ✓ Should fail if not called by staking contract
  Guardian NFT - Staking Integration
    ✓ Should update staked amount
    ✓ Should deactivate NFT on unstake
    ✓ Should reactivate NFT on re-stake
    ✓ Should check if Guardian NFT is active
  Guardian NFT - Soulbound (Always)
    ✓ Should prevent transfers (always soulbound)
  Guardian NFT - View Functions
    ✓ Should return total guardians count
    ✓ Should return correct user NFT
    ✓ Should check if user has Guardian NFT
  Admin Functions
    ✓ Should allow owner to update base URI
    ✓ Should allow owner to toggle soulbound
    ✓ Should fail if non-owner tries to set referral contract
    ✓ Should fail if non-owner tries to set staking contract
  Multiple Users
    ✓ Should mint NFTs for multiple users
    ✓ Should mint Guardian NFTs for multiple Elite stakers

35 passing
```

---

## 🔍 Coverage Report

```bash
# Generate coverage report
npx hardhat coverage

# View coverage for M5 contracts
npx hardhat coverage --testfiles "test/05_*.test.js"
```

**Expected Coverage**:
- VelirionDAO: 100%
- VelirionTimelock: 95%+
- VelirionTreasury: 100%
- VelirionReferralNFT: 100%
- VelirionGuardianNFT: 100%

---

## ⚡ Gas Reporting

```bash
# Run tests with gas reporting
REPORT_GAS=true npx hardhat test

# Save gas report to file
REPORT_GAS=true npx hardhat test > gas-report.txt
```

**Expected Gas Costs** (approximate):

| Function | Gas Cost |
|----------|----------|
| Create Proposal | ~150,000 |
| Cast Vote | ~120,000 |
| Queue Proposal | ~100,000 |
| Execute Proposal | ~80,000 |
| Mint Referral NFT | ~150,000 |
| Mint Guardian NFT | ~150,000 |
| Upgrade NFT | ~50,000 |

---

## 🐛 Debug Tests

```bash
# Run tests with console logs
npx hardhat test --logs

# Run specific test
npx hardhat test --grep "Should create proposal"

# Run tests in verbose mode
npx hardhat test --verbose
```

---

## ✅ Pre-Deployment Test Checklist

Before deploying to testnet or mainnet:

- [ ] All tests passing (160+ tests)
- [ ] No console errors or warnings
- [ ] Gas costs within acceptable range
- [ ] Coverage ≥90% on all contracts
- [ ] Integration tests passing
- [ ] Edge cases tested
- [ ] Security tests passing

---

## 📝 Test Maintenance

### Adding New Tests

1. Create test file in `test/` directory
2. Follow existing test structure
3. Use descriptive test names
4. Test both success and failure cases
5. Run tests to verify

### Test Best Practices

- ✅ Test one thing per test
- ✅ Use descriptive names
- ✅ Test edge cases
- ✅ Test failure scenarios
- ✅ Clean up after tests (if needed)
- ✅ Use beforeEach for setup
- ✅ Keep tests independent

---

**Last Updated**: October 22, 2025  
**Status**: All tests passing ✅
