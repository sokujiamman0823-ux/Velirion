const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VelirionToken", function () {
  let token;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  const INITIAL_SUPPLY = ethers.utils.parseEther("100000000"); // 100M tokens

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    
    const VelirionToken = await ethers.getContractFactory("VelirionToken");
    token = await VelirionToken.deploy();
    await token.deployed();
  });

  describe("Deployment", function () {
    it("Should set the correct name and symbol", async function () {
      expect(await token.name()).to.equal("Velirion");
      expect(await token.symbol()).to.equal("VLR");
    });

    it("Should have 18 decimals", async function () {
      expect(await token.decimals()).to.equal(18);
    });

    it("Should mint initial supply to owner", async function () {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });

    it("Should have correct initial supply", async function () {
      expect(await token.totalSupply()).to.equal(INITIAL_SUPPLY);
    });

    it("Should set the deployer as owner", async function () {
      expect(await token.owner()).to.equal(owner.address);
    });
  });

  describe("Token Allocation", function () {
    it("Should allocate tokens correctly", async function () {
      const amount = ethers.utils.parseEther("1000000"); // 1M tokens
      
      await token.allocate("presale", addr1.address, amount);
      
      expect(await token.balanceOf(addr1.address)).to.equal(amount);
      expect(await token.allocationTracking("presale")).to.equal(amount);
      expect(await token.totalAllocated()).to.equal(amount);
    });

    it("Should track multiple allocations to same category", async function () {
      const amount1 = ethers.utils.parseEther("1000000");
      const amount2 = ethers.utils.parseEther("500000");
      
      await token.allocate("presale", addr1.address, amount1);
      await token.allocate("presale", addr2.address, amount2);
      
      expect(await token.allocationTracking("presale")).to.equal(amount1.add(amount2));
      expect(await token.totalAllocated()).to.equal(amount1.add(amount2));
    });

    it("Should track allocations across different categories", async function () {
      const presaleAmount = ethers.utils.parseEther("30000000");
      const stakingAmount = ethers.utils.parseEther("20000000");
      
      await token.allocate("presale", addr1.address, presaleAmount);
      await token.allocate("staking", addr2.address, stakingAmount);
      
      expect(await token.getAllocation("presale")).to.equal(presaleAmount);
      expect(await token.getAllocation("staking")).to.equal(stakingAmount);
      expect(await token.totalAllocated()).to.equal(presaleAmount.add(stakingAmount));
    });

    it("Should emit TokensAllocated event", async function () {
      const amount = ethers.utils.parseEther("1000000");
      
      await expect(token.allocate("presale", addr1.address, amount))
        .to.emit(token, "TokensAllocated")
        .withArgs("presale", addr1.address, amount);
    });

    it("Should revert if non-owner tries to allocate", async function () {
      const amount = ethers.utils.parseEther("1000");
      
      await expect(
        token.connect(addr1).allocate("test", addr2.address, amount)
      ).to.be.reverted;
    });

    it("Should revert allocation to zero address", async function () {
      const amount = ethers.utils.parseEther("1000");
      
      await expect(
        token.allocate("test", ethers.constants.AddressZero, amount)
      ).to.be.revertedWith("VelirionToken: Invalid recipient address");
    });

    it("Should revert allocation of zero amount", async function () {
      await expect(
        token.allocate("test", addr1.address, 0)
      ).to.be.revertedWith("VelirionToken: Amount must be greater than zero");
    });

    it("Should revert if insufficient balance", async function () {
      const excessAmount = ethers.utils.parseEther("100000001"); // More than total supply
      
      await expect(
        token.allocate("test", addr1.address, excessAmount)
      ).to.be.revertedWith("VelirionToken: Insufficient balance");
    });
  });

  describe("Burning", function () {
    it("Should burn tokens correctly", async function () {
      const burnAmount = ethers.utils.parseEther("1000000");
      const initialSupply = await token.totalSupply();
      
      await token.burn(burnAmount);
      
      const finalSupply = await token.totalSupply();
      expect(finalSupply).to.equal(initialSupply.sub(burnAmount));
    });

    it("Should burn unsold presale tokens", async function () {
      const burnAmount = ethers.utils.parseEther("5000000");
      const initialSupply = await token.totalSupply();
      
      await token.burnUnsold(burnAmount);
      
      expect(await token.totalSupply()).to.equal(initialSupply.sub(burnAmount));
    });

    it("Should emit UnsoldTokensBurned event", async function () {
      const burnAmount = ethers.utils.parseEther("1000000");
      
      await expect(token.burnUnsold(burnAmount))
        .to.emit(token, "UnsoldTokensBurned")
        .withArgs(burnAmount);
    });

    it("Should revert burn of zero amount", async function () {
      await expect(
        token.burnUnsold(0)
      ).to.be.revertedWith("VelirionToken: Amount must be greater than zero");
    });

    it("Should revert if non-owner tries to burn unsold", async function () {
      const burnAmount = ethers.utils.parseEther("1000000");
      
      await expect(
        token.connect(addr1).burnUnsold(burnAmount)
      ).to.be.reverted;
    });

    it("Should allow users to burn their own tokens", async function () {
      const amount = ethers.utils.parseEther("1000");
      await token.transfer(addr1.address, amount);
      
      await token.connect(addr1).burn(amount);
      
      expect(await token.balanceOf(addr1.address)).to.equal(0);
    });
  });

  describe("Pausable", function () {
    it("Should pause and unpause transfers", async function () {
      await token.pause();
      
      await expect(
        token.transfer(addr1.address, ethers.utils.parseEther("100"))
      ).to.be.reverted;
      
      await token.unpause();
      
      await expect(
        token.transfer(addr1.address, ethers.utils.parseEther("100"))
      ).to.not.be.reverted;
    });

    it("Should emit EmergencyPause event", async function () {
      await expect(token.pause())
        .to.emit(token, "EmergencyPause")
        .withArgs(owner.address);
    });

    it("Should emit EmergencyUnpause event", async function () {
      await token.pause();
      
      await expect(token.unpause())
        .to.emit(token, "EmergencyUnpause")
        .withArgs(owner.address);
    });

    it("Should revert if non-owner tries to pause", async function () {
      await expect(
        token.connect(addr1).pause()
      ).to.be.reverted;
    });

    it("Should revert if non-owner tries to unpause", async function () {
      await token.pause();
      
      await expect(
        token.connect(addr1).unpause()
      ).to.be.reverted;
    });

    it("Should block transfers when paused", async function () {
      await token.transfer(addr1.address, ethers.utils.parseEther("1000"));
      await token.pause();
      
      await expect(
        token.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("100"))
      ).to.be.reverted;
    });
  });

  describe("Standard ERC20 Functions", function () {
    it("Should transfer tokens between accounts", async function () {
      const amount = ethers.utils.parseEther("1000");
      
      await token.transfer(addr1.address, amount);
      expect(await token.balanceOf(addr1.address)).to.equal(amount);
      
      await token.connect(addr1).transfer(addr2.address, amount);
      expect(await token.balanceOf(addr2.address)).to.equal(amount);
      expect(await token.balanceOf(addr1.address)).to.equal(0);
    });

    it("Should approve and transferFrom", async function () {
      const amount = ethers.utils.parseEther("1000");
      
      await token.approve(addr1.address, amount);
      expect(await token.allowance(owner.address, addr1.address)).to.equal(amount);
      
      await token.connect(addr1).transferFrom(owner.address, addr2.address, amount);
      expect(await token.balanceOf(addr2.address)).to.equal(amount);
    });

    it("Should fail transfer with insufficient balance", async function () {
      const amount = ethers.utils.parseEther("1000");
      
      await expect(
        token.connect(addr1).transfer(addr2.address, amount)
      ).to.be.reverted;
    });
  });

  describe("Ownership", function () {
    it("Should transfer ownership", async function () {
      await token.transferOwnership(addr1.address);
      expect(await token.owner()).to.equal(addr1.address);
    });

    it("Should renounce ownership", async function () {
      await token.renounceOwnership();
      expect(await token.owner()).to.equal(ethers.constants.AddressZero);
    });

    it("Should revert if non-owner tries to transfer ownership", async function () {
      await expect(
        token.connect(addr1).transferOwnership(addr2.address)
      ).to.be.reverted;
    });
  });

  describe("Edge Cases", function () {
    it("Should handle maximum supply correctly", async function () {
      const maxSupply = await token.totalSupply();
      expect(maxSupply).to.equal(INITIAL_SUPPLY);
    });

    it("Should handle multiple allocations correctly", async function () {
      const allocations = [
        { category: "presale", amount: ethers.utils.parseEther("30000000") },
        { category: "staking", amount: ethers.utils.parseEther("20000000") },
        { category: "marketing", amount: ethers.utils.parseEther("15000000") },
        { category: "team", amount: ethers.utils.parseEther("15000000") },
        { category: "liquidity", amount: ethers.utils.parseEther("10000000") },
      ];
      
      for (const alloc of allocations) {
        await token.allocate(alloc.category, addr1.address, alloc.amount);
      }
      
      const totalAllocated = allocations.reduce((sum, alloc) => sum.add(alloc.amount), ethers.BigNumber.from(0));
      expect(await token.totalAllocated()).to.equal(totalAllocated);
    });
  });
});
