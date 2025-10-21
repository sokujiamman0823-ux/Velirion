import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

/**
 * Deploy VelirionReferral Contract
 * 
 * Prerequisites:
 * - VLR Token must be deployed
 * - Presale contract should be deployed (for integration)
 * 
 * Post-deployment:
 * - Allocate 5M VLR tokens to referral contract
 * - Set presale contract as authorized
 * - Set staking contract as authorized (when deployed)
 */
async function main() {
  console.log("🚀 Starting VelirionReferral Deployment...\n");

  const [deployer] = await ethers.getSigners();
  console.log("📍 Deploying from account:", deployer.address);
  console.log("💰 Account balance:", ethers.utils.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // ============================================================================
  // Load Existing Deployments
  // ============================================================================

  let vlrTokenAddress: string;
  let presaleAddress: string;

  try {
    const tokenDeployment = JSON.parse(
      fs.readFileSync("deployment-token.json", "utf-8")
    );
    vlrTokenAddress = tokenDeployment.address || tokenDeployment.tokenAddress;
    console.log("✅ VLR Token found:", vlrTokenAddress);
  } catch (error) {
    console.error("❌ VLR Token deployment not found!");
    console.log("Please deploy VLR Token first using: npx hardhat run scripts/01_deploy_token.ts");
    process.exit(1);
  }

  try {
    const presaleDeployment = JSON.parse(
      fs.readFileSync("deployment-presale-v2.json", "utf-8")
    );
    presaleAddress = presaleDeployment.address || presaleDeployment.presaleAddress;
    console.log("✅ Presale Contract found:", presaleAddress);
  } catch (error) {
    console.log("⚠️  Presale contract not found (will skip integration)");
    presaleAddress = "";
  }

  console.log("");

  // ============================================================================
  // Deploy Referral Contract
  // ============================================================================

  console.log("📦 Deploying VelirionReferral...");

  const ReferralContract = await ethers.getContractFactory("VelirionReferral");
  const referralContract = await ReferralContract.deploy(vlrTokenAddress);

  await referralContract.deployed();
  const referralAddress = referralContract.address;

  console.log("✅ VelirionReferral deployed to:", referralAddress);
  console.log("");

  // ============================================================================
  // Verify Deployment
  // ============================================================================

  console.log("🔍 Verifying deployment...");

  const vlrToken = await referralContract.vlrToken();
  console.log("  VLR Token:", vlrToken);

  const ownerData = await referralContract.getReferrerData(deployer.address);
  console.log("  Owner initialized:", ownerData.isActive);
  console.log("  Owner tier:", ownerData.level.toString());

  const [tier1Purchase, tier1Staking] = await referralContract.getTierBonuses(1);
  console.log("  Tier 1 bonuses:", tier1Purchase.toString(), "BPS purchase,", tier1Staking.toString(), "BPS staking");

  console.log("");

  // ============================================================================
  // Allocate Tokens
  // ============================================================================

  console.log("💰 Allocating tokens to referral contract...");

  const VLRToken = await ethers.getContractAt("VelirionToken", vlrTokenAddress);
  const allocationAmount = ethers.utils.parseEther("5000000"); // 5M VLR

  const currentBalance = await VLRToken.balanceOf(referralAddress);
  
  if (currentBalance < allocationAmount) {
    console.log("  Transferring", ethers.utils.formatEther(allocationAmount), "VLR...");
    
    const tx = await VLRToken.transfer(referralAddress, allocationAmount);
    await tx.wait();
    
    const newBalance = await VLRToken.balanceOf(referralAddress);
    console.log("✅ Allocation complete. Contract balance:", ethers.utils.formatEther(newBalance), "VLR");
  } else {
    console.log("✅ Contract already has sufficient balance:", ethers.utils.formatEther(currentBalance), "VLR");
  }

  console.log("");

  // ============================================================================
  // Set Authorized Contracts
  // ============================================================================

  console.log("🔐 Setting authorized contracts...");

  if (presaleAddress) {
    console.log("  Authorizing presale contract:", presaleAddress);
    const authTx = await referralContract.setAuthorizedContract(presaleAddress, true);
    await authTx.wait();
    console.log("✅ Presale contract authorized");
  } else {
    console.log("⚠️  Skipping presale authorization (not deployed)");
  }

  console.log("");

  // ============================================================================
  // Integration with Presale (if deployed)
  // ============================================================================

  if (presaleAddress) {
    console.log("🔗 Integrating with presale contract...");
    
    try {
      const PresaleContract = await ethers.getContractAt(
        "VelirionPresaleV2",
        presaleAddress
      );

      // Check if presale has setReferralContract function
      console.log("  Setting referral contract in presale...");
      // Note: This will need to be added to PresaleContractV2
      console.log("⚠️  Manual integration required:");
      console.log("     Add setReferralContract() to PresaleContractV2");
      console.log("     Then call: presale.setReferralContract('" + referralAddress + "')");
    } catch (error) {
      console.log("⚠️  Could not auto-integrate with presale");
      console.log("     Manual integration may be required");
    }

    console.log("");
  }

  // ============================================================================
  // Save Deployment Info
  // ============================================================================

  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    chainId: (await ethers.provider.getNetwork()).chainId.toString(),
    address: referralAddress,
    vlrToken: vlrTokenAddress,
    presaleContract: presaleAddress || "Not deployed",
    deployer: deployer.address,
    deploymentTime: new Date().toISOString(),
    allocation: ethers.utils.formatEther(allocationAmount) + " VLR",
    tierBonuses: {
      tier1: { purchase: "5%", staking: "2%" },
      tier2: { purchase: "7%", staking: "3%" },
      tier3: { purchase: "10%", staking: "4%" },
      tier4: { purchase: "12%", staking: "5%" },
    },
    tierThresholds: {
      tier2: "10 referrals",
      tier3: "25 referrals",
      tier4: "50 referrals",
    },
  };

  const deploymentPath = "deployment-referral.json";
  fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));

  console.log("💾 Deployment info saved to:", deploymentPath);
  console.log("");

  // ============================================================================
  // Summary
  // ============================================================================

  console.log("📋 DEPLOYMENT SUMMARY");
  console.log("═".repeat(60));
  console.log("Contract Address:     ", referralAddress);
  console.log("VLR Token:            ", vlrTokenAddress);
  console.log("Presale Contract:     ", presaleAddress || "Not integrated");
  console.log("Token Allocation:     ", ethers.utils.formatEther(allocationAmount), "VLR");
  console.log("Owner Tier:           ", "4 (Gold)");
  console.log("═".repeat(60));
  console.log("");

  // ============================================================================
  // Next Steps
  // ============================================================================

  console.log("📝 NEXT STEPS:");
  console.log("1. Run tests: npx hardhat test test/03_Referral.test.js");
  console.log("2. Verify contract on Etherscan (if on testnet/mainnet):");
  console.log("   npx hardhat verify --network <network>", referralAddress, vlrTokenAddress);
  console.log("3. Update PresaleContractV2 to integrate with referral system");
  console.log("4. When staking is deployed, authorize staking contract:");
  console.log("   referral.setAuthorizedContract(stakingAddress, true)");
  console.log("5. Test integration with presale purchases");
  console.log("");

  console.log("✅ Deployment complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
