import { ethers } from "ethers";

/**
 * Generate Test Addresses for Multi-Sig Wallets
 * For testnet use only - generates 10 random addresses
 */
async function main() {
    console.log("\n" + "=".repeat(70));
    console.log("🔑 GENERATING TEST ADDRESSES FOR MULTI-SIG WALLETS");
    console.log("=".repeat(70) + "\n");

    console.log("⚠️  WARNING: These are TEST addresses for Sepolia testnet only!");
    console.log("⚠️  DO NOT use these for mainnet deployment!\n");

    const addresses: string[] = [];
    const privateKeys: string[] = [];

    // Generate 10 random wallets
    for (let i = 1; i <= 10; i++) {
        const wallet = ethers.Wallet.createRandom();
        addresses.push(wallet.address);
        privateKeys.push(wallet.privateKey);
        
        console.log(`Wallet ${i}:`);
        console.log(`  Address: ${wallet.address}`);
        console.log(`  Private Key: ${wallet.privateKey}`);
        console.log();
    }

    console.log("=".repeat(70));
    console.log("📋 SUGGESTED MULTI-SIG CONFIGURATION");
    console.log("=".repeat(70) + "\n");

    console.log("🏦 DAO Treasury Safe (3-of-5):");
    console.log(`  Signer 1: ${addresses[0]}`);
    console.log(`  Signer 2: ${addresses[1]}`);
    console.log(`  Signer 3: ${addresses[2]}`);
    console.log(`  Signer 4: ${addresses[3]}`);
    console.log(`  Signer 5: ${addresses[4]}`);
    console.log();

    console.log("📢 Marketing Safe (2-of-3):");
    console.log(`  Signer 1: ${addresses[5]}`);
    console.log(`  Signer 2: ${addresses[6]}`);
    console.log(`  Signer 3: ${addresses[7]}`);
    console.log();

    console.log("👥 Team Safe (3-of-5):");
    console.log(`  Signer 1: ${addresses[0]}`); // Reuse
    console.log(`  Signer 2: ${addresses[1]}`); // Reuse
    console.log(`  Signer 3: ${addresses[2]}`); // Reuse
    console.log(`  Signer 4: ${addresses[8]}`);
    console.log(`  Signer 5: ${addresses[9]}`);
    console.log();

    console.log("💧 Liquidity Safe (2-of-3):");
    console.log(`  Signer 1: ${addresses[5]}`); // Reuse
    console.log(`  Signer 2: ${addresses[6]}`); // Reuse
    console.log(`  Signer 3: ${addresses[8]}`); // Reuse
    console.log();

    console.log("=".repeat(70));
    console.log("💡 ALTERNATIVE: Use Deployer for All (Testing Only)");
    console.log("=".repeat(70) + "\n");

    console.log("For quick testnet deployment, you can use the deployer address:");
    console.log("Deployer: 0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62\n");

    console.log("Update .env with:");
    console.log("DAO_TREASURY_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62");
    console.log("MARKETING_WALLET_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62");
    console.log("TEAM_WALLET_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62");
    console.log("LIQUIDITY_WALLET_SAFE=0xdB84e27b7CaFb453298057Bcf6B7cd97fc988e62\n");

    console.log("=".repeat(70));
    console.log("✅ ADDRESSES GENERATED");
    console.log("=".repeat(70) + "\n");

    console.log("Next steps:");
    console.log("1. Save these addresses securely");
    console.log("2. Create Gnosis Safe wallets with these signers");
    console.log("3. Update .env with Safe addresses");
    console.log("4. Proceed with deployment\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
