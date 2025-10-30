const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

// Load deployment addresses
const deploymentPath = path.join(__dirname, "..", "deployment-sepolia.json");
const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

async function main() {
  console.log("\n👥 Testing Referral System\n");

  const [user1] = await ethers.getSigners();
  console.log(`User 1 (Main User): ${user1.address}`);
  console.log(`\n⚠️  Note: Testnet has only one signer. Referral testing requires multiple wallets.`);
  console.log(`   For full testing, use hardhat local network or provide multiple private keys.\n`);

  // Get contract instances
  const Referral = await ethers.getContractAt("VelirionReferral", deployment.contracts.referral);
  const VLRToken = await ethers.getContractAt("VelirionToken", deployment.contracts.vlrToken);
  const ReferralNFT = await ethers.getContractAt("VelirionReferralNFT", deployment.contracts.referralNFT);

  // Test 1: Check User 1 referral status
  console.log("--- Test 1: Check Referral Status ---");
  const referrer = await Referral.getReferrer(user1.address);
  if (referrer === ethers.constants.AddressZero) {
    console.log("❌ User not registered in referral system");
    console.log("   To register, call: Referral.register(referrerAddress)");
  } else {
    console.log(`✅ User registered with referrer: ${referrer}`);
  }

  // Test 2: Get Referrer Info
  console.log("\n--- Test 2: Get Referrer Info ---");
  const referrerData = await Referral.getReferrerData(user1.address);
  console.log(`Tier Level: ${referrerData.level}`);
  console.log(`Direct Referrals: ${referrerData.directReferrals.toString()}`);
  console.log(`Total Earned: ${ethers.utils.formatEther(referrerData.totalEarned)} VLR`);
  console.log(`Purchase Bonus Earned: ${ethers.utils.formatEther(referrerData.purchaseBonusEarned)} VLR`);
  console.log(`Staking Bonus Earned: ${ethers.utils.formatEther(referrerData.stakingBonusEarned)} VLR`);
  console.log(`Is Active: ${referrerData.isActive}`);

  // Test 3: Get Tier Bonuses
  console.log("\n--- Test 3: Tier Bonuses ---");
  const tier = referrerData.level.toNumber();
  const [purchaseBonus, stakingBonus] = await Referral.getTierBonuses(tier);
  const tierNames = ["None", "Starter", "Bronze", "Silver", "Gold"];
  console.log(`Current Tier: ${tierNames[tier] || tier}`);
  console.log(`Purchase Bonus: ${purchaseBonus.toNumber() / 100}%`);
  console.log(`Staking Bonus: ${stakingBonus.toNumber() / 100}%`);

  // Test 4: Check referral stats
  console.log("\n--- Test 4: Referral Statistics ---");
  const stats = await Referral.getReferralStats(user1.address);
  console.log(`Direct Referrals: ${stats.directReferrals.length}`);
  console.log(`Total Volume: ${ethers.utils.formatEther(stats.totalVolume)} VLR`);
  console.log(`Total Staking Volume: ${ethers.utils.formatEther(stats.totalStakingVolume)} VLR`);
  
  if (stats.directReferrals.length > 0) {
    console.log(`\nDirect Referral Addresses:`);
    stats.directReferrals.forEach((addr, i) => {
      console.log(`  ${i + 1}. ${addr}`);
    });
  }

  // Test 5: Check pending rewards
  console.log("\n--- Test 5: Pending Rewards ---");
  const pending = await Referral.getPendingRewards(user1.address);
  console.log(`Pending Rewards: ${ethers.utils.formatEther(pending)} VLR`);
  
  if (pending.gt(0)) {
    console.log(`\n💡 You can claim rewards with: Referral.claimRewards()`);
  }

  // Test 6: Next tier threshold
  console.log("\n--- Test 6: Tier Progression ---");
  const nextThreshold = await Referral.getNextTierThreshold(tier);
  if (nextThreshold.toNumber() > 0) {
    const needed = nextThreshold.toNumber() - referrerData.directReferrals.toNumber();
    console.log(`Next Tier Threshold: ${nextThreshold.toString()} referrals`);
    console.log(`Referrals Needed: ${Math.max(0, needed)}`);
  } else {
    console.log(`✅ Maximum tier reached!`);
  }

  // Check total referrers
  const totalReferrers = await Referral.totalReferrers();
  console.log(`Total Referrers in System: ${totalReferrers}`);

  console.log("\n✅ Referral system tests completed!");
  console.log("\n💡 Next Steps:");
  console.log("   1. Test presale purchases with referral codes");
  console.log("   2. Verify bonus distribution to referrers");
  console.log("   3. Test NFT minting for high-tier referrers\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
