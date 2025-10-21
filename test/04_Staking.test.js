const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VelirionStaking", function () {
  let stakingContract;
  let vlrToken;
  let referralContract;
  let owner;
  let user1;
  let user2;
  let user3;
  let users;

  const STAKING_ALLOCATION = ethers.utils.parseEther("20000000"); // 20M VLR

  // Helper function to advance time
  async function advanceTime(seconds) {
    await ethers.provider.send("evm_increaseTime", [seconds]);
    await ethers.provider.send("evm_mine");
  }

  beforeEach(async function () {
    [owner, user1, user2, user3, ...users] = await ethers.getSigners();

    // Deploy VLR Token
    const VLRToken = await ethers.getContractFactory("VelirionToken");
    vlrToken = await VLRToken.deploy();
    await vlrToken.deployed();

    // Deploy Referral Contract
    const ReferralContract = await ethers.getContractFactory("VelirionReferral");
    referralContract = await ReferralContract.deploy(vlrToken.address);
    await referralContract.deployed();

    // Deploy Staking Contract
    const StakingContract = await ethers.getContractFactory("VelirionStaking");
    stakingContract = await StakingContract.deploy(vlrToken.address);
    await stakingContract.deployed();

    // Allocate tokens to staking contract
    await vlrToken.transfer(stakingContract.address, STAKING_ALLOCATION);

    // Set referral contract in staking
    await stakingContract.setReferralContract(referralContract.address);

    // Authorize staking in referral contract
    await referralContract.setAuthorizedContract(stakingContract.address, true);

    // Transfer some tokens to users for staking
    const userAmount = ethers.utils.parseEther("1000000"); // 1M VLR each
    await vlrToken.transfer(user1.address, userAmount);
    await vlrToken.transfer(user2.address, userAmount);
    await vlrToken.transfer(user3.address, userAmount);

    // Approve staking contract
    await vlrToken.connect(user1).approve(stakingContract.address, ethers.constants.MaxUint256);
    await vlrToken.connect(user2).approve(stakingContract.address, ethers.constants.MaxUint256);
    await vlrToken.connect(user3).approve(stakingContract.address, ethers.constants.MaxUint256);
  });

  describe("Deployment", function () {
    it("Should deploy with correct VLR token", async function () {
      expect(await stakingContract.vlrToken()).to.equal(vlrToken.address);
    });

    it("Should have correct token allocation", async function () {
      const balance = await vlrToken.balanceOf(stakingContract.address);
      expect(balance).to.equal(STAKING_ALLOCATION);
    });

    it("Should set referral contract correctly", async function () {
      expect(await stakingContract.referralContract()).to.equal(referralContract.address);
    });
  });

  describe("Flexible Tier (6% APR, No Lock)", function () {
    const FLEXIBLE_TIER = 0;
    const stakeAmount = ethers.utils.parseEther("1000"); // 1000 VLR

    it("Should stake minimum amount (100 VLR)", async function () {
      const minAmount = ethers.utils.parseEther("100");
      
      await expect(
        stakingContract.connect(user1).stake(minAmount, FLEXIBLE_TIER, 0)
      ).to.emit(stakingContract, "Staked")
        .withArgs(user1.address, 0, minAmount, FLEXIBLE_TIER, 0, 600); // 600 = 6% APR

      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.amount).to.equal(minAmount);
      expect(stakeInfo.tier).to.equal(FLEXIBLE_TIER);
      expect(stakeInfo.apr).to.equal(600); // 6%
    });

    it("Should reject stake below minimum (100 VLR)", async function () {
      const belowMin = ethers.utils.parseEther("99");
      
      await expect(
        stakingContract.connect(user1).stake(belowMin, FLEXIBLE_TIER, 0)
      ).to.be.revertedWithCustomError(stakingContract, "BelowMinimumStake");
    });

    it("Should unstake anytime without penalty", async function () {
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      const balanceBefore = await vlrToken.balanceOf(user1.address);
      
      await stakingContract.connect(user1).unstake(0);
      
      const balanceAfter = await vlrToken.balanceOf(user1.address);
      // Should get stake back (some tiny rewards may have accrued during tx)
      expect(balanceAfter.sub(balanceBefore)).to.be.gte(stakeAmount); // No penalty, at least stake amount
    });

    it("Should calculate rewards correctly (6% APR)", async function () {
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // Advance 365 days
      await advanceTime(365 * 24 * 60 * 60);
      
      const rewards = await stakingContract.calculateRewards(user1.address, 0);
      
      // Expected: 1000 * 6% = 60 VLR per year
      const expectedRewards = ethers.utils.parseEther("60");
      const tolerance = ethers.utils.parseEther("0.1"); // 0.1 VLR tolerance
      
      expect(rewards).to.be.closeTo(expectedRewards, tolerance);
    });

    it("Should claim rewards successfully", async function () {
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // Advance 30 days
      await advanceTime(30 * 24 * 60 * 60);
      
      const rewardsBefore = await stakingContract.calculateRewards(user1.address, 0);
      expect(rewardsBefore).to.be.gt(0);
      
      const balanceBefore = await vlrToken.balanceOf(user1.address);
      
      await expect(stakingContract.connect(user1).claimRewards(0))
        .to.emit(stakingContract, "RewardsClaimed");
      
      const balanceAfter = await vlrToken.balanceOf(user1.address);
      expect(balanceAfter.sub(balanceBefore)).to.be.closeTo(rewardsBefore, ethers.utils.parseEther("0.01"));
    });
  });

  describe("Medium Tier (12-15% APR, 90-180 days)", function () {
    const MEDIUM_TIER = 1;
    const stakeAmount = ethers.utils.parseEther("5000"); // 5000 VLR

    it("Should stake with 90-day lock (12% APR)", async function () {
      const lockDuration = 90 * 24 * 60 * 60; // 90 days
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, lockDuration)
      ).to.emit(stakingContract, "Staked")
        .withArgs(user1.address, 0, stakeAmount, MEDIUM_TIER, lockDuration, 1200); // 1200 = 12%

      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.apr).to.equal(1200); // 12%
    });

    it("Should stake with 180-day lock (15% APR)", async function () {
      const lockDuration = 180 * 24 * 60 * 60; // 180 days
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, lockDuration)
      ).to.emit(stakingContract, "Staked")
        .withArgs(user1.address, 0, stakeAmount, MEDIUM_TIER, lockDuration, 1500); // 1500 = 15%

      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.apr).to.equal(1500); // 15%
    });

    it("Should calculate APR interpolation correctly (135 days = 13.5%)", async function () {
      const lockDuration = 135 * 24 * 60 * 60; // 135 days (middle)
      
      await stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, lockDuration);
      
      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      // 135 days is halfway between 90 and 180, so APR should be ~13.5% (1350 BPS)
      expect(stakeInfo.apr).to.equal(1350); // 13.5%
    });

    it("Should apply 5% penalty for early withdrawal", async function () {
      const lockDuration = 90 * 24 * 60 * 60; // 90 days
      await stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, lockDuration);
      
      // Unstake immediately (before lock ends)
      const penalty = await stakingContract.calculatePenalty(user1.address, 0);
      const expectedPenalty = stakeAmount.mul(500).div(10000); // 5%
      expect(penalty).to.equal(expectedPenalty);
      
      const balanceBefore = await vlrToken.balanceOf(user1.address);
      
      await stakingContract.connect(user1).unstake(0);
      
      const balanceAfter = await vlrToken.balanceOf(user1.address);
      const netAmount = stakeAmount.sub(expectedPenalty);
      expect(balanceAfter.sub(balanceBefore)).to.be.closeTo(netAmount, ethers.utils.parseEther("0.01"));
    });

    it("Should not apply penalty after lock period", async function () {
      const lockDuration = 90 * 24 * 60 * 60; // 90 days
      await stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, lockDuration);
      
      // Advance past lock period
      await advanceTime(91 * 24 * 60 * 60);
      
      const penalty = await stakingContract.calculatePenalty(user1.address, 0);
      expect(penalty).to.equal(0); // No penalty
      
      const canUnstake = await stakingContract.canUnstakeWithoutPenalty(user1.address, 0);
      expect(canUnstake).to.be.true;
    });

    it("Should reject lock duration below minimum", async function () {
      const shortLock = 89 * 24 * 60 * 60; // 89 days (below 90)
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, shortLock)
      ).to.be.revertedWithCustomError(stakingContract, "InvalidLockDuration");
    });

    it("Should reject lock duration above maximum", async function () {
      const longLock = 181 * 24 * 60 * 60; // 181 days (above 180)
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, MEDIUM_TIER, longLock)
      ).to.be.revertedWithCustomError(stakingContract, "InvalidLockDuration");
    });
  });

  describe("Long Tier (20-22% APR, 1 year)", function () {
    const LONG_TIER = 2;
    const stakeAmount = ethers.utils.parseEther("10000"); // 10000 VLR

    it("Should stake for 1 year (20% APR)", async function () {
      const lockDuration = 365 * 24 * 60 * 60; // 1 year
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, LONG_TIER, lockDuration)
      ).to.emit(stakingContract, "Staked")
        .withArgs(user1.address, 0, stakeAmount, LONG_TIER, lockDuration, 2000); // 2000 = 20%

      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.apr).to.equal(2000); // 20%
    });

    it("Should renew for 22% APR (+2% bonus)", async function () {
      const lockDuration = 365 * 24 * 60 * 60; // 1 year
      await stakingContract.connect(user1).stake(stakeAmount, LONG_TIER, lockDuration);
      
      // Advance past lock period
      await advanceTime(366 * 24 * 60 * 60);
      
      await expect(stakingContract.connect(user1).renewStake(0))
        .to.emit(stakingContract, "StakeRenewed")
        .withArgs(user1.address, 0, 2000, 2200); // 20% -> 22%
      
      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.apr).to.equal(2200); // 22%
      expect(stakeInfo.renewed).to.be.true;
    });

    it("Should apply 7% penalty for early withdrawal", async function () {
      const lockDuration = 365 * 24 * 60 * 60; // 1 year
      await stakingContract.connect(user1).stake(stakeAmount, LONG_TIER, lockDuration);
      
      const penalty = await stakingContract.calculatePenalty(user1.address, 0);
      const expectedPenalty = stakeAmount.mul(700).div(10000); // 7%
      expect(penalty).to.equal(expectedPenalty);
    });

    it("Should grant 2x DAO voting weight", async function () {
      const lockDuration = 365 * 24 * 60 * 60; // 1 year
      await stakingContract.connect(user1).stake(stakeAmount, LONG_TIER, lockDuration);
      
      const votingPower = await stakingContract.getVotingPower(user1.address);
      expect(votingPower).to.equal(stakeAmount.mul(2)); // 2x weight
    });

    it("Should reject renewal before lock period ends", async function () {
      const lockDuration = 365 * 24 * 60 * 60; // 1 year
      await stakingContract.connect(user1).stake(stakeAmount, LONG_TIER, lockDuration);
      
      await expect(
        stakingContract.connect(user1).renewStake(0)
      ).to.be.revertedWithCustomError(stakingContract, "CannotRenewBeforeLockEnd");
    });

    it("Should reject double renewal", async function () {
      const lockDuration = 365 * 24 * 60 * 60; // 1 year
      await stakingContract.connect(user1).stake(stakeAmount, LONG_TIER, lockDuration);
      
      // Advance past lock period
      await advanceTime(366 * 24 * 60 * 60);
      
      await stakingContract.connect(user1).renewStake(0);
      
      await expect(
        stakingContract.connect(user1).renewStake(0)
      ).to.be.revertedWithCustomError(stakingContract, "AlreadyRenewed");
    });
  });

  describe("Elite Tier (30-32% APR, 2 years)", function () {
    const ELITE_TIER = 3;
    const stakeAmount = ethers.utils.parseEther("300000"); // 300000 VLR

    it("Should stake for 2 years (30% APR)", async function () {
      const lockDuration = 730 * 24 * 60 * 60; // 2 years
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, ELITE_TIER, lockDuration)
      ).to.emit(stakingContract, "Staked")
        .withArgs(user1.address, 0, stakeAmount, ELITE_TIER, lockDuration, 3000); // 3000 = 30%

      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.apr).to.equal(3000); // 30%
    });

    it("Should renew for 32% APR (+2% bonus)", async function () {
      const lockDuration = 730 * 24 * 60 * 60; // 2 years
      await stakingContract.connect(user1).stake(stakeAmount, ELITE_TIER, lockDuration);
      
      // Advance past lock period
      await advanceTime(731 * 24 * 60 * 60);
      
      await expect(stakingContract.connect(user1).renewStake(0))
        .to.emit(stakingContract, "StakeRenewed")
        .withArgs(user1.address, 0, 3000, 3200); // 30% -> 32%
      
      const stakeInfo = await stakingContract.getStakeInfo(user1.address, 0);
      expect(stakeInfo.apr).to.equal(3200); // 32%
    });

    it("Should apply 10% penalty for early withdrawal", async function () {
      const lockDuration = 730 * 24 * 60 * 60; // 2 years
      await stakingContract.connect(user1).stake(stakeAmount, ELITE_TIER, lockDuration);
      
      const penalty = await stakingContract.calculatePenalty(user1.address, 0);
      const expectedPenalty = stakeAmount.mul(1000).div(10000); // 10%
      expect(penalty).to.equal(expectedPenalty);
    });

    it("Should grant 2x DAO voting weight", async function () {
      const lockDuration = 730 * 24 * 60 * 60; // 2 years
      await stakingContract.connect(user1).stake(stakeAmount, ELITE_TIER, lockDuration);
      
      const votingPower = await stakingContract.getVotingPower(user1.address);
      expect(votingPower).to.equal(stakeAmount.mul(2)); // 2x weight
    });

    it("Should reject stake below minimum (250,000 VLR)", async function () {
      const belowMin = ethers.utils.parseEther("249999");
      const lockDuration = 730 * 24 * 60 * 60;
      
      await expect(
        stakingContract.connect(user1).stake(belowMin, ELITE_TIER, lockDuration)
      ).to.be.revertedWithCustomError(stakingContract, "BelowMinimumStake");
    });
  });

  describe("Reward Calculations", function () {
    it("Should calculate rewards over time correctly", async function () {
      const stakeAmount = ethers.utils.parseEther("10000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // Check rewards after 30 days
      await advanceTime(30 * 24 * 60 * 60);
      const rewards30 = await stakingContract.calculateRewards(user1.address, 0);
      
      // Check rewards after another 30 days (60 total)
      await advanceTime(30 * 24 * 60 * 60);
      const rewards60 = await stakingContract.calculateRewards(user1.address, 0);
      
      // Rewards should approximately double
      expect(rewards60).to.be.closeTo(rewards30.mul(2), ethers.utils.parseEther("0.1"));
    });

    it("Should handle multiple claims correctly", async function () {
      const stakeAmount = ethers.utils.parseEther("10000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // First claim after 30 days
      await advanceTime(30 * 24 * 60 * 60);
      await stakingContract.connect(user1).claimRewards(0);
      
      // Second claim after another 30 days
      await advanceTime(30 * 24 * 60 * 60);
      const rewards = await stakingContract.calculateRewards(user1.address, 0);
      
      expect(rewards).to.be.gt(0); // Should have new rewards
    });

    it("Should support multiple active stakes", async function () {
      const stakeAmount = ethers.utils.parseEther("5000");
      const FLEXIBLE_TIER = 0;
      
      // Create 3 stakes
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      const userStakes = await stakingContract.getUserStakes(user1.address);
      expect(userStakes.length).to.equal(3);
      
      const userInfo = await stakingContract.getUserStakingInfo(user1.address);
      expect(userInfo.totalStaked).to.equal(stakeAmount.mul(3));
      expect(userInfo.activeStakes).to.equal(3);
    });
  });

  describe("Referral Integration", function () {
    it("Should distribute staking bonus to referrer on claim", async function () {
      // Setup referral
      await referralContract.connect(user1).register(owner.address);
      await referralContract.connect(user2).register(user1.address);
      
      // User2 stakes
      const stakeAmount = ethers.utils.parseEther("10000");
      const FLEXIBLE_TIER = 0;
      await stakingContract.connect(user2).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // Advance time and claim
      await advanceTime(30 * 24 * 60 * 60);
      
      const pendingBefore = await referralContract.getPendingRewards(user1.address);
      
      await stakingContract.connect(user2).claimRewards(0);
      
      const pendingAfter = await referralContract.getPendingRewards(user1.address);
      
      // Referrer should have received bonus (2% for tier 1)
      expect(pendingAfter).to.be.gt(pendingBefore);
    });

    it("Should work without referral contract", async function () {
      // Deploy new staking without referral
      const StakingContract = await ethers.getContractFactory("VelirionStaking");
      const newStaking = await StakingContract.deploy(vlrToken.address);
      await newStaking.deployed();
      
      await vlrToken.transfer(newStaking.address, STAKING_ALLOCATION);
      await vlrToken.connect(user1).approve(newStaking.address, ethers.constants.MaxUint256);
      
      const stakeAmount = ethers.utils.parseEther("1000");
      const FLEXIBLE_TIER = 0;
      
      // Should work without referral contract
      await expect(
        newStaking.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0)
      ).to.not.be.reverted;
    });
  });

  describe("View Functions", function () {
    it("Should get minimum stake amounts correctly", async function () {
      expect(await stakingContract.getMinimumStake(0)).to.equal(ethers.utils.parseEther("100"));
      expect(await stakingContract.getMinimumStake(1)).to.equal(ethers.utils.parseEther("1000"));
      expect(await stakingContract.getMinimumStake(2)).to.equal(ethers.utils.parseEther("5000"));
      expect(await stakingContract.getMinimumStake(3)).to.equal(ethers.utils.parseEther("250000"));
    });

    it("Should get lock durations correctly", async function () {
      expect(await stakingContract.getMinimumLock(0)).to.equal(0);
      expect(await stakingContract.getMinimumLock(1)).to.equal(90 * 24 * 60 * 60);
      expect(await stakingContract.getMinimumLock(2)).to.equal(365 * 24 * 60 * 60);
      expect(await stakingContract.getMinimumLock(3)).to.equal(730 * 24 * 60 * 60);
    });

    it("Should get contract stats correctly", async function () {
      const stakeAmount = ethers.utils.parseEther("1000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      await stakingContract.connect(user2).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      const stats = await stakingContract.getContractStats();
      expect(stats[0]).to.equal(stakeAmount.mul(2)); // totalStaked
      expect(stats[1]).to.equal(2); // totalStakers
    });
  });

  describe("Owner Functions", function () {
    it("Should allow owner to set referral contract", async function () {
      const newReferral = user3.address;
      
      await expect(stakingContract.setReferralContract(newReferral))
        .to.emit(stakingContract, "ReferralContractUpdated")
        .withArgs(newReferral);
      
      expect(await stakingContract.referralContract()).to.equal(newReferral);
    });

    it("Should allow emergency withdrawal of unstaked tokens", async function () {
      const withdrawAmount = ethers.utils.parseEther("1000");
      const balanceBefore = await vlrToken.balanceOf(owner.address);
      
      await stakingContract.emergencyWithdraw(withdrawAmount);
      
      const balanceAfter = await vlrToken.balanceOf(owner.address);
      expect(balanceAfter.sub(balanceBefore)).to.equal(withdrawAmount);
    });

    it("Should reject emergency withdrawal of staked tokens", async function () {
      const stakeAmount = ethers.utils.parseEther("10000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // Try to withdraw more than available (total - staked)
      const contractBalance = await vlrToken.balanceOf(stakingContract.address);
      
      await expect(
        stakingContract.emergencyWithdraw(contractBalance)
      ).to.be.revertedWith("Insufficient available balance");
    });

    it("Should allow pause and unpause", async function () {
      await stakingContract.pause();
      
      const stakeAmount = ethers.utils.parseEther("1000");
      const FLEXIBLE_TIER = 0;
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0)
      ).to.be.revertedWithCustomError(stakingContract, "EnforcedPause");
      
      await stakingContract.unpause();
      
      await expect(
        stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0)
      ).to.not.be.reverted;
    });
  });

  describe("Edge Cases", function () {
    it("Should handle claim with minimal rewards", async function () {
      const stakeAmount = ethers.utils.parseEther("1000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      // Even in the same block, some time passes between transactions
      // This test verifies the system handles very small reward amounts correctly
      // In practice, some tiny rewards will always accrue due to block time
      await expect(
        stakingContract.connect(user1).claimRewards(0)
      ).to.not.be.reverted; // Should work with tiny rewards
    });

    it("Should reject unstake of non-existent stake", async function () {
      await expect(
        stakingContract.connect(user1).unstake(999)
      ).to.be.revertedWithCustomError(stakingContract, "StakeNotFound");
    });

    it("Should reject renewal of Flexible tier", async function () {
      const stakeAmount = ethers.utils.parseEther("1000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      
      await expect(
        stakingContract.connect(user1).renewStake(0)
      ).to.be.revertedWithCustomError(stakingContract, "CannotRenewFlexible");
    });

    it("Should handle unstake after stake becomes inactive", async function () {
      const stakeAmount = ethers.utils.parseEther("1000");
      const FLEXIBLE_TIER = 0;
      
      await stakingContract.connect(user1).stake(stakeAmount, FLEXIBLE_TIER, 0);
      await stakingContract.connect(user1).unstake(0);
      
      await expect(
        stakingContract.connect(user1).unstake(0)
      ).to.be.revertedWithCustomError(stakingContract, "StakeNotActive");
    });
  });
});
