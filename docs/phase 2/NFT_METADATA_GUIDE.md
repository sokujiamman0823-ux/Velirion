# 🎨 NFT Metadata Preparation Guide

**Project**: Velirion NFT Rewards  
**Date**: October 28, 2025  
**Status**: Ready to prepare

---

## 📋 Overview

We need to create metadata for 4 NFT types:

### Referral NFT Badges (3 tiers)
1. **Bronze Badge** - 10+ referrals
2. **Silver Badge** - 25+ referrals
3. **Gold Badge** - 50+ referrals

### Guardian NFT (1 type)
4. **Guardian NFT** - Elite stakers (250K+ VLR, 2-year lock)

---

## 🎯 Step 1: Create Pinata Account

### Sign Up
1. Visit: https://pinata.cloud/
2. Click "Sign Up"
3. Choose plan: **Free** (1 GB storage, plenty for NFTs)
4. Verify email
5. Complete profile

### Get API Keys
1. Go to Account → API Keys
2. Click "New Key"
3. Name: "Velirion NFT Metadata"
4. Permissions: 
   - ✅ pinFileToIPFS
   - ✅ pinJSONToIPFS
5. Create key
6. **Save credentials** (shown only once):
   ```
   API Key: ________________________________
   API Secret: ________________________________
   JWT: ________________________________
   ```

### Add to .env
```env
# Pinata IPFS
PINATA_API_KEY=your_api_key_here
PINATA_API_SECRET=your_api_secret_here
PINATA_JWT=your_jwt_here
```

---

## 🎯 Step 2: Design NFT Images

### Option 1: AI Generation (Fastest)

**Using Midjourney**:
```
Prompt for Bronze Badge:
"Bronze medal badge, cryptocurrency theme, velirion token symbol, 
professional, clean design, 1024x1024, PNG, transparent background"

Prompt for Silver Badge:
"Silver medal badge, cryptocurrency theme, velirion token symbol, 
professional, clean design, 1024x1024, PNG, transparent background"

Prompt for Gold Badge:
"Gold medal badge, cryptocurrency theme, velirion token symbol, 
professional, clean design, 1024x1024, PNG, transparent background"

Prompt for Guardian NFT:
"Epic guardian warrior, cryptocurrency theme, velirion branding, 
futuristic, powerful, 1024x1024, PNG, detailed"
```

**Using DALL-E 3**:
- Visit: https://openai.com/dall-e-3
- Use similar prompts
- Generate and download

### Option 2: Commission Designer
- Fiverr: $20-100 per design
- Upwork: $50-200 per design
- 99designs: Contest $200-500

### Option 3: Use Placeholders (Testnet)
For testnet, we can use simple placeholder images:
- Bronze: Bronze color gradient circle
- Silver: Silver color gradient circle
- Gold: Gold color gradient circle
- Guardian: Purple/blue gradient with VLR logo

### Image Specifications
- **Format**: PNG (with transparency)
- **Size**: 1024x1024 pixels
- **File size**: < 5 MB each
- **Quality**: High resolution
- **Background**: Transparent or solid color

---

## 🎯 Step 3: Create Metadata JSON

### Bronze Badge Metadata

**File**: `bronze-badge.json`
```json
{
  "name": "Velirion Bronze Referrer",
  "description": "Awarded to Velirion community members who have successfully referred 10 or more users to the platform. Bronze referrers earn 7% bonus on purchases and 3% on staking rewards.",
  "image": "ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/bronze-badge.png",
  "external_url": "https://velirion.io/nft/bronze",
  "attributes": [
    {
      "trait_type": "Tier",
      "value": "Bronze"
    },
    {
      "trait_type": "Tier Level",
      "value": 2
    },
    {
      "trait_type": "Min Referrals Required",
      "value": 10
    },
    {
      "trait_type": "Purchase Bonus",
      "value": "7%"
    },
    {
      "trait_type": "Staking Bonus",
      "value": "3%"
    },
    {
      "trait_type": "Rarity",
      "value": "Common"
    },
    {
      "trait_type": "Type",
      "value": "Referral Badge"
    },
    {
      "trait_type": "Transferable",
      "value": "Optional"
    }
  ]
}
```

