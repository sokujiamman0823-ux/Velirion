import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
    console.log("\n🏛️  Deploying Velirion DAO Governance System...\n");

    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);
    
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log(
        "Account balance:",
        ethers.utils.formatEther(balance),
        "ETH\n"
    );

    // Get deployed contract addresses from .env or previous deployments
    const VLR_TOKEN_ADDRESS = process.env.VLR_TOKEN_ADDRESS;
    const STAKING_CONTRACT = process.env.STAKING_CONTRACT;
    
    if (!VLR_TOKEN_ADDRESS) {
        throw new Error("VLR_TOKEN_ADDRESS not found in .env");
    }

    console.log("Using VLR Token at:", VLR_TOKEN_ADDRESS);
    if (STAKING_CONTRACT) {
        console.log("Using Staking Contract at:", STAKING_CONTRACT);
    }

    // Multi-sig wallet addresses (from .env or use deployer for testing)
    const MARKETING_WALLET = process.env.MARKETING_WALLET || deployer.address;
    const TEAM_WALLET = process.env.TEAM_WALLET || deployer.address;
    const LIQUIDITY_WALLET = process.env.LIQUIDITY_WALLET || deployer.address;

    console.log("\n📋 Multi-sig Wallets:");
    console.log("  Marketing:", MARKETING_WALLET);
    console.log("  Team:", TEAM_WALLET);
    console.log("  Liquidity:", LIQUIDITY_WALLET);

    // ============================================================================
    // Deploy VelirionTimelock
    // ============================================================================

    console.log("\n⏰ Deploying VelirionTimelock...");
    const VelirionTimelock = await ethers.getContractFactory("VelirionTimelock");
    const timelock = await VelirionTimelock.deploy(deployer.address);
    await timelock.deployed();
    const timelockAddress = timelock.address;
    console.log("✅ VelirionTimelock deployed to:", timelockAddress);

    // ============================================================================
    // Deploy VelirionDAO
    // ============================================================================

    console.log("\n🗳️  Deploying VelirionDAO...");
    const VelirionDAO = await ethers.getContractFactory("VelirionDAO");
    const dao = await VelirionDAO.deploy(
        VLR_TOKEN_ADDRESS,
        timelockAddress,
        deployer.address
    );
    await dao.deployed();
    const daoAddress = dao.address;
    console.log("✅ VelirionDAO deployed to:", daoAddress);

    // ============================================================================
    // Deploy VelirionTreasury
    // ============================================================================

    console.log("\n💰 Deploying VelirionTreasury...");
    const VelirionTreasury = await ethers.getContractFactory("VelirionTreasury");
    const treasury = await VelirionTreasury.deploy(
        VLR_TOKEN_ADDRESS,
        MARKETING_WALLET,
        TEAM_WALLET,
        LIQUIDITY_WALLET,
        deployer.address
    );
    await treasury.deployed();
    const treasuryAddress = treasury.address;
    console.log("✅ VelirionTreasury deployed to:", treasuryAddress);

    // ============================================================================
    // Configure Contracts
    // ============================================================================

    console.log("\n⚙️  Configuring contracts...");

    // Set DAO contract in Treasury
    console.log("  Setting DAO contract in Treasury...");
    await treasury.setDAOContract(daoAddress);
    console.log("  ✅ DAO contract set");

    // Set Staking contract in DAO (if available)
    if (STAKING_CONTRACT) {
        console.log("  Setting Staking contract in DAO...");
        await dao.setStakingContract(STAKING_CONTRACT);
        console.log("  ✅ Staking contract set");
    } else {
        console.log("  ⚠️  Staking contract not set (will need to set later)");
    }

    // Transfer Timelock ownership to DAO
    console.log("  Transferring Timelock ownership to DAO...");
    await timelock.transferOwnership(daoAddress);
    console.log("  ✅ Timelock ownership transferred");

    // ============================================================================
    // Display Deployment Summary
    // ============================================================================

    console.log("\n" + "=".repeat(60));
    console.log("📊 DEPLOYMENT SUMMARY");
    console.log("=".repeat(60));
    console.log("\n🏛️  DAO Governance:");
    console.log("  Timelock:  ", timelockAddress);
    console.log("  DAO:       ", daoAddress);
    console.log("  Treasury:  ", treasuryAddress);
    console.log("\n💼 Multi-sig Wallets:");
    console.log("  Marketing: ", MARKETING_WALLET);
    console.log("  Team:      ", TEAM_WALLET);
    console.log("  Liquidity: ", LIQUIDITY_WALLET);
    console.log("\n⚙️  Configuration:");
    console.log("  VLR Token:        ", VLR_TOKEN_ADDRESS);
    console.log("  Staking Contract: ", STAKING_CONTRACT || "Not set");
    console.log("  Proposal Threshold: 10,000 VLR");
    console.log("  Voting Period:      7 days");
    console.log("  Timelock Delay:     2 days");
    console.log("  Quorum:            100,000 VLR");
    console.log("=".repeat(60));

    // ============================================================================
    // Save Deployment Info
    // ============================================================================

    const deploymentInfo = {
        network: (await ethers.provider.getNetwork()).name,
        timestamp: new Date().toISOString(),
        deployer: deployer.address,
        contracts: {
            timelock: timelockAddress,
            dao: daoAddress,
            treasury: treasuryAddress
        },
        wallets: {
            marketing: MARKETING_WALLET,
            team: TEAM_WALLET,
            liquidity: LIQUIDITY_WALLET
        },
        dependencies: {
            vlrToken: VLR_TOKEN_ADDRESS,
            stakingContract: STAKING_CONTRACT || null
        },
        parameters: {
            proposalThreshold: "10000000000000000000000", // 10K VLR
            votingPeriod: "604800", // 7 days in seconds
            timelockDelay: "172800", // 2 days in seconds
            quorum: "100000000000000000000000" // 100K VLR
        }
    };

    const deploymentPath = path.join(__dirname, "..", "deployment-dao.json");
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));
    console.log("\n💾 Deployment info saved to deployment-dao.json");

    // ============================================================================
    // Next Steps
    // ============================================================================

    console.log("\n📝 NEXT STEPS:");
    console.log("━".repeat(60));
    console.log("1. Update .env file:");
    console.log(`   TIMELOCK_CONTRACT=${timelockAddress}`);
    console.log(`   DAO_CONTRACT=${daoAddress}`);
    console.log(`   TREASURY_CONTRACT=${treasuryAddress}`);
    console.log("\n2. Verify contracts on Etherscan:");
    console.log(`   npx hardhat verify --network <network> ${timelockAddress} "${deployer.address}"`);
    console.log(`   npx hardhat verify --network <network> ${daoAddress} "${VLR_TOKEN_ADDRESS}" "${timelockAddress}" "${deployer.address}"`);
    console.log(`   npx hardhat verify --network <network> ${treasuryAddress} "${VLR_TOKEN_ADDRESS}" "${MARKETING_WALLET}" "${TEAM_WALLET}" "${LIQUIDITY_WALLET}" "${deployer.address}"`);
    console.log("\n3. Allocate DAO Treasury tokens (5% of supply = 5M VLR):");
    console.log("   Transfer 5,000,000 VLR to Treasury contract");
    console.log("\n4. Test governance:");
    console.log("   Create a test proposal");
    console.log("   Vote on the proposal");
    console.log("   Execute after timelock");
    console.log("━".repeat(60));

    console.log("\n✅ DAO Governance deployment complete!\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
