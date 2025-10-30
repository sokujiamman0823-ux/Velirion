# 📋 Week 2 Action Plan - Integration Testing Phase

**Week**: November 1-7, 2025 (Week 2 of Phase 2)  
**Phase**: Integration Testing  
**Status**: 🟢 **READY TO START**  
**Prerequisites**: ✅ All Week 1 deployments complete

---

## 🎯 Week 2 Objectives

The primary goal of Week 2 is to thoroughly test all deployed contracts on both Ethereum (Sepolia) and Solana (Devnet) to ensure they function correctly before community testing begins.

### Success Criteria
- ✅ All Ethereum contracts tested and functioning
- ✅ All Solana program functions tested and verified
- ✅ Critical bugs identified and fixed
- ✅ Test documentation completed
- ✅ Monitoring systems in place

---

## 📅 Day-by-Day Breakdown

### Day 8 (November 1): Ethereum Core Functions Testing

#### Morning Session: Token & Presale
**Tasks**:
1. Test VelirionToken basic functions
   ```bash
   # Test commands
   npx hardhat test test/VelirionToken.test.ts --network sepolia
   ```
   - [ ] Transfer tokens
   - [ ] Check burn mechanism (0.5%)
   - [ ] Verify balance updates
   - [ ] Test approval/transferFrom

2. Test PresaleContractV2
   ```bash
   npx hardhat test test/PresaleContractV2.test.ts --network sepolia
   ```
   - [ ] Purchase with ETH
   - [ ] Purchase with USDT
   - [ ] Purchase with USDC
   - [ ] Verify token distribution
   - [ ] Test phase transitions

#### Afternoon Session: Referral System
**Tasks**:
3. Test VelirionReferral
   ```bash
   npx hardhat test test/VelirionReferral.test.ts --network sepolia
   ```
   - [ ] Register referral codes
   - [ ] Apply referral codes
   - [ ] Verify bonus calculations
   - [ ] Test tier upgrades
   - [ ] Check referral tracking

**Deliverables**:
- Test results document
- Bug report (if any)
- Transaction logs

---

### Day 9 (November 2): Ethereum Advanced Functions

#### Morning Session: Staking
**Tasks**:
1. Test VelirionStaking (all 4 tiers)
   ```bash
   npx hardhat test test/VelirionStaking.test.ts --network sepolia
   ```
   - [ ] Stake in Bronze tier (30 days, 5% APY)
   - [ ] Stake in Silver tier (90 days, 10% APY)
   - [ ] Stake in Gold tier (180 days, 15% APY)
   - [ ] Stake in Platinum tier (365 days, 20% APY)
   - [ ] Calculate rewards
   - [ ] Test unstaking
   - [ ] Verify penalty calculations

#### Afternoon Session: Governance
**Tasks**:
2. Test VelirionDAO
   ```bash
   npx hardhat test test/VelirionDAO.test.ts --network sepolia
   ```
   - [ ] Create proposal
   - [ ] Cast votes
   - [ ] Execute proposal
   - [ ] Test quorum requirements

3. Test VelirionTimelock
   - [ ] Queue transactions
   - [ ] Execute after delay
   - [ ] Cancel transactions

4. Test VelirionTreasury
   - [ ] Deposit funds
   - [ ] Withdraw funds
   - [ ] Check access controls

**Deliverables**:
- Staking test results
- Governance test results
- APY calculation verification

---

### Day 10 (November 3): NFT & Solana Core Testing

#### Morning Session: NFT Contracts
**Tasks**:
1. Test VelirionReferralNFT
   ```bash
   npx hardhat test test/VelirionReferralNFT.test.ts --network sepolia
   ```
   - [ ] Mint Bronze badge
   - [ ] Mint Silver badge
   - [ ] Mint Gold badge
   - [ ] Verify metadata URIs
   - [ ] Test transfer restrictions

2. Test VelirionGuardianNFT
   ```bash
   npx hardhat test test/VelirionGuardianNFT.test.ts --network sepolia
   ```
   - [ ] Mint Guardian NFT
   - [ ] Verify special privileges
   - [ ] Test access controls

#### Afternoon Session: Solana Basic Functions
**Tasks**:
3. Test Solana SPL Token
   ```bash
   cd solana
   anchor test --skip-local-validator
   ```
   - [ ] Initialize token account
   - [ ] Transfer tokens
   - [ ] Verify 0.5% burn
   - [ ] Check balance updates
   - [ ] Test event emissions

**Deliverables**:
- NFT test results
- Solana basic function tests
- Burn mechanism verification

---

### Day 11 (November 4): Solana Advanced Testing

