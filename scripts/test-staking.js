const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

// Load deployment addresses
const deploymentPath = path.join(__dirname, "..", "deployment-sepolia.json");
const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

async function main() {
  console.log("\n🔒 Testing Staking Flow\n");

  const [staker] = await ethers.getSigners();
  console.log(`Staker address: ${staker.address}\n`);

  // Get contract instances
  const Staking = await ethers.getContractAt("VelirionStaking", deployment.contracts.staking);
  const VLRToken = await ethers.getContractAt("VelirionToken", deployment.contracts.vlrToken);

  // Check current balance
  let balance = await VLRToken.balanceOf(staker.address);
  console.log(`Current VLR balance: ${ethers.utils.formatEther(balance)} VLR`);

  // If balance is low, request tokens from presale or treasury
  if (balance.lt(ethers.utils.parseEther("1000"))) {
    console.log("\n⚠️  Low balance. You need VLR tokens to test staking.");
    console.log("Please purchase tokens from presale first or get tokens from treasury.\n");
    return;
  }

  // Display staking tier requirements
  console.log("\n--- Staking Tier Requirements ---");
  const Tier = { Flexible: 0, Medium: 1, Long: 2, Elite: 3 };
  const minFlexible = await Staking.getMinimumStake(Tier.Flexible);
  const minMedium = await Staking.getMinimumStake(Tier.Medium);
  const minLong = await Staking.getMinimumStake(Tier.Long);
  const minElite = await Staking.getMinimumStake(Tier.Elite);

  const minLockMedium = await Staking.getMinimumLock(Tier.Medium);
  const maxLockMedium = await Staking.getMaximumLock(Tier.Medium);

  console.log(`Flexible: Min ${ethers.utils.formatEther(minFlexible)} VLR, No lock`);
  console.log(`Medium: Min ${ethers.utils.formatEther(minMedium)} VLR, Lock ${minLockMedium/86400}–${maxLockMedium/86400} days`);
  console.log(`Long: Min ${ethers.utils.formatEther(minLong)} VLR, Lock 365 days`);
  console.log(`Elite: Min ${ethers.utils.formatEther(minElite)} VLR, Lock 730 days`);

  // Test staking with 30-day tier
  console.log("\n--- Test: Stake 1000 VLR in Medium tier for 90 days ---");
  const stakeAmount = ethers.utils.parseEther("1000");
  const tier = 1; // Medium
  const lockDurationSec = 90 * 24 * 60 * 60; // 90 days

  console.log("Approving VLR tokens...");
  let tx = await VLRToken.approve(deployment.contracts.staking, stakeAmount);
  await tx.wait();
  console.log("✅ Tokens approved");

  console.log(`Staking ${ethers.utils.formatEther(stakeAmount)} VLR in Medium tier for 90 days...`);
  try {
    tx = await Staking.stake(stakeAmount, tier, lockDurationSec);
    const receipt = await tx.wait();
    console.log(`✅ Staking successful! Tx: ${receipt.transactionHash}`);

    // Get stake info
    const stakeIds = await Staking.getUserStakes(staker.address);
    console.log(`\nTotal stakes: ${stakeIds.length}`);
    
    if (stakeIds.length > 0) {
      const latestId = stakeIds[stakeIds.length - 1];
      const info = await Staking.getStakeInfo(staker.address, latestId);
      const amount = info[0], startTime = info[1], lockDuration = info[2], apr = info[4], active = info[6];
      console.log("\nLatest Stake Details:");
      console.log(`  Amount: ${ethers.utils.formatEther(amount)} VLR`);
      console.log(`  Lock: ${Number(lockDuration)/86400} days`);
      console.log(`  APR (bps): ${apr}`);
      console.log(`  Start: ${new Date(Number(startTime) * 1000).toLocaleString()}`);
      console.log(`  Active: ${active}`);
    }

    // Check pending rewards
    const lastIndex = (await Staking.getUserStakes(staker.address)).length - 1;
    const lastId = (await Staking.getUserStakes(staker.address))[lastIndex];
    const pendingRewards = await Staking.calculateRewards(staker.address, lastId);
    console.log(`\nPending Rewards: ${ethers.utils.formatEther(pendingRewards)} VLR`);

  } catch (error) {
    console.log(`❌ Staking failed: ${error.message}`);
  }

  // Check updated balance
  balance = await VLRToken.balanceOf(staker.address);
  console.log(`\nNew VLR balance: ${ethers.utils.formatEther(balance)} VLR`);

  // Display total staked
  const totalStaked = await Staking.getTotalStaked();
  console.log(`Total Staked in Contract: ${ethers.utils.formatEther(totalStaked)} VLR`);

  console.log("\n✅ Staking tests completed!");
  console.log("\n💡 Note: You can claim rewards after the staking period ends.");
  console.log("   Use the unstake function to claim rewards and get your tokens back.\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
