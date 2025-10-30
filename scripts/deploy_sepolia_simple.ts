import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

/**
 * Simplified Sepolia Deployment Script
 * Uses deployer address for all wallets (testnet only)
 * No multi-sig, no IPFS required - just deploy and test
 */
async function main() {
    console.log("\n" + "=".repeat(70));
    console.log("VELIRION SEPOLIA TESTNET DEPLOYMENT (SIMPLIFIED)");
    console.log("=".repeat(70) + "\n");

    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

    if (balance.lt(ethers.utils.parseEther("0.05"))) {
        console.log("\nWARNING: Low balance. Deployment may fail.");
        console.log("   Recommended: 0.1+ ETH");
    }

    console.log("\nUsing deployer address for all wallets (testnet only)");
    console.log("   This is NOT suitable for mainnet!\n");

    // Use deployer for all wallets
    const MARKETING_WALLET = deployer.address;
    const TEAM_WALLET = deployer.address;
    const LIQUIDITY_WALLET = deployer.address;

    const deployedContracts: any = {
        network: "sepolia",
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

    console.log("\nPHASE 1: Deploying Core Token\n");
    
    const VelirionToken = await ethers.getContractFactory("VelirionToken");
    console.log("Deploying VelirionToken...");
    const vlrToken = await VelirionToken.deploy();
    await vlrToken.deployed();
    console.log("VelirionToken:", vlrToken.address);
    deployedContracts.contracts.vlrToken = vlrToken.address;

    // ============================================================================
    // PHASE 2: Presale System
    // ============================================================================

    console.log("\nPHASE 2: Deploying Presale System\n");

    // Deploy mock payment tokens
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    
    console.log("Deploying Mock USDT...");
    const usdt = await MockERC20.deploy("Tether USD", "USDT", 6);
    await usdt.deployed();
    console.log("Mock USDT:", usdt.address);

    console.log("Deploying Mock USDC...");
    const usdc = await MockERC20.deploy("USD Coin", "USDC", 6);
    await usdc.deployed();
    console.log("Mock USDC:", usdc.address);

    const usdtAddress = usdt.address;
    const usdcAddress = usdc.address;

    // Deploy Presale
    const VelirionPresaleV2 = await ethers.getContractFactory("VelirionPresaleV2");
    const initialEthPrice = ethers.utils.parseEther("2000"); // $2000 per ETH
    
    console.log("Deploying PresaleContractV2...");
    const presale = await VelirionPresaleV2.deploy(
        vlrToken.address,
        usdtAddress,
        usdcAddress,
        initialEthPrice
    );
    await presale.deployed();
    console.log("PresaleContractV2:", presale.address);
    deployedContracts.contracts.presale = presale.address;
    deployedContracts.contracts.usdt = usdtAddress;
    deployedContracts.contracts.usdc = usdcAddress;

    // ============================================================================
    // PHASE 3: Referral System
    // ============================================================================

    console.log("\nPHASE 3: Deploying Referral System\n");

    const VelirionReferral = await ethers.getContractFactory("VelirionReferral");
    console.log("Deploying VelirionReferral...");
    const referral = await VelirionReferral.deploy(vlrToken.address);
    await referral.deployed();
    console.log("VelirionReferral:", referral.address);
    deployedContracts.contracts.referral = referral.address;

    // ============================================================================
    // PHASE 4: Staking System
    // ============================================================================

    console.log("\nPHASE 4: Deploying Staking System\n");

    const VelirionStaking = await ethers.getContractFactory("VelirionStaking");
    console.log("Deploying VelirionStaking...");
    const staking = await VelirionStaking.deploy(vlrToken.address);
    await staking.deployed();
    console.log("VelirionStaking:", staking.address);
    deployedContracts.contracts.staking = staking.address;

    // ============================================================================
    // PHASE 5: Governance System
    // ============================================================================

    console.log("\nPHASE 5: Deploying Governance System\n");

    // Deploy Timelock
    const VelirionTimelock = await ethers.getContractFactory("VelirionTimelock");
    
    console.log("Deploying VelirionTimelock...");
    const timelock = await VelirionTimelock.deploy(deployer.address);
    await timelock.deployed();
    console.log("VelirionTimelock:", timelock.address);
    deployedContracts.contracts.timelock = timelock.address;

    // Deploy DAO
    const VelirionDAO = await ethers.getContractFactory("VelirionDAO");
    console.log("Deploying VelirionDAO...");
    const dao = await VelirionDAO.deploy(vlrToken.address, timelock.address, deployer.address);
    await dao.deployed();
    console.log("VelirionDAO:", dao.address);
    deployedContracts.contracts.dao = dao.address;

    // Deploy Treasury
    const VelirionTreasury = await ethers.getContractFactory("VelirionTreasury");
    console.log("Deploying VelirionTreasury...");
    const treasury = await VelirionTreasury.deploy(
        vlrToken.address,
        MARKETING_WALLET,
        TEAM_WALLET,
        LIQUIDITY_WALLET,
        deployer.address
    );
    await treasury.deployed();
    console.log("VelirionTreasury:", treasury.address);
    deployedContracts.contracts.treasury = treasury.address;

    // ============================================================================
    // PHASE 6: NFT Rewards (Simplified - No IPFS)
    // ============================================================================

    console.log("\nPHASE 6: Deploying NFT Rewards\n");

    // Use placeholder base URIs
    const referralNFTBaseURI = "https://velirion.io/nft/referral/";
    const guardianNFTBaseURI = "https://velirion.io/nft/guardian/";

    const VelirionReferralNFT = await ethers.getContractFactory("VelirionReferralNFT");
    console.log("Deploying VelirionReferralNFT...");
    const referralNFT = await VelirionReferralNFT.deploy(
        "Velirion Referral Badge",
        "VLRREF",
        referralNFTBaseURI,
        deployer.address
    );
    await referralNFT.deployed();
    console.log("VelirionReferralNFT:", referralNFT.address);
    deployedContracts.contracts.referralNFT = referralNFT.address;

    const VelirionGuardianNFT = await ethers.getContractFactory("VelirionGuardianNFT");
    console.log("Deploying VelirionGuardianNFT...");
    const guardianNFT = await VelirionGuardianNFT.deploy(
        "Velirion Guardian",
        "VLRGUARD",
        guardianNFTBaseURI,
        deployer.address
    );
    await guardianNFT.deployed();
    console.log("VelirionGuardianNFT:", guardianNFT.address);
    deployedContracts.contracts.guardianNFT = guardianNFT.address;

    // ============================================================================
    // CONFIGURATION
    // ============================================================================

    console.log("\nPHASE 7: Configuring Integrations\n");

    // Authorize contracts in Referral
    console.log("Authorizing Presale in Referral...");
    await referral.setAuthorizedContract(presale.address, true);
    console.log("Presale authorized");

    console.log("Authorizing Staking in Referral...");
    await referral.setAuthorizedContract(staking.address, true);
    console.log("Staking authorized");

    // Connect DAO and Staking
    console.log("Connecting DAO and Staking...");
    await dao.setStakingContract(staking.address);
    console.log("DAO <-> Staking connected");

    // Connect Treasury and DAO
    console.log("Connecting Treasury and DAO...");
    await treasury.setDAOContract(dao.address);
    console.log("Treasury <-> DAO connected");

    // Connect NFTs
    console.log("Connecting NFT contracts...");
    await referralNFT.setReferralContract(referral.address);
    await guardianNFT.setStakingContract(staking.address);
    console.log("NFT contracts connected");

    // ============================================================================
    // TOKEN ALLOCATION
    // ============================================================================

    console.log("\nPHASE 8: Token Allocation\n");

    const totalSupply = await vlrToken.totalSupply();
    console.log("Total Supply:", ethers.utils.formatEther(totalSupply), "VLR\n");

    console.log("Allocating tokens...");
    
    // Presale: 30M VLR
    await vlrToken.transfer(presale.address, ethers.utils.parseEther("30000000"));
    console.log("Presale: 30,000,000 VLR");

    // Staking Rewards: 20M VLR
    await vlrToken.transfer(staking.address, ethers.utils.parseEther("20000000"));
    console.log("Staking: 20,000,000 VLR");

    // Marketing: 15M VLR
    await vlrToken.transfer(MARKETING_WALLET, ethers.utils.parseEther("15000000"));
    console.log("Marketing: 15,000,000 VLR");

    // Team: 15M VLR
    await vlrToken.transfer(TEAM_WALLET, ethers.utils.parseEther("15000000"));
    console.log("Team: 15,000,000 VLR");

    // Liquidity: 10M VLR
    await vlrToken.transfer(LIQUIDITY_WALLET, ethers.utils.parseEther("10000000"));
    console.log("Liquidity: 10,000,000 VLR");

    // Referral Rewards: 5M VLR
    await vlrToken.transfer(referral.address, ethers.utils.parseEther("5000000"));
    console.log("Referral: 5,000,000 VLR");

    // DAO Treasury: 5M VLR
    await vlrToken.transfer(treasury.address, ethers.utils.parseEther("5000000"));
    console.log("DAO Treasury: 5,000,000 VLR");

    // ============================================================================
    // DEPLOYMENT SUMMARY
    // ============================================================================

    console.log("\n" + "=".repeat(70));
    console.log("DEPLOYMENT COMPLETE!");
    console.log("=".repeat(70));
    console.log("\nCONTRACT ADDRESSES:");
    console.log("━".repeat(70));
    console.log("\nCore:");
    console.log("  VLR Token:     ", vlrToken.address);
    console.log("\nPresale:");
    console.log("  Presale:       ", presale.address);
    console.log("  USDT:          ", usdtAddress);
    console.log("  USDC:          ", usdcAddress);
    console.log("\nReferral:");
    console.log("  Referral:      ", referral.address);
    console.log("\nStaking:");
    console.log("  Staking:       ", staking.address);
    console.log("\nDAO:");
    console.log("  Timelock:      ", timelock.address);
    console.log("  DAO:           ", dao.address);
    console.log("  Treasury:      ", treasury.address);
    console.log("\nNFTs:");
    console.log("  Referral NFT:  ", referralNFT.address);
    console.log("  Guardian NFT:  ", guardianNFT.address);
    console.log("\nWallets:");
    console.log("  Marketing:     ", MARKETING_WALLET);
    console.log("  Team:          ", TEAM_WALLET);
    console.log("  Liquidity:     ", LIQUIDITY_WALLET);
    console.log("━".repeat(70));

    // Save deployment info
    const deploymentPath = path.join(__dirname, "..", "deployment-sepolia.json");
    fs.writeFileSync(deploymentPath, JSON.stringify(deployedContracts, null, 2));
    console.log("\nDeployment saved to: deployment-sepolia.json");

    // Print .env updates
    console.log("\nUPDATE YOUR .ENV FILE:");
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
    console.log("━".repeat(70));

    // Print verification commands
    console.log("\nVERIFY CONTRACTS ON ETHERSCAN:");
    console.log("━".repeat(70));
    console.log(`npx hardhat verify --network sepolia ${vlrToken.address}`);
    console.log(`npx hardhat verify --network sepolia ${presale.address} "${vlrToken.address}" "${usdtAddress}" "${usdcAddress}" "${initialEthPrice}"`);
    console.log(`npx hardhat verify --network sepolia ${referral.address} "${vlrToken.address}"`);
    console.log(`npx hardhat verify --network sepolia ${staking.address} "${vlrToken.address}"`);
    console.log(`npx hardhat verify --network sepolia ${dao.address} "${vlrToken.address}" "${timelock.address}"`);
    console.log(`npx hardhat verify --network sepolia ${treasury.address} "${vlrToken.address}"`);
    console.log(`npx hardhat verify --network sepolia ${referralNFT.address} "${referralNFTBaseURI}"`);
    console.log(`npx hardhat verify --network sepolia ${guardianNFT.address} "${guardianNFTBaseURI}"`);
    console.log("━".repeat(70));

    console.log("\nNEXT STEPS:");
    console.log("1. Verify all contracts on Etherscan (commands above)");
    console.log("2. Update .env file with new addresses");
    console.log("3. Test basic functionality");
    console.log("4. Start presale Phase 1");
    console.log("5. Begin community testing\n");

    console.log("=".repeat(70));
    console.log("SEPOLIA DEPLOYMENT SUCCESSFUL!");
    console.log("=".repeat(70) + "\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("\nDEPLOYMENT FAILED:");
        console.error(error);
        process.exit(1);
    });