#### Full Day: Comprehensive Solana Testing
**Tasks**:
1. Test edge cases
   - [ ] Transfer 0 tokens
   - [ ] Transfer to self
   - [ ] Transfer entire balance
   - [ ] Large amount transfers (>1M tokens)
   - [ ] Rapid consecutive transfers

2. Test burn functionality
   - [ ] Automatic burn on transfer
   - [ ] Manual burn function
   - [ ] Burn event verification
   - [ ] Total supply tracking

3. Test error handling
   - [ ] Insufficient balance
   - [ ] Invalid accounts
   - [ ] Unauthorized operations

4. Performance testing
   - [ ] Transaction speed
   - [ ] Gas/compute unit usage
   - [ ] Concurrent transactions

**Deliverables**:
- Comprehensive Solana test report
- Performance metrics
- Edge case documentation

---

### Day 12 (November 5): Integration & Cross-Chain Testing

#### Morning Session: Integration Tests
**Tasks**:
1. Test complete user flows
   - [ ] User journey: Presale → Staking → Rewards
   - [ ] Referral journey: Register → Refer → Earn → NFT
   - [ ] DAO journey: Stake → Propose → Vote → Execute

2. Test cross-contract interactions
   - [ ] Presale → Token → Referral
   - [ ] Staking → Token → Rewards
   - [ ] DAO → Timelock → Treasury

#### Afternoon Session: Documentation
**Tasks**:
3. Document all test results
   - [ ] Create test summary report
   - [ ] Document all bugs found
   - [ ] Prioritize bug fixes
   - [ ] Update user guides

**Deliverables**:
- Integration test report
- User flow documentation
- Bug priority list

---

### Day 13 (November 6): Bug Fixes & Monitoring Setup

#### Morning Session: Bug Fixes
**Tasks**:
1. Fix critical bugs (if any)
   - [ ] Review bug list
   - [ ] Implement fixes
   - [ ] Re-test fixed functions
   - [ ] Document changes

#### Afternoon Session: Monitoring Setup
**Tasks**:
2. Set up monitoring tools
   - [ ] Configure Tenderly for Ethereum
   - [ ] Set up Solana transaction monitoring
   - [ ] Create alert rules
   - [ ] Test alert system

3. Set up analytics
   - [ ] Transaction tracking
   - [ ] User activity monitoring
   - [ ] Gas usage analytics

**Deliverables**:
- Bug fix report
- Monitoring dashboard
- Alert configuration

---

### Day 14 (November 7): Final Testing & Week 2 Report

#### Morning Session: Regression Testing
**Tasks**:
1. Re-run all tests
   - [ ] Ethereum full test suite
   - [ ] Solana full test suite
   - [ ] Integration tests
   - [ ] Verify all fixes

#### Afternoon Session: Week 2 Report
**Tasks**:
2. Prepare completion report
   - [ ] Summarize test results
   - [ ] Document all issues and fixes
   - [ ] Update Phase 2 tracker
   - [ ] Prepare Week 3 plan

**Deliverables**:
- Week 2 completion report
- Updated documentation
- Week 3 action plan

---

## 🛠️ Testing Tools & Scripts

### Ethereum Testing

**Hardhat Commands**:
```bash
# Run all tests on Sepolia
npx hardhat test --network sepolia

# Run specific test file
npx hardhat test test/VelirionToken.test.ts --network sepolia

# Run with gas reporting
REPORT_GAS=true npx hardhat test --network sepolia

# Run with coverage
npx hardhat coverage --network sepolia
```

**Useful Scripts**:
```bash
# Check contract on Etherscan
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>

# Interact with contract
npx hardhat console --network sepolia

# Check deployment
npx hardhat run scripts/check-deployment.ts --network sepolia
```

### Solana Testing

**Anchor Commands**:
```bash
# Run all tests on Devnet
anchor test --skip-local-validator

# Build program
anchor build

# Deploy program
anchor deploy --provider.cluster devnet

# Run specific test
anchor test --skip-local-validator -- --test <TEST_NAME>
```

**Useful Scripts**:
```bash
# Check program on Solana Explorer
solana program show <PROGRAM_ID> --url devnet

# Check token mint
solana account <MINT_ADDRESS> --url devnet

# Initialize token
node scripts/init-simple.js

# Check balance
solana balance --url devnet
```

---

## 📊 Test Tracking Template

### Test Case Template
```markdown
## Test Case: [Function Name]

**Contract**: [Contract Name]
**Network**: [Sepolia/Devnet]
**Date**: [Date]
**Tester**: [Name]

### Test Steps:
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Result:
[What should happen]

### Actual Result:
[What actually happened]

### Status:
- [ ] Pass
- [ ] Fail
- [ ] Blocked

### Notes:
[Any observations]

### Transaction Hash:
[TX hash if applicable]
```

