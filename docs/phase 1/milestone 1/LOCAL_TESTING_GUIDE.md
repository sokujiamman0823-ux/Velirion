# 🏠 Local Testing with Hardhat Network

## Why Use Hardhat Local Network?

✅ **No testnet ETH needed**  
✅ **Instant transactions**  
✅ **Free unlimited testing**  
✅ **10 pre-funded accounts**  
✅ **Perfect for development**

---

## Quick Start

### 1. Start Hardhat Node (Terminal 1)

```bash
npx hardhat node
```

This will:

- Start a local Ethereum network
- Give you 10 accounts with 10,000 ETH each
- Show you the private keys
- Run on `http://127.0.0.1:8545`

### 2. Deploy to Local Network (Terminal 2)

```bash
npx hardhat run scripts/01_deploy_token.ts --network localhost
```

---

## 📋 Step-by-Step Guide

### Step 1: Start Local Node

Open a terminal and run:

```bash
npx hardhat node
```

**You'll see:**

```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them on Mainnet or any other live network WILL BE LOST.

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

... (8 more accounts)
```

**Keep this terminal running!**

---

### Step 2: Deploy Contract

Open a **new terminal** and run:

```bash
npx hardhat run scripts/01_deploy_token.ts --network localhost
```

**Expected Output:**

```
 Deploying Velirion Token...

Deploying contracts with account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Account balance: 10000.0 ETH

Deploying VelirionToken...
✅ VelirionToken deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3

Token Information:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name: Velirion
Symbol: VLR
Decimals: 18
Total Supply: 100000000.0 VLR
Owner Balance: 100000000.0 VLR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Next Steps:
1. Update .env file:
   VLR_TOKEN_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

---

### Step 3: Interact with Contract

You can now interact with your deployed contract!

#### Using Hardhat Console:

```bash
npx hardhat console --network localhost
```

Then in the console:

```javascript
const VelirionToken = await ethers.getContractFactory("VelirionToken");
const token = await VelirionToken.attach(
  "0x5FbDB2315678afecb367f032d93F642f64180aa3"
);

// Check balance
const balance = await token.balanceOf(
  "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
);
console.log("Balance:", ethers.utils.formatEther(balance));

// Transfer tokens
const [owner, addr1] = await ethers.getSigners();
await token.transfer(addr1.address, ethers.utils.parseEther("1000"));

// Check new balance
const newBalance = await token.balanceOf(addr1.address);
console.log("New Balance:", ethers.utils.formatEther(newBalance));
```

---

## 🧪 Running Tests on Local Network

### Run All Tests:

```bash
npx hardhat test --network localhost
```

### Run Specific Test:

```bash
npx hardhat test test/01_VelirionToken.test.js --network localhost
```

### Run with Gas Reporter:

```bash
REPORT_GAS=true npx hardhat test --network localhost
```

---

## 🔄 Reset Local Network

If you need to reset the blockchain state:

1. Stop the node (Ctrl+C in Terminal 1)
2. Start it again:

```bash
npx hardhat node
```

This gives you a fresh blockchain with all accounts reset to 10,000 ETH.

---

## 💡 Pro Tips

### 1. Keep Node Running

Keep the `npx hardhat node` terminal open while developing. Deploy and test in other terminals.

### 2. Use Multiple Accounts

The local network gives you 10 accounts. Use them to test multi-user scenarios:

```javascript
const [owner, user1, user2, user3] = await ethers.getSigners();
```

### 3. Instant Transactions

No waiting for block confirmations! Transactions are instant.

### 4. Fork Mainnet (Advanced)

You can fork mainnet to test with real contracts:

```bash
npx hardhat node --fork https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
```

---

## Local Network vs Testnet

| Feature         | Local Network       | Sepolia Testnet             |
| --------------- | ------------------- | --------------------------- |
| **Cost**        | Free                | Free (but need faucet)      |
| **Speed**       | Instant             | ~12 seconds/block           |
| **ETH**         | 10,000 per account  | Need faucet (0.001 ETH min) |
| **Reset**       | Easy (restart node) | Can't reset                 |
| **Persistence** | Lost on restart     | Permanent                   |
| **Public**      | No                  | Yes (Etherscan)             |
| **Best For**    | Development         | Final testing               |

---

## 🎯 Recommended Workflow

### Phase 1: Local Development (NOW)

1. ✅ Start local node
2. ✅ Deploy contract
3. ✅ Run all tests
4. ✅ Test interactions
5. ✅ Verify everything works

### Phase 2: Testnet Deployment (Later)

1. ⏳ Get mainnet ETH (0.001+)
2. ⏳ Get Sepolia ETH from faucet
3. ⏳ Deploy to Sepolia
4. ⏳ Verify on Etherscan
5. ⏳ Public testing

### Phase 3: Mainnet (Production)

1. ⏳ Final audit
2. ⏳ Deploy to mainnet
3. ⏳ Verify on Etherscan
4. ⏳ Launch!

---

## 🛠️ Troubleshooting

### Node Already Running?

```bash
# Kill existing node
taskkill /F /IM node.exe /T

# Or use a different port
npx hardhat node --port 8546
```

### Can't Connect?

Make sure `hardhat.config.ts` has:

```typescript
networks: {
  localhost: {
    url: "http://127.0.0.1:8545";
  }
}
```

### Wrong Network?

Always specify `--network localhost` when deploying/testing.

---

## ✅ Ready to Test Locally!

**Terminal 1:**

```bash
npx hardhat node
```

**Terminal 2:**

```bash
npx hardhat run scripts/01_deploy_token.ts --network localhost
npx hardhat test --network localhost
```

**No testnet ETH needed!** 🎉

---

## 📚 Next Steps

After local testing succeeds:

1. ✅ Verify all functionality works
2. ✅ Test edge cases
3. ✅ Run coverage report
4. ⏳ Get mainnet ETH for Sepolia faucet
5. ⏳ Deploy to Sepolia for public testing

---

**Start testing locally now - it's faster and easier!**
