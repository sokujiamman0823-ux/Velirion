import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

/**
 * Complete Velirion Ecosystem Deployment Script
 * Deploys all contracts in the correct order with proper configuration
 */
async function main() {
    console.log("\n" + "=".repeat(70));
    console.log("🚀 VELIRION COMPLETE ECOSYSTEM DEPLOYMENT");
    console.log("=".repeat(70) + "\n");

    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH\n");

    // Multi-sig wallet addresses (from .env or use deployer for testing)
    const MARKETING_WALLET = process.env.MARKETING_WALLET || deployer.address;
    const TEAM_WALLET = process.env.TEAM_WALLET || deployer.address;
    const LIQUIDITY_WALLET = process.env.LIQUIDITY_WALLET || deployer.address;

    const deployedContracts: any = {
        network: (await ethers.provider.getNetwork()).name,
        timestamp: new Date().toISOString(),
        deployer: deployer.address,
        contracts: {},
        wallets: {
            marketing: MARKETING_WALLET,
            team: TEAM_WALLET,
            liquidity: LIQUIDITY_WALLET
        }
    };

    // ============================================================================
    // PHASE 1: Core Token
    // ============================================================================

    console.log("📍 PHASE 1: Deploying Core Token\n");
    
    const VelirionToken = await ethers.getContractFactory("VelirionToken");
    const vlrToken = await VelirionToken.deploy();
    await vlrToken.deployed();
    console.log("✅ VelirionToken:", vlrToken.address);
    deployedContracts.contracts.vlrToken = vlrToken.address;

    // ============================================================================
    // PHASE 2: Presale System
    // ============================================================================

    console.log("\n📍 PHASE 2: Deploying Presale System\n");

    // Deploy mock payment tokens for testing (skip on mainnet)
    const network = await ethers.provider.getNetwork();
    let usdtAddress, usdcAddress;

    if (network.chainId === 31337 || network.chainId === 11155111) { // localhost or sepolia
        const MockERC20 = await ethers.getContractFactory("MockERC20");
        
        const usdt = await MockERC20.deploy("Tether USD", "USDT", 6);
        await usdt.deployed();
        usdtAddress = usdt.address;
        console.log("✅ Mock USDT:", usdtAddress);

        const usdc = await MockERC20.deploy("USD Coin", "USDC", 6);
        await usdc.deployed();
        usdcAddress = usdc.address;
        console.log("✅ Mock USDC:", usdcAddress);
    } else {
        // Use real addresses on mainnet
        usdtAddress = process.env.USDT_ADDRESS || "";
        usdcAddress = process.env.USDC_ADDRESS || "";
    }

    const VelirionPresaleV2 = await ethers.getContractFactory("VelirionPresaleV2");
    // Initial ETH price in USD with 18 decimals (e.g., $2000 = 2000 * 10^18)
    const initialEthPrice = ethers.utils.parseEther("2000"); // $2000 per ETH
    const presale = await VelirionPresaleV2.deploy(
        vlrToken.address,
        usdtAddress,
        usdcAddress,
        initialEthPrice
    );
    await presale.deployed();
    console.log("✅ PresaleContractV2:", presale.address);
    deployedContracts.contracts.presale = presale.address;
    deployedContracts.contracts.usdt = usdtAddress;
    deployedContracts.contracts.usdc = usdcAddress;

    // ============================================================================
    // PHASE 3: Referral System
    // ============================================================================

    console.log("\n📍 PHASE 3: Deploying Referral System\n");

    const VelirionReferral = await ethers.getContractFactory("VelirionReferral");
    const referral = await VelirionReferral.deploy(vlrToken.address);
    await referral.deployed();
    console.log("✅ VelirionReferral:", referral.address);
    deployedContracts.contracts.referral = referral.address;

    // ============================================================================
    // PHASE 4: Staking System
    // ============================================================================

    console.log("\n📍 PHASE 4: Deploying Staking System\n");

    const VelirionStaking = await ethers.getContractFactory("VelirionStaking");
    const staking = await VelirionStaking.deploy(vlrToken.address);
    await staking.deployed();
    console.log("✅ VelirionStaking:", staking.address);
    deployedContracts.contracts.staking = staking.address;

    // ============================================================================
    // PHASE 5: DAO Governance
    // ============================================================================

    console.log("\n📍 PHASE 5: Deploying DAO Governance\n");

    const VelirionTimelock = await ethers.getContractFactory("VelirionTimelock");
    const timelock = await VelirionTimelock.deploy(deployer.address);
    await timelock.deployed();
    console.log("✅ VelirionTimelock:", timelock.address);
    deployedContracts.contracts.timelock = timelock.address;

    const VelirionDAO = await ethers.getContractFactory("VelirionDAO");
    const dao = await VelirionDAO.deploy(
        vlrToken.address,
        timelock.address,
        deployer.address
    );
    await dao.deployed();
    console.log("✅ VelirionDAO:", dao.address);
    deployedContracts.contracts.dao = dao.address;

    const VelirionTreasury = await ethers.getContractFactory("VelirionTreasury");
    const treasury = await VelirionTreasury.deploy(
        vlrToken.address,
        MARKETING_WALLET,
        TEAM_WALLET,
        LIQUIDITY_WALLET,
        deployer.address
    );
    await treasury.deployed();
    console.log("✅ VelirionTreasury:", treasury.address);
    deployedContracts.contracts.treasury = treasury.address;

    // ============================================================================
    // PHASE 6: NFT Rewards
    // ============================================================================

    console.log("\n📍 PHASE 6: Deploying NFT Reward System\n");

    const REFERRAL_NFT_BASE_URI = process.env.REFERRAL_NFT_BASE_URI || "ipfs://QmReferral/";
    const GUARDIAN_NFT_BASE_URI = process.env.GUARDIAN_NFT_BASE_URI || "ipfs://QmGuardian/";

    const VelirionReferralNFT = await ethers.getContractFactory("VelirionReferralNFT");
    const referralNFT = await VelirionReferralNFT.deploy(
        "Velirion Referral Badge",
        "VLR-REF",
        REFERRAL_NFT_BASE_URI,
        deployer.address
    );
    await referralNFT.deployed();
    console.log("✅ VelirionReferralNFT:", referralNFT.address);
    deployedContracts.contracts.referralNFT = referralNFT.address;

    const VelirionGuardianNFT = await ethers.getContractFactory("VelirionGuardianNFT");
    const guardianNFT = await VelirionGuardianNFT.deploy(
        "Velirion Guardian",
        "VLR-GUARD",
        GUARDIAN_NFT_BASE_URI,
        deployer.address
    );
    await guardianNFT.deployed();
    console.log("✅ VelirionGuardianNFT:", guardianNFT.address);
    deployedContracts.contracts.guardianNFT = guardianNFT.address;

    // ============================================================================
    // CONFIGURATION: Connect All Contracts
    // ============================================================================

    console.log("\n📍 CONFIGURATION: Connecting Contracts\n");

    // Authorize Presale in Referral
    console.log("⚙️  Authorizing Presale in Referral...");
    await referral.setAuthorizedContract(presale.address, true);
    console.log("✅ Presale authorized in Referral");

    // Connect Staking <-> Referral
    console.log("⚙️  Connecting Staking and Referral...");
    await staking.setReferralContract(referral.address);
    await referral.setAuthorizedContract(staking.address, true);
    console.log("✅ Staking ↔ Referral connected");

    // Connect DAO <-> Staking
    console.log("⚙️  Connecting DAO and Staking...");
    await dao.setStakingContract(staking.address);
    console.log("✅ DAO ↔ Staking connected");

    // Connect Treasury <-> DAO
    console.log("⚙️  Connecting Treasury and DAO...");
    await treasury.setDAOContract(dao.address);
    console.log("✅ Treasury ↔ DAO connected");

    // Connect NFTs
    console.log("⚙️  Connecting NFT contracts...");
    await referralNFT.setReferralContract(referral.address);
    await guardianNFT.setStakingContract(staking.address);
    console.log("✅ NFT contracts connected");

    // Transfer Timelock ownership to DAO
    console.log("⚙️  Transferring Timelock to DAO...");
    await timelock.transferOwnership(dao.address);
    console.log("✅ Timelock → DAO ownership transferred");

    // ============================================================================
    // TOKEN ALLOCATION
    // ============================================================================

    console.log("\n📍 TOKEN ALLOCATION\n");

    const totalSupply = await vlrToken.totalSupply();
    console.log("Total Supply:", ethers.utils.formatEther(totalSupply), "VLR");

    // Allocate tokens according to tokenomics
    console.log("\n⚙️  Allocating tokens...");
    
    // Presale: 30M VLR
    await vlrToken.transfer(presale.address, ethers.utils.parseEther("30000000"));
    console.log("✅ Presale: 30,000,000 VLR");

    // Staking Rewards: 20M VLR
    await vlrToken.transfer(staking.address, ethers.utils.parseEther("20000000"));
    console.log("✅ Staking: 20,000,000 VLR");

    // Marketing: 15M VLR
    await vlrToken.transfer(MARKETING_WALLET, ethers.utils.parseEther("15000000"));
    console.log("✅ Marketing: 15,000,000 VLR");

    // Team: 15M VLR
    await vlrToken.transfer(TEAM_WALLET, ethers.utils.parseEther("15000000"));
    console.log("✅ Team: 15,000,000 VLR");

    // Liquidity: 10M VLR
    await vlrToken.transfer(LIQUIDITY_WALLET, ethers.utils.parseEther("10000000"));
    console.log("✅ Liquidity: 10,000,000 VLR");

    // Referral Rewards: 5M VLR
    await vlrToken.transfer(referral.address, ethers.utils.parseEther("5000000"));
    console.log("✅ Referral: 5,000,000 VLR");

    // DAO Treasury: 5M VLR
    await vlrToken.transfer(treasury.address, ethers.utils.parseEther("5000000"));
    console.log("✅ DAO Treasury: 5,000,000 VLR");

    // ============================================================================
    // DEPLOYMENT SUMMARY
    // ============================================================================

    console.log("\n" + "=".repeat(70));
    console.log("📊 DEPLOYMENT SUMMARY");
    console.log("=".repeat(70));
    console.log("\n🪙 Core:");
    console.log("  VLR Token:     ", vlrToken.address);
    console.log("\n💰 Presale:");
    console.log("  Presale:       ", presale.address);
    console.log("  USDT:          ", usdtAddress);
    console.log("  USDC:          ", usdcAddress);
    console.log("\n👥 Referral:");
    console.log("  Referral:      ", referral.address);
    console.log("\n🔒 Staking:");
    console.log("  Staking:       ", staking.address);
    console.log("\n🏛️  DAO:");
    console.log("  Timelock:      ", timelock.address);
    console.log("  DAO:           ", dao.address);
    console.log("  Treasury:      ", treasury.address);
    console.log("\n🎨 NFTs:");
    console.log("  Referral NFT:  ", referralNFT.address);
    console.log("  Guardian NFT:  ", guardianNFT.address);
    console.log("\n💼 Wallets:");
    console.log("  Marketing:     ", MARKETING_WALLET);
    console.log("  Team:          ", TEAM_WALLET);
    console.log("  Liquidity:     ", LIQUIDITY_WALLET);
    console.log("=".repeat(70));

    // Save deployment info
    const deploymentPath = path.join(__dirname, "..", "deployment-complete.json");
    fs.writeFileSync(deploymentPath, JSON.stringify(deployedContracts, null, 2));
    console.log("\n💾 Deployment info saved to deployment-complete.json");

    // Update .env template
    console.log("\n📝 UPDATE YOUR .ENV FILE:");
    console.log("━".repeat(70));
    console.log(`VLR_TOKEN_ADDRESS=${vlrToken.address}`);
    console.log(`PRESALE_CONTRACT_V2=${presale.address}`);
    console.log(`REFERRAL_CONTRACT=${referral.address}`);
    console.log(`STAKING_CONTRACT=${staking.address}`);
    console.log(`TIMELOCK_CONTRACT=${timelock.address}`);
    console.log(`DAO_CONTRACT=${dao.address}`);
    console.log(`TREASURY_CONTRACT=${treasury.address}`);
    console.log(`REFERRAL_NFT_CONTRACT=${referralNFT.address}`);
    console.log(`GUARDIAN_NFT_CONTRACT=${guardianNFT.address}`);
    console.log(`USDT_ADDRESS=${usdtAddress}`);
    console.log(`USDC_ADDRESS=${usdcAddress}`);
    console.log("━".repeat(70));

    console.log("\n✅ COMPLETE ECOSYSTEM DEPLOYED SUCCESSFULLY!\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
