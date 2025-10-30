# Velirion Presale System - Technical Specification

## Overview

A secure, multi-phase presale system supporting multiple payment tokens with referral tracking and dynamic pricing.

---

## 1. Core Requirements

### 1.1 Multi-Phase System

- **10 Phases** with distinct pricing
- Sequential phase progression
- Configurable start/end times per phase
- Maximum token allocation per phase
- Automatic phase transition

### 1.2 Payment Methods

- **ETH** - Native Ethereum payments
- **USDT** - Tether stablecoin
- **USDC** - USD Coin stablecoin
- Real-time price conversion
- Slippage protection

### 1.3 Token Distribution

- Immediate VLR token distribution
- Accurate price calculations
- Minimum purchase amounts
- Maximum purchase limits per wallet

### 1.4 Referral System

- Referral code generation
- Multi-level referral tracking
- Bonus distribution (5% to referrer)
- Referral statistics

---

## 2. Phase Configuration

### Phase Structure

```solidity
struct Phase {
    uint256 startTime;          // Phase start timestamp
    uint256 endTime;            // Phase end timestamp
    uint256 pricePerToken;      // Price in USD (18 decimals)
    uint256 maxTokens;          // Maximum tokens for this phase
    uint256 soldTokens;         // Tokens sold in this phase
    uint256 minPurchase;        // Minimum purchase amount
    uint256 maxPurchase;        // Maximum purchase per wallet
    bool isActive;              // Phase active status
}
```

### Proposed Phase Pricing

| Phase | Price (USD) | Max Tokens | Duration |
| ----- | ----------- | ---------- | -------- |
| 1     | $0.01       | 5,000,000  | 7 days   |
| 2     | $0.015      | 5,000,000  | 7 days   |
| 3     | $0.02       | 5,000,000  | 7 days   |
| 4     | $0.025      | 5,000,000  | 7 days   |
| 5     | $0.03       | 5,000,000  | 7 days   |
| 6     | $0.035      | 5,000,000  | 7 days   |
| 7     | $0.04       | 5,000,000  | 7 days   |
| 8     | $0.045      | 5,000,000  | 7 days   |
| 9     | $0.05       | 5,000,000  | 7 days   |
| 10    | $0.055      | 5,000,000  | 7 days   |

**Total**: 50,000,000 VLR tokens (50% of supply)

---

## 3. Security Features

### 3.1 Access Control

- Owner-only functions (pause, phase management)
- ReentrancyGuard on all payment functions
- Pausable for emergency stops

### 3.2 Input Validation

- Amount > 0 checks
- Phase active validation
- Token availability checks
- Wallet purchase limits

### 3.3 Safe Math

- OpenZeppelin SafeMath (built into Solidity 0.8+)
- Overflow/underflow protection
- Precision handling for price calculations

### 3.4 Oracle Integration (Future)

- Chainlink price feeds for ETH/USD
- Fallback manual price updates
- Price staleness checks

---

## 4. Contract Architecture

### 4.1 Main Contract: PresaleContract.sol

```
PresaleContract
├── Ownable (access control)
├── Pausable (emergency stop)
├── ReentrancyGuard (reentrancy protection)
└── Interfaces
    ├── IERC20 (VLR token)
    ├── IERC20 (USDT)
    └── IERC20 (USDC)
```

### 4.2 Key Functions

#### Owner Functions

- `initializePhases()` - Set up all 10 phases
- `updatePhase()` - Modify phase parameters
- `setTokenPrice()` - Update token prices
- `withdrawFunds()` - Withdraw collected funds
- `emergencyWithdraw()` - Emergency fund recovery
- `pause() / unpause()` - Emergency controls

#### User Functions

- `buyWithETH(referrer)` - Purchase with ETH
- `buyWithUSDT(amount, referrer)` - Purchase with USDT
- `buyWithUSDC(amount, referrer)` - Purchase with USDC
- `claimTokens()` - Claim purchased tokens (if vesting)
- `getReferralCode()` - Get user's referral code
- `getReferralStats()` - View referral statistics

#### View Functions

- `getCurrentPhase()` - Get active phase info
- `calculateTokenAmount()` - Calculate tokens for payment
- `getUserPurchases()` - Get user purchase history
- `getPhaseInfo()` - Get specific phase details
- `getTotalRaised()` - Get total funds raised

---

## 5. Payment Flow

### 5.1 ETH Payment Flow

```
1. User calls buyWithETH{value: amount}(referrer)
2. Validate phase is active
3. Calculate token amount based on ETH/USD price
4. Validate purchase limits
5. Transfer VLR tokens to user
6. Process referral bonus (if applicable)
7. Emit PurchaseEvent
```

### 5.2 Stablecoin Payment Flow

```
1. User approves USDT/USDC to presale contract
2. User calls buyWithUSDT/USDC(amount, referrer)
3. Validate phase is active
4. Calculate token amount based on USD price
5. Transfer USDT/USDC from user
6. Transfer VLR tokens to user
7. Process referral bonus (if applicable)
8. Emit PurchaseEvent
```

---

## 6. Referral System

### 6.1 Referral Structure

```solidity
struct Referral {
    address referrer;           // Who referred this user
    uint256 totalReferred;      // Number of users referred
    uint256 totalEarned;        // Total bonus earned
    uint256 totalVolume;        // Total purchase volume from referrals
}
```

