# Velirion Smart Contract - Quick Start Guide

## 🚀 Get Started in 15 Minutes

This guide will help you set up the development environment and deploy your first contract to testnet.

---

## Prerequisites Check

```bash
# Check Node.js version (need 18+)
node --version

# Check npm version
npm --version

# Check if Git is installed
git --version
```

---

## Step 1: Project Setup (5 minutes)

```bash
# Navigate to project
cd velirion-sc

# Install dependencies
npm install

# Verify Hardhat installation
npx hardhat --version
```

### Install Additional Dependencies

```bash
npm install --save-dev @nomicfoundation/hardhat-verify
npm install @chainlink/contracts
```

---

## Step 2: Environment Configuration (3 minutes)

Create `.env` file in project root:

```env
# Get free API keys from:
# Alchemy: https://www.alchemy.com/
# Etherscan: https://etherscan.io/myapikey

SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=your_metamask_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key

# Testnet token addresses (Sepolia)
USDT_ADDRESS=0x7169D38820dfd117C3FA1f22a697dBA58d90BA06
USDC_ADDRESS=0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8

# Will be filled after deployment
VLR_TOKEN_ADDRESS=
PRESALE_CONTRACT=
REFERRAL_CONTRACT=
STAKING_CONTRACT=
```

**⚠️ Security Warning**: Never commit `.env` file to Git!

---

## Step 3: Create Contract Files (5 minutes)

### 3.1 Create VelirionToken.sol

```bash
mkdir -p contracts/core
```

Create `contracts/core/VelirionToken.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract VelirionToken is ERC20, ERC20Burnable, Ownable, Pausable {
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18;
    
    mapping(string => uint256) public allocationTracking;
    
    event TokensAllocated(string category, address to, uint256 amount);
    event UnsoldBurned(uint256 amount);
    
    constructor() ERC20("Velirion", "VLR") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    function allocate(string memory category, address to, uint256 amount) 
        external onlyOwner 
    {
        require(to != address(0), "Invalid address");
        allocationTracking[category] += amount;
        _transfer(owner(), to, amount);
        emit TokensAllocated(category, to, amount);
    }
    
    function burnUnsold(uint256 amount) external onlyOwner {
        _burn(owner(), amount);
        emit UnsoldBurned(amount);
    }
    
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal override whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
```

### 3.2 Create Deployment Script

Create `scripts/01_deploy_token.ts`:

