# Quick Verification Guide

✅ **ALL CONTRACTS VERIFIED ON SEPOLIA ETHERSCAN**

This guide documents the verification process and constructor arguments for reference.

---

## Step-by-Step Verification Process

### 1. VLR Token (PRIORITY 1)

**Address**: `0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9`

1. Go to: https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9#code
2. Click "Verify and Publish"
3. Fill in:
   - Compiler Type: **Solidity (Single file)**
   - Compiler Version: **v0.8.20+commit.a1b79de6**
   - Open Source License: **MIT**
   - **EVM Version: paris** ⚠️ CRITICAL!
   - Optimization: **Yes**
   - Runs: **200**
4. Copy content from: `VelirionToken_flattened.sol`
5. Constructor Arguments: **Leave empty** (no constructor args)
6. Click "Verify and Publish"

---

### 2. Presale Contract (PRIORITY 2)

**Address**: `0xAF8021201524b1E487350F48D5609dFE7ecBb529`

1. Go to: https://sepolia.etherscan.io/address/0xAF8021201524b1E487350F48D5609dFE7ecBb529#code
2. Same settings as above
3. Copy content from: `PresaleV2_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
0000000000000000000000004cc6c5a87db2035ce3c64953e263d3153283bfd900000000000000000000000096f7e7bdc6d2403e5feea154591566469c6aca13000000000000000000000000f036e0ce0f69c3ff6660c240619872f923e58ebc00000000000000000000000000000000000000000000006c6b935b8bbd400000
```

---

### 3. Referral Contract (PRIORITY 3)

**Address**: `0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8`

1. Go to: https://sepolia.etherscan.io/address/0xAd126Bfd9F1781085E15cF9Fd0405A371Fd22FD8#code
2. Same settings
3. Copy content from: `VelirionReferral_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
0000000000000000000000004cc6c5a87db2035ce3c64953e263d3153283bfd9
```

---

### 4. Staking Contract (PRIORITY 4)

**Address**: `0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F`

1. Go to: https://sepolia.etherscan.io/address/0xA4F6E47A2d3a4B0f330C04fCb9c9D4B34A66232F#code
2. Same settings
3. Copy content from: `VelirionStaking_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
0000000000000000000000004cc6c5a87db2035ce3c64953e263d3153283bfd9
```

---

### 5. DAO Contract

**Address**: `0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE`

1. Go to: https://sepolia.etherscan.io/address/0x498Da63aC742DaDA798D9cBfcC2DF192E8B4A3FE#code
2. Same settings
3. Copy content from: `VelirionDAO_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
0000000000000000000000004cc6c5a87db2035ce3c64953e263d3153283bfd9000000000000000000000000705705dcb1012be25c6022e47ca3fb1ab4f610ef000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62
```

---

### 6. Timelock Contract

**Address**: `0x705705Dcb1012BE25c6022E47CA3Fb1AB4F610EF`

1. Go to: https://sepolia.etherscan.io/address/0x705705Dcb1012BE25c6022E47CA3Fb1AB4F610EF#code
2. Same settings
3. Copy content from: `VelirionTimelock_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62
```

---

### 7. Treasury Contract

**Address**: `0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1`

1. Go to: https://sepolia.etherscan.io/address/0x1A462637f6eCAbe092C59F32be81700ddF2ea5A1#code
2. Same settings
3. Copy content from: `VelirionTreasury_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
0000000000000000000000004cc6c5a87db2035ce3c64953e263d3153283bfd9000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62
```

---

### 8. Referral NFT

**Address**: `0x11aC4D9569a4F51C3c00529931b54d55335cE3b4`

1. Go to: https://sepolia.etherscan.io/address/0x11aC4D9569a4F51C3c00529931b54d55335cE3b4#code
2. Same settings
3. Copy content from: `VelirionReferralNFT_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e620000000000000000000000000000000000000000000000000000000000000017 56656c6972696f6e205265666572 72616c2042616467650000000000000000000000000000000000000000000000000000000000000000000000000000000006564c52524546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000216874747073 3a2f2f76656c6972696f6e2e696f2f6e66742f7265666572 72616c2f00000000000000000000000000000000000000000000000000000000
```

---

### 9. Guardian NFT

**Address**: `0x0baF2aca6044dCb120034E278Ba651F048658C19`

1. Go to: https://sepolia.etherscan.io/address/0x0baF2aca6044dCb120034E278Ba651F048658C19#code
2. Same settings
3. Copy content from: `VelirionGuardianNFT_flattened.sol`
4. Constructor Arguments (ABI-encoded):
```
0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000db84e27b7cafb453298057bcf6b7cd97fc988e62000000000000000000000000000000000000000000000000000000000000001056656c6972696f6e204775617264 69616e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000085 64c52475541524400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000216874747073 3a2f2f76656c6972696f6e2e696f2f6e66742f677561726469616e2f00000000000000000000000000000000000000000000000000000000
```

---

### 10. Mock USDT & USDC (Optional)

**USDT**: `0x96f7e7bDc6d2403e5FeEa154591566469c6aCA13`  
**USDC**: `0xF036E0Ce0f69C3ff6660C240619872f923e58ebc`

Use `MockERC20_flattened.sol` for both.

---

## Critical Notes

1. **EVM Version MUST be `paris`**: This is critical! The contracts were deployed with Paris EVM, not Shanghai. Using the wrong EVM version causes bytecode mismatch.

2. **Flattened files cleaned**: All duplicate SPDX licenses and pragma statements removed using automated script.

3. **Constructor arguments**: All ABI-encoded constructor arguments documented above for reference.

4. **Verification file**: Use `VelirionToken_VERIFIED.sol` for VLR Token (exact formatting match).

---

## Verification Status ✅ COMPLETE

- [x] VLR Token - Verified Oct 29, 2025
- [x] Presale Contract - Verified Oct 29, 2025
- [x] Referral Contract - Verified Oct 29, 2025
- [x] Staking Contract - Verified Oct 29, 2025
- [x] DAO Contract - Verified Oct 29, 2025
- [x] Timelock Contract - Verified Oct 29, 2025
- [x] Treasury Contract - Verified Oct 29, 2025
- [x] Referral NFT - Verified Oct 29, 2025
- [x] Guardian NFT - Verified Oct 29, 2025
- [x] Mock USDT - Verified Oct 29, 2025
- [x] Mock USDC - Verified Oct 29, 2025

---

**Files Location**: `flattened_contracts/` directory

**Verified Contracts**: https://sepolia.etherscan.io/address/0x4cC6C5a87db2035Ce3c64953e263D3153283BfD9#code
