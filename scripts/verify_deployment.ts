import hre from "hardhat";
import * as fs from "fs";
import * as path from "path";

/**
 * Verification script for deployed VelirionToken
 * Reads deployment info and verifies contract on Etherscan
 */
async function main() {
  console.log("🔍 Verifying VelirionToken deployment...\n");

  // Check if deployment file exists
  const deploymentFile = path.join(__dirname, "..", "deployment-token.json");
  
  if (!fs.existsSync(deploymentFile)) {
    console.error("❌ deployment-token.json not found!");
    console.error("Please deploy the contract first using:");
    console.error("npx hardhat run scripts/01_deploy_token.ts --network sepolia\n");
    process.exit(1);
  }

  // Read deployment info
  const deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, "utf-8"));
  const tokenAddress = deploymentInfo.tokenAddress;
  const network = deploymentInfo.network;

  console.log("📋 Deployment Information:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Network:", network);
  console.log("Token Address:", tokenAddress);
  console.log("Deployer:", deploymentInfo.deployer);
  console.log("Timestamp:", deploymentInfo.timestamp);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Verify on Etherscan
  console.log("🔐 Verifying contract on Etherscan...");
  console.log("This may take a few moments...\n");

  try {
    await hre.run("verify:verify", {
      address: tokenAddress,
      constructorArguments: [],
    });

    console.log("✅ Contract verified successfully!");
    console.log(`View on Etherscan: https://${network === 'sepolia' ? 'sepolia.' : ''}etherscan.io/address/${tokenAddress}\n`);

    // Update deployment file with verification status
    deploymentInfo.verified = true;
    deploymentInfo.verifiedAt = new Date().toISOString();
    fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));

    console.log(" Next Steps:");
    console.log("1. Update .env file:");
    console.log(`   VLR_TOKEN_ADDRESS=${tokenAddress}`);
    console.log("\n2. Update PROJECT_TRACKER.md with deployment info");
    console.log("\n3. Test contract interaction on testnet");
    console.log(`   npx hardhat console --network ${network}`);

  } catch (error: any) {
    if (error.message.includes("Already Verified")) {
      console.log("ℹ️  Contract is already verified!");
      console.log(`View on Etherscan: https://${network === 'sepolia' ? 'sepolia.' : ''}etherscan.io/address/${tokenAddress}\n`);
    } else {
      console.error("❌ Verification failed:");
      console.error(error.message);
      process.exit(1);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
