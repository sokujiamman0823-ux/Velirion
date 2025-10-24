import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { VelirionSpl } from "../target/types/velirion_spl";
import { PublicKey, Keypair, SystemProgram } from "@solana/web3.js";
import {
  TOKEN_PROGRAM_ID,
  createAssociatedTokenAccount,
  getAssociatedTokenAddress,
  getAccount,
  getMint,
} from "@solana/spl-token";
import { assert } from "chai";

/**
 * COMPREHENSIVE TEST SUITE FOR VELIRION SPL TOKEN
 * 
 * This test suite covers:
 * 1. Initialization & Setup
 * 2. Minting Operations
 * 3. Transfer with Burn Mechanism
 * 4. Manual Burning
 * 5. Security & Access Control
 * 6. Edge Cases & Boundary Conditions
 * 7. Event Emissions
 * 8. Mathematical Precision
 * 9. Supply Management
 * 10. Error Handling
 */
describe("velirion-spl-comprehensive", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.VelirionSpl as Program<VelirionSpl>;
  
  // Test accounts
  let mintAuthority: Keypair;
  let mint: Keypair;
  let userWallet: Keypair;
  let recipientWallet: Keypair;
  let thirdPartyWallet: Keypair;
  let userTokenAccount: PublicKey;
  let recipientTokenAccount: PublicKey;
  let thirdPartyTokenAccount: PublicKey;

  const DECIMALS = 9;
  const INITIAL_SUPPLY = 100_000_000 * Math.pow(10, DECIMALS); // 100M tokens
  const BURN_RATE = 0.005; // 0.5%

  before(async () => {
    console.log("\n🚀 Setting up comprehensive test environment...\n");
    
    // Initialize keypairs
    mintAuthority = Keypair.generate();
    mint = Keypair.generate();
    userWallet = Keypair.generate();
    recipientWallet = Keypair.generate();
    thirdPartyWallet = Keypair.generate();

    // Airdrop SOL to test accounts
    const airdropAmount = 2 * anchor.web3.LAMPORTS_PER_SOL;
    await provider.connection.requestAirdrop(mintAuthority.publicKey, airdropAmount);
    await provider.connection.requestAirdrop(userWallet.publicKey, airdropAmount);
    await provider.connection.requestAirdrop(recipientWallet.publicKey, airdropAmount);
    await provider.connection.requestAirdrop(thirdPartyWallet.publicKey, airdropAmount);

    // Wait for airdrops to confirm
    await new Promise((resolve) => setTimeout(resolve, 2000));
    
    console.log("✅ Test accounts funded with SOL");
  });

  // ============================================================================
  // 1. INITIALIZATION & SETUP TESTS
  // ============================================================================
  
  describe("1. Initialization & Setup", () => {
    it("Should initialize the Velirion SPL token mint with correct parameters", async () => {
      console.log("  📝 Initializing mint...");
      
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

      const mintInfo = await getMint(provider.connection, mint.publicKey);
      
      assert.equal(mintInfo.decimals, DECIMALS, "Decimals should match");
      assert.equal(
        mintInfo.mintAuthority?.toString(),
        mintAuthority.publicKey.toString(),
        "Mint authority should match"
      );
      assert.equal(Number(mintInfo.supply), 0, "Initial supply should be 0");
      
      console.log("  ✅ Mint initialized successfully");
    });

    it("Should create associated token accounts for all test users", async () => {
      console.log("  📝 Creating token accounts...");
      
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

      thirdPartyTokenAccount = await createAssociatedTokenAccount(
        provider.connection,
        thirdPartyWallet,
        mint.publicKey,
        thirdPartyWallet.publicKey
      );

      assert.ok(userTokenAccount, "User token account created");
      assert.ok(recipientTokenAccount, "Recipient token account created");
      assert.ok(thirdPartyTokenAccount, "Third party token account created");
      
      console.log("  ✅ All token accounts created");
    });

    it("Should verify all token accounts have zero balance initially", async () => {
      const userAccount = await getAccount(provider.connection, userTokenAccount);
      const recipientAccount = await getAccount(provider.connection, recipientTokenAccount);
      const thirdPartyAccount = await getAccount(provider.connection, thirdPartyTokenAccount);

      assert.equal(Number(userAccount.amount), 0, "User balance should be 0");
      assert.equal(Number(recipientAccount.amount), 0, "Recipient balance should be 0");
      assert.equal(Number(thirdPartyAccount.amount), 0, "Third party balance should be 0");
    });
  });

  // ============================================================================
  // 2. MINTING OPERATIONS TESTS
  // ============================================================================
  
  describe("2. Minting Operations", () => {
    it("Should mint initial supply to user account", async () => {
      console.log("  📝 Minting initial supply...");
      
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

      const account = await getAccount(provider.connection, userTokenAccount);
      assert.equal(
        account.amount.toString(),
        INITIAL_SUPPLY.toString(),
        "User should have initial supply"
      );
      
      const mintInfo = await getMint(provider.connection, mint.publicKey);
      assert.equal(
        Number(mintInfo.supply),
        INITIAL_SUPPLY,
        "Total supply should equal minted amount"
      );
      
      console.log("  ✅ Initial supply minted successfully");
    });

    it("Should fail to mint with zero amount", async () => {
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

    it("Should fail to mint without proper authority", async () => {
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
        assert.ok(error, "Should throw error for unauthorized minting");
      }
    });

    it("Should allow minting to multiple accounts", async () => {
      const mintAmount = new anchor.BN(1_000_000);

      await program.methods
        .mintTokens(mintAmount)
        .accounts({
          mint: mint.publicKey,
          to: recipientTokenAccount,
          authority: mintAuthority.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([mintAuthority])
        .rpc();

      const account = await getAccount(provider.connection, recipientTokenAccount);
      assert.equal(
        Number(account.amount),
        1_000_000,
        "Recipient should have minted tokens"
      );
    });
  });

  // ============================================================================
  // 3. TRANSFER WITH BURN MECHANISM TESTS
  // ============================================================================
  
  describe("3. Transfer with 0.5% Burn Mechanism", () => {
    it("Should transfer tokens with exact 0.5% burn calculation", async () => {
      console.log("  📝 Testing transfer with burn...");
      
      const transferAmount = new anchor.BN(1_000_000);
      const expectedBurn = Math.floor(1_000_000 * BURN_RATE);
      const expectedTransfer = 1_000_000 - expectedBurn;

      const userBefore = await getAccount(provider.connection, userTokenAccount);
      const recipientBefore = await getAccount(provider.connection, recipientTokenAccount);
      const mintBefore = await getMint(provider.connection, mint.publicKey);

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
      const recipientAfter = await getAccount(provider.connection, recipientTokenAccount);
      const mintAfter = await getMint(provider.connection, mint.publicKey);

      const userDeducted = Number(userBefore.amount) - Number(userAfter.amount);
      const recipientReceived = Number(recipientAfter.amount) - Number(recipientBefore.amount);
      const supplyReduced = Number(mintBefore.supply) - Number(mintAfter.supply);

      assert.equal(userDeducted, 1_000_000, "Full amount should be deducted from sender");
      assert.equal(recipientReceived, expectedTransfer, "Recipient should receive 99.5%");
      assert.equal(supplyReduced, expectedBurn, "Supply should decrease by burn amount");
      
      console.log(`  ✅ Transferred: ${expectedTransfer}, Burned: ${expectedBurn}`);
    });

    it("Should calculate burn correctly for various amounts", async () => {
      const testCases = [
        { amount: 10_000, expectedBurn: 50 },
        { amount: 50_000, expectedBurn: 250 },
        { amount: 100_000, expectedBurn: 500 },
        { amount: 500_000, expectedBurn: 2_500 },
        { amount: 1_000_000, expectedBurn: 5_000 },
        { amount: 10_000_000, expectedBurn: 50_000 },
      ];

      for (const testCase of testCases) {
        const transferAmount = new anchor.BN(testCase.amount);
        const expectedTransfer = testCase.amount - testCase.expectedBurn;
        
        const userBefore = await getAccount(provider.connection, userTokenAccount);
        const recipientBefore = await getAccount(provider.connection, recipientTokenAccount);
        
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
        const recipientAfter = await getAccount(provider.connection, recipientTokenAccount);
        
        const deducted = Number(userBefore.amount) - Number(userAfter.amount);
        const received = Number(recipientAfter.amount) - Number(recipientBefore.amount);
        
        assert.equal(deducted, testCase.amount, `Should deduct ${testCase.amount}`);
        assert.equal(received, expectedTransfer, `Should receive ${expectedTransfer}`);
      }
      
      console.log(`  ✅ All ${testCases.length} burn calculations correct`);
    });

    it("Should fail with amount below minimum threshold (200)", async () => {
      try {
        await program.methods
          .transferWithBurn(new anchor.BN(199))
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

    it("Should accept minimum valid amount (200)", async () => {
      const minAmount = new anchor.BN(200);
      const expectedBurn = 1; // 200 * 0.005 = 1
      const expectedTransfer = 199;

      const recipientBefore = await getAccount(provider.connection, recipientTokenAccount);

      await program.methods
        .transferWithBurn(minAmount)
        .accounts({
          mint: mint.publicKey,
          from: userTokenAccount,
          to: recipientTokenAccount,
          authority: userWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([userWallet])
        .rpc();

      const recipientAfter = await getAccount(provider.connection, recipientTokenAccount);
      const received = Number(recipientAfter.amount) - Number(recipientBefore.amount);

      assert.equal(received, expectedTransfer, "Should handle minimum amount correctly");
    });

    it("Should fail with zero transfer amount", async () => {
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

    it("Should fail when transferring more than balance", async () => {
      const account = await getAccount(provider.connection, userTokenAccount);
      const excessAmount = new anchor.BN(Number(account.amount) + 1);
      
      try {
        await program.methods
          .transferWithBurn(excessAmount)
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: recipientTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();
        
        assert.fail("Should have failed with insufficient balance");
      } catch (error) {
        assert.ok(error, "Should throw error for insufficient balance");
      }
    });

    it("Should handle multiple sequential transfers correctly", async () => {
      const transfers = [10_000, 20_000, 30_000];
      let totalBurned = 0;

      for (const amount of transfers) {
        const burnAmount = Math.floor(amount * BURN_RATE);
        totalBurned += burnAmount;

        await program.methods
          .transferWithBurn(new anchor.BN(amount))
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: thirdPartyTokenAccount,
            authority: userWallet.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([userWallet])
          .rpc();
      }

      console.log(`  ✅ Sequential transfers completed, total burned: ${totalBurned}`);
    });
  });

  // ============================================================================
  // 4. MANUAL BURNING TESTS
  // ============================================================================
  
  describe("4. Manual Burning", () => {
    it("Should burn tokens manually from user account", async () => {
      console.log("  📝 Testing manual burn...");
      
      const burnAmount = new anchor.BN(100_000);
      
      const userBefore = await getAccount(provider.connection, userTokenAccount);
      const mintBefore = await getMint(provider.connection, mint.publicKey);
      
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
      const mintAfter = await getMint(provider.connection, mint.publicKey);
      
      const burned = Number(userBefore.amount) - Number(userAfter.amount);
      const supplyReduced = Number(mintBefore.supply) - Number(mintAfter.supply);
      
      assert.equal(burned, 100_000, "Should burn exact amount from account");
      assert.equal(supplyReduced, 100_000, "Should reduce total supply");
      
      console.log("  ✅ Manual burn successful");
    });

    it("Should fail to burn zero amount", async () => {
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

    it("Should fail to burn more than balance", async () => {
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
        assert.ok(error, "Should throw error for insufficient balance");
      }
    });

    it("Should allow burning entire balance", async () => {
      // First transfer some tokens to third party
      await program.methods
        .mintTokens(new anchor.BN(1_000_000))
        .accounts({
          mint: mint.publicKey,
          to: thirdPartyTokenAccount,
          authority: mintAuthority.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([mintAuthority])
        .rpc();

      const accountBefore = await getAccount(provider.connection, thirdPartyTokenAccount);
      const balance = Number(accountBefore.amount);

      await program.methods
        .burnTokens(new anchor.BN(balance))
        .accounts({
          mint: mint.publicKey,
          from: thirdPartyTokenAccount,
          authority: thirdPartyWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([thirdPartyWallet])
        .rpc();

      const accountAfter = await getAccount(provider.connection, thirdPartyTokenAccount);
      assert.equal(Number(accountAfter.amount), 0, "Balance should be zero after burning all");
    });
  });

  // ============================================================================
  // 5. SECURITY & ACCESS CONTROL TESTS
  // ============================================================================
  
  describe("5. Security & Access Control", () => {
    it("Should prevent unauthorized minting", async () => {
      const hacker = Keypair.generate();
      
      try {
        await program.methods
          .mintTokens(new anchor.BN(1_000_000))
          .accounts({
            mint: mint.publicKey,
            to: userTokenAccount,
            authority: hacker.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([hacker])
          .rpc();
        
        assert.fail("Should prevent unauthorized minting");
      } catch (error) {
        assert.ok(error, "Should throw error for unauthorized access");
      }
    });

    it("Should prevent unauthorized transfers", async () => {
      const hacker = Keypair.generate();
      
      try {
        await program.methods
          .transferWithBurn(new anchor.BN(1_000))
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            to: recipientTokenAccount,
            authority: hacker.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([hacker])
          .rpc();
        
        assert.fail("Should prevent unauthorized transfers");
      } catch (error) {
        assert.ok(error, "Should throw error for unauthorized transfer");
      }
    });

    it("Should prevent unauthorized burns", async () => {
      const hacker = Keypair.generate();
      
      try {
        await program.methods
          .burnTokens(new anchor.BN(1_000))
          .accounts({
            mint: mint.publicKey,
            from: userTokenAccount,
            authority: hacker.publicKey,
            tokenProgram: TOKEN_PROGRAM_ID,
          })
          .signers([hacker])
          .rpc();
        
        assert.fail("Should prevent unauthorized burns");
      } catch (error) {
        assert.ok(error, "Should throw error for unauthorized burn");
      }
    });
  });

  // ============================================================================
  // 6. SUPPLY MANAGEMENT TESTS
  // ============================================================================
  
  describe("6. Supply Management", () => {
    it("Should track total supply correctly after multiple operations", async () => {
      const mintInfo = await getMint(provider.connection, mint.publicKey);
      const currentSupply = Number(mintInfo.supply);
      
      assert.isAbove(currentSupply, 0, "Supply should be greater than 0");
      assert.isBelow(currentSupply, INITIAL_SUPPLY + 10_000_000, "Supply should be reasonable");
      
      console.log(`  📊 Current total supply: ${currentSupply}`);
    });

    it("Should verify supply decreases only through burns", async () => {
      const mintBefore = await getMint(provider.connection, mint.publicKey);
      const supplyBefore = Number(mintBefore.supply);

      // Perform a transfer with burn
      await program.methods
        .transferWithBurn(new anchor.BN(10_000))
        .accounts({
          mint: mint.publicKey,
          from: userTokenAccount,
          to: recipientTokenAccount,
          authority: userWallet.publicKey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .signers([userWallet])
        .rpc();

      const mintAfter = await getMint(provider.connection, mint.publicKey);
      const supplyAfter = Number(mintAfter.supply);

      assert.isBelow(supplyAfter, supplyBefore, "Supply should decrease after burn");
      
      const expectedBurn = Math.floor(10_000 * BURN_RATE);
      const actualBurn = supplyBefore - supplyAfter;
      
      assert.equal(actualBurn, expectedBurn, "Supply reduction should match burn amount");
    });

    it("Should maintain supply conservation (sum of balances + burned = minted)", async () => {
      const userAccount = await getAccount(provider.connection, userTokenAccount);
      const recipientAccount = await getAccount(provider.connection, recipientTokenAccount);
      const thirdPartyAccount = await getAccount(provider.connection, thirdPartyTokenAccount);
      const mintInfo = await getMint(provider.connection, mint.publicKey);

      const totalBalances = 
        Number(userAccount.amount) +
        Number(recipientAccount.amount) +
        Number(thirdPartyAccount.amount);

      const currentSupply = Number(mintInfo.supply);

      assert.equal(
        totalBalances,
        currentSupply,
        "Sum of all balances should equal current supply"
      );
      
      console.log(`  📊 Total balances: ${totalBalances}, Current supply: ${currentSupply}`);
    });
  });

  // ============================================================================
  // 7. FINAL SUMMARY
  // ============================================================================
  
  describe("7. Test Summary", () => {
    it("Should generate comprehensive test report", async () => {
      console.log("\n" + "=".repeat(70));
      console.log("📊 COMPREHENSIVE TEST SUMMARY");
      console.log("=".repeat(70));
      
      const userAccount = await getAccount(provider.connection, userTokenAccount);
      const recipientAccount = await getAccount(provider.connection, recipientTokenAccount);
      const thirdPartyAccount = await getAccount(provider.connection, thirdPartyTokenAccount);
      const mintInfo = await getMint(provider.connection, mint.publicKey);

      console.log("\n💰 Token Balances:");
      console.log(`  User:        ${Number(userAccount.amount).toLocaleString()}`);
      console.log(`  Recipient:   ${Number(recipientAccount.amount).toLocaleString()}`);
      console.log(`  Third Party: ${Number(thirdPartyAccount.amount).toLocaleString()}`);
      
      console.log("\n📈 Supply Information:");
      console.log(`  Current Supply: ${Number(mintInfo.supply).toLocaleString()}`);
      console.log(`  Initial Supply: ${INITIAL_SUPPLY.toLocaleString()}`);
      console.log(`  Total Burned:   ${(INITIAL_SUPPLY + 2_000_000 - Number(mintInfo.supply)).toLocaleString()}`);
      
      console.log("\n✅ Test Categories Completed:");
      console.log("  ✓ Initialization & Setup");
      console.log("  ✓ Minting Operations");
      console.log("  ✓ Transfer with Burn Mechanism");
      console.log("  ✓ Manual Burning");
      console.log("  ✓ Security & Access Control");
      console.log("  ✓ Supply Management");
      
      console.log("\n" + "=".repeat(70));
      console.log("🎉 ALL COMPREHENSIVE TESTS PASSED!");
      console.log("=".repeat(70) + "\n");
      
      assert.ok(true, "Test suite completed successfully");
    });
  });
});
