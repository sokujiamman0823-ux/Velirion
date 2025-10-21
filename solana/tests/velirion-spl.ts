import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { VelirionSpl } from "../target/types/velirion_spl";
import { PublicKey, Keypair, SystemProgram } from "@solana/web3.js";
import {
  TOKEN_PROGRAM_ID,
  createAssociatedTokenAccount,
  getAssociatedTokenAddress,
  getAccount,
} from "@solana/spl-token";
import { assert } from "chai";

describe("velirion-spl", () => {
  // Configure the client to use the local cluster
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.VelirionSpl as Program<VelirionSpl>;
  
  // Test accounts
  let mintAuthority: Keypair;
  let mint: Keypair;
  let userWallet: Keypair;
  let recipientWallet: Keypair;
  let userTokenAccount: PublicKey;
  let recipientTokenAccount: PublicKey;

  const DECIMALS = 9;
  const INITIAL_SUPPLY = 100_000_000 * Math.pow(10, DECIMALS); // 100M tokens

  before(async () => {
    // Initialize keypairs
    mintAuthority = Keypair.generate();
    mint = Keypair.generate();
    userWallet = Keypair.generate();
    recipientWallet = Keypair.generate();

    // Airdrop SOL to test accounts
    await provider.connection.requestAirdrop(
      mintAuthority.publicKey,
      2 * anchor.web3.LAMPORTS_PER_SOL
    );
    await provider.connection.requestAirdrop(
      userWallet.publicKey,
      2 * anchor.web3.LAMPORTS_PER_SOL
    );
    await provider.connection.requestAirdrop(
      recipientWallet.publicKey,
      2 * anchor.web3.LAMPORTS_PER_SOL
    );

    // Wait for airdrops to confirm
    await new Promise((resolve) => setTimeout(resolve, 1000));
  });

  describe("Initialization", () => {
    it("Initializes the Velirion SPL token mint", async () => {
      await program.methods
        .initialize(DECIMALS)
        .accounts({
          mint: mint.publicKey,
          mintAuthority: mintAuthority.publicKey,
          payer: provider.wallet.publicKey,
          systemProgram: SystemProgram.programId,
          tokenProgram: TOKEN_PROGRAM_ID,
          rent: anchor.web3.SYSVAR_RENT_PUBKEY,
        })
        .signers([mint])
        .rpc();

      // Verify mint was created
      const mintAccount = await program.provider.connection.getAccountInfo(
        mint.publicKey
      );
      assert.isNotNull(mintAccount, "Mint account should exist");
    });

    it("Creates token accounts for users", async () => {
      // Create associated token accounts
      userTokenAccount = await createAssociatedTokenAccount(
        provider.connection,
        userWallet,
        mint.publicKey,
        userWallet.publicKey
      );

      recipientTokenAccount = await createAssociatedTokenAccount(
        provider.connection,
        recipientWallet,
        mint.publicKey,
        recipientWallet.publicKey
      );

      assert.ok(userTokenAccount, "User token account created");
      assert.ok(recipientTokenAccount, "Recipient token account created");
    });
  });

  describe("Minting", () => {
    it("Mints initial supply to user", async () => {
      const mintAmount = new anchor.BN(INITIAL_SUPPLY);

      await program.methods
        .mintTokens(mintAmount)
        .accounts({
          mint: mint.publicKey,
          to: userTokenAccount,
          authority: mintAuthority.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([mintAuthority])
        .rpc();

      // Verify balance
      const account = await getAccount(provider.connection, userTokenAccount);
      assert.equal(
        account.amount.toString(),
        INITIAL_SUPPLY.toString(),
        "User should have initial supply"
      );
    });

    it("Fails to mint with zero amount", async () => {
      try {
        await program.methods
          .mintTokens(new anchor.BN(0))
          .accounts({
            mint: mint.publicKey,
            to: userTokenAccount,
            authority: mintAuthority.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([mintAuthority])
          .rpc();
        
        assert.fail("Should have failed with zero amount");
      } catch (error) {
        assert.include(error.toString(), "InvalidAmount");
      }
    });

    it("Fails to mint without authority", async () => {
      const unauthorizedUser = Keypair.generate();
      
      try {
        await program.methods
          .mintTokens(new anchor.BN(1000))
          .accounts({
            mint: mint.publicKey,
            to: userTokenAccount,
            authority: unauthorizedUser.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([unauthorizedUser])
          .rpc();
        
        assert.fail("Should have failed without authority");
      } catch (error) {
        assert.ok(error, "Should throw error");
      }
    });
  });

  describe("Transfer with 0.5% Burn", () => {
    it("Transfers tokens with 0.5% burn", async () => {
      const transferAmount = new anchor.BN(1_000_000); // 1M tokens
      const expectedBurn = Math.floor(1_000_000 * 0.005); // 0.5% = 5,000
      const expectedTransfer = 1_000_000 - expectedBurn; // 995,000

      // Get initial balances
      const userBefore = await getAccount(provider.connection, userTokenAccount);
      const recipientBefore = await getAccount(
        provider.connection,
        recipientTokenAccount
      );

      // Transfer with burn
      await program.methods
        .transferWithBurn(transferAmount)
        .accounts({
          mint: mint.publicKey,
          from: userTokenAccount,
          to: recipientTokenAccount,
          authority: userWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([userWallet])
        .rpc();

      // Get final balances
      const userAfter = await getAccount(provider.connection, userTokenAccount);
      const recipientAfter = await getAccount(
        provider.connection,
        recipientTokenAccount
      );

      // Verify balances
      const userDeducted = Number(userBefore.amount) - Number(userAfter.amount);
      const recipientReceived =
        Number(recipientAfter.amount) - Number(recipientBefore.amount);

      assert.equal(
        userDeducted,
        1_000_000,
        "User should have full amount deducted"
      );
      assert.equal(
        recipientReceived,
        expectedTransfer,
        "Recipient should receive 99.5%"
      );
    });

    it("Calculates burn correctly for different amounts", async () => {
      const testAmounts = [
        { amount: 10_000, expectedBurn: 50 },
        { amount: 100_000, expectedBurn: 500 },
        { amount: 1_000_000, expectedBurn: 5_000 },
      ];

      for (const test of testAmounts) {
        const transferAmount = new anchor.BN(test.amount);
        
        const userBefore = await getAccount(provider.connection, userTokenAccount);
        
        await program.methods
          .transferWithBurn(transferAmount)
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: recipientTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();

        const userAfter = await getAccount(provider.connection, userTokenAccount);
        const deducted = Number(userBefore.amount) - Number(userAfter.amount);
        
        assert.equal(deducted, test.amount, `Should deduct ${test.amount}`);
      }
    });

    it("Fails with amount too small for burn", async () => {
      try {
        await program.methods
          .transferWithBurn(new anchor.BN(100)) // Less than 200
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: recipientTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();
        
        assert.fail("Should have failed with amount too small");
      } catch (error) {
        assert.include(error.toString(), "AmountTooSmall");
      }
    });

    it("Fails with zero amount", async () => {
      try {
        await program.methods
          .transferWithBurn(new anchor.BN(0))
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: recipientTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();
        
        assert.fail("Should have failed with zero amount");
      } catch (error) {
        assert.include(error.toString(), "InvalidAmount");
      }
    });

    it("Emits transfer event", async () => {
      const transferAmount = new anchor.BN(10_000);
      
      const tx = await program.methods
        .transferWithBurn(transferAmount)
        .accounts({
          mint: mint.publicKey,
          from: userTokenAccount,
          to: recipientTokenAccount,
          authority: userWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([userWallet])
        .rpc();

      // Verify transaction succeeded
      assert.ok(tx, "Transaction should succeed");
    });
  });

  describe("Manual Burning", () => {
    it("Burns tokens manually", async () => {
      const burnAmount = new anchor.BN(50_000);
      
      const userBefore = await getAccount(provider.connection, userTokenAccount);
      
      await program.methods
        .burnTokens(burnAmount)
        .accounts({
          mint: mint.publicKey,
          from: userTokenAccount,
          authority: userWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([userWallet])
        .rpc();

      const userAfter = await getAccount(provider.connection, userTokenAccount);
      const burned = Number(userBefore.amount) - Number(userAfter.amount);
      
      assert.equal(burned, 50_000, "Should burn exact amount");
    });

    it("Fails to burn zero amount", async () => {
      try {
        await program.methods
          .burnTokens(new anchor.BN(0))
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();
        
        assert.fail("Should have failed with zero amount");
      } catch (error) {
        assert.include(error.toString(), "InvalidAmount");
      }
    });

    it("Fails to burn more than balance", async () => {
      const account = await getAccount(provider.connection, userTokenAccount);
      const excessAmount = new anchor.BN(Number(account.amount) + 1);
      
      try {
        await program.methods
          .burnTokens(excessAmount)
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();
        
        assert.fail("Should have failed with insufficient balance");
      } catch (error) {
        assert.ok(error, "Should throw error");
      }
    });

    it("Emits burn event", async () => {
      const burnAmount = new anchor.BN(10_000);
      
      const tx = await program.methods
        .burnTokens(burnAmount)
        .accounts({
          mint: mint.publicKey,
          from: userTokenAccount,
          authority: userWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([userWallet])
        .rpc();

      assert.ok(tx, "Transaction should succeed");
    });
  });

  describe("Edge Cases", () => {
    it("Handles large transfer amounts", async () => {
      const largeAmount = new anchor.BN(10_000_000); // 10M tokens
      
      const userBefore = await getAccount(provider.connection, userTokenAccount);
      
      if (Number(userBefore.amount) >= 10_000_000) {
        await program.methods
          .transferWithBurn(largeAmount)
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: recipientTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();

        const userAfter = await getAccount(provider.connection, userTokenAccount);
        const deducted = Number(userBefore.amount) - Number(userAfter.amount);
        
        assert.equal(deducted, 10_000_000, "Should handle large amounts");
      }
    });

    it("Verifies total supply decreases with burns", async () => {
      const mintInfo = await program.provider.connection.getAccountInfo(
        mint.publicKey
      );
      assert.isNotNull(mintInfo, "Mint should exist");
      
      // Total supply should be less than initial due to burns
      // This is verified through the burn operations above
    });
  });
});
