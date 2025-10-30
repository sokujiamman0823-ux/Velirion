import { ethers } from "hardhat";

/**
 * Verify Sepolia Connection and Deployer Wallet
 * Run: npx hardhat run scripts/verify_sepolia_connection.ts --network sepolia
 */
async function main() {
    console.log("\n" + "=".repeat(70));
    console.log("🔍 SEPOLIA CONNECTION VERIFICATION");
    console.log("=".repeat(70) + "\n");

    try {
        // 1. Check Network
        console.log("📡 Checking Network Connection...");
        const network = await ethers.provider.getNetwork();
        console.log("✅ Network:", network.name);
        console.log("✅ Chain ID:", network.chainId);
        
        if (network.chainId !== 11155111) {
            console.log("❌ ERROR: Not connected to Sepolia (expected chain ID: 11155111)");
            process.exit(1);
        }

        // 2. Check Block Number
        console.log("\n📦 Checking Latest Block...");
        const blockNumber = await ethers.provider.getBlockNumber();
        console.log("✅ Current Block:", blockNumber.toLocaleString());

        // 3. Check Deployer Wallet
        console.log("\n👤 Checking Deployer Wallet...");
        const [deployer] = await ethers.getSigners();
        console.log("✅ Deployer Address:", deployer.address);

        // 4. Check Balance
        console.log("\n💰 Checking Balance...");
        const balance = await ethers.provider.getBalance(deployer.address);
        const balanceInEth = ethers.utils.formatEther(balance);
        console.log("✅ Balance:", balanceInEth, "ETH");

        // 5. Balance Assessment
        const requiredBalance = 0.5;
        if (parseFloat(balanceInEth) < requiredBalance) {
            console.log(`\n⚠️  WARNING: Insufficient balance for deployment`);
            console.log(`   Current: ${balanceInEth} ETH`);
            console.log(`   Required: ${requiredBalance} ETH`);
            console.log(`   Need: ${(requiredBalance - parseFloat(balanceInEth)).toFixed(4)} ETH more`);
            console.log("\n📝 Get testnet ETH from:");
            console.log("   - https://sepoliafaucet.com/");
            console.log("   - https://www.infura.io/faucet/sepolia");
            console.log("   - https://faucets.chain.link/sepolia");
        } else {
            console.log(`\n✅ Sufficient balance for deployment!`);
        }

        // 6. Check Gas Price
        console.log("\n⛽ Checking Gas Price...");
        const gasPrice = await ethers.provider.getGasPrice();
        const gasPriceInGwei = ethers.utils.formatUnits(gasPrice, "gwei");
        console.log("✅ Current Gas Price:", gasPriceInGwei, "gwei");

        // 7. Estimate Deployment Cost
        console.log("\n💸 Estimating Deployment Cost...");
        const estimatedGas = 26000000; // Total gas for all contracts
        const estimatedCostWei = gasPrice.mul(estimatedGas);
        const estimatedCostEth = ethers.utils.formatEther(estimatedCostWei);
        console.log("   Estimated Gas:", estimatedGas.toLocaleString());
        console.log("   Estimated Cost:", estimatedCostEth, "ETH");
        console.log("   With 20% buffer:", (parseFloat(estimatedCostEth) * 1.2).toFixed(4), "ETH");

        // 8. Check Etherscan API
        console.log("\n🔍 Checking Etherscan API...");
        const etherscanApiKey = process.env.ETHERSCAN_API_KEY;
        if (etherscanApiKey && etherscanApiKey.length > 0) {
            console.log("✅ Etherscan API Key configured");
        } else {
            console.log("⚠️  WARNING: Etherscan API Key not found in .env");
        }

        // 9. Check Chainlink Price Feed
        console.log("\n📊 Checking Chainlink Price Feed...");
        const priceFeedAddress = process.env.ETH_USD_PRICE_FEED || "0x694AA1769357215DE4FAC081bf1f309aDC325306";
        console.log("   Price Feed Address:", priceFeedAddress);
        
        // Try to read from price feed
        try {
            const priceFeedABI = [
                "function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)"
            ];
            const priceFeed = new ethers.Contract(priceFeedAddress, priceFeedABI, ethers.provider);
            const roundData = await priceFeed.latestRoundData();
            const price = ethers.utils.formatUnits(roundData.answer, 8);
            console.log("✅ ETH/USD Price:", "$" + parseFloat(price).toLocaleString());
        } catch (error) {
            console.log("⚠️  Could not read price feed (may not be deployed yet)");
        }

        // 10. Summary
        console.log("\n" + "=".repeat(70));
        console.log("📋 VERIFICATION SUMMARY");
        console.log("=".repeat(70));
        console.log("Network:          ✅ Sepolia (Chain ID: 11155111)");
        console.log("RPC Connection:   ✅ Working");
        console.log("Deployer Wallet:  ✅", deployer.address);
        console.log("Balance:         ", parseFloat(balanceInEth) >= requiredBalance ? "✅" : "⚠️ ", balanceInEth, "ETH");
        console.log("Gas Price:        ✅", gasPriceInGwei, "gwei");
        console.log("Etherscan API:   ", etherscanApiKey ? "✅" : "⚠️ ", "Configured");
        
        console.log("\n" + "=".repeat(70));
        
        if (parseFloat(balanceInEth) >= requiredBalance) {
            console.log("🎉 READY FOR DEPLOYMENT!");
        } else {
            console.log("⏳ GET TESTNET ETH BEFORE DEPLOYMENT");
        }
        
        console.log("=".repeat(70) + "\n");

    } catch (error) {
        console.error("\n❌ ERROR:", error);
        process.exit(1);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
