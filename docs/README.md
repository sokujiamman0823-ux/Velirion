# Velirion (VLR) Smart Contract Suite

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/sokujiamman0823-ux/Velirion)
[![Solidity](https://img.shields.io/badge/solidity-0.8.20-brightgreen)](https://docs.soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/hardhat-3.0.7-yellow)](https://hardhat.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Tests](https://img.shields.io/badge/tests-passing-success)](./test)

> **Enterprise-grade multichain DeFi protocol featuring advanced tokenomics, decentralized governance, and institutional-grade security standards.**

## Overview

Velirion (VLR) is a sophisticated decentralized finance ecosystem built on Ethereum and Solana, implementing a comprehensive suite of smart contracts for token management, fundraising, incentivization, and community governance. The protocol is designed with security, scalability, and regulatory compliance as core principles.

### Core Architecture

The Velirion protocol consists of five interconnected smart contract modules:

- **Token Contract** — ERC-20/SPL compliant token with deflationary mechanics and multi-signature controls
- **Presale Module** — Multi-phase token distribution system with advanced anti-bot protection and linear vesting
- **Referral Engine** — Tiered incentive structure rewarding community growth and engagement
- **Staking Protocol** — Four-tier staking mechanism with variable APR and lock-up periods
- **DAO Governance** — Decentralized decision-making framework with treasury management and burn mechanisms

### Tokenomics

| Metric | Value |
|--------|-------|
| **Total Supply** | 100,000,000 VLR |
| **Token Standard** | ERC-20 (Ethereum) / SPL (Solana) |
| **Decimals** | 18 |
| **Initial Circulating Supply** | 30% (Presale) |

#### Token Distribution

```
Presale Allocation       30%  →  30,000,000 VLR
Staking Rewards          20%  →  20,000,000 VLR
Marketing & Adoption     15%  →  15,000,000 VLR
Team & Advisors          15%  →  15,000,000 VLR (24-month vesting)
Initial Liquidity        10%  →  10,000,000 VLR
Referral Incentives       5%  →   5,000,000 VLR
DAO Treasury              5%  →   5,000,000 VLR
```

---

## Technical Specifications

### Technology Stack

**Blockchain Infrastructure**
- Ethereum Mainnet (Primary) / Sepolia Testnet
- Solana Mainnet-Beta / Devnet
- Cross-chain bridge architecture

**Smart Contract Development**
- Solidity ^0.8.20 with optimizer enabled
- Hardhat 3.0.7 development environment
- OpenZeppelin Contracts 5.x (audited libraries)
- Ethers.js v6 for blockchain interactions

**Testing & Quality Assurance**
- Mocha/Chai testing framework
- Minimum 90% code coverage requirement
- Automated gas optimization analysis
- Continuous integration pipeline

**Security Infrastructure**
- Multi-signature wallet integration (Gnosis Safe)
- ReentrancyGuard on all external functions
- Emergency pause mechanisms
- Comprehensive access control (Ownable, Role-based)

---

## Development Setup

### System Requirements

```
Node.js      ≥ 18.0.0
npm          ≥ 9.0.0
Git          ≥ 2.30.0
Hardhat      3.0.7
```

### Installation

```bash
# Clone repository
git clone https://github.com/sokujiamman0823-ux/Velirion.git
cd velirion-sc

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# Add your API keys: SEPOLIA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY

# Compile smart contracts
npx hardhat compile

# Execute test suite
npx hardhat test

# Generate coverage report
npx hardhat coverage
```

### Network Configuration

The project supports multiple deployment targets:

- **Local Development**: Hardhat Network (EVM simulation)
- **Testnet**: Ethereum Sepolia
- **Production**: Ethereum Mainnet, Solana Mainnet-Beta

### Deployment

```bash
# Testnet deployment
npx hardhat run scripts/01_deploy_token.ts --network sepolia

# Contract verification
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>

# Production deployment (requires additional security checks)
npx hardhat run scripts/01_deploy_token.ts --network mainnet
```

---

## Repository Structure

```
velirion-sc/
├── contracts/              # Solidity smart contracts
│   ├── core/              # Core protocol contracts
│   │   ├── VelirionToken.sol
│   │   ├── VelirionPresale.sol
│   │   ├── VelirionReferral.sol
│   │   ├── VelirionStaking.sol
│   │   └── VelirionDAO.sol
│   ├── interfaces/        # Contract interfaces
│   └── libraries/         # Shared libraries
│
├── scripts/               # Deployment automation
│   ├── 01_deploy_token.ts
│   ├── 02_deploy_presale.ts
│   ├── 03_deploy_referral.ts
│   ├── 04_deploy_staking.ts
│   └── 05_deploy_dao.ts
│
├── test/                  # Comprehensive test suite
│   ├── 01_Token.test.ts
│   ├── 02_Presale.test.ts
│   ├── 03_Referral.test.ts
│   ├── 04_Staking.test.ts
│   └── 05_DAO.test.ts
│
├── docs/                  # Technical documentation
│   └── [Implementation guides and specifications]
│
└── hardhat.config.ts      # Hardhat configuration
```

---

## Testing & Quality Assurance

### Test Execution

```bash
# Full test suite
npx hardhat test

# Specific test file
npx hardhat test test/01_Token.test.ts

# Coverage analysis
npx hardhat coverage

# Gas optimization report
REPORT_GAS=true npx hardhat test
```

### Quality Metrics

- **Code Coverage**: Minimum 90% (target: 95%+)
- **Gas Optimization**: Continuous monitoring and optimization
- **Security**: Multi-layered security approach with automated scanning

### Testing Strategy

1. **Unit Tests**: Individual contract function validation
2. **Integration Tests**: Cross-contract interaction verification
3. **Scenario Tests**: Real-world use case simulation
4. **Stress Tests**: Edge case and boundary condition testing
5. **Security Tests**: Vulnerability and attack vector analysis

---

## Security Framework

### Security Measures

**Smart Contract Security**
- OpenZeppelin battle-tested contract libraries
- Comprehensive reentrancy protection (ReentrancyGuard)
- Emergency pause functionality for critical situations
- Role-based access control (RBAC) implementation
- Input validation and sanitization on all external calls
- Event emission for complete audit trail

**Operational Security**
- Multi-signature wallet requirements (Gnosis Safe)
- Timelocks on critical administrative functions
- Separation of concerns across contract modules
- Upgradability considerations with proxy patterns

### Audit & Compliance

- **Internal Review**: Comprehensive code review by senior developers
- **Automated Analysis**: Static analysis tools (Slither, Mythril)
- **Test Coverage**: Minimum 90% coverage across all contracts
- **External Audit**: Third-party security audit recommended before mainnet deployment
- **Bug Bounty**: Community-driven security program (post-launch)

---

## Protocol Features

### 1. Multi-Phase Presale System

**Technical Implementation**
- 10 progressive pricing phases with automatic phase transitions
- Price range: $0.005 - $0.015 per VLR token
- Multi-currency payment support (ETH, USDT, USDC)
- Advanced anti-bot protection mechanisms
- Linear vesting schedule: 40% TGE, 30% monthly over 2 months

**Security Features**
- Transaction limits: Maximum 50,000 VLR per transaction
- Wallet limits: Maximum 500,000 VLR per address
- Rate limiting: 5-minute cooldown between purchases
- Whitelist functionality for early access control

### 2. Tiered Referral Engine

**Incentive Structure**

| Tier | Requirements | Purchase Bonus | Staking Bonus | Additional Benefits |
|------|-------------|----------------|---------------|---------------------|
| **Level 1** | 0 referrals | 5% | 2% | Base tier access |
| **Level 2** | 10+ referrals | 7% | 3% | Exclusive NFT |
| **Level 3** | 25+ referrals | 10% | 4% | Priority support |
| **Level 4** | 50+ referrals | 12% | 5% | Private pool access |

### 3. Staking Protocol

**Tier Specifications**

| Tier | APR | Lock Period | Minimum Stake | Early Withdrawal Penalty | Benefits |
|------|-----|-------------|---------------|-------------------------|----------|
| **Flexible** | 6% | None | 100 VLR | None | Instant liquidity |
| **Medium** | 12-15% | 90-180 days | 1,000 VLR | 5% | +2% renewal bonus |
| **Long** | 20-22% | 365 days | 5,000 VLR | 7% | 2x DAO voting weight |
| **Elite** | 30% | 730 days | 250,000 VLR | 10% | Guardian NFT + exclusive access |

### 4. Deflationary Mechanisms

**Burn Strategy**
- **Presale Completion**: All unsold tokens permanently burned
- **Solana Transactions**: Automatic 0.5% burn on every transfer
- **Monthly Buyback**: DAO-initiated market buyback and burn
- **Quarterly Governance**: Community-voted burn proposals

### 5. DAO Governance Framework

**Governance Structure**
- Proposal creation and voting system
- Treasury management and fund allocation
- Protocol parameter adjustments
- Burn mechanism governance
- Multi-signature execution (Gnosis Safe 2-of-2)

**Voting Power**
- Standard: 1 VLR = 1 vote
- Long-term stakers: 2x voting weight
- Elite stakers: 2x voting weight + priority proposals

---

## Production Deployment

### Pre-Deployment Checklist

- [ ] All tests passing with ≥90% coverage
- [ ] Gas optimization completed
- [ ] Security audit completed
- [ ] Multi-signature wallets configured
- [ ] Emergency procedures documented
- [ ] Monitoring infrastructure ready

### Mainnet Deployment Process

```bash
# 1. Final compilation
npx hardhat compile --optimizer-runs 200

# 2. Deploy to mainnet
npx hardhat run scripts/deploy_all.ts --network mainnet

# 3. Verify all contracts
npx hardhat verify --network mainnet <TOKEN_ADDRESS>
npx hardhat verify --network mainnet <PRESALE_ADDRESS> <CONSTRUCTOR_ARGS>

# 4. Transfer ownership to multisig
npx hardhat run scripts/transfer_ownership.ts --network mainnet
```

---

## Resources & Documentation

### Technical Documentation
- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/)
- [Solidity Language](https://docs.soliditylang.org/)
- [Ethers.js Library](https://docs.ethers.org/)

### Development Tools
- [Ethereum Sepolia Faucet](https://sepoliafaucet.com/)
- [Etherscan Block Explorer](https://etherscan.io/)
- [Gnosis Safe Multisig](https://app.safe.global/)
- [Tenderly Monitoring](https://tenderly.co/)

### Community & Support
- GitHub Issues: [Report bugs or request features](https://github.com/sokujiamman0823-ux/Velirion/issues)
- Documentation: [Technical specifications and guides](./docs/)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for complete details.

---

## Disclaimer

This software is provided "as is", without warranty of any kind. The developers assume no responsibility for any losses incurred through the use of this code. Always conduct thorough testing and security audits before deploying to production environments.

---

**Project Status**: Active Development  
**Version**: 1.0.0  
**Last Updated**: October 2025

For detailed implementation guides and technical specifications, please refer to the [documentation](./docs/) directory.