---

## 🚨 Issue Tracking

### Bug Report Template
```markdown
## Bug Report: [Issue Title]

**Severity**: Critical / High / Medium / Low
**Contract**: [Contract Name]
**Network**: [Sepolia/Devnet]
**Discovered**: [Date]

### Description:
[Detailed description of the issue]

### Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior:
[What should happen]

### Actual Behavior:
[What actually happens]

### Impact:
[How this affects users/system]

### Proposed Solution:
[Suggested fix]

### Status:
- [ ] Open
- [ ] In Progress
- [ ] Fixed
- [ ] Verified

### Related Transactions:
[TX hashes if applicable]
```

---

## 📈 Success Metrics

### Testing Coverage Goals
- [ ] 100% of core functions tested
- [ ] 90%+ of edge cases covered
- [ ] All critical paths verified
- [ ] <5 critical bugs found
- [ ] All found bugs documented

### Performance Goals
- [ ] Ethereum gas usage optimized
- [ ] Solana compute units within limits
- [ ] Transaction success rate >99%
- [ ] Average confirmation time <30s

### Documentation Goals
- [ ] All test cases documented
- [ ] All bugs documented
- [ ] User guides updated
- [ ] API documentation complete

---

## 🔗 Resources

### Ethereum Resources
- **Sepolia Etherscan**: https://sepolia.etherscan.io/
- **Sepolia Faucet**: https://sepoliafaucet.com/
- **Hardhat Docs**: https://hardhat.org/docs
- **Deployment Config**: `deployment-sepolia.json`

### Solana Resources
- **Devnet Explorer**: https://explorer.solana.com/?cluster=devnet
- **Devnet Faucet**: https://faucet.solana.com/
- **Anchor Docs**: https://www.anchor-lang.com/
- **Deployment Config**: `solana/deployment-spl.json`

### Monitoring Tools
- **Tenderly**: https://tenderly.co/
- **Defender**: https://defender.openzeppelin.com/
- **Solana Beach**: https://solanabeach.io/

---

## 💡 Tips for Successful Testing

### Best Practices
1. **Test Incrementally**: Start with basic functions, then move to complex
2. **Document Everything**: Record all test results and observations
3. **Use Version Control**: Commit after each major test milestone
4. **Monitor Gas/Compute**: Track resource usage for optimization
5. **Test Edge Cases**: Don't just test happy paths

### Common Pitfalls to Avoid
1. ❌ Testing only happy paths
2. ❌ Not documenting test results
3. ❌ Skipping edge cases
4. ❌ Not verifying on explorers
5. ❌ Ignoring gas optimization

### Debugging Tips
1. Use console.log in Hardhat tests
2. Check transaction logs on Etherscan/Explorer
3. Use Tenderly for transaction simulation
4. Test with different wallet addresses
5. Verify contract state after each test

---

## 📞 Support & Communication

### Daily Standups
- **Time**: 9:00 AM UTC
- **Duration**: 15 minutes
- **Format**: What was tested, any blockers, today's plan

### Issue Escalation
- **Critical bugs**: Immediate notification
- **High priority**: Within 4 hours
- **Medium/Low**: Daily summary

### Progress Reporting
- **Daily**: Brief update in tracker
- **End of Week**: Comprehensive report

---

## ✅ Week 2 Checklist

### Pre-Testing Setup
- [ ] Verify all contracts deployed
- [ ] Confirm wallet has sufficient funds
- [ ] Set up testing environment
- [ ] Prepare test data
- [ ] Configure monitoring tools

### Testing Execution
- [ ] Day 8: Ethereum core functions
- [ ] Day 9: Ethereum advanced functions
- [ ] Day 10: NFT & Solana core
- [ ] Day 11: Solana advanced
- [ ] Day 12: Integration testing
- [ ] Day 13: Bug fixes & monitoring
- [ ] Day 14: Final testing & report

### Post-Testing
- [ ] All tests documented
- [ ] All bugs reported
- [ ] Critical bugs fixed
- [ ] Monitoring active
- [ ] Week 2 report complete

---

**Plan Prepared By**: AI Development Assistant  
**Plan Date**: October 31, 2025  
**Review Date**: November 7, 2025  
**Status**: 🟢 **READY TO EXECUTE**

---

## 🚀 Let's Begin Week 2!

Week 1 was a success with all deployments complete. Week 2 focuses on ensuring everything works perfectly before opening to community testing. Let's make it count! 💪
