# Contract Verification Guide

**Network**: Sepolia Testnet  
**Issue**: Etherscan API V1 deprecated, need to use V2 or manual verification

---

## Option 1: Manual Verification on Etherscan (Recommended)

Since the Hardhat verification plugin is having issues with the Etherscan API, you can verify contracts manually through the Etherscan website.

### Steps for Each Contract:

1. **Flatten the contract** (already done - see flattened files in root directory)
2. Go to the contract address on Sepolia Etherscan
3. Click "Contract" tab
4. Click "Verify and Publish"
5. Select "Solidity (Single file)" 
6. Copy the flattened contract code
7. Fill in the verification details below

### Flattened Contracts

Run these commands to generate flattened versions:

```bash
npx hardhat flatten contracts/core/VelirionToken.sol > VelirionToken_flattened.sol
npx hardhat flatten contracts/mocks/MockERC20.sol > MockERC20_flattened.sol
npx hardhat flatten contracts/presale/VelirionPresaleV2.sol > PresaleV2_flattened.sol
npx hardhat flatten contracts/core/VelirionReferral.sol > VelirionReferral_flattened.sol
npx hardhat flatten contracts/core/VelirionStaking.sol > VelirionStaking_flattened.sol
npx hardhat flatten contracts/governance/VelirionTimelock.sol > VelirionTimelock_flattened.sol
npx hardhat flatten contracts/governance/VelirionDAO.sol > VelirionDAO_flattened.sol
npx hardhat flatten contracts/governance/VelirionTreasury.sol > VelirionTreasury_flattened.sol
npx hardhat flatten contracts/nft/VelirionReferralNFT.sol > VelirionReferralNFT_flattened.sol
npx hardhat flatten contracts/nft/VelirionGuardianNFT.sol > VelirionGuardianNFT_flattened.sol
```

---

## VLR Token

**Address**: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`  
**URL**: https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9#code

**Verification Details**:
- Compiler Type: Solidity (Single file)
- Compiler Version: v0.8.20+commit.a1b79de6
- Open Source License Type: MIT
- Optimization: Yes
- Runs: 200

**Contract Code**: `contracts/core/VelirionToken.sol`

**Constructor Arguments**: None

---

## Mock USDT

**Address**: `0x96f7e7bDc6d2403e5FeEa154591566469c6aCA13`  
**URL**: https://sepolia.etherscan.io/address/0x96f7e7bDc6d2403e5FeEa154591566469c6aCA13#code

**Constructor Arguments ABI-encoded**:
```
0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000a546574686572205553440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045553445400000000000000000000000000000000000000000000000000000000
```

---

## Mock USDC

**Address**: `0xF036E0Ce0f69C3ff6660C240619872f923e58ebc`  
**URL**: https://sepolia.etherscan.io/address/0xF036E0Ce0f69C3ff6660C240619872f923e58ebc#code

**Constructor Arguments ABI-encoded**:
```
00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000008555344 20436f696e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004555344430000000000000000000000000000000000000000000000000000000
```

---

## Presale Contract

**Address**: `0xAF8021201524b1E487350F48D5609dFE7ecBb529`  
**URL**: https://sepolia.etherscan.io/address/0xAF8021201524b1E487350F48D5609dFE7ecBb529#code

**Constructor Arguments**:
- `_vlrToken`: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`
- `_usdt`: `0x96f7e7bDc6d2403e5FeEa154591566469c6aCA13`
- `_usdc`: `0xF036E0Ce0f69C3ff6660C240619872f923e58ebc`
- `_initialEthPrice`: `2000000000000000000000` (2000 ETH in wei)

---

## Referral Contract

**Address**: `0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8`  
**URL**: https://sepolia.etherscan.io/address/0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8#code

**Constructor Arguments**:
- `_vlrToken`: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`

---

## Staking Contract

**Address**: `0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F`  
**URL**: https://sepolia.etherscan.io/address/0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F#code

**Constructor Arguments**:
- `_vlrToken`: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`

---

## Timelock Contract

**Address**: `0x705705Dcb1012BE25c6022E47CA3Fb1AB4F610EF`  
**URL**: https://sepolia.etherscan.io/address/0x705705Dcb1012BE25c6022E47CA3Fb1AB4F610EF#code

**Constructor Arguments**:
- `_admin`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`

---

## DAO Contract

**Address**: `0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE`  
**URL**: https://sepolia.etherscan.io/address/0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE#code

**Constructor Arguments**:
- `_vlrToken`: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`
- `_timelock`: `0x705705Dcb1012BE25c6022E47CA3Fb1AB4F610EF`
- `_admin`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`

---

## Treasury Contract

**Address**: `0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1`  
**URL**: https://sepolia.etherscan.io/address/0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1#code

**Constructor Arguments**:
- `_vlrToken`: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`
- `_marketingWallet`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`
- `_teamWallet`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`
- `_liquidityWallet`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`
- `_admin`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`

---

## Referral NFT

**Address**: `0x11aC4D9569a4F51C3c00529931b54d55335cE3b4`  
**URL**: https://sepolia.etherscan.io/address/0x11aC4D9569a4F51C3c00529931b54d55335cE3b4#code

**Constructor Arguments**:
- `_name`: `Velirion Referral Badge`
- `_symbol`: `VLRREF`
- `_baseTokenURI`: `https://velirion.io/nft/referral/`
- `_admin`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`

---

## Guardian NFT

**Address**: `0x0baF2aca6044dCb120034E278Ba651F048658C19`  
**URL**: https://sepolia.etherscan.io/address/0x0baF2aca6044dCb120034E278Ba651F048658C19#code

**Constructor Arguments**:
- `_name`: `Velirion Guardian`
- `_symbol`: `VLRGUARD`
- `_baseTokenURI`: `https://velirion.io/nft/guardian/`
- `_admin`: `0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62`

---

## Option 2: Update Hardhat Packages

If you want to fix the Hardhat verification, update the packages:

```bash
npm install --save-dev @nomicfoundation/hardhat-toolbox@latest @nomicfoundation/hardhat-verify@latest
```

Then try verification again.

---

## Option 3: Use Etherscan API V2 Directly

You can also verify using curl with Etherscan API V2, but manual verification through the website is easier for now.

---

## Verification Priority

**High Priority** (User-facing):
1. VLR Token
2. Presale Contract
3. Staking Contract
4. Referral Contract

**Medium Priority**:
5. DAO Contract
6. Referral NFT
7. Guardian NFT

**Low Priority** (Internal):
8. Timelock
9. Treasury
10. Mock USDT/USDC

---

## Note

For testnet, verification is optional but recommended for transparency. All contracts are already deployed and functional. Verification just makes the source code visible on Etherscan for easier interaction and auditing.

**Status**: Contracts deployed and working ✅  
**Verification**: Optional for testnet, can be done manually
