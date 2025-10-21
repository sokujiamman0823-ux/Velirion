import { ethers } from "hardhat";
import * as fs from "fs";

/**
 * Deploy VelirionStaking Contract
 * 
 * Prerequisites:
 * - VLR Token must be deployed
 * - Referral contract should be deployed (for integration)
 * 
 * Post-deployment:
 * - Allocate 20M VLR tokens to staking contract
 * - Set referral contract address
 * - Authorize staking contract in referral
 */
async function main() {
  console.log("🚀 Starting VelirionStaking Deployment...\n");

  const [deployer] = await ethers.getSigners();
  console.log("📍 Deploying from account:", deployer.address);
  console.log(
    "💰 Account balance:",
    ethers.utils.formatEther(await ethers.provider.getBalance(deployer.address)),
    "ETH\n"
  );

  // ============================================================================
  // Load Existing Deployments
  // ============================================================================

  let vlrTokenAddress: string;
  let referralAddress: string;

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
    const referralDeployment = JSON.parse(
      fs.readFileSync("deployment-referral.json", "utf-8")
    );
    referralAddress = referralDeployment.address;
    console.log("✅ Referral Contract found:", referralAddress);
  } catch (error) {
    console.log("⚠️  Referral contract not found (will skip integration)");
    referralAddress = "";
  }

  console.log("");

  // ============================================================================
  // Deploy Staking Contract
  // ============================================================================

  console.log("📦 Deploying VelirionStaking...");

  const StakingContract = await ethers.getContractFactory("VelirionStaking");
  const stakingContract = await StakingContract.deploy(vlrTokenAddress);

  await stakingContract.deployed();
  const stakingAddress = stakingContract.address;

  console.log("✅ VelirionStaking deployed to:", stakingAddress);
  console.log("");

  // ============================================================================
  // Verify Deployment
  // ============================================================================

  console.log("🔍 Verifying deployment...");

  const vlrToken = await stakingContract.vlrToken();
  console.log("  VLR Token:", vlrToken);

  // Check tier constants
  console.log("\n  Tier Minimums:");
  console.log("    Flexible:", ethers.utils.formatEther(await stakingContract.MIN_FLEXIBLE_STAKE()), "VLR");
  console.log("    Medium:", ethers.utils.formatEther(await stakingContract.MIN_MEDIUM_STAKE()), "VLR");
  console.log("    Long:", ethers.utils.formatEther(await stakingContract.MIN_LONG_STAKE()), "VLR");
  console.log("    Elite:", ethers.utils.formatEther(await stakingContract.MIN_ELITE_STAKE()), "VLR");

  console.log("\n  APR Rates:");
  console.log("    Flexible:", (await stakingContract.FLEXIBLE_APR()).toString(), "BPS (6%)");
  console.log("    Medium:", (await stakingContract.MEDIUM_MIN_APR()).toString(), "-", (await stakingContract.MEDIUM_MAX_APR()).toString(), "BPS (12-15%)");
  console.log("    Long:", (await stakingContract.LONG_APR()).toString(), "BPS (20%)");
  console.log("    Elite:", (await stakingContract.ELITE_APR()).toString(), "BPS (30%)");

  console.log("");

  // ============================================================================
  // Allocate Tokens
  // ============================================================================

  console.log("💰 Allocating tokens to staking contract...");

  const VLRToken = await ethers.getContractAt("VelirionToken", vlrTokenAddress);
  const allocationAmount = ethers.utils.parseEther("20000000"); // 20M VLR

  const currentBalance = await VLRToken.balanceOf(stakingAddress);
  
  if (currentBalance.lt(allocationAmount)) {
    console.log("  Transferring", ethers.utils.formatEther(allocationAmount), "VLR...");
    
    const tx = await VLRToken.transfer(stakingAddress, allocationAmount);
    await tx.wait();
    
    const newBalance = await VLRToken.balanceOf(stakingAddress);
    console.log("✅ Allocation complete. Contract balance:", ethers.utils.formatEther(newBalance), "VLR");
  } else {
    console.log("✅ Contract already has sufficient balance:", ethers.utils.formatEther(currentBalance), "VLR");
  }

  console.log("");

  // ============================================================================
  // Set Referral Contract
  // ============================================================================

  if (referralAddress) {
    console.log("🔗 Integrating with referral contract...");
    
    console.log("  Setting referral contract in staking...");
    const setRefTx = await stakingContract.setReferralContract(referralAddress);
    await setRefTx.wait();
    console.log("✅ Referral contract set");

    // Authorize staking in referral contract
    console.log("  Authorizing staking in referral contract...");
    const ReferralContract = await ethers.getContractAt(
      "VelirionReferral",
      referralAddress
    );
    const authTx = await ReferralContract.setAuthorizedContract(stakingAddress, true);
    await authTx.wait();
    console.log("✅ Staking contract authorized");

    console.log("");
  }

  // ============================================================================
  // Save Deployment Info
  // ============================================================================

  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    chainId: (await ethers.provider.getNetwork()).chainId.toString(),
    address: stakingAddress,
    vlrToken: vlrTokenAddress,
    referralContract: referralAddress || "Not integrated",
    deployer: deployer.address,
    deploymentTime: new Date().toISOString(),
    allocation: ethers.utils.formatEther(allocationAmount) + " VLR",
    tiers: {
      flexible: {
        minStake: "100 VLR",
        apr: "6%",
        lock: "None",
        penalty: "None"
      },
      medium: {
        minStake: "1,000 VLR",
        apr: "12-15%",
        lock: "90-180 days",
        penalty: "5%"
      },
      long: {
        minStake: "5,000 VLR",
        apr: "20-22%",
        lock: "1 year",
        penalty: "7%"
      },
      elite: {
        minStake: "250,000 VLR",
        apr: "30-32%",
        lock: "2 years",
        penalty: "10%"
      }
    }
  };

  const deploymentPath = "deployment-staking.json";
  fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));

  console.log("💾 Deployment info saved to:", deploymentPath);
  console.log("");

  // ============================================================================
  // Summary
  // ============================================================================

  console.log("📋 DEPLOYMENT SUMMARY");
  console.log("═".repeat(60));
  console.log("Contract Address:     ", stakingAddress);
  console.log("VLR Token:            ", vlrTokenAddress);
  console.log("Referral Contract:    ", referralAddress || "Not integrated");
  console.log("Token Allocation:     ", ethers.utils.formatEther(allocationAmount), "VLR");
  console.log("═".repeat(60));
  console.log("");

  console.log("🎯 STAKING TIERS:");
  console.log("  Flexible: 100 VLR min, 6% APR, No lock");
  console.log("  Medium:   1K VLR min, 12-15% APR, 90-180 days");
  console.log("  Long:     5K VLR min, 20-22% APR, 1 year");
  console.log("  Elite:    250K VLR min, 30-32% APR, 2 years");
  console.log("");

  // ============================================================================
  // Next Steps
  // ============================================================================

  console.log("📝 NEXT STEPS:");
  console.log("1. Run tests: npx hardhat test test/04_Staking.test.js");
  console.log("2. Verify contract on Etherscan (if on testnet/mainnet):");
  console.log("   npx hardhat verify --network <network>", stakingAddress, vlrTokenAddress);
  console.log("3. Test staking with small amounts");
  console.log("4. Monitor first stakes and reward claims");
  console.log("5. Update frontend to integrate staking");
  console.log("");

  console.log("✅ Deployment complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
