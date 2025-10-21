const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("VelirionPresaleV2 - Specification Compliant", function () {
  let presale;
  let vlrToken;
  let usdtToken;
  let usdcToken;
  let owner;
  let buyer1;
  let buyer2;
  let referrer;
  let addrs;

  const INITIAL_ETH_PRICE = ethers.utils.parseEther("2000"); // $2000 per ETH
  const PHASE_DURATION = 7 * 24 * 60 * 60; // 7 days
  const PURCHASE_DELAY = 5 * 60; // 5 minutes

  beforeEach(async function () {
    [owner, buyer1, buyer2, referrer, ...addrs] = await ethers.getSigners();

    // Deploy VLR Token
    const VelirionToken = await ethers.getContractFactory("VelirionToken");
    vlrToken = await VelirionToken.deploy();
    await vlrToken.deployed();

    // Deploy Mock USDT (6 decimals)
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    usdtToken = await MockERC20.deploy("Tether USD", "USDT", 6);
    await usdtToken.deployed();

    // Deploy Mock USDC (6 decimals)
    usdcToken = await MockERC20.deploy("USD Coin", "USDC", 6);
    await usdcToken.deployed();

    // Deploy Presale Contract V2
    const Presale = await ethers.getContractFactory("VelirionPresaleV2");
    presale = await Presale.deploy(
      vlrToken.address,
      usdtToken.address,
      usdcToken.address,
      INITIAL_ETH_PRICE
    );
    await presale.deployed();

    // Transfer VLR tokens to presale (35M: 30M presale + 5M referral bonuses)
    const presaleAmount = ethers.utils.parseEther("35000000");
    await vlrToken.transfer(presale.address, presaleAmount);

    // Mint stablecoins to buyers
    await usdtToken.mint(buyer1.address, 100000 * 10**6);
    await usdtToken.mint(buyer2.address, 100000 * 10**6);
    await usdcToken.mint(buyer1.address, 100000 * 10**6);
    await usdcToken.mint(buyer2.address, 100000 * 10**6);

    // Approve presale
    await usdtToken.connect(buyer1).approve(presale.address, ethers.constants.MaxUint256);
    await usdtToken.connect(buyer2).approve(presale.address, ethers.constants.MaxUint256);
    await usdcToken.connect(buyer1).approve(presale.address, ethers.constants.MaxUint256);
    await usdcToken.connect(buyer2).approve(presale.address, ethers.constants.MaxUint256);

    // Initialize phases
    await presale.initializePhases();
  });

  describe("Phase Initialization - Per Specification", function () {
    it("Should initialize all 10 phases with correct prices", async function () {
      const expectedPrices = [
        ethers.utils.parseEther("0.005"),
        ethers.utils.parseEther("0.006"),
        ethers.utils.parseEther("0.007"),
        ethers.utils.parseEther("0.008"),
        ethers.utils.parseEther("0.009"),
        ethers.utils.parseEther("0.010"),
        ethers.utils.parseEther("0.011"),
        ethers.utils.parseEther("0.012"),
        ethers.utils.parseEther("0.013"),
        ethers.utils.parseEther("0.015"),
      ];

      for (let i = 0; i < 10; i++) {
        const phase = await presale.getPhaseInfo(i);
        expect(phase.pricePerToken).to.equal(expectedPrices[i]);
      }
    });

    it("Should initialize each phase with 3M tokens", async function () {
      for (let i = 0; i < 10; i++) {
        const phase = await presale.getPhaseInfo(i);
        expect(phase.maxTokens).to.equal(ethers.utils.parseEther("3000000"));
      }
    });

    it("Should have 30M total tokens across all phases", async function () {
      let totalTokens = ethers.BigNumber.from(0);
      for (let i = 0; i < 10; i++) {
        const phase = await presale.getPhaseInfo(i);
        totalTokens = totalTokens.add(phase.maxTokens);
      }
      expect(totalTokens).to.equal(ethers.utils.parseEther("30000000"));
    });
  });

  describe("Purchase Limits - Per Specification", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should enforce 50k VLR max per transaction", async function () {
      // At $0.005 per VLR: 50k VLR = $250
      const maxAmount = ethers.utils.parseEther("250"); // $250 in ETH value
      const ethAmount = maxAmount.mul(ethers.utils.parseEther("1")).div(INITIAL_ETH_PRICE);
      
      // This should work (exactly 50k VLR)
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      // Try to buy more than 50k VLR
      const tooMuch = ethAmount.mul(2);
      await expect(
        presale.connect(buyer2).buyWithETH(ethers.constants.AddressZero, {
          value: tooMuch
        })
      ).to.be.revertedWithCustomError(presale, "ExceedsMaxPerTransaction");
    });

    it("Should enforce 500k VLR max per wallet", async function () {
      // Buy 50k VLR multiple times
      const amount = ethers.utils.parseEther("250"); // $250 = 50k VLR at $0.005
      const ethAmount = amount.mul(ethers.utils.parseEther("1")).div(INITIAL_ETH_PRICE);
      
      // Buy 10 times = 500k VLR (should work)
      for (let i = 0; i < 10; i++) {
        await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
          value: ethAmount
        });
        await time.increase(PURCHASE_DELAY + 1);
      }

      // 11th purchase should fail
      await time.increase(PURCHASE_DELAY + 1);
      await expect(
        presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
          value: ethAmount
        })
      ).to.be.revertedWithCustomError(presale, "ExceedsMaxPerWallet");
    });
  });

  describe("Antibot - 5 Minute Delay", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should allow first purchase immediately", async function () {
      const ethAmount = ethers.utils.parseEther("0.01");
      
      await expect(
        presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
          value: ethAmount
        })
      ).to.not.be.reverted;
    });

    it("Should block second purchase within 5 minutes", async function () {
      const ethAmount = ethers.utils.parseEther("0.01");
      
      // First purchase
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      // Second purchase immediately (should fail)
      await expect(
        presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
          value: ethAmount
        })
      ).to.be.revertedWithCustomError(presale, "PurchaseDelayNotMet");
    });

    it("Should allow purchase after 5 minutes", async function () {
      const ethAmount = ethers.utils.parseEther("0.01");
      
      // First purchase
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      // Wait 5 minutes
      await time.increase(PURCHASE_DELAY + 1);

      // Second purchase (should work)
      await expect(
        presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
          value: ethAmount
        })
      ).to.not.be.reverted;
    });

    it("Should show correct wait time via canPurchase", async function () {
      const ethAmount = ethers.utils.parseEther("0.01");
      
      // First purchase
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      // Check immediately
      const [canBuy, message] = await presale.canPurchase(buyer1.address);
      expect(canBuy).to.be.false;
      expect(message).to.include("Wait");
    });
  });

  describe("Vesting Schedule - 40% + 30% + 30%", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should setup vesting correctly on purchase", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      const schedule = await presale.getVestingSchedule(buyer1.address);
      expect(schedule.totalAmount).to.be.gt(0);
      expect(schedule.claimedAmount).to.equal(0);
    });

    it("Should allow claiming 40% at TGE", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      const schedule = await presale.getVestingSchedule(buyer1.address);
      const claimable = await presale.getClaimableAmount(buyer1.address);
      
      // Should be 40% of total
      const expected40Percent = schedule.totalAmount.mul(40).div(100);
      expect(claimable).to.be.closeTo(expected40Percent, ethers.utils.parseEther("0.01"));
    });

    it("Should allow claiming 70% after 30 days", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      // Wait 30 days
      await time.increase(30 * 24 * 60 * 60);

      const schedule = await presale.getVestingSchedule(buyer1.address);
      const claimable = await presale.getClaimableAmount(buyer1.address);
      
      // Should be 70% of total (40% + 30%)
      const expected70Percent = schedule.totalAmount.mul(70).div(100);
      expect(claimable).to.be.closeTo(expected70Percent, ethers.utils.parseEther("0.01"));
    });

    it("Should allow claiming 100% after 60 days", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      // Wait 60 days
      await time.increase(60 * 24 * 60 * 60);

      const schedule = await presale.getVestingSchedule(buyer1.address);
      const claimable = await presale.getClaimableAmount(buyer1.address);
      
      // Should be 100% of total
      expect(claimable).to.equal(schedule.totalAmount);
    });

    it("Should transfer tokens on claim", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      const balanceBefore = await vlrToken.balanceOf(buyer1.address);
      await presale.connect(buyer1).claimTokens();
      const balanceAfter = await vlrToken.balanceOf(buyer1.address);
      
      expect(balanceAfter).to.be.gt(balanceBefore);
    });

    it("Should update claimed amount after claim", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      await presale.connect(buyer1).claimTokens();
      
      const schedule = await presale.getVestingSchedule(buyer1.address);
      expect(schedule.claimedAmount).to.be.gt(0);
    });
  });

  describe("ETH Purchases", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should calculate correct token amount for ETH", async function () {
      const ethAmount = ethers.utils.parseEther("1"); // 1 ETH = $2000
      const expectedTokens = await presale.calculateTokenAmountForETH(ethAmount);
      
      // At $0.005 per token: $2000 / $0.005 = 400,000 tokens
      expect(expectedTokens).to.equal(ethers.utils.parseEther("400000"));
    });

    it("Should process ETH purchase correctly", async function () {
      const ethAmount = ethers.utils.parseEther("0.01");
      
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethAmount
      });

      const purchases = await presale.getUserPurchases(buyer1.address);
      expect(purchases.length).to.equal(1);
      expect(purchases[0].paymentToken).to.equal(ethers.constants.AddressZero);
    });
  });

  describe("Stablecoin Purchases", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should process USDT purchase correctly", async function () {
      const usdtAmount = 100 * 10**6; // 100 USDT
      
      await presale.connect(buyer1).buyWithUSDT(usdtAmount, ethers.constants.AddressZero);

      const purchases = await presale.getUserPurchases(buyer1.address);
      expect(purchases.length).to.equal(1);
      expect(purchases[0].paymentToken).to.equal(usdtToken.address);
    });

    it("Should process USDC purchase correctly", async function () {
      const usdcAmount = 100 * 10**6; // 100 USDC
      
      await presale.connect(buyer1).buyWithUSDC(usdcAmount, ethers.constants.AddressZero);

      const purchases = await presale.getUserPurchases(buyer1.address);
      expect(purchases.length).to.equal(1);
      expect(purchases[0].paymentToken).to.equal(usdcToken.address);
    });
  });

  describe("Referral System", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should process 5% referral bonus", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      const referrerBalanceBefore = await vlrToken.balanceOf(referrer.address);
      
      await presale.connect(buyer1).buyWithETH(referrer.address, {
        value: ethAmount
      });

      const referrerBalanceAfter = await vlrToken.balanceOf(referrer.address);
      expect(referrerBalanceAfter).to.be.gt(referrerBalanceBefore);
    });

    it("Should update referral statistics", async function () {
      const ethAmount = ethers.utils.parseEther("0.1");
      
      await presale.connect(buyer1).buyWithETH(referrer.address, {
        value: ethAmount
      });

      const referralInfo = await presale.getReferralInfo(referrer.address);
      expect(referralInfo.totalReferred).to.equal(1);
      expect(referralInfo.totalEarned).to.be.gt(0);
    });
  });

  describe("Presale Finalization", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
    });

    it("Should allow owner to finalize presale", async function () {
      await expect(presale.finalizePresale()).to.not.be.reverted;
    });

    it("Should burn unsold tokens on finalization", async function () {
      const contractBalanceBefore = await vlrToken.balanceOf(presale.address);
      
      await presale.finalizePresale();
      
      // Tokens should be burned (sent to dead address)
      const deadBalance = await vlrToken.balanceOf("0x000000000000000000000000000000000000dead");
      expect(deadBalance).to.be.gt(0);
    });
  });

  describe("Fund Withdrawal", function () {
    beforeEach(async function () {
      await presale.startPresale(PHASE_DURATION);
      await presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
        value: ethers.utils.parseEther("0.1")
      });
    });

    it("Should allow owner to withdraw ETH", async function () {
      await expect(presale.withdrawETH()).to.not.be.reverted;
    });

    it("Should only allow owner to withdraw", async function () {
      await expect(
        presale.connect(buyer1).withdrawETH()
      ).to.be.reverted;
    });
  });

  describe("Emergency Controls", function () {
    it("Should allow owner to pause", async function () {
      await presale.pause();
      expect(await presale.paused()).to.be.true;
    });

    it("Should block purchases when paused", async function () {
      await presale.startPresale(PHASE_DURATION);
      await presale.pause();
      
      await expect(
        presale.connect(buyer1).buyWithETH(ethers.constants.AddressZero, {
          value: ethers.utils.parseEther("0.1")
        })
      ).to.be.reverted;
    });
  });
});
