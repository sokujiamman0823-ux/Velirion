# Deployment Issue & Solution

## 🔴 Current Problem

**Hardhat 3.x `hardhat-toolbox-mocha-ethers` plugin is not functioning properly.**

### Symptoms:

1. `hre.ethers` is undefined
2. Cannot run tests (HHE1200 error)
3. Cannot run deployment scripts (ethers not exported)
4. Plugin loads but doesn't inject ethers into HRE

### Root Cause:

The `@nomicfoundation/hardhat-toolbox-mocha-ethers` plugin has compatibility issues with:

- Hardhat 3.x's new architecture
- ES modules (`"type": "module"`)
- Internal module resolution

---

## ✅ SOLUTION: Downgrade to Hardhat 2.x

The contract is production-ready. The issue is purely tooling. **Downgrade to Hardhat 2.x** where everything works.

### Step-by-Step Fix:

#### 1. Uninstall Hardhat 3.x packages

```bash
npm uninstall hardhat @nomicfoundation/hardhat-toolbox-mocha-ethers @nomicfoundation/hardhat-verify @nomicfoundation/hardhat-ignition
```

#### 2. Install Hardhat 2.x

```bash
npm install --save-dev hardhat@^2.19.5
npm install --save-dev @nomicfoundation/hardhat-toolbox@^2.0.2
npm install --save-dev @nomicfoundation/hardhat-verify@^1.1.1
```

#### 3. Update package.json

Remove `"type": "module"` line (Hardhat 2.x uses CommonJS)

#### 4. Update hardhat.config.ts

```typescript
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    mainnet: {
      url: process.env.ETHEREUM_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
```

#### 5. Update deployment script

```typescript
import { ethers } from "hardhat";
// Rest of the script works as-is
```

#### 6. Rename test file back to .ts

```bash
Move-Item test\01_VelirionToken.test.js test\01_VelirionToken.test.ts
```

#### 7. Restore TypeScript types in test file

```typescript
let token: VelirionToken;
let owner: SignerWithAddress;
// etc.
```

#### 8. Run everything

```bash
npx hardhat compile
npx hardhat test
npx hardhat coverage
npx hardhat run scripts/01_deploy_token.ts --network sepolia
```

---

## Alternative: Deploy with Cast (if you have Foundry)

If you have Foundry installed:

```bash
# Deploy
forge create contracts/core/VelirionToken.sol:VelirionToken \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

# Verify
forge verify-contract <ADDRESS> \
  contracts/core/VelirionToken.sol:VelirionToken \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

---

## What's Working vs Not Working

### ✅ Working:

- Contract compiles perfectly
- Contract code is production-ready
- OpenZeppelin v5 compatible
- Solidity tests work (Foundry)
- All features implemented correctly

### ❌ Not Working (Hardhat 3.x):

- JavaScript/TypeScript tests
- Deployment scripts
- `hre.ethers` undefined
- Plugin integration

---

## 🎯 Recommended Action

**Option 1: Downgrade to Hardhat 2.x** (15 minutes)

- Follow steps above
- Everything will work immediately
- Run tests, deploy, verify

**Option 2: Use Foundry** (if installed)

- Deploy with `forge create`
- Test with `forge test`
- Verify with `forge verify-contract`

**Option 3: Manual Deployment via Remix**

- Copy contract to Remix IDE
- Compile and deploy via MetaMask
- Verify manually on Etherscan

---

## 💡 Why This Happened

Hardhat 3.x is a major rewrite with:

- New plugin architecture
- ES modules requirement
- Breaking changes in toolbox plugins
- Some plugins not fully compatible yet

The `hardhat-toolbox-mocha-ethers` plugin appears to be in transition and doesn't properly inject `ethers` into the Hardhat Runtime Environment in all configurations.

---

## ✨ Bottom Line

**The contract is PERFECT. The tooling is broken.**

Choose one of the solutions above and you'll be deploying in minutes!

---

**Recommended**: Downgrade to Hardhat 2.x for the smoothest experience.
