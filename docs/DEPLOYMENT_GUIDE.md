# VelirionToken Deployment Guide

## Pre-Deployment Checklist

- [ ] All tests passing (`npx hardhat test`)
- [ ] Test coverage ≥90% (`npx hardhat coverage`)
- [ ] Contracts compiled (`npx hardhat compile`)
- [ ] `.env` file configured with:
  - [ ] `SEPOLIA_RPC_URL`
  - [ ] `PRIVATE_KEY`
  - [ ] `ETHERSCAN_API_KEY`
- [ ] Sufficient testnet ETH in deployer wallet
- [ ] Network configuration verified in `hardhat.config.ts`

---

## Step 1: Get Testnet ETH

### Sepolia Faucets

1. **Alchemy Sepolia Faucet**: https://sepoliafaucet.com/
2. **Infura Sepolia Faucet**: https://www.infura.io/faucet/sepolia
3. **Chainlink Faucet**: https://faucets.chain.link/sepolia

**Required Amount**: ~0.1 ETH for deployment + verification

---

## Step 2: Verify Environment Configuration

```bash
# Check your deployer address
npx hardhat console --network sepolia
```

```javascript
const [deployer] = await ethers.getSigners();
console.log("Deployer address:", deployer.address);
console.log(
  "Balance:",
  ethers.formatEther(await ethers.provider.getBalance(deployer.address)),
  "ETH"
);
```

---

## Step 3: Deploy to Sepolia Testnet

```bash
npx hardhat run scripts/01_deploy_token.ts --network sepolia
```

### Expected Output

```
 Deploying Velirion Token...

Deploying contracts with account: 0x...
Account balance: 0.5 ETH

Deploying VelirionToken...
✅ VelirionToken deployed to: 0x...

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
   VLR_TOKEN_ADDRESS=0x...

2. Verify contract on Etherscan:
   npx hardhat verify --network sepolia 0x...

3. Allocate tokens to contracts:
   - Run allocation scripts after deploying other contracts

💾 Deployment info saved to deployment-token.json
```

---

## Step 4: Verify Contract on Etherscan

### Automatic Verification

```bash
npx hardhat run scripts/verify_deployment.ts --network sepolia
```

### Manual Verification

```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

### Verification Success

```
🔍 Verifying VelirionToken deployment...

📋 Deployment Information:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Network: sepolia
Token Address: 0x...
Deployer: 0x...
Timestamp: 2025-10-21T...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐 Verifying contract on Etherscan...
This may take a few moments...

✅ Contract verified successfully!
View on Etherscan: https://sepolia.etherscan.io/address/0x...
```

---

## Step 5: Update Configuration Files

### Update `.env`

```env
VLR_TOKEN_ADDRESS=0x<DEPLOYED_ADDRESS>
```

### Update `deployment-token.json`

This file is automatically created by the deployment script:

```json
{
  "network": "sepolia",
  "tokenAddress": "0x...",
  "deployer": "0x...",
  "timestamp": "2025-10-21T...",
  "totalSupply": "100000000.0",
  "verified": true,
  "verifiedAt": "2025-10-21T..."
}
```

---

## Step 6: Verify Deployment

### Check on Etherscan

1. Visit: `https://sepolia.etherscan.io/address/<CONTRACT_ADDRESS>`
2. Verify:
   - ✅ Contract is verified (green checkmark)
   - ✅ Total supply: 100,000,000 VLR
   - ✅ Deployer owns all tokens
   - ✅ Contract code visible

### Test Contract Interaction

```bash
npx hardhat console --network sepolia
```

```javascript
const VelirionToken = await ethers.getContractFactory("VelirionToken");
const token = VelirionToken.attach("<CONTRACT_ADDRESS>");

// Check basic info
console.log("Name:", await token.name());
console.log("Symbol:", await token.symbol());
console.log("Total Supply:", ethers.formatEther(await token.totalSupply()));

// Check deployer balance
const [deployer] = await ethers.getSigners();
console.log(
  "Deployer Balance:",
  ethers.formatEther(await token.balanceOf(deployer.address))
);
```

