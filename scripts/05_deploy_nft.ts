import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
    console.log("\n🎨 Deploying Velirion NFT Reward System...\n");

    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);
    
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log(
        "Account balance:",
        ethers.utils.formatEther(balance),
        "ETH\n"
    );

    // Get deployed contract addresses
    const REFERRAL_CONTRACT = process.env.REFERRAL_CONTRACT;
    const STAKING_CONTRACT = process.env.STAKING_CONTRACT;

    if (!REFERRAL_CONTRACT) {
        console.log("⚠️  REFERRAL_CONTRACT not found in .env");
        console.log("   NFT auto-minting will need to be configured later");
    }

    if (!STAKING_CONTRACT) {
        console.log("⚠️  STAKING_CONTRACT not found in .env");
        console.log("   Guardian NFT minting will need to be configured later");
    }

    // IPFS base URIs (placeholder - should be updated with actual IPFS hashes)
    const REFERRAL_NFT_BASE_URI = process.env.REFERRAL_NFT_BASE_URI || "ipfs://QmReferralNFT/";
    const GUARDIAN_NFT_BASE_URI = process.env.GUARDIAN_NFT_BASE_URI || "ipfs://QmGuardianNFT/";

    console.log("\n📋 Configuration:");
    console.log("  Referral NFT Base URI:", REFERRAL_NFT_BASE_URI);
    console.log("  Guardian NFT Base URI:", GUARDIAN_NFT_BASE_URI);

    // ============================================================================
    // Deploy VelirionReferralNFT
    // ============================================================================

    console.log("\n🏅 Deploying VelirionReferralNFT...");
    const VelirionReferralNFT = await ethers.getContractFactory("VelirionReferralNFT");
    const referralNFT = await VelirionReferralNFT.deploy(
        "Velirion Referral Badge",
        "VLR-REF",
        REFERRAL_NFT_BASE_URI,
        deployer.address
    );
    await referralNFT.deployed();
    const referralNFTAddress = referralNFT.address;
    console.log("✅ VelirionReferralNFT deployed to:", referralNFTAddress);

    // ============================================================================
    // Deploy VelirionGuardianNFT
    // ============================================================================

    console.log("\n🛡️  Deploying VelirionGuardianNFT...");
    const VelirionGuardianNFT = await ethers.getContractFactory("VelirionGuardianNFT");
    const guardianNFT = await VelirionGuardianNFT.deploy(
        "Velirion Guardian",
        "VLR-GUARD",
        GUARDIAN_NFT_BASE_URI,
        deployer.address
    );
    await guardianNFT.deployed();
    const guardianNFTAddress = guardianNFT.address;
    console.log("✅ VelirionGuardianNFT deployed to:", guardianNFTAddress);

    // ============================================================================
    // Configure Contracts
    // ============================================================================

    console.log("\n⚙️  Configuring contracts...");

    // Set Referral contract in ReferralNFT
    if (REFERRAL_CONTRACT) {
        console.log("  Setting Referral contract in ReferralNFT...");
        await referralNFT.setReferralContract(REFERRAL_CONTRACT);
        console.log("  ✅ Referral contract set");
    } else {
        console.log("  ⚠️  Referral contract not set (will need to set later)");
    }

    // Set Staking contract in GuardianNFT
    if (STAKING_CONTRACT) {
        console.log("  Setting Staking contract in GuardianNFT...");
        await guardianNFT.setStakingContract(STAKING_CONTRACT);
        console.log("  ✅ Staking contract set");
    } else {
        console.log("  ⚠️  Staking contract not set (will need to set later)");
    }

    // ============================================================================
    // Display Deployment Summary
    // ============================================================================

    console.log("\n" + "=".repeat(60));
    console.log("📊 DEPLOYMENT SUMMARY");
    console.log("=".repeat(60));
    console.log("\n🎨 NFT Contracts:");
    console.log("  Referral NFT: ", referralNFTAddress);
    console.log("  Guardian NFT: ", guardianNFTAddress);
    console.log("\n🏅 Referral NFT Tiers:");
    console.log("  Tier 2 (Bronze): 10+ referrals");
    console.log("  Tier 3 (Silver): 25+ referrals");
    console.log("  Tier 4 (Gold):   50+ referrals");
    console.log("\n🛡️  Guardian NFT:");
    console.log("  Requirement: 250K+ VLR staked (Elite tier)");
    console.log("  Lock Period: 2 years");
    console.log("  Benefit: 2x DAO voting power");
    console.log("\n⚙️  Configuration:");
    console.log("  Referral Contract:", REFERRAL_CONTRACT || "Not set");
    console.log("  Staking Contract: ", STAKING_CONTRACT || "Not set");
    console.log("  Referral NFT URI: ", REFERRAL_NFT_BASE_URI);
    console.log("  Guardian NFT URI: ", GUARDIAN_NFT_BASE_URI);
    console.log("=".repeat(60));

    // ============================================================================
    // Save Deployment Info
    // ============================================================================

    const deploymentInfo = {
        network: (await ethers.provider.getNetwork()).name,
        timestamp: new Date().toISOString(),
        deployer: deployer.address,
        contracts: {
            referralNFT: referralNFTAddress,
            guardianNFT: guardianNFTAddress
        },
        metadata: {
            referralNFT: {
                name: "Velirion Referral Badge",
                symbol: "VLR-REF",
                baseURI: REFERRAL_NFT_BASE_URI,
                tiers: {
                    bronze: { tier: 2, requirement: "10+ referrals" },
                    silver: { tier: 3, requirement: "25+ referrals" },
                    gold: { tier: 4, requirement: "50+ referrals" }
                }
            },
            guardianNFT: {
                name: "Velirion Guardian",
                symbol: "VLR-GUARD",
                baseURI: GUARDIAN_NFT_BASE_URI,
                requirement: "250K+ VLR staked (Elite tier)",
                lockPeriod: "2 years",
                benefit: "2x DAO voting power"
            }
        },
        dependencies: {
            referralContract: REFERRAL_CONTRACT || null,
            stakingContract: STAKING_CONTRACT || null
        }
    };

    const deploymentPath = path.join(__dirname, "..", "deployment-nft.json");
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));
    console.log("\n💾 Deployment info saved to deployment-nft.json");

    // ============================================================================
    // Next Steps
    // ============================================================================

    console.log("\n📝 NEXT STEPS:");
    console.log("━".repeat(60));
    console.log("1. Update .env file:");
    console.log(`   REFERRAL_NFT_CONTRACT=${referralNFTAddress}`);
    console.log(`   GUARDIAN_NFT_CONTRACT=${guardianNFTAddress}`);
    console.log("\n2. Verify contracts on Etherscan:");
    console.log(`   npx hardhat verify --network <network> ${referralNFTAddress} "Velirion Referral Badge" "VLR-REF" "${REFERRAL_NFT_BASE_URI}" "${deployer.address}"`);
    console.log(`   npx hardhat verify --network <network> ${guardianNFTAddress} "Velirion Guardian" "VLR-GUARD" "${GUARDIAN_NFT_BASE_URI}" "${deployer.address}"`);
    console.log("\n3. Upload NFT metadata to IPFS:");
    console.log("   Create JSON metadata files for each tier");
    console.log("   Upload to IPFS/Pinata");
    console.log("   Update base URIs if needed");
    console.log("\n4. Integrate with existing contracts:");
    console.log("   Set NFT contract addresses in Referral and Staking contracts");
    console.log("   Test auto-minting on tier upgrades");
    console.log("\n5. Configure OpenSea (optional):");
    console.log("   Set collection info");
    console.log("   Add collection banner/logo");
    console.log("   Configure royalties");
    console.log("━".repeat(60));

    console.log("\n✅ NFT Reward System deployment complete!\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
