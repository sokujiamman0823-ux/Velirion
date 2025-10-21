const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VelirionReferral", function () {
  let referralContract;
  let vlrToken;
  let owner;
  let presaleContract;
  let stakingContract;
  let referrer1;
  let referrer2;
  let user1;
  let user2;
  let user3;
  let users;

  const REFERRAL_ALLOCATION = ethers.utils.parseEther("5000000"); // 5M VLR

  beforeEach(async function () {
    [
      owner,
      presaleContract,
      stakingContract,
      referrer1,
      referrer2,
      user1,
      user2,
      user3,
      ...users
    ] = await ethers.getSigners();

    // Deploy VLR Token
    const VLRToken = await ethers.getContractFactory("VelirionToken");
    vlrToken = await VLRToken.deploy();
    await vlrToken.deployed();

    // Deploy Referral Contract
    const ReferralContract = await ethers.getContractFactory("VelirionReferral");
    referralContract = await ReferralContract.deploy(vlrToken.address);
    await referralContract.deployed();

    // Allocate tokens to referral contract
    await vlrToken.transfer(referralContract.address, REFERRAL_ALLOCATION);

    // Set authorized contracts
    await referralContract.setAuthorizedContract(presaleContract.address, true);
    await referralContract.setAuthorizedContract(stakingContract.address, true);
  });

  describe("Deployment", function () {
    it("Should deploy with correct VLR token", async function () {
      expect(await referralContract.vlrToken()).to.equal(vlrToken.address);
    });

    it("Should initialize owner as active referrer", async function () {
      const ownerData = await referralContract.getReferrerData(owner.address);
      expect(ownerData.isActive).to.be.true;
      expect(ownerData.level).to.equal(4); // Max tier
    });

    it("Should have correct token allocation", async function () {
      const balance = await vlrToken.balanceOf(referralContract.address);
      expect(balance).to.equal(REFERRAL_ALLOCATION);
    });

    it("Should set authorized contracts correctly", async function () {
      expect(await referralContract.isAuthorizedContract(presaleContract.address)).to.be.true;
      expect(await referralContract.isAuthorizedContract(stakingContract.address)).to.be.true;
    });
  });

  describe("Registration", function () {
    it("Should allow user to register with valid referrer", async function () {
      await expect(referralContract.connect(user1).register(owner.address))
        .to.emit(referralContract, "ReferralRegistered")
        .withArgs(user1.address, owner.address);

      expect(await referralContract.getReferrer(user1.address)).to.equal(owner.address);
    });

    it("Should initialize new user as active referrer", async function () {
      await referralContract.connect(user1).register(owner.address);

      const userData = await referralContract.getReferrerData(user1.address);
      expect(userData.isActive).to.be.true;
      expect(userData.level).to.equal(1); // Starter tier
      expect(userData.directReferrals).to.equal(0);
    });

    it("Should increment referrer's direct referral count", async function () {
      await referralContract.connect(user1).register(owner.address);

      const ownerData = await referralContract.getReferrerData(owner.address);
      expect(ownerData.directReferrals).to.equal(1);
    });

    it("Should reject self-referral", async function () {
      await expect(
        referralContract.connect(user1).register(user1.address)
      ).to.be.revertedWithCustomError(referralContract, "CannotReferSelf");
    });

    it("Should reject double registration", async function () {
      await referralContract.connect(user1).register(owner.address);

      await expect(
        referralContract.connect(user1).register(referrer1.address)
      ).to.be.revertedWithCustomError(referralContract, "AlreadyReferred");
    });

    it("Should reject invalid referrer (zero address)", async function () {
      await expect(
        referralContract.connect(user1).register(ethers.constants.AddressZero)
      ).to.be.revertedWithCustomError(referralContract, "InvalidReferrer");
    });

    it("Should reject inactive referrer", async function () {
      await expect(
        referralContract.connect(user1).register(referrer1.address)
      ).to.be.revertedWithCustomError(referralContract, "ReferrerNotActive");
    });

    it("Should allow chain referrals", async function () {
      // user1 refers to owner
      await referralContract.connect(user1).register(owner.address);

      // user2 refers to user1
      await referralContract.connect(user2).register(user1.address);

      expect(await referralContract.getReferrer(user2.address)).to.equal(user1.address);

      const user1Data = await referralContract.getReferrerData(user1.address);
      expect(user1Data.directReferrals).to.equal(1);
    });
  });

  describe("Tier System", function () {
    beforeEach(async function () {
      // Register referrer1 with owner
      await referralContract.connect(referrer1).register(owner.address);
    });

    it("Should start at Tier 1 (Starter)", async function () {
      const data = await referralContract.getReferrerData(referrer1.address);
      expect(data.level).to.equal(1);
    });

    it("Should upgrade to Tier 2 (Bronze) at 10 referrals", async function () {
      // Register 10 users under referrer1
      for (let i = 0; i < 10; i++) {
        await referralContract.connect(users[i]).register(referrer1.address);
      }

      const data = await referralContract.getReferrerData(referrer1.address);
      expect(data.level).to.equal(2); // Bronze
      expect(data.directReferrals).to.equal(10);
    });

    it("Should upgrade to Tier 3 (Silver) at 25 referrals", async function () {
      // Manually upgrade to test tier 3 (since we don't have 25 signers)
      await referralContract.manualTierUpgrade(referrer1.address, 3);

      const data = await referralContract.getReferrerData(referrer1.address);
      expect(data.level).to.equal(3); // Silver
    });

    it("Should upgrade to Tier 4 (Gold) at 50 referrals", async function () {
      // Manually upgrade to test tier 4 (since we don't have 50 signers)
      await referralContract.manualTierUpgrade(referrer1.address, 4);

      const data = await referralContract.getReferrerData(referrer1.address);
      expect(data.level).to.equal(4); // Gold
    });

    it("Should emit TierUpgraded event", async function () {
      // Register 9 users first
      for (let i = 0; i < 9; i++) {
        await referralContract.connect(users[i]).register(referrer1.address);
      }

      // 10th user should trigger upgrade
      await expect(referralContract.connect(users[9]).register(referrer1.address))
        .to.emit(referralContract, "TierUpgraded")
        .withArgs(referrer1.address, 1, 2);
    });

    it("Should get correct tier bonuses", async function () {
      const tier1 = await referralContract.getTierBonuses(1);
      expect(tier1[0]).to.equal(500); // 5% purchase
      expect(tier1[1]).to.equal(200); // 2% staking

      const tier2 = await referralContract.getTierBonuses(2);
      expect(tier2[0]).to.equal(700); // 7% purchase
      expect(tier2[1]).to.equal(300); // 3% staking

      const tier3 = await referralContract.getTierBonuses(3);
      expect(tier3[0]).to.equal(1000); // 10% purchase
      expect(tier3[1]).to.equal(400); // 4% staking

      const tier4 = await referralContract.getTierBonuses(4);
      expect(tier4[0]).to.equal(1200); // 12% purchase
      expect(tier4[1]).to.equal(500); // 5% staking
    });
  });

  describe("Purchase Bonus Distribution", function () {
    beforeEach(async function () {
      // Setup: referrer1 -> owner, user1 -> referrer1
      await referralContract.connect(referrer1).register(owner.address);
      await referralContract.connect(user1).register(referrer1.address);
    });

    it("Should distribute purchase bonus correctly (Tier 1)", async function () {
      const purchaseAmount = ethers.utils.parseEther("10000"); // 10k VLR
      const expectedBonus = ethers.utils.parseEther("500"); // 5% of 10k

      await expect(
        referralContract
          .connect(presaleContract)
          .distributePurchaseBonus(user1.address, purchaseAmount)
      )
        .to.emit(referralContract, "PurchaseBonusDistributed")
        .withArgs(referrer1.address, user1.address, expectedBonus);

      const pending = await referralContract.getPendingRewards(referrer1.address);
      expect(pending).to.equal(expectedBonus);
    });

    it("Should calculate bonus correctly for different tiers", async function () {
      // Upgrade referrer1 to Tier 2 (7% bonus)
      for (let i = 0; i < 10; i++) {
        await referralContract.connect(users[i]).register(referrer1.address);
      }

      const purchaseAmount = ethers.utils.parseEther("10000");
      const expectedBonus = ethers.utils.parseEther("700"); // 7% of 10k

      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      const pending = await referralContract.getPendingRewards(referrer1.address);
      expect(pending).to.equal(expectedBonus);
    });

    it("Should accumulate multiple bonuses", async function () {
      const purchaseAmount = ethers.utils.parseEther("5000");
      const expectedBonusPerPurchase = ethers.utils.parseEther("250"); // 5% of 5k

      // First purchase
      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      // Second purchase
      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      const pending = await referralContract.getPendingRewards(referrer1.address);
      expect(pending).to.equal(expectedBonusPerPurchase.mul(2));
    });

    it("Should update referrer stats correctly", async function () {
      const purchaseAmount = ethers.utils.parseEther("10000");

      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      const data = await referralContract.getReferrerData(referrer1.address);
      expect(data.totalEarned).to.equal(ethers.utils.parseEther("500"));
      expect(data.purchaseBonusEarned).to.equal(ethers.utils.parseEther("500"));

      const stats = await referralContract.getReferralStats(referrer1.address);
      expect(stats.totalVolume).to.equal(purchaseAmount);
    });

    it("Should skip bonus if no referrer", async function () {
      // user2 has no referrer
      const purchaseAmount = ethers.utils.parseEther("10000");

      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user2.address, purchaseAmount);

      // Should not revert, just skip
      const pending = await referralContract.getPendingRewards(user2.address);
      expect(pending).to.equal(0);
    });

    it("Should reject unauthorized caller", async function () {
      const purchaseAmount = ethers.utils.parseEther("10000");

      await expect(
        referralContract
          .connect(user2)
          .distributePurchaseBonus(user1.address, purchaseAmount)
      ).to.be.revertedWithCustomError(referralContract, "NotAuthorized");
    });

    it("Should reject zero amount", async function () {
      await expect(
        referralContract
          .connect(presaleContract)
          .distributePurchaseBonus(user1.address, 0)
      ).to.be.revertedWithCustomError(referralContract, "InvalidAmount");
    });
  });

  describe("Staking Bonus Distribution", function () {
    beforeEach(async function () {
      await referralContract.connect(referrer1).register(owner.address);
      await referralContract.connect(user1).register(referrer1.address);
    });

    it("Should distribute staking bonus correctly (Tier 1)", async function () {
      const rewardAmount = ethers.utils.parseEther("1000"); // 1k VLR rewards
      const expectedBonus = ethers.utils.parseEther("20"); // 2% of 1k

      await expect(
        referralContract
          .connect(stakingContract)
          .distributeStakingBonus(user1.address, rewardAmount)
      )
        .to.emit(referralContract, "StakingBonusDistributed")
        .withArgs(referrer1.address, user1.address, expectedBonus);

      const pending = await referralContract.getPendingRewards(referrer1.address);
      expect(pending).to.equal(expectedBonus);
    });

    it("Should calculate staking bonus for different tiers", async function () {
      // Upgrade to Tier 3 (4% staking bonus) manually
      await referralContract.manualTierUpgrade(referrer1.address, 3);

      const rewardAmount = ethers.utils.parseEther("1000");
      const expectedBonus = ethers.utils.parseEther("40"); // 4% of 1k

      await referralContract
        .connect(stakingContract)
        .distributeStakingBonus(user1.address, rewardAmount);

      const pending = await referralContract.getPendingRewards(referrer1.address);
      expect(pending).to.equal(expectedBonus);
    });

    it("Should update staking stats correctly", async function () {
      const rewardAmount = ethers.utils.parseEther("1000");

      await referralContract
        .connect(stakingContract)
        .distributeStakingBonus(user1.address, rewardAmount);

      const data = await referralContract.getReferrerData(referrer1.address);
      expect(data.stakingBonusEarned).to.equal(ethers.utils.parseEther("20"));

      const stats = await referralContract.getReferralStats(referrer1.address);
      expect(stats.totalStakingVolume).to.equal(rewardAmount);
    });
  });

  describe("Reward Claiming", function () {
    beforeEach(async function () {
      await referralContract.connect(referrer1).register(owner.address);
      await referralContract.connect(user1).register(referrer1.address);

      // Distribute some bonuses
      const purchaseAmount = ethers.utils.parseEther("10000");
      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);
    });

    it("Should allow claiming pending rewards", async function () {
      const pendingBefore = await referralContract.getPendingRewards(referrer1.address);
      const balanceBefore = await vlrToken.balanceOf(referrer1.address);

      await expect(referralContract.connect(referrer1).claimRewards())
        .to.emit(referralContract, "RewardsClaimed")
        .withArgs(referrer1.address, pendingBefore);

      const pendingAfter = await referralContract.getPendingRewards(referrer1.address);
      const balanceAfter = await vlrToken.balanceOf(referrer1.address);

      expect(pendingAfter).to.equal(0);
      expect(balanceAfter.sub(balanceBefore)).to.equal(pendingBefore);
    });

    it("Should reject claim with no rewards", async function () {
      await expect(
        referralContract.connect(user2).claimRewards()
      ).to.be.revertedWithCustomError(referralContract, "NoRewardsToClaim");
    });

    it("Should reject claim if insufficient contract balance", async function () {
      // Drain contract balance
      const contractBalance = await vlrToken.balanceOf(referralContract.address);
      await referralContract.emergencyWithdraw(contractBalance);

      await expect(
        referralContract.connect(referrer1).claimRewards()
      ).to.be.revertedWithCustomError(referralContract, "InsufficientContractBalance");
    });

    it("Should update total rewards claimed", async function () {
      const pending = await referralContract.getPendingRewards(referrer1.address);

      await referralContract.connect(referrer1).claimRewards();

      const stats = await referralContract.getContractStats();
      expect(stats[2]).to.equal(pending); // totalRewardsClaimed
    });
  });

  describe("View Functions", function () {
    beforeEach(async function () {
      await referralContract.connect(referrer1).register(owner.address);
      await referralContract.connect(user1).register(referrer1.address);
    });

    it("Should get tier names correctly", async function () {
      expect(await referralContract.getTierName(1)).to.equal("Starter");
      expect(await referralContract.getTierName(2)).to.equal("Bronze");
      expect(await referralContract.getTierName(3)).to.equal("Silver");
      expect(await referralContract.getTierName(4)).to.equal("Gold");
    });

    it("Should get next tier thresholds", async function () {
      expect(await referralContract.getNextTierThreshold(1)).to.equal(10);
      expect(await referralContract.getNextTierThreshold(2)).to.equal(25);
      expect(await referralContract.getNextTierThreshold(3)).to.equal(50);
      expect(await referralContract.getNextTierThreshold(4)).to.equal(0);
    });

    it("Should get direct referrals array", async function () {
      const referrals = await referralContract.getDirectReferrals(referrer1.address);
      expect(referrals.length).to.equal(1);
      expect(referrals[0]).to.equal(user1.address);
    });

    it("Should get contract stats", async function () {
      const stats = await referralContract.getContractStats();
      expect(stats[0]).to.be.gt(0); // totalReferrers
      expect(stats[3]).to.equal(REFERRAL_ALLOCATION); // contractBalance
    });
  });

  describe("Owner Functions", function () {
    it("Should allow owner to set authorized contracts", async function () {
      await expect(referralContract.setAuthorizedContract(user1.address, true))
        .to.emit(referralContract, "AuthorizedContractUpdated")
        .withArgs(user1.address, true);

      expect(await referralContract.isAuthorizedContract(user1.address)).to.be.true;
    });

    it("Should allow owner to manually upgrade tier", async function () {
      await referralContract.connect(user1).register(owner.address);

      await expect(referralContract.manualTierUpgrade(user1.address, 3))
        .to.emit(referralContract, "TierUpgraded")
        .withArgs(user1.address, 1, 3);

      const data = await referralContract.getReferrerData(user1.address);
      expect(data.level).to.equal(3);
    });

    it("Should reject invalid tier in manual upgrade", async function () {
      await expect(
        referralContract.manualTierUpgrade(user1.address, 0)
      ).to.be.revertedWithCustomError(referralContract, "InvalidTier");

      await expect(
        referralContract.manualTierUpgrade(user1.address, 5)
      ).to.be.revertedWithCustomError(referralContract, "InvalidTier");
    });

    it("Should allow emergency withdrawal", async function () {
      const withdrawAmount = ethers.utils.parseEther("1000");
      const balanceBefore = await vlrToken.balanceOf(owner.address);

      await referralContract.emergencyWithdraw(withdrawAmount);

      const balanceAfter = await vlrToken.balanceOf(owner.address);
      expect(balanceAfter.sub(balanceBefore)).to.equal(withdrawAmount);
    });

    it("Should allow pause and unpause", async function () {
      await referralContract.pause();

      await expect(
        referralContract.connect(user1).register(owner.address)
      ).to.be.revertedWithCustomError(referralContract, "EnforcedPause");

      await referralContract.unpause();

      await expect(referralContract.connect(user1).register(owner.address)).to.not.be.reverted;
    });
  });

  describe("Integration Scenarios", function () {
    it("Should handle complete referral flow", async function () {
      // 1. Register referrer chain
      await referralContract.connect(referrer1).register(owner.address);
      await referralContract.connect(user1).register(referrer1.address);

      // 2. User makes purchase
      const purchaseAmount = ethers.utils.parseEther("10000");
      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      // 3. User stakes and earns rewards
      const rewardAmount = ethers.utils.parseEther("1000");
      await referralContract
        .connect(stakingContract)
        .distributeStakingBonus(user1.address, rewardAmount);

      // 4. Referrer claims rewards
      const totalExpected = ethers.utils.parseEther("500").add(ethers.utils.parseEther("20"));
      const pending = await referralContract.getPendingRewards(referrer1.address);
      expect(pending).to.equal(totalExpected);

      await referralContract.connect(referrer1).claimRewards();

      const balance = await vlrToken.balanceOf(referrer1.address);
      expect(balance).to.equal(totalExpected);
    });

    it("Should handle tier progression with bonuses", async function () {
      await referralContract.connect(referrer1).register(owner.address);

      // Register users and track bonus changes
      const purchaseAmount = ethers.utils.parseEther("1000");

      // Tier 1: 5% bonus
      await referralContract.connect(user1).register(referrer1.address);
      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      let pending1 = await referralContract.getPendingRewards(referrer1.address);
      expect(pending1).to.equal(ethers.utils.parseEther("50")); // 5% of 1000

      // Register 9 more to reach Tier 2
      for (let i = 0; i < 9; i++) {
        await referralContract.connect(users[i]).register(referrer1.address);
      }

      // Tier 2: 7% bonus
      await referralContract
        .connect(presaleContract)
        .distributePurchaseBonus(user1.address, purchaseAmount);

      let pending2 = await referralContract.getPendingRewards(referrer1.address);
      expect(pending2).to.equal(ethers.utils.parseEther("50").add(ethers.utils.parseEther("70"))); // 50 + 70
    });
  });
});
