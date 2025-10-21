import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { VelirionSpl } from "../target/types/velirion_spl";
import { PublicKey } from "@solana/web3.js";
import {
  TOKEN_PROGRAM_ID,
  createAssociatedTokenAccount,
  getAssociatedTokenAddress,
  getAccount,
} from "@solana/spl-token";
import * as fs from "fs";
import * as path from "path";

/**
 * Mint initial supply of Velirion tokens
 * Mints 100,000,000 VLR to the deployer's associated token account
 */
async function main() {
  console.log("🪙 Minting Velirion Initial Supply...\n");

  // Load deployment info
  const deploymentPath = path.join(__dirname, "..", "deployment-spl.json");
  
  if (!fs.existsSync(deploymentPath)) {
    console.error("❌ deployment-spl.json not found!");
    console.error("Please deploy the token first using: ts-node scripts/deploy.ts");
    process.exit(1);
  }

  const deploymentInfo = JSON.parse(fs.readFileSync(deploymentPath, "utf-8"));
  const mintAddress = new PublicKey(deploymentInfo.mintAddress);

  // Configure provider
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.VelirionSpl as Program<VelirionSpl>;

  console.log("📋 Minting Configuration:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Mint Address:", mintAddress.toString());
  console.log("Authority:", provider.wallet.publicKey.toString());
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Calculate initial supply (100M tokens with 9 decimals)
  const INITIAL_SUPPLY = 100_000_000 * Math.pow(10, 9);
  const mintAmount = new anchor.BN(INITIAL_SUPPLY);

  console.log("Initial Supply:", INITIAL_SUPPLY / Math.pow(10, 9), "VLR");

  try {
    // Get or create associated token account
    console.log("\n⏳ Creating associated token account...");
    
    const associatedTokenAccount = await getAssociatedTokenAddress(
      mintAddress,
      provider.wallet.publicKey
    );

    let tokenAccount;
    try {
      tokenAccount = await getAccount(provider.connection, associatedTokenAccount);
      console.log("✅ Token account already exists");
    } catch {
      tokenAccount = await createAssociatedTokenAccount(
        provider.connection,
        provider.wallet.payer,
        mintAddress,
        provider.wallet.publicKey
      );
      console.log("✅ Token account created:", associatedTokenAccount.toString());
    }

    // Mint tokens
    console.log("\n⏳ Minting initial supply...");
    
    const tx = await program.methods
      .mintTokens(mintAmount)
      .accounts({
        mint: mintAddress,
        to: associatedTokenAccount,
        authority: provider.wallet.publicKey,
        tokenProgram: TOKEN_PROGRAM_ID,
      })
      .rpc();

    console.log("✅ Tokens minted successfully!");
    console.log("Transaction signature:", tx);

    // Verify balance
    const account = await getAccount(provider.connection, associatedTokenAccount);
    const balance = Number(account.amount) / Math.pow(10, 9);

    console.log("\nToken Information:");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("Token Account:", associatedTokenAccount.toString());
    console.log("Balance:", balance.toLocaleString(), "VLR");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    // Update deployment info
    deploymentInfo.initialSupplyMinted = true;
    deploymentInfo.mintedAt = new Date().toISOString();
    deploymentInfo.mintTransaction = tx;
    deploymentInfo.tokenAccount = associatedTokenAccount.toString();
    
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));

    console.log("✅ Initial supply minted successfully!");
    console.log("\n Next Steps:");
    console.log("1. Allocate tokens to contracts");
    console.log("2. Test transfer with burn mechanism");
    console.log("3. Update PROJECT_TRACKER.md");
  } catch (error) {
    console.error("❌ Minting failed:");
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
