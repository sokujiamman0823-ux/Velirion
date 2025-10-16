# Velirion Smart Contract Templates

This document contains detailed contract templates for the Velirion project.

---

## VelirionPresale.sol - Complete Template

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title VelirionPresale
 * @dev 10-phase presale with antibot protection and vesting
 */
contract VelirionPresale is Ownable, ReentrancyGuard, Pausable {
    
    // ============ State Variables ============
    
    IERC20 public immutable vlrToken;
    IERC20 public immutable usdt;
    IERC20 public immutable usdc;
    
    uint256 public constant TOTAL_PHASES = 10;
    uint256 public constant TOKENS_PER_PHASE = 3_000_000 * 10**18;
    uint256 public constant INITIAL_DURATION = 90 days;
    uint256 public constant EXTENSION_DURATION = 30 days;
    
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 public currentPhase = 1;
    uint256 public tgeTime;
    bool public presaleExtended;
    bool public presaleFinalized;
    
    // Antibot & Whale Limits
    uint256 public maxPurchasePerTx = 50_000 * 10**18;
    uint256 public maxPurchasePerWallet = 500_000 * 10**18;
    uint256 public minDelayBetweenPurchases = 5 minutes;
    
    // Phase pricing (in USD cents: 50 = $0.005)
    uint256[11] public phasePrice = [0, 50, 60, 70, 80, 90, 100, 110, 120, 130, 150];
    
    // User data
    struct Purchase {
        uint256 totalPurchased;
        uint256 vestedAmount;
        uint256 claimedAmount;
        uint256 lastPurchaseTime;
        uint256 lastClaimTime;
    }
    
    mapping(address => Purchase) public purchases;
    mapping(uint256 => uint256) public phaseSold;
    mapping(address => bool) public whitelist;
    
    bool public whitelistEnabled;
    
    // ============ Events ============
    
    event PresaleStarted(uint256 startTime, uint256 endTime);
    event PresaleExtended(uint256 newEndTime);
    event PresaleFinalized(uint256 unsoldBurned);
    event TokensPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 phase,
        address paymentToken,
        uint256 paymentAmount
    );
    event TokensClaimed(address indexed user, uint256 amount);
    event TGEStarted(uint256 timestamp);
    
    // ============ Constructor ============
    
    constructor(
        address _vlrToken,
        address _usdt,
        address _usdc
    ) {
        require(_vlrToken != address(0), "Invalid VLR");
        require(_usdt != address(0), "Invalid USDT");
        require(_usdc != address(0), "Invalid USDC");
        
        vlrToken = IERC20(_vlrToken);
        usdt = IERC20(_usdt);
        usdc = IERC20(_usdc);
    }
    
    // ============ Presale Control ============
    
    function startPresale() external onlyOwner {
        require(presaleStartTime == 0, "Already started");
        presaleStartTime = block.timestamp;
        presaleEndTime = block.timestamp + INITIAL_DURATION;
        emit PresaleStarted(presaleStartTime, presaleEndTime);
    }
    
    function extendPresale() external onlyOwner {
        require(!presaleExtended, "Already extended");
        require(block.timestamp < presaleEndTime, "Already ended");
        presaleExtended = true;
        presaleEndTime += EXTENSION_DURATION;
        emit PresaleExtended(presaleEndTime);
    }
    
    function finalizePresale() external onlyOwner {
        require(block.timestamp >= presaleEndTime, "Not ended yet");
        require(!presaleFinalized, "Already finalized");
        
        presaleFinalized = true;
        
        // Calculate unsold tokens and burn
        uint256 totalSold = 0;
        for (uint256 i = 1; i <= TOTAL_PHASES; i++) {
            totalSold += phaseSold[i];
        }
        uint256 unsold = (TOTAL_PHASES * TOKENS_PER_PHASE) - totalSold;
        
        if (unsold > 0) {
            // Burn or return to owner for burning
            vlrToken.transfer(owner(), unsold);
        }
        
        emit PresaleFinalized(unsold);
    }
    
    function startTGE() external onlyOwner {
        require(presaleFinalized, "Presale not finalized");
        require(tgeTime == 0, "TGE already started");
        tgeTime = block.timestamp;
        emit TGEStarted(tgeTime);
    }
    
    // ============ Purchase Functions ============
    
    function buyWithETH() external payable nonReentrant whenNotPaused {
        require(isPresaleActive(), "Presale not active");
        require(msg.value > 0, "Invalid amount");
        
        // Get ETH price from oracle (simplified - use Chainlink in production)
        uint256 ethPriceUSD = 2000; // $2000 per ETH (hardcoded for example)
        uint256 usdAmount = (msg.value * ethPriceUSD * 100) / 1e18; // Convert to cents
        uint256 tokenAmount = calculateTokenAmount(usdAmount);
        
        _processPurchase(msg.sender, tokenAmount);
        
        emit TokensPurchased(msg.sender, tokenAmount, currentPhase, address(0), msg.value);
    }
    
    function buyWithUSDT(uint256 usdtAmount) external nonReentrant whenNotPaused {
        require(isPresaleActive(), "Presale not active");
        require(usdtAmount > 0, "Invalid amount");
        
        require(usdt.transferFrom(msg.sender, address(this), usdtAmount), "Transfer failed");
        
        // USDT has 6 decimals, convert to cents
        uint256 usdCents = (usdtAmount * 100) / 1e6;
        uint256 tokenAmount = calculateTokenAmount(usdCents);
        
        _processPurchase(msg.sender, tokenAmount);
        
        emit TokensPurchased(msg.sender, tokenAmount, currentPhase, address(usdt), usdtAmount);
    }
    
    function buyWithUSDC(uint256 usdcAmount) external nonReentrant whenNotPaused {
        require(isPresaleActive(), "Presale not active");
        require(usdcAmount > 0, "Invalid amount");
        
        require(usdc.transferFrom(msg.sender, address(this), usdcAmount), "Transfer failed");
        
        // USDC has 6 decimals, convert to cents
        uint256 usdCents = (usdcAmount * 100) / 1e6;
        uint256 tokenAmount = calculateTokenAmount(usdCents);
        
        _processPurchase(msg.sender, tokenAmount);
        
        emit TokensPurchased(msg.sender, tokenAmount, currentPhase, address(usdc), usdcAmount);
    }
    
    // ============ Internal Functions ============
    
    function _processPurchase(address buyer, uint256 tokenAmount) internal {
        Purchase storage purchase = purchases[buyer];
        
        // Whitelist check
        if (whitelistEnabled) {
            require(whitelist[buyer], "Not whitelisted");
        }
        
        // Antibot checks
        require(tokenAmount <= maxPurchasePerTx, "Exceeds tx limit");
        require(
            purchase.totalPurchased + tokenAmount <= maxPurchasePerWallet,
            "Exceeds wallet limit"
        );
        require(
            block.timestamp >= purchase.lastPurchaseTime + minDelayBetweenPurchases,
            "Too soon"
        );
        
        // Phase capacity check
        require(
            phaseSold[currentPhase] + tokenAmount <= TOKENS_PER_PHASE,
            "Phase sold out"
        );
        
        // Update state
        purchase.totalPurchased += tokenAmount;
        purchase.vestedAmount += tokenAmount;
        purchase.lastPurchaseTime = block.timestamp;
        phaseSold[currentPhase] += tokenAmount;
        
        // Advance phase if needed
        if (phaseSold[currentPhase] >= TOKENS_PER_PHASE && currentPhase < TOTAL_PHASES) {
            currentPhase++;
        }
    }
    
    function calculateTokenAmount(uint256 usdCents) public view returns (uint256) {
        // usdCents is in cents (100 = $1.00)
        // phasePrice is in 0.001 dollar units (50 = $0.050)
        // Return tokens with 18 decimals
        return (usdCents * 10**20) / (phasePrice[currentPhase] * 10);
    }
    
    // ============ Vesting & Claims ============
    
    function claimTokens() external nonReentrant {
        require(tgeTime > 0, "TGE not started");
        
        Purchase storage purchase = purchases[msg.sender];
        require(purchase.vestedAmount > 0, "No tokens");
        
        uint256 claimable = calculateClaimable(msg.sender);
        require(claimable > 0, "Nothing to claim");
        
        purchase.claimedAmount += claimable;
        purchase.lastClaimTime = block.timestamp;
        
        require(vlrToken.transfer(msg.sender, claimable), "Transfer failed");
        
        emit TokensClaimed(msg.sender, claimable);
    }
    
    function calculateClaimable(address user) public view returns (uint256) {
        if (tgeTime == 0) return 0;
        
        Purchase memory purchase = purchases[user];
        if (purchase.vestedAmount == 0) return 0;
        
        uint256 totalVested = purchase.vestedAmount;
        uint256 alreadyClaimed = purchase.claimedAmount;
        
        // 40% at TGE
        uint256 initialRelease = (totalVested * 40) / 100;
        
        // 30% per month for 2 months
        uint256 monthsPassed = (block.timestamp - tgeTime) / 30 days;
        if (monthsPassed > 2) monthsPassed = 2;
        
        uint256 monthlyRelease = (totalVested * 30 * monthsPassed) / 100;
        
        uint256 totalClaimable = initialRelease + monthlyRelease;
        
        return totalClaimable > alreadyClaimed ? totalClaimable - alreadyClaimed : 0;
    }
    
    // ============ View Functions ============
    
    function isPresaleActive() public view returns (bool) {
        return presaleStartTime > 0 &&
               block.timestamp >= presaleStartTime &&
               block.timestamp < presaleEndTime &&
               !presaleFinalized;
    }
    
    function getUserPurchase(address user) external view returns (
        uint256 totalPurchased,
        uint256 vestedAmount,
        uint256 claimedAmount,
        uint256 claimable
    ) {
        Purchase memory p = purchases[user];
        return (
            p.totalPurchased,
            p.vestedAmount,
            p.claimedAmount,
            calculateClaimable(user)
        );
    }
    
    function getCurrentPhaseInfo() external view returns (
        uint256 phase,
        uint256 price,
        uint256 sold,
        uint256 remaining
    ) {
        return (
            currentPhase,
            phasePrice[currentPhase],
            phaseSold[currentPhase],
            TOKENS_PER_PHASE - phaseSold[currentPhase]
        );
    }
    
    // ============ Admin Functions ============
    
    function setLimits(
        uint256 _maxPerTx,
        uint256 _maxPerWallet,
        uint256 _minDelay
    ) external onlyOwner {
        maxPurchasePerTx = _maxPerTx;
        maxPurchasePerWallet = _maxPerWallet;
        minDelayBetweenPurchases = _minDelay;
    }
    
    function setWhitelistEnabled(bool enabled) external onlyOwner {
        whitelistEnabled = enabled;
    }
    
    function addToWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }
    
    function removeFromWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist[users[i]] = false;
        }
    }
    
    function withdrawFunds() external onlyOwner {
        require(presaleFinalized, "Not finalized");
        
        // Withdraw ETH
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            payable(owner()).transfer(ethBalance);
        }
        
        // Withdraw USDT
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(owner(), usdtBalance);
        }
        
        // Withdraw USDC
        uint256 usdcBalance = usdc.balanceOf(address(this));
        if (usdcBalance > 0) {
            usdc.transfer(owner(), usdcBalance);
        }
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // Receive ETH
    receive() external payable {}
}
```

---

## VelirionReferral.sol - Complete Template

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title VelirionReferral
 * @dev 4-level referral system with purchase and staking bonuses
 */
contract VelirionReferral is Ownable, ReentrancyGuard {
    
    IERC20 public immutable vlrToken;
    
    // ============ Structs ============
    
    struct Referrer {
        uint256 level;
        uint256 directReferrals;
        uint256 totalPurchaseBonus;
        uint256 totalStakingBonus;
        uint256 claimedRewards;
        bool nftIssued;
    }
    
    // ============ State Variables ============
    
    mapping(address => address) public referredBy;
    mapping(address => Referrer) public referrers;
    mapping(address => address[]) public referralTree;
    mapping(address => uint256) public pendingRewards;
    
    // Level thresholds
    uint256[5] public levelThresholds = [0, 10, 25, 50, type(uint256).max];
    
    // Bonus percentages (multiplied by 100: 500 = 5%)
    uint256[5] public purchaseBonusPercent = [0, 500, 700, 1000, 1200]; // 5%, 7%, 10%, 12%
    uint256[5] public stakingBonusPercent = [0, 200, 300, 400, 500]; // 2%, 3%, 4%, 5%
    
    address public presaleContract;
    address public stakingContract;
    
    // ============ Events ============
    
    event ReferralRegistered(address indexed user, address indexed referrer);
    event LevelUpgraded(address indexed referrer, uint256 newLevel);
    event PurchaseBonusDistributed(address indexed referrer, address indexed buyer, uint256 amount);
    event StakingBonusDistributed(address indexed referrer, address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event NFTIssued(address indexed user, uint256 level);
    
    // ============ Constructor ============
    
    constructor(address _vlrToken) {
        require(_vlrToken != address(0), "Invalid token");
        vlrToken = IERC20(_vlrToken);
    }
    
    // ============ Referral Registration ============
    
    function register(address referrer) external {
        require(referredBy[msg.sender] == address(0), "Already registered");
        require(referrer != address(0), "Invalid referrer");
        require(referrer != msg.sender, "Cannot refer yourself");
        
        referredBy[msg.sender] = referrer;
        referralTree[referrer].push(msg.sender);
        
        Referrer storage ref = referrers[referrer];
        ref.directReferrals++;
        
        // Check for level upgrade
        _checkAndUpgradeLevel(referrer);
        
        emit ReferralRegistered(msg.sender, referrer);
    }
    
    // ============ Bonus Distribution ============
    
    function distributePurchaseBonus(address buyer, uint256 purchaseAmount) external {
        require(msg.sender == presaleContract, "Only presale");
        
        address referrer = referredBy[buyer];
        if (referrer == address(0)) return;
        
        Referrer storage ref = referrers[referrer];
        uint256 bonusPercent = purchaseBonusPercent[ref.level];
        uint256 bonus = (purchaseAmount * bonusPercent) / 10000;
        
        if (bonus > 0) {
            ref.totalPurchaseBonus += bonus;
            pendingRewards[referrer] += bonus;
            emit PurchaseBonusDistributed(referrer, buyer, bonus);
        }
    }
    
    function distributeStakingBonus(address staker, uint256 rewardAmount) external {
        require(msg.sender == stakingContract, "Only staking");
        
        address referrer = referredBy[staker];
        if (referrer == address(0)) return;
        
        Referrer storage ref = referrers[referrer];
        uint256 bonusPercent = stakingBonusPercent[ref.level];
        uint256 bonus = (rewardAmount * bonusPercent) / 10000;
        
        if (bonus > 0) {
            ref.totalStakingBonus += bonus;
            pendingRewards[referrer] += bonus;
            emit StakingBonusDistributed(referrer, staker, bonus);
        }
    }
    
    // ============ Claims ============
    
    function claimRewards() external nonReentrant {
        uint256 rewards = pendingRewards[msg.sender];
        require(rewards > 0, "No rewards");
        
        pendingRewards[msg.sender] = 0;
        referrers[msg.sender].claimedRewards += rewards;
        
        require(vlrToken.transfer(msg.sender, rewards), "Transfer failed");
        
        emit RewardsClaimed(msg.sender, rewards);
    }
    
    // ============ Internal Functions ============
    
    function _checkAndUpgradeLevel(address user) internal {
        Referrer storage ref = referrers[user];
        uint256 currentLevel = ref.level;
        uint256 newLevel = currentLevel;
        
        // Determine new level based on referrals
        if (ref.directReferrals >= 50) {
            newLevel = 4;
        } else if (ref.directReferrals >= 25) {
            newLevel = 3;
        } else if (ref.directReferrals >= 10) {
            newLevel = 2;
        } else {
            newLevel = 1;
        }
        
        if (newLevel > currentLevel) {
            ref.level = newLevel;
            emit LevelUpgraded(user, newLevel);
            
            // Issue NFT for levels 2, 3, 4
            if (newLevel >= 2 && !ref.nftIssued) {
                ref.nftIssued = true;
                // Call NFT contract to mint (implement separately)
                emit NFTIssued(user, newLevel);
            }
        }
    }
    
    // ============ View Functions ============
    
    function getReferralStats(address user) external view returns (
        uint256 level,
        uint256 directReferrals,
        uint256 totalPurchaseBonus,
        uint256 totalStakingBonus,
        uint256 pending,
        uint256 claimed
    ) {
        Referrer memory ref = referrers[user];
        return (
            ref.level,
            ref.directReferrals,
            ref.totalPurchaseBonus,
            ref.totalStakingBonus,
            pendingRewards[user],
            ref.claimedRewards
        );
    }
    
    function getReferralTree(address user) external view returns (address[] memory) {
        return referralTree[user];
    }
    
    // ============ Admin Functions ============
    
    function setPresaleContract(address _presale) external onlyOwner {
        require(_presale != address(0), "Invalid address");
        presaleContract = _presale;
    }
    
    function setStakingContract(address _staking) external onlyOwner {
        require(_staking != address(0), "Invalid address");
        stakingContract = _staking;
    }
    
    function updateBonusPercents(
        uint256[5] calldata _purchaseBonus,
        uint256[5] calldata _stakingBonus
    ) external onlyOwner {
        purchaseBonusPercent = _purchaseBonus;
        stakingBonusPercent = _stakingBonus;
    }
}
```

