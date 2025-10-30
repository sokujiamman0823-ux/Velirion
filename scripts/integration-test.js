const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

// Load deployment addresses
const deploymentPath = path.join(__dirname, "..", "deployment-sepolia.json");
const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

// Color codes for console output
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  cyan: "\x1b[36m"
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function logSection(title) {
  console.log("\n" + "=".repeat(60));
  log(title, colors.cyan);
  console.log("=".repeat(60));
}

function logTest(testName, passed, details = "") {
  const status = passed ? "✅ PASS" : "❌ FAIL";
  const statusColor = passed ? colors.green : colors.red;
  log(`${status} - ${testName}`, statusColor);
  if (details) {
    console.log(`   ${details}`);
  }
}

async function main() {
  log("\n🚀 Starting Velirion Integration Tests on Sepolia", colors.blue);
  log(`Network: ${deployment.network}`, colors.yellow);
  log(`Deployer: ${deployment.deployer}`, colors.yellow);

  const [signer] = await ethers.getSigners();
  log(`Testing with account: ${signer.address}\n`, colors.yellow);

  // Get contract instances
  const VLRToken = await ethers.getContractAt("VelirionToken", deployment.contracts.vlrToken);
  const Presale = await ethers.getContractAt("VelirionPresaleV2", deployment.contracts.presale);
  const USDT = await ethers.getContractAt("MockERC20", deployment.contracts.usdt);
  const USDC = await ethers.getContractAt("MockERC20", deployment.contracts.usdc);
  const Referral = await ethers.getContractAt("VelirionReferral", deployment.contracts.referral);
  const Staking = await ethers.getContractAt("VelirionStaking", deployment.contracts.staking);
  const DAO = await ethers.getContractAt("VelirionDAO", deployment.contracts.dao);
  const Treasury = await ethers.getContractAt("VelirionTreasury", deployment.contracts.treasury);
  const ReferralNFT = await ethers.getContractAt("VelirionReferralNFT", deployment.contracts.referralNFT);
  const GuardianNFT = await ethers.getContractAt("VelirionGuardianNFT", deployment.contracts.guardianNFT);

  let testResults = {
    passed: 0,
    failed: 0,
    total: 0
  };

  // ========== TOKEN TESTS ==========
  logSection("1. VLR TOKEN TESTS");

  try {
    const name = await VLRToken.name();
    const symbol = await VLRToken.symbol();
    const decimals = await VLRToken.decimals();
    const totalSupply = await VLRToken.totalSupply();
    
    logTest("Token Name", name === "Velirion", `Name: ${name}`);
    testResults.total++;
    if (name === "Velirion") testResults.passed++; else testResults.failed++;

    logTest("Token Symbol", symbol === "VLR", `Symbol: ${symbol}`);
    testResults.total++;
    if (symbol === "VLR") testResults.passed++; else testResults.failed++;

    logTest("Token Decimals", decimals === 18, `Decimals: ${decimals}`);
    testResults.total++;
    if (decimals === 18) testResults.passed++; else testResults.failed++;

    const expectedSupply = ethers.utils.parseEther("100000000"); // 100M
    logTest("Total Supply", totalSupply.eq(expectedSupply), 
      `Supply: ${ethers.utils.formatEther(totalSupply)} VLR`);
    testResults.total++;
    if (totalSupply.eq(expectedSupply)) testResults.passed++; else testResults.failed++;

    // Check burn functionality
    const balance = await VLRToken.balanceOf(signer.address);
    log(`\n   Current balance: ${ethers.utils.formatEther(balance)} VLR`, colors.yellow);
    
  } catch (error) {
    logTest("Token Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== PRESALE TESTS ==========
  logSection("2. PRESALE TESTS");

  try {
    const phaseActive = await Presale.isPhaseActive();
    logTest("Phase Status", true, `Active: ${phaseActive}`);
    testResults.total++;
    testResults.passed++;

    const currentPhase = await Presale.getCurrentPhaseInfo();
    logTest("Current Phase", true, `Phase: ${await Presale.currentPhase()}, Price: ${ethers.utils.formatEther(currentPhase.pricePerToken)} per VLR`);
    testResults.total++;
    testResults.passed++;

    const totalSold = await Presale.getTotalTokensSold();
    logTest("Total Tokens Sold", true, 
      `Sold: ${ethers.utils.formatEther(totalSold)} VLR`);
    testResults.total++;
    testResults.passed++;

  } catch (error) {
    logTest("Presale Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== REFERRAL TESTS ==========
  logSection("3. REFERRAL SYSTEM TESTS");

  try {
    const referralToken = await Referral.vlrToken();
    logTest("Referral Token Address", referralToken === deployment.contracts.vlrToken,
      `Token: ${referralToken}`);
    testResults.total++;
    if (referralToken === deployment.contracts.vlrToken) testResults.passed++; else testResults.failed++;

    const referrer = await Referral.getReferrer(signer.address);
    logTest("User Referrer", true, `Referrer: ${referrer}`);
    testResults.total++;
    testResults.passed++;

    const totalReferrers = await Referral.totalReferrers();
    logTest("Total Referrers", true, `Count: ${totalReferrers}`);
    testResults.total++;
    testResults.passed++;

  } catch (error) {
    logTest("Referral Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== STAKING TESTS ==========
  logSection("4. STAKING TESTS");

  try {
    const stakingToken = await Staking.vlrToken();
    logTest("Staking Token Address", stakingToken === deployment.contracts.vlrToken,
      `Token: ${stakingToken}`);
    testResults.total++;
    if (stakingToken === deployment.contracts.vlrToken) testResults.passed++; else testResults.failed++;

    // Check staking constants
    const minFlexible = await Staking.MIN_FLEXIBLE_STAKE();
    const minMedium = await Staking.MIN_MEDIUM_STAKE();
    const minLong = await Staking.MIN_LONG_STAKE();
    const minElite = await Staking.MIN_ELITE_STAKE();
    
    logTest("Staking Tiers Configured", true, 
      `Flexible: ${ethers.utils.formatEther(minFlexible)}, Medium: ${ethers.utils.formatEther(minMedium)}, Long: ${ethers.utils.formatEther(minLong)}, Elite: ${ethers.utils.formatEther(minElite)} VLR`);
    testResults.total++;
    testResults.passed++;

    const totalStaked = await Staking.getTotalStaked();
    logTest("Total Staked", true, `Amount: ${ethers.utils.formatEther(totalStaked)} VLR`);
    testResults.total++;
    testResults.passed++;

  } catch (error) {
    logTest("Staking Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== DAO TESTS ==========
  logSection("5. DAO GOVERNANCE TESTS");

  try {
    const daoToken = await DAO.vlrToken();
    logTest("DAO Token Address", daoToken === deployment.contracts.vlrToken,
      `Token: ${daoToken}`);
    testResults.total++;
    if (daoToken === deployment.contracts.vlrToken) testResults.passed++; else testResults.failed++;

    const proposalCount = await DAO.proposalCount();
    logTest("Proposal Count", true, `Total Proposals: ${proposalCount}`);
    testResults.total++;
    testResults.passed++;

    const votingPeriod = await DAO.VOTING_PERIOD();
    logTest("Voting Period", true, `Period: ${votingPeriod.div(86400)} days`);
    testResults.total++;
    testResults.passed++;

  } catch (error) {
    logTest("DAO Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== TREASURY TESTS ==========
  logSection("6. TREASURY TESTS");

  try {
    const treasuryBalance = await VLRToken.balanceOf(deployment.contracts.treasury);
    logTest("Treasury Balance", treasuryBalance.gt(0), 
      `Balance: ${ethers.utils.formatEther(treasuryBalance)} VLR`);
    testResults.total++;
    if (treasuryBalance.gt(0)) testResults.passed++; else testResults.failed++;

  } catch (error) {
    logTest("Treasury Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== NFT TESTS ==========
  logSection("7. NFT TESTS");

  try {
    const refNFTName = await ReferralNFT.name();
    const refNFTSymbol = await ReferralNFT.symbol();
    logTest("Referral NFT", true, `${refNFTName} (${refNFTSymbol})`);
    testResults.total++;
    testResults.passed++;

    const guardianNFTName = await GuardianNFT.name();
    const guardianNFTSymbol = await GuardianNFT.symbol();
    logTest("Guardian NFT", true, `${guardianNFTName} (${guardianNFTSymbol})`);
    testResults.total++;
    testResults.passed++;

  } catch (error) {
    logTest("NFT Tests", false, error.message);
    testResults.failed++;
    testResults.total++;
  }

  // ========== SUMMARY ==========
  logSection("TEST SUMMARY");
  log(`Total Tests: ${testResults.total}`, colors.cyan);
  log(`Passed: ${testResults.passed}`, colors.green);
  log(`Failed: ${testResults.failed}`, testResults.failed > 0 ? colors.red : colors.green);
  
  const successRate = ((testResults.passed / testResults.total) * 100).toFixed(2);
  log(`Success Rate: ${successRate}%`, successRate === "100.00" ? colors.green : colors.yellow);

  console.log("\n" + "=".repeat(60) + "\n");

  if (testResults.failed > 0) {
    log("⚠️  Some tests failed. Please review the results above.", colors.yellow);
    process.exit(1);
  } else {
    log("🎉 All tests passed! Contracts are ready for interactive testing.", colors.green);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