---

## Step 7: Document Deployment

### Update PROJECT_TRACKER.md

```markdown
### Testnet (Sepolia)

| Contract  | Address | Verified | Status   |
| --------- | ------- | -------- | -------- |
| VLR Token | 0x...   | ✅       | Deployed |
```

### Create Deployment Report

Document the following:

- Deployment date and time
- Network (Sepolia)
- Contract address
- Deployer address
- Transaction hash
- Gas used
- Etherscan link
- Verification status

---

## Mainnet Deployment (Future)

### Additional Pre-Deployment Steps

- [ ] Complete security audit
- [ ] Multi-signature wallet setup
- [ ] Gnosis Safe configuration
- [ ] Team approval obtained
- [ ] Deployment plan reviewed
- [ ] Emergency procedures documented
- [ ] Monitoring systems ready

### Mainnet Deployment Command

```bash
# ⚠️ USE WITH EXTREME CAUTION
npx hardhat run scripts/01_deploy_token.ts --network mainnet
```

### Post-Mainnet Deployment

1. Transfer ownership to multisig
2. Renounce deployer privileges
3. Allocate tokens to contracts
4. Initialize monitoring
5. Announce deployment
6. Update all documentation

---

## Troubleshooting

### Issue: "Insufficient funds"

**Solution**: Get more testnet ETH from faucets

### Issue: "Nonce too high"

**Solution**: Reset MetaMask account or wait for pending transactions

### Issue: "Network connection timeout"

**Solution**: Check RPC URL in `.env`, try alternative RPC provider

### Issue: "Contract verification failed"

**Solution**:

- Ensure Etherscan API key is correct
- Wait a few minutes and retry
- Check constructor arguments match deployment

### Issue: "Gas estimation failed"

**Solution**:

- Increase gas limit in hardhat config
- Check network congestion
- Verify contract code compiles

---

## Gas Costs (Estimated)

| Action       | Sepolia (Testnet) | Mainnet (Est.) |
| ------------ | ----------------- | -------------- |
| Deployment   | ~2,000,000 gas    | ~$50-100       |
| Verification | Free              | Free           |
| Transfer     | ~50,000 gas       | ~$2-5          |
| Allocate     | ~70,000 gas       | ~$3-7          |

**Note**: Mainnet costs vary with gas prices

---

## Security Considerations

### Before Deployment

- ✅ Code reviewed by multiple developers
- ✅ All tests passing
- ✅ Coverage ≥90%
- ✅ No hardcoded values
- ✅ Access controls verified
- ✅ Emergency pause tested

### After Deployment

- ✅ Monitor contract activity
- ✅ Set up alerts for unusual transactions
- ✅ Keep private keys secure
- ✅ Document all admin actions
- ✅ Regular security reviews

---

## Next Steps After Deployment

1. ✅ Update all documentation
2. ✅ Test contract interactions
3. ✅ Deploy remaining contracts (Presale, Referral, Staking, DAO)
4. ✅ Allocate tokens to contracts
5. ✅ Integration testing
6. ✅ Prepare for mainnet

---

## Emergency Procedures

### If Deployment Fails

1. Check error message
2. Verify configuration
3. Check wallet balance
4. Review transaction on Etherscan
5. Retry with adjusted parameters

### If Wrong Network

1. **DO NOT PANIC**
2. Document the deployment
3. Deploy to correct network
4. Update all references
5. Consider the test deployment as practice

### If Contract Has Issues

1. **DO NOT** send mainnet funds
2. Document the issue
3. Fix in code
4. Redeploy to testnet
5. Test thoroughly
6. Update version number

---

**Last Updated**: October 21, 2025  
**Deployment Version**: 1.0  
**Status**: ✅ Ready for Testnet Deployment