---

## Testing Template

```typescript
// test/02_Presale.test.ts
import { expect } from "chai";
import { ethers } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("VelirionPresale", function () {
  let vlrToken, usdt, usdc, presale;
  let owner, user1, user2;
  
  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    
    // Deploy mock tokens
    const Token = await ethers.getContractFactory("VelirionToken");
    vlrToken = await Token.deploy();
    
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    usdt = await MockERC20.deploy("USDT", "USDT", 6);
    usdc = await MockERC20.deploy("USDC", "USDC", 6);
    
    // Deploy presale
    const Presale = await ethers.getContractFactory("VelirionPresale");
    presale = await Presale.deploy(
      await vlrToken.getAddress(),
      await usdt.getAddress(),
      await usdc.getAddress()
    );
    
    // Allocate tokens to presale
    await vlrToken.allocate(
      "presale",
      await presale.getAddress(),
      ethers.parseEther("30000000")
    );
  });
  
  describe("Presale Lifecycle", function () {
    it("Should start presale", async function () {
      await presale.startPresale();
      expect(await presale.presaleStartTime()).to.be.gt(0);
    });
    
    it("Should allow ETH purchases", async function () {
      await presale.startPresale();
      
      await presale.connect(user1).buyWithETH({ value: ethers.parseEther("1") });
      
      const purchase = await presale.getUserPurchase(user1.address);
      expect(purchase.totalPurchased).to.be.gt(0);
    });
    
    it("Should enforce transaction limits", async function () {
      await presale.startPresale();
      
      // Try to buy more than max per tx
      const largeAmount = ethers.parseEther("100"); // Assuming this exceeds limit
      await expect(
        presale.connect(user1).buyWithETH({ value: largeAmount })
      ).to.be.revertedWith("Exceeds tx limit");
    });
    
    it("Should advance phases correctly", async function () {
      await presale.startPresale();
      
      // Buy enough to fill phase 1
      // Implementation depends on pricing
    });
  });
  
  describe("Vesting", function () {
    it("Should calculate claimable correctly", async function () {
      await presale.startPresale();
      await presale.connect(user1).buyWithETH({ value: ethers.parseEther("1") });
      
      // Start TGE
      await time.increase(91 * 24 * 60 * 60); // 91 days
      await presale.finalizePresale();
      await presale.startTGE();
      
      const claimable = await presale.calculateClaimable(user1.address);
      expect(claimable).to.be.gt(0);
    });
    
    it("Should allow claims after TGE", async function () {
      // Setup...
      await presale.connect(user1).buyWithETH({ value: ethers.parseEther("1") });
      
      // Fast forward and start TGE
      await time.increase(91 * 24 * 60 * 60);
      await presale.finalizePresale();
      await presale.startTGE();
      
      await presale.connect(user1).claimTokens();
      
      const purchase = await presale.getUserPurchase(user1.address);
      expect(purchase.claimedAmount).to.be.gt(0);
    });
  });
});
```

