import { ethers } from "hardhat";

async function main() {
  console.log(" Deploying Velirion Token...\n");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", ethers.utils.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");
  
  // Deploy VelirionToken
  console.log("Deploying VelirionToken...");
  const VelirionToken = await ethers.getContractFactory("VelirionToken");
  const token = await VelirionToken.deploy();
  await token.deployed();
  
  const tokenAddress = token.address;
  console.log("✅ VelirionToken deployed to:", tokenAddress);
  
  // Verify deployment
  const totalSupply = await token.totalSupply();
  const name = await token.name();
  const symbol = await token.symbol();
  const decimals = await token.decimals();
  const ownerBalance = await token.balanceOf(deployer.address);
  
  console.log("\nToken Information:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Name:", name);
  console.log("Symbol:", symbol);
  console.log("Decimals:", decimals);
  console.log("Total Supply:", ethers.utils.formatEther(totalSupply), "VLR");
  console.log("Owner Balance:", ethers.utils.formatEther(ownerBalance), "VLR");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
  
  console.log(" Next Steps:");
  console.log("1. Update .env file:");
  console.log(`   VLR_TOKEN_ADDRESS=${tokenAddress}`);
  console.log("\n2. Verify contract on Etherscan:");
  console.log(`   npx hardhat verify --network sepolia ${tokenAddress}`);
  console.log("\n3. Allocate tokens to contracts:");
  console.log("   - Run allocation scripts after deploying other contracts");
  
  // Save deployment info to file
  const fs = require('fs');
  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    tokenAddress: tokenAddress,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    totalSupply: ethers.utils.formatEther(totalSupply),
  };
  
  fs.writeFileSync(
    'deployment-token.json',
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("\n💾 Deployment info saved to deployment-token.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