### Silver Badge Metadata

**File**: `silver-badge.json`
```json
{
  "name": "Velirion Silver Referrer",
  "description": "Awarded to Velirion community members who have successfully referred 25 or more users to the platform. Silver referrers earn 10% bonus on purchases and 4% on staking rewards.",
  "image": "ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/silver-badge.png",
  "external_url": "https://velirion.io/nft/silver",
  "attributes": [
    {
      "trait_type": "Tier",
      "value": "Silver"
    },
    {
      "trait_type": "Tier Level",
      "value": 3
    },
    {
      "trait_type": "Min Referrals Required",
      "value": 25
    },
    {
      "trait_type": "Purchase Bonus",
      "value": "10%"
    },
    {
      "trait_type": "Staking Bonus",
      "value": "4%"
    },
    {
      "trait_type": "Rarity",
      "value": "Uncommon"
    },
    {
      "trait_type": "Type",
      "value": "Referral Badge"
    },
    {
      "trait_type": "Transferable",
      "value": "Optional"
    }
  ]
}
```

### Gold Badge Metadata

**File**: `gold-badge.json`
```json
{
  "name": "Velirion Gold Referrer",
  "description": "Awarded to Velirion community members who have successfully referred 50 or more users to the platform. Gold referrers earn 12% bonus on purchases and 5% on staking rewards.",
  "image": "ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/gold-badge.png",
  "external_url": "https://velirion.io/nft/gold",
  "attributes": [
    {
      "trait_type": "Tier",
      "value": "Gold"
    },
    {
      "trait_type": "Tier Level",
      "value": 4
    },
    {
      "trait_type": "Min Referrals Required",
      "value": 50
    },
    {
      "trait_type": "Purchase Bonus",
      "value": "12%"
    },
    {
      "trait_type": "Staking Bonus",
      "value": "5%"
    },
    {
      "trait_type": "Rarity",
      "value": "Rare"
    },
    {
      "trait_type": "Type",
      "value": "Referral Badge"
    },
    {
      "trait_type": "Transferable",
      "value": "Optional"
    }
  ]
}
```

### Guardian NFT Metadata

**File**: `guardian-nft.json`
```json
{
  "name": "Velirion Guardian",
  "description": "Exclusive NFT awarded to Elite tier stakers who have committed 250,000+ VLR tokens for a 2-year lock period. Guardians receive 30-32% APR, 2x DAO voting power, and exclusive community benefits. This is a soulbound token and cannot be transferred.",
  "image": "ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/guardian-nft.png",
  "external_url": "https://velirion.io/nft/guardian",
  "attributes": [
    {
      "trait_type": "Type",
      "value": "Guardian"
    },
    {
      "trait_type": "Tier",
      "value": "Elite"
    },
    {
      "trait_type": "Min Stake Required",
      "value": "250000 VLR"
    },
    {
      "trait_type": "Lock Period",
      "value": "2 years"
    },
    {
      "trait_type": "APR",
      "value": "30-32%"
    },
    {
      "trait_type": "DAO Voting Power",
      "value": "2x"
    },
    {
      "trait_type": "Rarity",
      "value": "Legendary"
    },
    {
      "trait_type": "Transferable",
      "value": "No (Soulbound)"
    },
    {
      "trait_type": "Benefits",
      "value": "Exclusive Access"
    }
  ]
}
```

---

## 🎯 Step 4: Upload to IPFS

### Upload Images First

**Using Pinata Web Interface**:
1. Login to Pinata
2. Click "Upload" → "File"
3. Select all 4 images
4. Add names:
   - bronze-badge.png
   - silver-badge.png
   - gold-badge.png
   - guardian-nft.png
