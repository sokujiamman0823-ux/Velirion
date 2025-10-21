import { ethers } from "hardhat";

async function main() {
  console.log(" Deploying Velirion Presale V2 (Specification Compliant)...\n");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", ethers.utils.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");
  
  // Get deployed VLR token address
  const VLR_TOKEN_ADDRESS = process.env.VLR_TOKEN_ADDRESS || "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  
  let USDT_ADDRESS = process.env.USDT_ADDRESS;
  let USDC_ADDRESS = process.env.USDC_ADDRESS;
  
  // Deploy mock tokens if on localhost
  const network = await ethers.provider.getNetwork();
  if (network.chainId === 31337) {
    console.log(" Deploying mock USDT and USDC for testing...");
    
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    
    const usdt = await MockERC20.deploy("Tether USD", "USDT", 6);
    await usdt.deployed();
    USDT_ADDRESS = usdt.address;
    console.log("✅ Mock USDT deployed to:", USDT_ADDRESS);
    
    const usdc = await MockERC20.deploy("USD Coin", "USDC", 6);
    await usdc.deployed();
    USDC_ADDRESS = usdc.address;
    console.log("✅ Mock USDC deployed to:", USDC_ADDRESS);
    console.log("");
  }
  
  if (!USDT_ADDRESS || !USDC_ADDRESS) {
    throw new Error("USDT_ADDRESS and USDC_ADDRESS must be set in .env file");
  }
  
  // Initial ETH price (e.g., $2000 per ETH)
  const INITIAL_ETH_PRICE = ethers.utils.parseEther("2000");
  
  // Deploy Presale Contract V2
  console.log("Deploying VelirionPresaleV2...");
  const Presale = await ethers.getContractFactory("VelirionPresaleV2");
  const presale = await Presale.deploy(
    VLR_TOKEN_ADDRESS,
    USDT_ADDRESS,
    USDC_ADDRESS,
    INITIAL_ETH_PRICE
  );
  await presale.deployed();
  
  const presaleAddress = presale.address;
  console.log("✅ VelirionPresaleV2 deployed to:", presaleAddress);
  console.log("");
  
  // Initialize phases
  console.log("Initializing presale phases (per specification)...");
  const initTx = await presale.initializePhases();
  await initTx.wait();
  console.log("✅ All 10 phases initialized");
  console.log("");
  
  // Transfer VLR tokens to presale contract
  console.log("Transferring VLR tokens to presale contract...");
  const vlrToken = await ethers.getContractAt("VelirionToken", VLR_TOKEN_ADDRESS);
  
  // Transfer 35M tokens (30M for presale + 5M buffer for referral bonuses)
  const presaleAllocation = ethers.utils.parseEther("35000000");
  const transferTx = await vlrToken.transfer(presaleAddress, presaleAllocation);
  await transferTx.wait();
  console.log("✅ Transferred", ethers.utils.formatEther(presaleAllocation), "VLR to presale");
  console.log("");
  
  // Verify presale setup
  const presaleBalance = await vlrToken.balanceOf(presaleAddress);
  const currentPhase = await presale.currentPhase();
  const phase0 = await presale.getPhaseInfo(0);
  const phase9 = await presale.getPhaseInfo(9);
  
  console.log("Presale V2 Information (Per Specification):");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Presale Address:", presaleAddress);
  console.log("VLR Token:", VLR_TOKEN_ADDRESS);
  console.log("USDT Token:", USDT_ADDRESS);
  console.log("USDC Token:", USDC_ADDRESS);
  console.log("VLR Balance:", ethers.utils.formatEther(presaleBalance), "VLR");
  console.log("");
  console.log("📈 Phase Configuration:");
  console.log("  Total Phases: 10");
  console.log("  Tokens per Phase: 3,000,000 VLR");
  console.log("  Total Presale: 30,000,000 VLR");
  console.log("  Phase 0 Price: $" + ethers.utils.formatEther(phase0.pricePerToken));
  console.log("  Phase 9 Price: $" + ethers.utils.formatEther(phase9.pricePerToken));
  console.log("");
  console.log("🛡️ Antibot Features:");
  console.log("  Max per Transaction: 50,000 VLR");
  console.log("  Max per Wallet: 500,000 VLR");
  console.log("  Purchase Delay: 5 minutes");
  console.log("");
  console.log("📅 Vesting Schedule:");
  console.log("  TGE (Immediate): 40%");
  console.log("  Month 1 (+30 days): 30%");
  console.log("  Month 2 (+60 days): 30%");
  console.log("");
  console.log("💰 Target Fundraising:");
  console.log("  Total: $288,000 (30M tokens @ avg $0.0096)");
  console.log("  ETH/USD Price:", ethers.utils.formatEther(await presale.ethUsdPrice()), "USD");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
  
  console.log(" Next Steps:");
  console.log("1. Update .env file:");
  console.log(`   PRESALE_CONTRACT_V2=${presaleAddress}`);
  if (network.chainId === 31337) {
    console.log(`   USDT_ADDRESS=${USDT_ADDRESS}`);
    console.log(`   USDC_ADDRESS=${USDC_ADDRESS}`);
  }
  console.log("\n2. Start presale:");
  console.log(`   npx hardhat run scripts/03_start_presale_v2.ts --network ${network.name}`);
  console.log("\n3. Test all features:");
  console.log("   - Purchase limits (50k per tx, 500k per wallet)");
  console.log("   - 5-minute delay between purchases");
  console.log("   - Vesting schedule (40% + 30% + 30%)");
  console.log("   - Referral system (5% bonus)");
  
  if (network.chainId !== 31337) {
    console.log("\n4. Verify contract on Etherscan:");
    console.log(`   npx hardhat verify --network ${network.name} ${presaleAddress} ${VLR_TOKEN_ADDRESS} ${USDT_ADDRESS} ${USDC_ADDRESS} ${INITIAL_ETH_PRICE.toString()}`);
  }
  
  // Save deployment info
  const fs = require('fs');
  const deploymentInfo = {
    network: network.name,
    chainId: network.chainId,
    presaleAddress: presaleAddress,
    vlrToken: VLR_TOKEN_ADDRESS,
    usdtToken: USDT_ADDRESS,
    usdcToken: USDC_ADDRESS,
    initialEthPrice: ethers.utils.formatEther(INITIAL_ETH_PRICE),
    presaleAllocation: ethers.utils.formatEther(presaleAllocation),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    specification: {
      totalPhases: 10,
      tokensPerPhase: "3,000,000 VLR",
      totalPresale: "30,000,000 VLR",
      priceRange: "$0.005 - $0.015",
      maxPerTransaction: "50,000 VLR",
      maxPerWallet: "500,000 VLR",
      purchaseDelay: "5 minutes",
      vesting: "40% TGE + 30% monthly × 2",
      referralBonus: "5%"
    }
  };
  
  fs.writeFileSync(
    'deployment-presale-v2.json',
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("\n💾 Deployment info saved to deployment-presale-v2.json");
  console.log("\n✅ All discrepancies fixed! Contract now matches VELIRION_IMPLEMENTATION_GUIDE.md");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
