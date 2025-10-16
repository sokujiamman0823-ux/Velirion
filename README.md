# Velirion (VLR) - Smart Contract Project

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Solidity](https://img.shields.io/badge/solidity-0.8.20-brightgreen)
![License](https://img.shields.io/badge/license-MIT-green)

**Multichain DeFi Token with Presale, Referral, Staking & DAO Governance**

---

## 🎯 Project Overview

Velirion (VLR) is a comprehensive DeFi ecosystem featuring:
- **ERC-20 Token** on Ethereum with burning mechanisms
- **SPL Token** on Solana with automatic 0.5% burn
- **10-Phase Presale** with antibot protection and vesting
- **4-Level Referral System** with purchase & staking bonuses
- **4-Tier Staking** with APR ranging from 6% to 30%
- **DAO Governance** with burn voting and treasury management

### Token Economics
- **Total Supply**: 100,000,000 VLR
- **Networks**: Ethereum (ERC-20) + Solana (SPL)
- **Distribution**: Presale 30%, Staking 20%, Marketing 15%, Team 15%, Liquidity 10%, Referral 5%, DAO 5%

---

## 📚 Documentation

### Quick Access
| Document | Purpose | Audience |
|----------|---------|----------|
| **[📖 Documentation Index](DOCUMENTATION_INDEX.md)** | Complete guide to all docs | Everyone |
| **[🚀 Quick Start Guide](QUICK_START_GUIDE.md)** | Get started in 15 minutes | Developers |
| **[📋 Implementation Guide](VELIRION_IMPLEMENTATION_GUIDE.md)** | Full technical specs | Developers |
| **[📝 Contract Templates](CONTRACT_TEMPLATES.md)** | Ready-to-use code | Developers |
| **[📊 Project Tracker](PROJECT_TRACKER.md)** | Progress tracking | Project Managers |

**👉 Start here**: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

## 🚀 Quick Start

### Prerequisites
```bash
Node.js >= 18.x
npm >= 9.x
Git
```

### Installation
```bash
# Clone and install
cd velirion-sc
npm install

# Setup environment
cp .env.example .env
# Edit .env with your API keys

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
```

### Deploy to Testnet
```bash
# Deploy VLR Token
npx hardhat run scripts/01_deploy_token.ts --network sepolia

# Verify on Etherscan
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

**Detailed instructions**: [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)

---

## 📦 Project Structure

```
velirion-sc/
├── contracts/
│   ├── core/
│   │   ├── VelirionToken.sol        # ERC-20 token
│   │   ├── VelirionPresale.sol      # Presale system
│   │   ├── VelirionReferral.sol     # Referral system
│   │   ├── VelirionStaking.sol      # Staking module
│   │   └── VelirionDAO.sol          # DAO governance
│   ├── interfaces/
│   └── libraries/
├── scripts/
│   ├── 01_deploy_token.ts
│   ├── 02_deploy_presale.ts
│   ├── 03_deploy_referral.ts
│   ├── 04_deploy_staking.ts
│   └── 05_deploy_dao.ts
├── test/
│   ├── 01_Token.test.ts
│   ├── 02_Presale.test.ts
│   ├── 03_Referral.test.ts
│   ├── 04_Staking.test.ts
│   └── 05_DAO.test.ts
├── docs/
│   ├── DOCUMENTATION_INDEX.md
│   ├── VELIRION_IMPLEMENTATION_GUIDE.md
│   ├── QUICK_START_GUIDE.md
│   ├── CONTRACT_TEMPLATES.md
│   └── PROJECT_TRACKER.md
└── hardhat.config.ts
```

---

## 🎯 Development Roadmap

| Phase | Milestone | Duration | Budget | Status |
|-------|-----------|----------|--------|--------|
| 1 | Token + Core Logic | 5-6 days | $120 | ⏳ Pending |
| 2 | Presale System | 5 days | $120 | ⏳ Pending |
| 3 | Referral System | 4 days | $100 | ⏳ Pending |
| **Launch** | **Presale Goes Live** | **Day 15** | | |
| 4 | Staking Module | 7-8 days | $150 | ⏳ Pending |
| 5 | DAO + Integration | 6-7 days | $110 | ⏳ Pending |
| **Total** | | **27-31 days** | **$600** | |

---

## 🔧 Tech Stack

### Ethereum
- **Solidity**: 0.8.20
- **Framework**: Hardhat 3.x
- **Libraries**: OpenZeppelin Contracts 5.x
- **Testing**: Mocha/Chai + Ethers.js v6
- **Network**: Ethereum Mainnet & Sepolia Testnet

### Solana
- **Language**: Rust 1.70+
- **Framework**: Anchor 0.28+
- **Token**: SPL Token Standard
- **Network**: Solana Mainnet & Devnet

---

## 🧪 Testing

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/01_Token.test.ts

# Check coverage
npx hardhat coverage

# Gas reporting
REPORT_GAS=true npx hardhat test
```

**Target Coverage**: ≥90%

---

## 🔐 Security

### Best Practices
- ✅ OpenZeppelin audited contracts
- ✅ ReentrancyGuard on external functions
- ✅ Pausable for emergency stops
- ✅ Access control with Ownable
- ✅ Input validation on all functions
- ✅ Events for all state changes

### Auditing
- Internal code review
- Automated testing (≥90% coverage)
- External audit (recommended before mainnet)

---

## 📊 Key Features

### 🎫 Presale System
- 10 progressive pricing phases ($0.005 - $0.015)
- Multi-token payments (ETH, USDT, USDC)
- Antibot protection (tx limits, wallet limits, delays)
- Vesting: 40% at TGE, 30% monthly

### 🤝 Referral System
- 4 levels based on referral count (0, 10+, 25+, 50+)
- Purchase bonuses: 5% to 12%
- Staking bonuses: 2% to 5%
- NFT rewards for top performers

### 💰 Staking Module
- **Flexible**: 6% APR, no lock, 100 VLR min
- **Medium**: 12-15% APR, 90-180 days, 1K VLR min
- **Long**: 20-22% APR, 1 year, 5K VLR min
- **Elite**: 30% APR, 2 years, 250K VLR min

### 🔥 Burning Mechanisms
- Unsold presale tokens burned
- 0.5% burn per Solana transaction
- Monthly DAO buyback & burn
- Quarterly community burn votes

### 🏛️ DAO Governance
- Proposal creation & voting
- Burn amount decisions
- Treasury management
- 2-of-2 multisig via Gnosis Safe

---

## 🌐 Deployment

### Testnet (Sepolia)
```bash
npx hardhat run scripts/01_deploy_token.ts --network sepolia
npx hardhat verify --network sepolia <ADDRESS>
```

### Mainnet (Ethereum)
```bash
npx hardhat run scripts/01_deploy_token.ts --network mainnet
npx hardhat verify --network mainnet <ADDRESS>
```

**⚠️ Warning**: Always test thoroughly on testnet before mainnet deployment!

---

## 📞 Support & Resources

### Documentation
- [Hardhat Docs](https://hardhat.org/docs)
- [OpenZeppelin](https://docs.openzeppelin.com/)
- [Solidity](https://docs.soliditylang.org/)
- [Ethers.js](https://docs.ethers.org/)

### Tools
- [Ethereum Testnet Faucets](https://sepoliafaucet.com/)
- [Etherscan](https://etherscan.io/)
- [Gnosis Safe](https://app.safe.global/)

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

- OpenZeppelin for secure contract libraries
- Hardhat for development framework
- Ethereum & Solana communities

---

## 📈 Current Status

**Project Status**: 🔴 Setup Phase  
**Latest Version**: 1.0.0  
**Last Updated**: October 2025

---

**Ready to get started?** 👉 [Begin with Quick Start Guide](QUICK_START_GUIDE.md)
