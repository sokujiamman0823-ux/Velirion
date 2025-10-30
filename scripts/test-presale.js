const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

// Load deployment addresses
const deploymentPath = path.join(__dirname, "..", "deployment-sepolia.json");
const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

async function main() {
  console.log("\n🛒 Testing Presale Purchase Flow\n");

  const [buyer] = await ethers.getSigners();
  console.log(`Buyer address: ${buyer.address}\n`);

  // Configure gas from .env
  const gasPrice = process.env.GAS_PRICE ? ethers.BigNumber.from(process.env.GAS_PRICE) : undefined;
  const gasLimit = process.env.GAS_LIMIT ? parseInt(process.env.GAS_LIMIT) : undefined;
  const gasConfig = {};
  if (gasPrice) {
    gasConfig.gasPrice = gasPrice;
    console.log(`Using gas price: ${ethers.utils.formatUnits(gasPrice, "gwei")} gwei`);
  }
  if (gasLimit) {
    gasConfig.gasLimit = gasLimit;
    console.log(`Using gas limit: ${gasLimit}`);
  }
  console.log("");

  // Get contract instances
  const Presale = await ethers.getContractAt("VelirionPresaleV2", deployment.contracts.presale);
  const VLRToken = await ethers.getContractAt("VelirionToken", deployment.contracts.vlrToken);
  const USDT = await ethers.getContractAt("MockERC20", deployment.contracts.usdt);
  const USDC = await ethers.getContractAt("MockERC20", deployment.contracts.usdc);

  // Check phase status and start presale if needed (1 hour duration for tests)
  const phaseActive = await Presale.isPhaseActive();
  console.log(`Phase Active: ${phaseActive}`);
  
  // Ensure phases are initialized
  const beforePhase = await Presale.getCurrentPhaseInfo();
  if (beforePhase.pricePerToken.eq(0)) {
    console.log("\n⚠️  Phases not initialized. Initializing all phases per spec...");
    const tx = await Presale.initializePhases(gasConfig);
    await tx.wait();
    console.log("✅ Phases initialized");
  }

  // Check presale VLR balance and transfer if needed
  const presaleBalance = await VLRToken.balanceOf(deployment.contracts.presale);
  console.log(`Presale VLR balance: ${ethers.utils.formatEther(presaleBalance)} VLR`);
  
  const requiredBalance = ethers.utils.parseEther("35000000"); // 30M + 5M buffer
  if (presaleBalance.lt(requiredBalance)) {
    console.log(`\n⚠️  Presale needs ${ethers.utils.formatEther(requiredBalance)} VLR. Transferring...`);
    const buyerBalance = await VLRToken.balanceOf(buyer.address);
    const toTransfer = requiredBalance.sub(presaleBalance);
    
    if (buyerBalance.gte(toTransfer)) {
      const transferTx = await VLRToken.transfer(deployment.contracts.presale, toTransfer, gasConfig);
      await transferTx.wait();
      console.log(`✅ Transferred ${ethers.utils.formatEther(toTransfer)} VLR to presale`);
    } else {
      console.log(`❌ Insufficient VLR in buyer wallet. Has ${ethers.utils.formatEther(buyerBalance)}, needs ${ethers.utils.formatEther(toTransfer)}`);
      console.log("   Presale purchases will likely fail due to insufficient contract balance.\n");
    }
  }
  console.log("");

  // Ensure ETH/USD price is set
  const ethUsd = await Presale.ethUsdPrice();
  if (ethUsd.eq(0)) {
    console.log("\n⚠️  ETH/USD price is 0. Setting to $2000 for testing...");
    const tx = await Presale.setEthUsdPrice(ethers.utils.parseEther("2000"), gasConfig);
    await tx.wait();
    console.log("✅ ETH/USD price set");
  }
  console.log(`ETH/USD Price: $${ethers.utils.formatEther(await Presale.ethUsdPrice())}`);

  if (!phaseActive) {
    const presaleStartTime = await Presale.presaleStartTime();
    if (presaleStartTime.eq(0)) {
      console.log("\n⚠️  Presale not started. Starting phase 0 for 1 hour...");
      const tx = await Presale.startPresale(3600, gasConfig);
      await tx.wait();
      console.log("✅ Presale phase started!");
    } else {
      console.log("\n⚠️  Presale already started but phase inactive. Starting next phase...");
      const currentPhaseNum = await Presale.currentPhase();
      const nextPhase = currentPhaseNum.toNumber() + 1;
      if (nextPhase < 10) {
        const tx = await Presale.startPhase(nextPhase, 3600, gasConfig);
        await tx.wait();
        console.log(`✅ Phase ${nextPhase} started!`);
      } else {
        console.log("❌ All phases completed. Cannot start new phase.");
        return;
      }
    }
  }

  const currentPhase = await Presale.getCurrentPhaseInfo();
  console.log(`Token Price (USD): ${ethers.utils.formatEther(currentPhase.pricePerToken)} per VLR`);

  // Test 1: Purchase with ETH
  console.log("\n--- Test 1: Purchase with ETH ---");
  const ethAmount = ethers.utils.parseEther("0.01"); // 0.01 ETH
  const expectedTokens = await Presale.calculateTokenAmountForETH(ethAmount);
  
  console.log(`Purchasing with ${ethers.utils.formatEther(ethAmount)} ETH (expected ~${ethers.utils.formatEther(expectedTokens)} VLR)...`);
  
  try {
    const tx = await Presale.buyWithETH(ethers.constants.AddressZero, { value: ethAmount, ...gasConfig });
    const receipt = await tx.wait();
    console.log(`✅ Purchase successful! Tx: ${receipt.transactionHash}`);

    // Inspect vesting schedule and claim TGE (40%)
    const schedule = await Presale.getVestingSchedule(buyer.address);
    console.log(`Vesting Total: ${ethers.utils.formatEther(schedule.totalAmount)} VLR`);
    console.log(`TGE Amount: ${ethers.utils.formatEther(schedule.tgeAmount)} VLR`);

    console.log("Claiming TGE tokens...");
    const claimTx = await Presale.claimTokens(gasConfig);
    const claimReceipt = await claimTx.wait();
    console.log(`✅ Claimed TGE! Tx: ${claimReceipt.transactionHash}`);

    const balance = await VLRToken.balanceOf(buyer.address);
    console.log(`New VLR balance (after TGE claim): ${ethers.utils.formatEther(balance)} VLR`);
  } catch (error) {
    console.log(`❌ Purchase failed: ${error.message}`);
    if (error.error && error.error.data) {
      console.log(`   Revert data: ${error.error.data}`);
    }
  }

  // Test 2: Purchase with USDT
  console.log("\n--- Test 2: Purchase with USDT ---");
  const usdtAmount = ethers.utils.parseUnits("10", 6); // 10 USDT (6 decimals)
  
  console.log("Minting test USDT...");
  let tx = await USDT.mint(buyer.address, usdtAmount, gasConfig);
  await tx.wait();
  console.log(`✅ Minted ${ethers.utils.formatUnits(usdtAmount, 6)} USDT`);

  console.log("Approving USDT...");
  tx = await USDT.approve(deployment.contracts.presale, usdtAmount, gasConfig);
  await tx.wait();
  console.log("✅ USDT approved");

  console.log("Purchasing with USDT...");
  try {
    tx = await Presale.buyWithUSDT(usdtAmount, ethers.constants.AddressZero, gasConfig);
    const receipt = await tx.wait();
    console.log(`✅ Purchase successful! Tx: ${receipt.transactionHash}`);
    
    const balance = await VLRToken.balanceOf(buyer.address);
    console.log(`New VLR balance: ${ethers.utils.formatEther(balance)} VLR`);
  } catch (error) {
    console.log(`❌ Purchase failed: ${error.message}`);
    if (error.error && error.error.data) {
      console.log(`   Revert data: ${error.error.data}`);
    }
  }

  // Test 3: Purchase with USDC
  console.log("\n--- Test 3: Purchase with USDC ---");
  const usdcAmount = ethers.utils.parseUnits("10", 6); // 10 USDC (6 decimals)
  
  console.log("Minting test USDC...");
  tx = await USDC.mint(buyer.address, usdcAmount, gasConfig);
  await tx.wait();
  console.log(`✅ Minted ${ethers.utils.formatUnits(usdcAmount, 6)} USDC`);

  console.log("Approving USDC...");
  tx = await USDC.approve(deployment.contracts.presale, usdcAmount, gasConfig);
  await tx.wait();
  console.log("✅ USDC approved");

  console.log("Purchasing with USDC...");
  try {
    tx = await Presale.buyWithUSDC(usdcAmount, ethers.constants.AddressZero, gasConfig);
    const receipt = await tx.wait();
    console.log(`✅ Purchase successful! Tx: ${receipt.transactionHash}`);
    
    const balance = await VLRToken.balanceOf(buyer.address);
    console.log(`New VLR balance: ${ethers.utils.formatEther(balance)} VLR`);
  } catch (error) {
    console.log(`❌ Purchase failed: ${error.message}`);
    if (error.error && error.error.data) {
      console.log(`   Revert data: ${error.error.data}`);
    }
  }

  // Final balance check
  console.log("\n--- Final Balances ---");
  const vlrBalance = await VLRToken.balanceOf(buyer.address);
  const usdtBalance = await USDT.balanceOf(buyer.address);
  const usdcBalance = await USDC.balanceOf(buyer.address);
  
  console.log(`VLR: ${ethers.utils.formatEther(vlrBalance)} VLR`);
  console.log(`USDT: ${ethers.utils.formatUnits(usdtBalance, 6)} USDT`);
  console.log(`USDC: ${ethers.utils.formatUnits(usdcBalance, 6)} USDC`);

  console.log("\n✅ Presale tests completed!\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