```typescript
import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Deploying Velirion Token...\n");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("Balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");
  
  // Deploy token
  const VelirionToken = await ethers.getContractFactory("VelirionToken");
  console.log("Deploying contract...");
  const token = await VelirionToken.deploy();
  await token.waitForDeployment();
  
  const address = await token.getAddress();
  console.log("✅ VelirionToken deployed to:", address);
  
  // Verify deployment
  const totalSupply = await token.totalSupply();
  const name = await token.name();
  const symbol = await token.symbol();
  
  console.log("\n📊 Token Info:");
  console.log("Name:", name);
  console.log("Symbol:", symbol);
  console.log("Total Supply:", ethers.formatEther(totalSupply), "VLR");
  console.log("Decimals:", await token.decimals());
  
  console.log("\n📝 Next Steps:");
  console.log("1. Add to .env: VLR_TOKEN_ADDRESS=" + address);
  console.log("2. Verify on Etherscan:");
  console.log(`   npx hardhat verify --network sepolia ${address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

### 3.3 Create Test File

Create `test/01_Token.test.ts`:

```typescript
import { expect } from "chai";
import { ethers } from "hardhat";

describe("VelirionToken", function () {
  let token: any;
  let owner: any;
  let addr1: any;
  let addr2: any;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    
    const VelirionToken = await ethers.getContractFactory("VelirionToken");
    token = await VelirionToken.deploy();
    await token.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should have correct name and symbol", async function () {
      expect(await token.name()).to.equal("Velirion");
      expect(await token.symbol()).to.equal("VLR");
    });

    it("Should mint 100M tokens to owner", async function () {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(ownerBalance).to.equal(ethers.parseEther("100000000"));
    });
  });

  describe("Allocation", function () {
    it("Should allocate tokens correctly", async function () {
      const amount = ethers.parseEther("1000000");
      await token.allocate("presale", addr1.address, amount);
      
      expect(await token.balanceOf(addr1.address)).to.equal(amount);
      expect(await token.allocationTracking("presale")).to.equal(amount);
    });

    it("Should revert if non-owner tries to allocate", async function () {
      const amount = ethers.parseEther("1000");
      await expect(
        token.connect(addr1).allocate("test", addr2.address, amount)
      ).to.be.reverted;
    });
  });

  describe("Burning", function () {
    it("Should burn tokens and reduce supply", async function () {
      const burnAmount = ethers.parseEther("1000000");
      const initialSupply = await token.totalSupply();
      
      await token.burn(burnAmount);
      
      const finalSupply = await token.totalSupply();
      expect(finalSupply).to.equal(initialSupply - burnAmount);
    });
  });

  describe("Pausable", function () {
    it("Should pause and unpause transfers", async function () {
      await token.pause();
      
      await expect(
        token.transfer(addr1.address, ethers.parseEther("100"))
      ).to.be.reverted;
      
      await token.unpause();
      
      await token.transfer(addr1.address, ethers.parseEther("100"));
      expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseEther("100"));
    });
  });
});
```

---

## Step 4: Run Tests (2 minutes)

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Check test coverage
npx hardhat coverage
```

Expected output:
```
  VelirionToken
    Deployment
      ✔ Should have correct name and symbol
      ✔ Should mint 100M tokens to owner
    Allocation
      ✔ Should allocate tokens correctly
      ✔ Should revert if non-owner tries to allocate
    Burning
      ✔ Should burn tokens and reduce supply
    Pausable
      ✔ Should pause and unpause transfers

  6 passing (2s)
```

---

## Step 5: Deploy to Testnet

### 5.1 Get Testnet ETH

Visit [Sepolia Faucet](https://sepoliafaucet.com/) and get free testnet ETH.

### 5.2 Deploy

```bash
npx hardhat run scripts/01_deploy_token.ts --network sepolia
```

### 5.3 Verify on Etherscan

```bash
npx hardhat verify --network sepolia <DEPLOYED_CONTRACT_ADDRESS>
```

---

## Step 6: Interact with Contract

### Using Hardhat Console

```bash
npx hardhat console --network sepolia
```

```javascript
// Get contract instance
const token = await ethers.getContractAt("VelirionToken", "YOUR_CONTRACT_ADDRESS");

// Check balance
const balance = await token.balanceOf("YOUR_ADDRESS");
console.log("Balance:", ethers.formatEther(balance));

// Check total supply
const supply = await token.totalSupply();
console.log("Total Supply:", ethers.formatEther(supply));

// Allocate tokens (only owner)
await token.allocate("test", "RECIPIENT_ADDRESS", ethers.parseEther("1000"));
```

---

## Common Issues & Solutions

### Issue 1: "Insufficient funds" error
**Solution**: Get more testnet ETH from faucet or check you're using correct network.

### Issue 2: "Nonce too high" error
**Solution**: Reset MetaMask account or use different account.

```bash
# Clear cache
npx hardhat clean
rm -rf cache artifacts
```

### Issue 3: Compilation errors
**Solution**: Ensure OpenZeppelin version is compatible.

```bash
npm install @openzeppelin/contracts@^5.0.0
```

### Issue 4: "Invalid API Key" during verification
**Solution**: Double-check your Etherscan API key in `.env`

---

## Next Steps

Now that you have the token deployed, proceed to:

1. **Milestone 2**: Deploy Presale Contract
2. **Milestone 3**: Deploy Referral System
3. **Milestone 4**: Deploy Staking Module
4. **Milestone 5**: Setup DAO & Integration

Refer to `VELIRION_IMPLEMENTATION_GUIDE.md` for detailed instructions.

---

## Useful Commands Reference

```bash
# Compile contracts
npx hardhat compile

# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/01_Token.test.ts

# Deploy to Sepolia
npx hardhat run scripts/01_deploy_token.ts --network sepolia

# Deploy to mainnet (⚠️ USE WITH CAUTION)
npx hardhat run scripts/01_deploy_token.ts --network mainnet

# Verify contract
npx hardhat verify --network sepolia <ADDRESS>

# Clean artifacts
npx hardhat clean

# Check gas usage
REPORT_GAS=true npx hardhat test

# Run coverage
npx hardhat coverage

# Open Hardhat console
npx hardhat console --network sepolia
```

---

## Testing Checklist

Before deploying to mainnet, ensure:

- [ ] All tests pass with 100% success rate
- [ ] Test coverage is ≥90%
- [ ] Contract verified on Etherscan
- [ ] Manual testing completed on testnet
- [ ] Security audit performed (if budget allows)
- [ ] Emergency pause tested
- [ ] Owner functions work correctly
- [ ] Gas optimization reviewed
- [ ] Documentation complete
- [ ] Team review completed

---

## Security Best Practices

1. **Never share your private key**
2. **Always test on testnet first**
3. **Use hardware wallet for mainnet**
4. **Enable 2FA on all accounts**
5. **Keep .env file out of version control**
6. **Use multisig for critical operations**
7. **Implement timelock for major changes**
8. **Regular security audits**
9. **Monitor contract activity**
10. **Have emergency response plan**

---

## Support Resources

- **Hardhat Docs**: https://hardhat.org/docs
- **OpenZeppelin**: https://docs.openzeppelin.com/
- **Ethers.js**: https://docs.ethers.org/
- **Solidity**: https://docs.soliditylang.org/

---

**Estimated Time**: 15 minutes  
**Difficulty**: Beginner  
**Prerequisites**: Node.js, MetaMask, basic Solidity knowledge

**Status**: ✅ Ready to Use