---

## Deployment Script Template

```typescript
// scripts/02_deploy_presale.ts
import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying VelirionPresale with account:", deployer.address);
  console.log("Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)));
  
  // Get addresses from .env
  const VLR_TOKEN = process.env.VLR_TOKEN_ADDRESS;
  const USDT = process.env.USDT_ADDRESS;
  const USDC = process.env.USDC_ADDRESS;
  
  if (!VLR_TOKEN || !USDT || !USDC) {
    throw new Error("Missing token addresses in .env");
  }
  
  // Deploy Presale
  const Presale = await ethers.getContractFactory("VelirionPresale");
  const presale = await Presale.deploy(VLR_TOKEN, USDT, USDC);
  
  await presale.waitForDeployment();
  const presaleAddress = await presale.getAddress();
  
  console.log("✅ VelirionPresale deployed to:", presaleAddress);
  
  // Allocate tokens from VLR contract
  console.log("\n📦 Allocating tokens to presale contract...");
  const vlrToken = await ethers.getContractAt("VelirionToken", VLR_TOKEN);
  const allocationTx = await vlrToken.allocate(
    "presale",
    presaleAddress,
    ethers.parseEther("30000000")
  );
  await allocationTx.wait();
  console.log("✅ Tokens allocated");
  
  // Verify balance
  const presaleBalance = await vlrToken.balanceOf(presaleAddress);
  console.log("Presale contract balance:", ethers.formatEther(presaleBalance), "VLR");
  
  console.log("\n📋 Update .env with:");
  console.log("PRESALE_CONTRACT=", presaleAddress);
  
  console.log("\n🔍 Verify contract with:");
  console.log(`npx hardhat verify --network ${network.name} ${presaleAddress} ${VLR_TOKEN} ${USDT} ${USDC}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```
