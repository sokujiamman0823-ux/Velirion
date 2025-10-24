const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time, mine } = require("@nomicfoundation/hardhat-network-helpers");

describe("VelirionDAO Governance", function () {
    let vlrToken;
    let timelock;
    let dao;
    let treasury;
    let stakingContract;
    let owner, proposer, voter1, voter2, voter3;
    let marketingWallet, teamWallet, liquidityWallet;

    const PROPOSAL_THRESHOLD = ethers.utils.parseEther("10000"); // 10K VLR
    const QUORUM_VOTES = ethers.utils.parseEther("100000"); // 100K VLR
    const VOTING_DELAY = 1 * 24 * 60 * 60; // 1 day in seconds
    const VOTING_PERIOD = 7 * 24 * 60 * 60; // 7 days in seconds
    const TIMELOCK_DELAY = 2 * 24 * 60 * 60; // 2 days in seconds
    const VOTING_DELAY_BLOCKS = Math.floor(VOTING_DELAY / 12); // ~7200 blocks
    const VOTING_PERIOD_BLOCKS = Math.floor(VOTING_PERIOD / 12); // ~50400 blocks

    beforeEach(async function () {
        [owner, proposer, voter1, voter2, voter3, marketingWallet, teamWallet, liquidityWallet] = 
            await ethers.getSigners();

        // Deploy VLR Token
        const VelirionToken = await ethers.getContractFactory("VelirionToken");
        vlrToken = await VelirionToken.deploy();
        await vlrToken.deployed();

        // Deploy Timelock
        const VelirionTimelock = await ethers.getContractFactory("VelirionTimelock");
        timelock = await VelirionTimelock.deploy(owner.address);
        await timelock.deployed();

        // Deploy DAO
        const VelirionDAO = await ethers.getContractFactory("VelirionDAO");
        dao = await VelirionDAO.deploy(
            vlrToken.address,
            timelock.address,
            owner.address
        );
        await dao.deployed();

        // Deploy Treasury
        const VelirionTreasury = await ethers.getContractFactory("VelirionTreasury");
        treasury = await VelirionTreasury.deploy(
            vlrToken.address,
            marketingWallet.address,
            teamWallet.address,
            liquidityWallet.address,
            owner.address
        );
        await treasury.deployed();

        // Configure Treasury - set Timelock as DAO contract since it executes proposals
        await treasury.setDAOContract(timelock.address);

        // Transfer Timelock ownership to DAO
        await timelock.transferOwnership(dao.address);

        // Distribute tokens for testing
        const totalSupply = await vlrToken.totalSupply();
        await vlrToken.transfer(proposer.address, ethers.utils.parseEther("50000"));
        await vlrToken.transfer(voter1.address, ethers.utils.parseEther("150000"));
        await vlrToken.transfer(voter2.address, ethers.utils.parseEther("100000"));
        await vlrToken.transfer(voter3.address, ethers.utils.parseEther("50000"));
        await vlrToken.transfer(treasury.address, ethers.utils.parseEther("5000000")); // 5M for treasury

        // Approve DAO to burn tokens
        await vlrToken.connect(proposer).approve(dao.address, ethers.constants.MaxUint256);
        await vlrToken.connect(voter1).approve(dao.address, ethers.constants.MaxUint256);
        await vlrToken.connect(voter2).approve(dao.address, ethers.constants.MaxUint256);
        await vlrToken.connect(voter3).approve(dao.address, ethers.constants.MaxUint256);
    });

    describe("Deployment", function () {
        it("Should set correct initial parameters", async function () {
            expect(await dao.PROPOSAL_THRESHOLD()).to.equal(PROPOSAL_THRESHOLD);
            expect(await dao.QUORUM_VOTES()).to.equal(QUORUM_VOTES);
            expect(await dao.VOTING_PERIOD()).to.equal(VOTING_PERIOD);
            expect(await dao.VOTING_DELAY()).to.equal(VOTING_DELAY);
        });

        it("Should have correct token and timelock addresses", async function () {
            expect(await dao.vlrToken()).to.equal(vlrToken.address);
            expect(await dao.timelock()).to.equal(timelock.address);
        });

        it("Should start with zero proposals", async function () {
            expect(await dao.proposalCount()).to.equal(0);
        });
    });

    describe("Proposal Creation", function () {
        it("Should create proposal with sufficient tokens", async function () {
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [
                treasury.interface.encodeFunctionData("allocateFunds", [
                    marketingWallet.address,
                    ethers.utils.parseEther("1000"),
                    "Marketing campaign"
                ])
            ];
            const description = "Allocate 1000 VLR for marketing";

            const proposerBalanceBefore = await vlrToken.balanceOf(proposer.address);

            await expect(
                dao.connect(proposer).propose(targets, values, calldatas, description)
            ).to.emit(dao, "ProposalCreated");

            expect(await dao.proposalCount()).to.equal(1);

            // Check tokens were burned
            const proposerBalanceAfter = await vlrToken.balanceOf(proposer.address);
            expect(proposerBalanceBefore.sub(proposerBalanceAfter)).to.equal(PROPOSAL_THRESHOLD);
        });

        it("Should fail to create proposal without sufficient tokens", async function () {
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("allocateFunds", [
                marketingWallet.address,
                ethers.utils.parseEther("1000"),
                "Test"
            ])];

            // Try with account that has no tokens
            const [, , , , , newAccount] = await ethers.getSigners();
            await vlrToken.connect(newAccount).approve(dao.address, ethers.constants.MaxUint256);

            await expect(
                dao.connect(newAccount).propose(targets, values, calldatas, "Test")
            ).to.be.reverted;
        });

        it("Should fail with invalid proposal data", async function () {
            await expect(
                dao.connect(proposer).propose([], [], [], "Empty proposal")
            ).to.be.revertedWithCustomError(dao, "InvalidProposalData");
        });

        it("Should fail with mismatched array lengths", async function () {
            const targets = [treasury.address];
            const values = [0, 0]; // Mismatched length
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];

            await expect(
                dao.connect(proposer).propose(targets, values, calldatas, "Test")
            ).to.be.revertedWithCustomError(dao, "InvalidProposalData");
        });
    });

    describe("Voting", function () {
        let proposalId;

        beforeEach(async function () {
            // Create a proposal
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [
                treasury.interface.encodeFunctionData("allocateFunds", [
                    marketingWallet.address,
                    ethers.utils.parseEther("1000"),
                    "Marketing"
                ])
            ];

            await dao.connect(proposer).propose(targets, values, calldatas, "Test Proposal");
            proposalId = await dao.proposalCount();

            // Mine blocks past voting delay
            await mine(VOTING_DELAY_BLOCKS + 1);
        });

        it("Should allow voting with token burn", async function () {
            const burnAmount = ethers.utils.parseEther("50000");
            const voter1BalanceBefore = await vlrToken.balanceOf(voter1.address);

            await expect(
                dao.connect(voter1).castVote(proposalId, 1, burnAmount, "I support this")
            ).to.emit(dao, "VoteCast");

            // Check tokens were burned
            const voter1BalanceAfter = await vlrToken.balanceOf(voter1.address);
            expect(voter1BalanceBefore.sub(voter1BalanceAfter)).to.equal(burnAmount);

            // Check vote was recorded
            const receipt = await dao.getReceipt(proposalId, voter1.address);
            expect(receipt.hasVoted).to.be.true;
            expect(receipt.support).to.equal(1);
            expect(receipt.burnedAmount).to.equal(burnAmount);
        });

        it("Should calculate voting power correctly (1x without staking)", async function () {
            const burnAmount = ethers.utils.parseEther("50000");
            
            await dao.connect(voter1).castVote(proposalId, 1, burnAmount, "");

            const receipt = await dao.getReceipt(proposalId, voter1.address);
            expect(receipt.votes).to.equal(burnAmount); // 1x multiplier
        });

        it("Should prevent double voting", async function () {
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("50000"), "");

            await expect(
                dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("10000"), "")
            ).to.be.revertedWithCustomError(dao, "AlreadyVoted");
        });

        it("Should allow voting against", async function () {
            await dao.connect(voter1).castVote(proposalId, 0, ethers.utils.parseEther("50000"), "Against");

            const proposal = await dao.getProposal(proposalId);
            expect(proposal.againstVotes).to.equal(ethers.utils.parseEther("50000"));
        });

        it("Should allow abstain voting", async function () {
            await dao.connect(voter1).castVote(proposalId, 2, ethers.utils.parseEther("50000"), "Abstain");

            const proposal = await dao.getProposal(proposalId);
            expect(proposal.abstainVotes).to.equal(ethers.utils.parseEther("50000"));
        });

        it("Should fail voting on inactive proposal", async function () {
            // Try to vote before voting starts
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];
            
            await dao.connect(proposer).propose(targets, values, calldatas, "New Proposal");
            const newProposalId = await dao.proposalCount();

            await expect(
                dao.connect(voter1).castVote(newProposalId, 1, ethers.utils.parseEther("10000"), "")
            ).to.be.revertedWithCustomError(dao, "ProposalNotActive");
        });

        it("Should fail with invalid vote type", async function () {
            await expect(
                dao.connect(voter1).castVote(proposalId, 3, ethers.utils.parseEther("10000"), "")
            ).to.be.revertedWithCustomError(dao, "InvalidVoteType");
        });
    });

    describe("Proposal States", function () {
        let proposalId;

        beforeEach(async function () {
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];
            
            await dao.connect(proposer).propose(targets, values, calldatas, "Test");
            proposalId = await dao.proposalCount();
        });

        it("Should be Pending initially", async function () {
            expect(await dao.state(proposalId)).to.equal(0); // Pending
        });

        it("Should be Active during voting period", async function () {
            await mine(VOTING_DELAY_BLOCKS + 1);
            expect(await dao.state(proposalId)).to.equal(1); // Active
        });

        it("Should be Defeated if not enough votes", async function () {
            await mine(VOTING_DELAY_BLOCKS + 1);
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("10000"), "");
            await mine(VOTING_PERIOD_BLOCKS + 1);
            
            expect(await dao.state(proposalId)).to.equal(2); // Defeated (no quorum)
        });

        it("Should be Succeeded if passed", async function () {
            await mine(VOTING_DELAY_BLOCKS + 1);
            
            // Vote with enough to reach quorum and pass
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("100000"), "");
            
            await mine(VOTING_PERIOD_BLOCKS + 1);
            
            expect(await dao.state(proposalId)).to.equal(3); // Succeeded
        });

        it("Should be Canceled if proposer cancels", async function () {
            await dao.connect(proposer).cancel(proposalId);
            expect(await dao.state(proposalId)).to.equal(6); // Canceled
        });
    });

    describe("Quorum and Success", function () {
        let proposalId;

        beforeEach(async function () {
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];
            
            await dao.connect(proposer).propose(targets, values, calldatas, "Test");
            proposalId = await dao.proposalCount();
            await mine(VOTING_DELAY_BLOCKS + 1);
        });

        it("Should reach quorum with 100K votes", async function () {
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("100000"), "");
            expect(await dao.quorumReached(proposalId)).to.be.true;
        });

        it("Should not reach quorum with less than 100K votes", async function () {
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("50000"), "");
            expect(await dao.quorumReached(proposalId)).to.be.false;
        });

        it("Should succeed if for votes > against votes", async function () {
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("80000"), "");
            await dao.connect(voter2).castVote(proposalId, 0, ethers.utils.parseEther("30000"), "");
            
            expect(await dao.quorumReached(proposalId)).to.be.true;
            expect(await dao.proposalSucceeded(proposalId)).to.be.true;
        });

        it("Should fail if against votes >= for votes", async function () {
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("50000"), "");
            await dao.connect(voter2).castVote(proposalId, 0, ethers.utils.parseEther("60000"), "");
            
            expect(await dao.quorumReached(proposalId)).to.be.true;
            expect(await dao.proposalSucceeded(proposalId)).to.be.false;
        });
    });

    describe("Proposal Execution", function () {
        let proposalId;

        beforeEach(async function () {
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [
                treasury.interface.encodeFunctionData("allocateFunds", [
                    marketingWallet.address,
                    ethers.utils.parseEther("1000"),
                    "Marketing"
                ])
            ];
            
            await dao.connect(proposer).propose(targets, values, calldatas, "Allocate funds");
            proposalId = await dao.proposalCount();
            
            // Vote and pass proposal
            await mine(VOTING_DELAY_BLOCKS + 1);
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("100000"), "");
            await mine(VOTING_PERIOD_BLOCKS + 1);
        });

        it("Should queue successful proposal", async function () {
            await expect(dao.queue(proposalId))
                .to.emit(dao, "ProposalQueued");
            
            expect(await dao.state(proposalId)).to.equal(4); // Queued
        });

        it("Should execute proposal after timelock", async function () {
            await dao.queue(proposalId);
            await time.increase(TIMELOCK_DELAY + 1);

            const marketingBalanceBefore = await vlrToken.balanceOf(marketingWallet.address);

            await expect(dao.execute(proposalId))
                .to.emit(dao, "ProposalExecuted");

            const marketingBalanceAfter = await vlrToken.balanceOf(marketingWallet.address);
            expect(marketingBalanceAfter.sub(marketingBalanceBefore)).to.equal(ethers.utils.parseEther("1000"));

            expect(await dao.state(proposalId)).to.equal(5); // Executed
        });

        it("Should fail to execute before timelock", async function () {
            await dao.queue(proposalId);

            await expect(dao.execute(proposalId))
                .to.be.revertedWithCustomError(timelock, "TimelockNotMet");
        });

        it("Should fail to queue defeated proposal", async function () {
            // Create new proposal that will be defeated
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];
            
            await dao.connect(proposer).propose(targets, values, calldatas, "Will fail");
            const newProposalId = await dao.proposalCount();
            
            await mine(VOTING_DELAY_BLOCKS + 1);
            await dao.connect(voter1).castVote(newProposalId, 1, ethers.utils.parseEther("10000"), "");
            await mine(VOTING_PERIOD_BLOCKS + 1);

            await expect(dao.queue(newProposalId))
                .to.be.revertedWithCustomError(dao, "ProposalNotSucceeded");
        });
    });

    describe("Proposal Cancellation", function () {
        let proposalId;

        beforeEach(async function () {
            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];
            
            await dao.connect(proposer).propose(targets, values, calldatas, "Test");
            proposalId = await dao.proposalCount();
        });

        it("Should allow proposer to cancel", async function () {
            await expect(dao.connect(proposer).cancel(proposalId))
                .to.emit(dao, "ProposalCanceled");
            
            expect(await dao.state(proposalId)).to.equal(6); // Canceled
        });

        it("Should fail if not proposer", async function () {
            await expect(dao.connect(voter1).cancel(proposalId))
                .to.be.revertedWithCustomError(dao, "OnlyProposer");
        });

        it("Should fail to cancel executed proposal", async function () {
            await mine(VOTING_DELAY_BLOCKS + 1);
            await dao.connect(voter1).castVote(proposalId, 1, ethers.utils.parseEther("100000"), "");
            await mine(VOTING_PERIOD_BLOCKS + 1);
            await dao.queue(proposalId);
            await time.increase(TIMELOCK_DELAY + 1);
            await dao.execute(proposalId);

            await expect(dao.connect(proposer).cancel(proposalId))
                .to.be.revertedWithCustomError(dao, "ProposalAlreadyExecuted");
        });
    });

    describe("Admin Functions", function () {
        it("Should allow owner to pause", async function () {
            await dao.pause();
            expect(await dao.paused()).to.be.true;
        });

        it("Should prevent proposals when paused", async function () {
            await dao.pause();

            const targets = [treasury.address];
            const values = [0];
            const calldatas = [treasury.interface.encodeFunctionData("getTreasuryBalance", [])];

            await expect(
                dao.connect(proposer).propose(targets, values, calldatas, "Test")
            ).to.be.revertedWithCustomError(dao, "EnforcedPause");
        });

        it("Should allow owner to unpause", async function () {
            await dao.pause();
            await dao.unpause();
            expect(await dao.paused()).to.be.false;
        });
    });
});
