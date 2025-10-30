const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

// Load deployment addresses
const deploymentPath = path.join(__dirname, "..", "deployment-sepolia.json");
const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

async function main() {
  console.log("\n🏛️  Testing DAO Governance\n");

  const [proposer] = await ethers.getSigners();
  console.log(`User: ${proposer.address}`);
  console.log(`\n⚠️  Note: Testnet has only one signer. Full DAO testing requires multiple wallets.\n`);

  // Get contract instances
  const DAO = await ethers.getContractAt("VelirionDAO", deployment.contracts.dao);
  const VLRToken = await ethers.getContractAt("VelirionToken", deployment.contracts.vlrToken);

  // Check balance
  const proposerBalance = await VLRToken.balanceOf(proposer.address);
  console.log(`Proposer VLR balance: ${ethers.utils.formatEther(proposerBalance)} VLR`);
  if (proposerBalance.lt(ethers.utils.parseEther("10000"))) {
    console.log("\n⚠️  Proposer should have at least 10,000 VLR to create proposals (burn required).\n");
    return;
  }

  // Display DAO parameters
  console.log("\n--- DAO Parameters ---");
  const votingPeriod = await DAO.VOTING_PERIOD();
  const quorumVotes = await DAO.QUORUM_VOTES();
  const proposalThreshold = await DAO.PROPOSAL_THRESHOLD();
  
  console.log(`Voting Period: ${votingPeriod.div(86400)} days`);
  console.log(`Quorum Votes: ${ethers.utils.formatEther(quorumVotes)} VLR`);
  console.log(`Proposal Threshold: ${ethers.utils.formatEther(proposalThreshold)} VLR\n`);

  // Test 1: Create a proposal
  console.log("--- Test 1: Create Proposal ---");
  const proposalDescription = "Test proposal: no-op call";
  console.log(`Creating proposal with description: "${proposalDescription}"...`);
  try {
    // Approve DAO to burn from proposer for proposal threshold
    console.log("Approving VLR for proposal burn...");
    let tx = await VLRToken.connect(proposer).approve(DAO.address, proposalThreshold);
    await tx.wait();
    console.log("✅ Approval set for proposal");

    // Create a minimal proposal (no external calls) by passing empty arrays is invalid.
    // Use a self-call to DAO with 0 value and empty calldata to act as a no-op.
    const targets = [DAO.address];
    const values = [0];
    const calldatas = ["0x"];

    tx = await DAO.connect(proposer).propose(targets, values, calldatas, proposalDescription);
    let receipt = await tx.wait();
    console.log(`✅ Proposal created! Tx: ${receipt.transactionHash}`);
    
    const proposalCount = await DAO.proposalCount();
    console.log(`Total proposals: ${proposalCount}`);
    
    // Get proposal details
    const proposalId = (await DAO.proposalCount()).toNumber();
    const proposal = await DAO.getProposal(proposalId);
    
    console.log(`\nProposal #${proposalId} Details:`);
    console.log(`  Proposer: ${proposal.proposer}`);
    console.log(`  Start Block: ${proposal.startBlock}`);
    console.log(`  End Block: ${proposal.endBlock}`);
    console.log(`  For Votes: ${ethers.utils.formatEther(proposal.forVotes)} VLR`);
    console.log(`  Against Votes: ${ethers.utils.formatEther(proposal.againstVotes)} VLR`);
    console.log(`  Executed: ${proposal.executed}`);
    console.log(`  Canceled: ${proposal.canceled}`);

    // Test 2: Vote on proposal
    console.log("\n--- Test 2: Vote on Proposal ---");
    console.log("Approving VLR for vote burn and voting FOR the proposal...");
    
    try {
      const voteBurn = ethers.utils.parseEther("100");
      let tx2 = await VLRToken.connect(proposer).approve(DAO.address, voteBurn);
      await tx2.wait();
      tx = await DAO.connect(proposer).castVote(proposalId, 1, voteBurn, "support"); // 1 = for
      receipt = await tx.wait();
      console.log(`✅ Vote cast! Tx: ${receipt.transactionHash}`);
      
      // Check updated vote counts
      const updatedProposal = await DAO.getProposal(proposalId);
      console.log(`\nUpdated Vote Counts:`);
      console.log(`  For: ${ethers.utils.formatEther(updatedProposal.forVotes)} VLR`);
      console.log(`  Against: ${ethers.utils.formatEther(updatedProposal.againstVotes)} VLR`);
      
      // Check voting receipt
      const receiptInfo = await DAO.getReceipt(proposalId, proposer.address);
      console.log(`  Proposer has voted: ${receiptInfo.hasVoted}`);
      
    } catch (error) {
      console.log(`❌ Voting failed: ${error.message}`);
    }

    // Test 3: Check proposal state
    console.log("\n--- Test 3: Check Proposal State ---");
    const state = await DAO.state(proposalId);
    const states = ["Pending", "Active", "Defeated", "Succeeded", "Queued", "Executed", "Canceled"];
    console.log(`Proposal State: ${states[state]}`);

    // Calculate if quorum is reached
    const totalVotes = updatedProposal.forVotes.add(updatedProposal.againstVotes).add(updatedProposal.abstainVotes);
    console.log(`\nQuorum Progress:`);
    console.log(`  Current Votes: ${ethers.utils.formatEther(totalVotes)} VLR`);
    console.log(`  Required: ${ethers.utils.formatEther(quorumVotes)} VLR`);
    const reached = await DAO.quorumReached(proposalId);
    console.log(`  Reached: ${reached}`);

    // Test 4: Try to execute (will fail if voting period not ended)
    console.log("\n--- Test 4: Execute Proposal ---");
    console.log("Note: Proposal can only be executed after voting period ends.");
    
    console.log("Note: Execution requires queuing via timelock after voting ends; skipping in this quick test.");

  } catch (error) {
    console.log(`❌ Proposal creation failed: ${error.message}`);
  }

  // Display all proposals
  console.log("\n--- All Proposals ---");
  const totalProposals = (await DAO.proposalCount()).toNumber();
  console.log(`Total Proposals: ${totalProposals}\n`);

  for (let i = 0; i < totalProposals && i < 5; i++) {
    const proposal = await DAO.getProposal(i);
    const state = await DAO.state(i);
    const states = ["Pending", "Active", "Defeated", "Succeeded", "Queued", "Executed", "Canceled"];
    
    console.log(`Proposal #${i}:`);
    console.log(`  Title: ${proposal.title}`);
    console.log(`  State: ${states[state]}`);
    console.log(`  For: ${ethers.utils.formatEther(proposal.forVotes)} | Against: ${ethers.utils.formatEther(proposal.againstVotes)}`);
    console.log();
  }

  console.log("✅ DAO governance tests completed!");
  console.log("\n💡 Next Steps:");
  console.log("   1. Wait for voting period to end");
  console.log("   2. Execute successful proposals");
  console.log("   3. Test proposal cancellation (if needed)\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
