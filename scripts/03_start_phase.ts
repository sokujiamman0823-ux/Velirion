import { ethers } from "hardhat";

async function main() {
  console.log(" Starting Presale Phase...\n");
  
  const [deployer] = await ethers.getSigners();
  console.log("Using account:", deployer.address);
  
  // Get presale address
  const PRESALE_ADDRESS = process.env.PRESALE_CONTRACT;
  if (!PRESALE_ADDRESS) {
    throw new Error("PRESALE_CONTRACT must be set in .env file");
  }
  
  const presale = await ethers.getContractAt("VelirionPresale", PRESALE_ADDRESS);
  
  // Get current phase
  const currentPhase = await presale.currentPhase();
  console.log("Current Phase:", currentPhase.toString());
  
  // Phase duration (7 days)
  const PHASE_DURATION = 7 * 24 * 60 * 60; // 7 days in seconds
  
  // Start the phase
  console.log(`\nStarting Phase ${currentPhase}...`);
  const tx = await presale.startPhase(currentPhase, PHASE_DURATION);
  await tx.wait();
  console.log("✅ Phase started successfully!");
  
  // Get phase info
  const phaseInfo = await presale.getPhaseInfo(currentPhase);
  const isActive = await presale.isPhaseActive();
  
  console.log("\nPhase Information:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Phase ID:", currentPhase.toString());
  console.log("Price per Token:", ethers.utils.formatEther(phaseInfo.pricePerToken), "USD");
  console.log("Max Tokens:", ethers.utils.formatEther(phaseInfo.maxTokens), "VLR");
  console.log("Sold Tokens:", ethers.utils.formatEther(phaseInfo.soldTokens), "VLR");
  console.log("Min Purchase:", ethers.utils.formatEther(phaseInfo.minPurchase), "USD");
  console.log("Max Purchase:", ethers.utils.formatEther(phaseInfo.maxPurchase), "USD");
  console.log("Start Time:", new Date(phaseInfo.startTime.toNumber() * 1000).toLocaleString());
  console.log("End Time:", new Date(phaseInfo.endTime.toNumber() * 1000).toLocaleString());
  console.log("Is Active:", isActive);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
  
  console.log("✅ Phase is now active and ready for purchases!");
  console.log("\n Users can now:");
  console.log("- Buy with ETH: presale.buyWithETH(referrer, {value: amount})");
  console.log("- Buy with USDT: presale.buyWithUSDT(amount, referrer)");
  console.log("- Buy with USDC: presale.buyWithUSDC(amount, referrer)");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