### 6.2 Referral Bonus

- **5%** bonus to referrer in VLR tokens
- Instant distribution
- No self-referral
- Tracked per transaction

### 6.3 Referral Code

- Generated from user address
- Unique per wallet
- Easy to share
- Verifiable on-chain

---

## 7. Price Oracle Integration

### 7.1 Chainlink Integration (Recommended)

```solidity
// ETH/USD Price Feed
AggregatorV3Interface priceFeed;

function getLatestPrice() public view returns (uint256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return uint256(price) * 10**10; // Convert to 18 decimals
}
```

### 7.2 Manual Price Update (Fallback)

```solidity
uint256 public ethUsdPrice; // Owner can update

function setEthUsdPrice(uint256 _price) external onlyOwner {
    ethUsdPrice = _price;
    emit PriceUpdated(_price);
}
```

---

## 8. Events

```solidity
event PhaseStarted(uint256 indexed phaseId, uint256 startTime);
event PhaseEnded(uint256 indexed phaseId, uint256 endTime);
event TokensPurchased(
    address indexed buyer,
    uint256 indexed phaseId,
    uint256 amount,
    uint256 tokenAmount,
    address paymentToken
);
event ReferralBonus(
    address indexed referrer,
    address indexed referee,
    uint256 bonusAmount
);
event FundsWithdrawn(address indexed owner, uint256 amount);
event PriceUpdated(uint256 newPrice);
```

---

## 9. Testing Strategy

### 9.1 Unit Tests

- Phase initialization
- Purchase with each payment method
- Referral bonus calculation
- Phase transitions
- Access control
- Emergency functions

### 9.2 Integration Tests

- Multi-user purchases
- Phase progression
- Fund withdrawal
- Referral chains
- Edge cases

### 9.3 Security Tests

- Reentrancy attacks
- Overflow/underflow
- Access control bypass
- Price manipulation
- Double spending

---

## 10. Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] Security audit (internal)
- [ ] Gas optimization
- [ ] Documentation complete
- [ ] Deployment scripts ready

### Deployment Steps

1. Deploy VLR token (✅ Done)
2. Deploy Presale contract
3. Transfer VLR tokens to presale
4. Initialize phases
5. Set price feeds
6. Verify on Etherscan
7. Test purchases

### Post-Deployment

- [ ] Verify contract on Etherscan
- [ ] Test all functions
- [ ] Monitor first purchases
- [ ] Update documentation
- [ ] Announce presale

---

## 11. Gas Optimization

### Strategies

1. **Batch Operations** - Initialize all phases at once
2. **Storage Optimization** - Pack structs efficiently
3. **View Functions** - Use view for read-only operations
4. **Events** - Use indexed parameters wisely
5. **Minimal Storage** - Store only essential data

### Expected Gas Costs

- Deploy: ~3,000,000 gas
- Buy with ETH: ~150,000 gas
- Buy with USDT/USDC: ~200,000 gas
- Withdraw: ~50,000 gas

---

## 12. Risk Mitigation

### Identified Risks

1. **Price Volatility** - Use stablecoins or frequent oracle updates
2. **Smart Contract Bugs** - Comprehensive testing + audit
3. **Reentrancy** - ReentrancyGuard on all payment functions
4. **Front-running** - Slippage protection on purchases
5. **Centralization** - Multi-sig for owner functions (future)

### Mitigation Strategies

- Pausable for emergencies
- Withdrawal limits
- Time-locks on critical functions
- Comprehensive event logging
- Regular monitoring

---

## 13. Future Enhancements

### Phase 2 Features

- [ ] Vesting schedules
- [ ] KYC integration
- [ ] Whitelist functionality
- [ ] Multi-sig wallet
- [ ] Governance integration

### Phase 3 Features

- [ ] Cross-chain presale
- [ ] NFT bonuses
- [ ] Tiered pricing
- [ ] Dynamic phase durations
- [ ] Advanced analytics

---

## 14. Success Metrics

### Key Performance Indicators

- Total funds raised
- Number of participants
- Average purchase size
- Referral conversion rate
- Phase completion time
- Gas efficiency

### Target Goals

- **Participants**: 1,000+
- **Funds Raised**: $500,000+
- **Referral Rate**: 30%+
- **Phase Completion**: 70 days
- **Gas Efficiency**: <200k per purchase

---

## 15. Technical Stack

### Smart Contracts

- **Solidity**: 0.8.20
- **OpenZeppelin**: 5.4.0
- **Hardhat**: 2.19.5

### Testing

- **Mocha/Chai**: Test framework
- **Hardhat Network**: Local testing
- **Coverage**: 100% target

### Deployment

- **Hardhat**: Deployment scripts
- **Etherscan**: Verification
- **Tenderly**: Monitoring

---

## 16. Timeline

### Week 1

- Day 1-2: Contract development
- Day 3-4: Testing
- Day 5: Gas optimization
- Day 6-7: Documentation

### Week 2

- Day 1-2: Security review
- Day 3: Deployment to testnet
- Day 4-5: Testing on testnet
- Day 6-7: Mainnet deployment

---

## Conclusion

This specification provides a comprehensive blueprint for a secure, scalable presale system. The implementation will follow industry best practices and security standards.

**Next Step**: Begin contract implementation following this specification.

---

**Document Version**: 1.0  
**Date**: October 21, 2025  
**Status**: Approved for Implementation
