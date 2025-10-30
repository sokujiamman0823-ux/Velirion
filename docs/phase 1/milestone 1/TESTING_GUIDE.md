# VelirionToken Testing Guide

## Quick Start

### Run All Tests
```bash
npx hardhat test
```

### Run Specific Test File
```bash
npx hardhat test test/01_VelirionToken.test.ts
```

### Run with Gas Reporting
```bash
REPORT_GAS=true npx hardhat test
```

### Generate Coverage Report
```bash
npx hardhat coverage
```

---

## Test Suite Overview

### Test File: `test/01_VelirionToken.test.ts`

**Total Tests**: 28  
**Categories**: 6

#### 1. Deployment Tests (5 tests)
- ✅ Correct name and symbol
- ✅ 18 decimals
- ✅ Initial supply minted to owner
- ✅ Correct initial supply (100M)
- ✅ Deployer set as owner

#### 2. Token Allocation Tests (8 tests)
- ✅ Allocate tokens correctly
- ✅ Track multiple allocations to same category
- ✅ Track allocations across different categories
- ✅ Emit TokensAllocated event
- ✅ Revert if non-owner tries to allocate
- ✅ Revert allocation to zero address
- ✅ Revert allocation of zero amount
- ✅ Revert if insufficient balance

#### 3. Burning Tests (6 tests)
- ✅ Burn tokens correctly
- ✅ Burn unsold presale tokens
- ✅ Emit UnsoldTokensBurned event
- ✅ Revert burn of zero amount
- ✅ Revert if non-owner tries to burn unsold
- ✅ Allow users to burn their own tokens

#### 4. Pausable Tests (6 tests)
- ✅ Pause and unpause transfers
- ✅ Emit EmergencyPause event
- ✅ Emit EmergencyUnpause event
- ✅ Revert if non-owner tries to pause
- ✅ Revert if non-owner tries to unpause
- ✅ Block transfers when paused

#### 5. Standard ERC-20 Tests (3 tests)
- ✅ Transfer tokens between accounts
- ✅ Approve and transferFrom
- ✅ Fail transfer with insufficient balance

#### 6. Ownership Tests (3 tests)
- ✅ Transfer ownership
- ✅ Renounce ownership
- ✅ Revert if non-owner tries to transfer ownership

#### 7. Edge Cases (2 tests)
- ✅ Handle maximum supply correctly
- ✅ Handle multiple allocations correctly

---

## Expected Test Output

```
  VelirionToken
    Deployment
      ✔ Should set the correct name and symbol
      ✔ Should have 18 decimals
      ✔ Should mint initial supply to owner
      ✔ Should have correct initial supply
      ✔ Should set the deployer as owner
    Token Allocation
      ✔ Should allocate tokens correctly
      ✔ Should track multiple allocations to same category
      ✔ Should track allocations across different categories
      ✔ Should emit TokensAllocated event
      ✔ Should revert if non-owner tries to allocate
      ✔ Should revert allocation to zero address
      ✔ Should revert allocation of zero amount
      ✔ Should revert if insufficient balance
    Burning
      ✔ Should burn tokens correctly
      ✔ Should burn unsold presale tokens
      ✔ Should emit UnsoldTokensBurned event
      ✔ Should revert burn of zero amount
      ✔ Should revert if non-owner tries to burn unsold
      ✔ Should allow users to burn their own tokens
    Pausable
      ✔ Should pause and unpause transfers
      ✔ Should emit EmergencyPause event
      ✔ Should emit EmergencyUnpause event
      ✔ Should revert if non-owner tries to pause
      ✔ Should revert if non-owner tries to unpause
      ✔ Should block transfers when paused
    Standard ERC20 Functions
      ✔ Should transfer tokens between accounts
      ✔ Should approve and transferFrom
      ✔ Should fail transfer with insufficient balance
    Ownership
      ✔ Should transfer ownership
      ✔ Should renounce ownership
      ✔ Should revert if non-owner tries to transfer ownership
    Edge Cases
      ✔ Should handle maximum supply correctly
      ✔ Should handle multiple allocations correctly

  28 passing (2s)
```

---

## Coverage Requirements

**Minimum Required**: 90%

### Expected Coverage Metrics
- **Statements**: ≥90%
- **Branches**: ≥90%
- **Functions**: ≥90%
- **Lines**: ≥90%

### Coverage Report Location
After running `npx hardhat coverage`, view the report at:
- `coverage/index.html` (Open in browser)
- `coverage/lcov.info` (Machine-readable format)

---

## Gas Optimization

### Run Gas Reporter
```bash
REPORT_GAS=true npx hardhat test
```

### Expected Gas Usage (Approximate)
| Function | Gas Cost |
|----------|----------|
| deploy() | ~2,000,000 |
| transfer() | ~50,000 |
| allocate() | ~70,000 |
| burn() | ~30,000 |
| burnUnsold() | ~35,000 |
| pause() | ~30,000 |
| unpause() | ~30,000 |

---

## Troubleshooting

### Issue: Tests fail with "Cannot find module"
**Solution**: Compile contracts first
```bash
npx hardhat compile
npx hardhat test
```

### Issue: "Task coverage not found"
**Solution**: Install solidity-coverage
```bash
npm install --save-dev solidity-coverage --legacy-peer-deps
```

### Issue: TypeScript errors in test file
**Solution**: These resolve after compilation generates typechain types
```bash
npx hardhat compile
```

### Issue: Gas estimation errors
**Solution**: Ensure you have sufficient test ETH in hardhat network
```bash
npx hardhat node  # Run local node
npx hardhat test --network localhost
```

---

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install
      - run: npx hardhat compile
      - run: npx hardhat test
      - run: npx hardhat coverage
```

---

## Test Maintenance

### Adding New Tests
1. Create test file in `test/` directory
2. Follow naming convention: `##_ContractName.test.ts`
3. Import required dependencies
4. Write descriptive test cases
5. Run tests to verify
6. Update this guide

### Test Best Practices
- ✅ Test one thing per test case
- ✅ Use descriptive test names
- ✅ Test both success and failure cases
- ✅ Test edge cases and boundaries
- ✅ Use proper assertions
- ✅ Clean up after tests (if needed)
- ✅ Keep tests independent

---

## Next Steps

After all tests pass:
1. ✅ Verify coverage ≥90%
2. ✅ Review gas optimization
3. ✅ Deploy to testnet
4. ✅ Run integration tests
5. ✅ Prepare for audit

---

**Last Updated**: October 21, 2025  
**Test Suite Version**: 1.0  
**Status**: ✅ Ready for Execution
