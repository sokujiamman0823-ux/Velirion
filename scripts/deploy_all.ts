import { ethers } from "hardhat";
import * as fs from "fs";

/**
 * Complete Deployment Script - Milestones 1, 2, and 3
 * 
 * Deploys:
 * 1. VelirionToken
 * 2. Mock USDT and USDC (for testing)
 * 3. PresaleContractV2
 * 4. VelirionReferral
 * 
 * And sets up all integrations
 */
async function main() {
  console.log("🚀 Starting Complete Velirion Deployment...\n");
  console.log("═".repeat(60));

  const [deployer] = await ethers.getSigners();
  console.log("📍 Deploying from:", deployer.address);
  console.log("💰 Balance:", ethers.utils.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // ============================================================================
  // 1. Deploy VLR Token
  // ============================================================================
  
  console.log("📦 Step 1: Deploying VelirionToken...");
  const VelirionToken = await ethers.getContractFactory("VelirionToken");
  const vlrToken = await VelirionToken.deploy();
  await vlrToken.deployed();
  console.log("✅ VLR Token:", vlrToken.address);
  console.log("   Total Supply:", ethers.utils.formatEther(await vlrToken.totalSupply()), "VLR\n");

  // ============================================================================
  // 2. Deploy Mock Tokens (for testing)
  // ============================================================================
  
  console.log("📦 Step 2: Deploying Mock Tokens...");
  const MockERC20 = await ethers.getContractFactory("MockERC20");
  
  const mockUSDT = await MockERC20.deploy("Mock USDT", "USDT", 6);
  await mockUSDT.deployed();
  console.log("✅ Mock USDT:", mockUSDT.address);
  
  const mockUSDC = await MockERC20.deploy("Mock USDC", "USDC", 6);
  await mockUSDC.deployed();
  console.log("✅ Mock USDC:", mockUSDC.address);
  
  // Mint some mock tokens for testing
  await mockUSDT.mint(deployer.address, ethers.utils.parseUnits("1000000", 6));
  await mockUSDC.mint(deployer.address, ethers.utils.parseUnits("1000000", 6));
  console.log("   Minted 1M USDT and 1M USDC for testing\n");

  // ============================================================================
  // 3. Deploy Presale Contract
  // ============================================================================
  
  console.log("📦 Step 3: Deploying PresaleContractV2...");
  const initialEthPrice = ethers.utils.parseEther("2000"); // $2000 per ETH
  
  const PresaleContract = await ethers.getContractFactory("VelirionPresaleV2");
  const presaleContract = await PresaleContract.deploy(
    vlrToken.address,
    mockUSDT.address,
    mockUSDC.address,
    initialEthPrice
  );
  await presaleContract.deployed();
  console.log("✅ Presale Contract:", presaleContract.address);
  console.log("   ETH Price:", ethers.utils.formatEther(initialEthPrice), "USD\n");

  // Initialize presale phases
  console.log("⚙️  Initializing presale phases...");
  await presaleContract.initializePhases();
  console.log("✅ 10 phases initialized ($0.005 - $0.015)\n");

  // Allocate tokens to presale
  console.log("💰 Allocating 30M VLR to presale...");
  const presaleAllocation = ethers.utils.parseEther("30000000");
  await vlrToken.transfer(presaleContract.address, presaleAllocation);
  console.log("✅ Presale funded with", ethers.utils.formatEther(presaleAllocation), "VLR\n");

  // ============================================================================
  // 4. Deploy Referral Contract
  // ============================================================================
  
  console.log("📦 Step 4: Deploying VelirionReferral...");
  const ReferralContract = await ethers.getContractFactory("VelirionReferral");
  const referralContract = await ReferralContract.deploy(vlrToken.address);
  await referralContract.deployed();
  console.log("✅ Referral Contract:", referralContract.address);
  
  // Allocate tokens to referral
  console.log("💰 Allocating 5M VLR to referral...");
  const referralAllocation = ethers.utils.parseEther("5000000");
  await vlrToken.transfer(referralContract.address, referralAllocation);
  console.log("✅ Referral funded with", ethers.utils.formatEther(referralAllocation), "VLR\n");

  // ============================================================================
  // 5. Deploy Staking Contract
  // ============================================================================
  
  console.log("📦 Step 5: Deploying VelirionStaking...");
  const StakingContract = await ethers.getContractFactory("VelirionStaking");
  const stakingContract = await StakingContract.deploy(vlrToken.address);
  await stakingContract.deployed();
  console.log("✅ Staking Contract:", stakingContract.address);
  
  // Allocate tokens to staking
  console.log("💰 Allocating 20M VLR to staking...");
  const stakingAllocation = ethers.utils.parseEther("20000000");
  await vlrToken.transfer(stakingContract.address, stakingAllocation);
  console.log("✅ Staking funded with", ethers.utils.formatEther(stakingAllocation), "VLR\n");

  // ============================================================================
  // 6. Setup Integrations
  // ============================================================================
  
  console.log("🔗 Step 6: Setting up integrations...");
  
  // Authorize presale to distribute referral bonuses
  await referralContract.setAuthorizedContract(presaleContract.address, true);
  console.log("✅ Presale authorized in referral contract");
  
  // Set referral contract in staking
  await stakingContract.setReferralContract(referralContract.address);
  console.log("✅ Referral contract set in staking");
  
  // Authorize staking to distribute referral bonuses
  await referralContract.setAuthorizedContract(stakingContract.address, true);
  console.log("✅ Staking authorized in referral contract");
  
  // Start presale
  const phaseDuration = 7 * 24 * 60 * 60; // 7 days
  await presaleContract.startPresale(phaseDuration);
  console.log("✅ Presale started (Phase 0, 7 days)\n");

  // ============================================================================
  // 7. Save Deployment Info
  // ============================================================================
  
  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    chainId: (await ethers.provider.getNetwork()).chainId.toString(),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      vlrToken: vlrToken.address,
      presale: presaleContract.address,
      referral: referralContract.address,
      staking: stakingContract.address,
      mockUSDT: mockUSDT.address,
      mockUSDC: mockUSDC.address,
    },
    allocations: {
      presale: ethers.utils.formatEther(presaleAllocation) + " VLR",
      referral: ethers.utils.formatEther(referralAllocation) + " VLR",
      staking: ethers.utils.formatEther(stakingAllocation) + " VLR",
    },
    config: {
      ethPrice: ethers.utils.formatEther(initialEthPrice) + " USD",
      phaseDuration: phaseDuration + " seconds (7 days)",
    }
  };

  fs.writeFileSync("deployment-complete.json", JSON.stringify(deploymentInfo, null, 2));
  console.log("💾 Deployment info saved to deployment-complete.json\n");

  // ============================================================================
  // 8. Verification & Summary
  // ============================================================================
  
  console.log("═".repeat(60));
  console.log("📋 DEPLOYMENT SUMMARY");
  console.log("═".repeat(60));
  console.log("\n🪙 Token Contracts:");
  console.log("   VLR Token:        ", vlrToken.address);
  console.log("   Mock USDT:        ", mockUSDT.address);
  console.log("   Mock USDC:        ", mockUSDC.address);
  
  console.log("\n📊 Core Contracts:");
  console.log("   Presale:          ", presaleContract.address);
  console.log("   Referral:         ", referralContract.address);
  console.log("   Staking:          ", stakingContract.address);
  
  console.log("\n💰 Token Allocations:");
  console.log("   Presale:          ", ethers.utils.formatEther(presaleAllocation), "VLR");
  console.log("   Referral:         ", ethers.utils.formatEther(referralAllocation), "VLR");
  console.log("   Staking:          ", ethers.utils.formatEther(stakingAllocation), "VLR");
  console.log("   Remaining:        ", ethers.utils.formatEther(await vlrToken.balanceOf(deployer.address)), "VLR");
  
  console.log("\n⚙️  Configuration:");
  console.log("   ETH Price:        ", "$" + ethers.utils.formatEther(initialEthPrice));
  console.log("   Presale Status:   ", "Active (Phase 0)");
  console.log("   Phase Duration:   ", "7 days");
  
  console.log("\n✅ Integrations:");
  console.log("   Presale ↔ Referral:  Connected");
  console.log("   Staking ↔ Referral:  Connected");
  console.log("   All Authorized:       Yes");
  
  console.log("\n" + "═".repeat(60));
  console.log("📝 NEXT STEPS:");
  console.log("═".repeat(60));
  console.log("\n1. Run all tests:");
  console.log("   npx hardhat test");
  console.log("\n2. Test presale purchase:");
  console.log("   - Use buyWithETH() or buyWithUSDT/USDC()");
  console.log("   - Include referrer address for bonus");
  console.log("\n3. Check referral stats:");
  console.log("   - Call getReferrerInfo(address)");
  console.log("   - Call getPendingRewards(address)");
  console.log("\n4. Claim referral rewards:");
  console.log("   - Call claimRewards()");
  
  console.log("\n" + "═".repeat(60));
  console.log("✅ Deployment Complete!");
  console.log("═".repeat(60) + "\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