5. Click "Upload"
6. **Save IPFS hashes** (CIDs):
   ```
   Bronze: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   Silver: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   Gold: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   Guardian: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

### Update Metadata with Image CIDs

Update the `"image"` field in each JSON file with the correct IPFS hash:
```json
"image": "ipfs://QmActualHashHere/bronze-badge.png"
```

### Upload Metadata JSON

1. Update all JSON files with correct image CIDs
2. Upload each JSON to Pinata
3. **Save metadata IPFS hashes**:
   ```
   Bronze metadata: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   Silver metadata: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   Gold metadata: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   Guardian metadata: QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

---

## 🎯 Step 5: Configure Base URIs

### For Referral NFT Contract

The base URI will be: `ipfs://QmBaseHashHere/`

The contract will append token IDs:
- Token 0 (Bronze): `ipfs://QmBaseHashHere/bronze-badge.json`
- Token 1 (Silver): `ipfs://QmBaseHashHere/silver-badge.json`
- Token 2 (Gold): `ipfs://QmBaseHashHere/gold-badge.json`

### For Guardian NFT Contract

Each Guardian NFT can have the same metadata:
`ipfs://QmGuardianMetadataHash`

### Update Deployment Script

In `deploy_complete.ts`, update the NFT deployment section:

```typescript
// Deploy Referral NFT
const referralNFTBaseURI = "ipfs://QmYourBaseHashHere/";
const referralNFT = await VelirionReferralNFT.deploy(referralNFTBaseURI);

// Deploy Guardian NFT
const guardianNFTBaseURI = "ipfs://QmYourGuardianHashHere/";
const guardianNFT = await VelirionGuardianNFT.deploy(guardianNFTBaseURI);
```

---

## 🎯 Step 6: Test Metadata

### Verify IPFS Access

Test each IPFS link in browser:
```
https://ipfs.io/ipfs/QmYourHashHere
https://gateway.pinata.cloud/ipfs/QmYourHashHere
```

Should display the image or JSON metadata.

### Verify JSON Structure

Use JSON validator: https://jsonlint.com/

Paste each metadata JSON and verify it's valid.

### Test on OpenSea Testnet

After deployment, check how NFTs appear on OpenSea testnet:
```
https://testnets.opensea.io/assets/sepolia/<contract_address>/<token_id>
```

---

## 📋 Checklist

### Preparation
- [ ] Pinata account created
- [ ] API keys saved
- [ ] .env file updated

### Images
- [ ] Bronze badge image created
- [ ] Silver badge image created
- [ ] Gold badge image created
- [ ] Guardian NFT image created
- [ ] All images 1024x1024 PNG
- [ ] All images < 5 MB

### Metadata
- [ ] Bronze metadata JSON created
- [ ] Silver metadata JSON created
- [ ] Gold metadata JSON created
- [ ] Guardian metadata JSON created
- [ ] All JSON validated

### IPFS Upload
- [ ] All 4 images uploaded to IPFS
- [ ] Image CIDs saved
- [ ] Metadata updated with image CIDs
- [ ] All 4 metadata files uploaded
- [ ] Metadata CIDs saved

### Configuration
- [ ] Base URIs determined
- [ ] Deployment script updated
- [ ] IPFS links tested
- [ ] Ready for deployment

---

## 🚀 Quick Start (Placeholder Images)

If you want to deploy quickly with placeholders:

### Use Simple SVG Images

Create simple SVG badges inline in metadata:

```json
"image": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAyNCIgaGVpZ2h0PSIxMDI0IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDI0IiBoZWlnaHQ9IjEwMjQiIGZpbGw9IiNDRDdGMzIiLz48dGV4dCB4PSI1MTIiIHk9IjUxMiIgZm9udC1zaXplPSI2MCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiPkJyb256ZTwvdGV4dD48L3N2Zz4="
```

This creates a simple colored badge without needing external images.

---

## 📊 Summary

**Total Files Needed**: 8 files
- 4 image files (PNG)
- 4 metadata files (JSON)

**IPFS Hashes to Save**: 8 hashes
- 4 image CIDs
- 4 metadata CIDs

**Time Estimate**:
- With AI images: 1-2 hours
- With designer: 1-3 days
- With placeholders: 30 minutes

---

**Status**: Ready to prepare  
**Next Step**: Create Pinata account and start uploading  
**Blocker**: None (can proceed independently)
