// Simple test runner for VelirionToken
import hre from "hardhat";
import { expect } from "chai";

async function main() {
  console.log("🧪 Running VelirionToken Tests...\n");

  console.log("Available in hre:", Object.keys(hre));
  
  // Import ethers directly
  const { ethers } = await import("ethers");
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  
  let token, owner, addr1, addr2;
  const INITIAL_SUPPLY = ethers.parseEther("100000000");
  
  // Get signers
  [owner, addr1, addr2] = await ethers.getSigners();
  
  // Deploy contract
  console.log("📦 Deploying VelirionToken...");
  const VelirionToken = await ethers.getContractFactory("VelirionToken");
  token = await VelirionToken.deploy();
  await token.waitForDeployment();
  console.log("✅ Contract deployed\n");

  let passed = 0;
  let failed = 0;

  // Test 1: Name and Symbol
  try {
    const name = await token.name();
    const symbol = await token.symbol();
    expect(name).to.equal("Velirion");
    expect(symbol).to.equal("VLR");
    console.log("✅ Test 1: Correct name and symbol");
    passed++;
  } catch (e) {
    console.log("❌ Test 1 FAILED:", e.message);
    failed++;
  }

  // Test 2: Decimals
  try {
    const decimals = await token.decimals();
    expect(decimals).to.equal(18n);
    console.log("✅ Test 2: Correct decimals (18)");
    passed++;
  } catch (e) {
    console.log("❌ Test 2 FAILED:", e.message);
    failed++;
  }

  // Test 3: Initial Supply
  try {
    const totalSupply = await token.totalSupply();
    expect(totalSupply).to.equal(INITIAL_SUPPLY);
    console.log("✅ Test 3: Correct initial supply (100M)");
    passed++;
  } catch (e) {
    console.log("❌ Test 3 FAILED:", e.message);
    failed++;
  }

  // Test 4: Owner Balance
  try {
    const ownerBalance = await token.balanceOf(owner.address);
    expect(ownerBalance).to.equal(INITIAL_SUPPLY);
    console.log("✅ Test 4: Owner has all initial supply");
    passed++;
  } catch (e) {
    console.log("❌ Test 4 FAILED:", e.message);
    failed++;
  }

  // Test 5: Transfer
  try {
    const amount = ethers.parseEther("1000");
    await token.transfer(addr1.address, amount);
    const balance = await token.balanceOf(addr1.address);
    expect(balance).to.equal(amount);
    console.log("✅ Test 5: Transfer works correctly");
    passed++;
  } catch (e) {
    console.log("❌ Test 5 FAILED:", e.message);
    failed++;
  }

  // Test 6: Allocate
  try {
    const amount = ethers.parseEther("5000");
    await token.allocate("presale", addr2.address, amount);
    const balance = await token.balanceOf(addr2.address);
    expect(balance).to.equal(amount);
    const allocation = await token.getAllocation("presale");
    expect(allocation).to.equal(amount);
    console.log("✅ Test 6: Allocate function works");
    passed++;
  } catch (e) {
    console.log("❌ Test 6 FAILED:", e.message);
    failed++;
  }

  // Test 7: Burn
  try {
    const burnAmount = ethers.parseEther("100");
    const balanceBefore = await token.balanceOf(owner.address);
    await token.burn(burnAmount);
    const balanceAfter = await token.balanceOf(owner.address);
    expect(balanceAfter).to.equal(balanceBefore - burnAmount);
    console.log("✅ Test 7: Burn function works");
    passed++;
  } catch (e) {
    console.log("❌ Test 7 FAILED:", e.message);
    failed++;
  }

  // Test 8: Pause/Unpause
  try {
    await token.pause();
    let paused = await token.paused();
    expect(paused).to.be.true;
    
    await token.unpause();
    paused = await token.paused();
    expect(paused).to.be.false;
    console.log("✅ Test 8: Pause/Unpause works");
    passed++;
  } catch (e) {
    console.log("❌ Test 8 FAILED:", e.message);
    failed++;
  }

  // Test 9: Transfer blocked when paused
  try {
    await token.pause();
    let errorThrown = false;
    try {
      await token.transfer(addr1.address, ethers.parseEther("10"));
    } catch {
      errorThrown = true;
    }
    await token.unpause();
    expect(errorThrown).to.be.true;
    console.log("✅ Test 9: Transfers blocked when paused");
    passed++;
  } catch (e) {
    console.log("❌ Test 9 FAILED:", e.message);
    failed++;
  }

  // Test 10: Only owner can allocate
  try {
    let errorThrown = false;
    try {
      await token.connect(addr1).allocate("test", addr2.address, ethers.parseEther("100"));
    } catch {
      errorThrown = true;
    }
    expect(errorThrown).to.be.true;
    console.log("✅ Test 10: Only owner can allocate");
    passed++;
  } catch (e) {
    console.log("❌ Test 10 FAILED:", e.message);
    failed++;
  }

  // Summary
  console.log("\n" + "=".repeat(50));
  console.log(`Test Results: ${passed} passed, ${failed} failed`);
  console.log("=".repeat(50));

  if (failed === 0) {
    console.log("\n🎉 All tests passed!");
    process.exit(0);
  } else {
    console.log(`\n❌ ${failed} test(s) failed`);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
