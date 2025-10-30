import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { VelirionSpl } from "../target/types/velirion_spl";
import { Keypair, PublicKey } from "@solana/web3.js";
import { TOKEN_PROGRAM_ID } from "@solana/spl-token";
import * as fs from "fs";
import * as path from "path";

/**
 * Deployment script for Velirion SPL Token
 * Deploys to Solana devnet/mainnet and initializes the token
 */
async function main() {
  console.log(" Deploying Velirion SPL Token...\n");

  // Configure provider
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.VelirionSpl as Program<VelirionSpl>;
  const network = provider.connection.rpcEndpoint.includes("devnet")
    ? "devnet"
    : provider.connection.rpcEndpoint.includes("mainnet")
    ? "mainnet"
    : "localnet";

  console.log("📋 Deployment Configuration:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Network:", network);
  console.log("Program ID:", program.programId.toString());
  console.log("Deployer:", provider.wallet.publicKey.toString());
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Generate mint keypair
  const mint = Keypair.generate();
  const mintAuthority = provider.wallet.publicKey;
  const decimals = 9;

  console.log("🪙 Token Configuration:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Mint Address:", mint.publicKey.toString());
  console.log("Mint Authority:", mintAuthority.toString());
  console.log("Decimals:", decimals);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Check deployer balance
  const balance = await provider.connection.getBalance(provider.wallet.publicKey);
  console.log("Deployer Balance:", balance / anchor.web3.LAMPORTS_PER_SOL, "SOL");

  if (balance < 0.1 * anchor.web3.LAMPORTS_PER_SOL) {
    console.error("❌ Insufficient SOL balance!");
    console.error("Please fund your wallet with at least 0.1 SOL");
    process.exit(1);
  }

  console.log("\n⏳ Initializing token mint...");

  try {
    // Initialize the token
    const tx = await program.methods
      .initialize(decimals)
      .accounts({
        mint: mint.publicKey,
        mintAuthority: mintAuthority,
        payer: provider.wallet.publicKey,
      })
      .signers([mint])
      .rpc();

    console.log("✅ Token initialized successfully!");
    console.log("Transaction signature:", tx);

    // Save deployment info
    const deploymentInfo = {
      network,
      programId: program.programId.toString(),
      mintAddress: mint.publicKey.toString(),
      mintAuthority: mintAuthority.toString(),
      decimals,
      deployer: provider.wallet.publicKey.toString(),
      timestamp: new Date().toISOString(),
      transactionSignature: tx,
    };

    const deploymentPath = path.join(__dirname, "..", "deployment-spl.json");
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));

    console.log("\n💾 Deployment info saved to deployment-spl.json");

    console.log("\n Next Steps:");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("1. Update .env file:");
    console.log(`   SOLANA_MINT_ADDRESS=${mint.publicKey.toString()}`);
    console.log("\n2. Mint initial supply:");
    console.log("   ts-node scripts/mint-initial-supply.ts");
    console.log("\n3. Verify on Solana Explorer:");
    console.log(
      `   https://explorer.solana.com/address/${mint.publicKey.toString()}?cluster=${network}`
    );
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    console.log("✅ Deployment completed successfully!");
  } catch (error) {
    console.error("❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
