const anchor = require("@coral-xyz/anchor");
const { Keypair } = require("@solana/web3.js");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🪙 Initializing Velirion SPL Token Mint...\n");

  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);
  const program = anchor.workspace.VelirionSpl;

  console.log("Program ID:", program.programId.toString());
  console.log("Deployer:", provider.wallet.publicKey.toString(), "\n");

  const mint = Keypair.generate();
  const decimals = 9;

  console.log("Mint Address:", mint.publicKey.toString(), "\n");

  const balance = await provider.connection.getBalance(provider.wallet.publicKey);
  console.log("Balance:", balance / 1e9, "SOL\n");

  console.log("⏳ Initializing...");

  const tx = await program.methods
    .initialize(decimals)
    .accounts({
      mint: mint.publicKey,
      mintAuthority: provider.wallet.publicKey,
      payer: provider.wallet.publicKey,
    })
    .signers([mint])
    .rpc();

  console.log("✅ Success! TX:", tx);

  const mintInfo = await provider.connection.getAccountInfo(mint.publicKey);
  if (!mintInfo) throw new Error("Mint not created!");

  const info = {
    network: "devnet",
    programId: program.programId.toString(),
    mintAddress: mint.publicKey.toString(),
    mintAuthority: provider.wallet.publicKey.toString(),
    decimals,
    timestamp: new Date().toISOString(),
    tx,
  };

  fs.writeFileSync("deployment-spl.json", JSON.stringify(info, null, 2));
  console.log("\n💾 Saved to deployment-spl.json");
  console.log("\nExplorer:", `https://explorer.solana.com/address/${mint.publicKey.toString()}?cluster=devnet`);
}

main().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
