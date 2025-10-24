// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../interfaces/IVelirionDAO.sol";
import "../interfaces/IVelirionStaking.sol";
import "./VelirionTimelock.sol";

/**
 * @title VelirionDAO
 * @notice Decentralized governance with burn-to-vote mechanism
 * 
 * Key Features:
 * - Burn VLR tokens to gain voting power
 * - Staking multiplier: 1x (no stake), 2x (Long/Elite tier)
 * - Proposal threshold: 10,000 VLR burned to create proposal
 * - Voting period: 7 days
 * - Timelock: 2 days execution delay
 * - Quorum: 100,000 VLR total votes required
 * 
 * Governance Flow:
 * 1. User burns 10K+ VLR to create proposal
 * 2. 1-day delay before voting starts
 * 3. 7-day voting period (users burn VLR to vote)
 * 4. If passed, proposal queued in timelock
 * 5. After 2-day delay, proposal can be executed
 */
contract VelirionDAO is IVelirionDAO, Ownable, Pausable, ReentrancyGuard {
    // ============================================================================
    // Constants - Governance Parameters
    // ============================================================================

    uint256 public constant PROPOSAL_THRESHOLD = 10000 * 10**18;   // 10K VLR to propose
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant VOTING_DELAY = 1 days;
    uint256 public constant QUORUM_VOTES = 100000 * 10**18;        // 100K VLR quorum

    // Voting multipliers based on staking tier
    uint256 public constant NO_STAKE_MULTIPLIER = 1;               // 1x
    uint256 public constant LONG_STAKE_MULTIPLIER = 2;             // 2x
    uint256 public constant ELITE_STAKE_MULTIPLIER = 2;            // 2x

    // ============================================================================
    // State Variables
    // ============================================================================

    ERC20Burnable public immutable vlrToken;
    IVelirionStaking public stakingContract;
    VelirionTimelock public timelock;

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Receipt)) public receipts;
    mapping(uint256 => uint256) public proposalEta;  // Execution time after timelock

    // ============================================================================
    // Errors
    // ============================================================================

    error BelowProposalThreshold();
    error InvalidProposalData();
    error ProposalNotActive();
    error AlreadyVoted();
    error InvalidVoteType();
    error ProposalNotSucceeded();
    error ProposalNotQueued();
    error OnlyProposer();
    error ProposalAlreadyExecuted();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(
        address _vlrToken,
        address _timelock,
        address _admin
    ) Ownable(_admin) {
        vlrToken = ERC20Burnable(_vlrToken);
        timelock = VelirionTimelock(payable(_timelock));
    }

    // ============================================================================
    // Admin Functions
    // ============================================================================

    /**
     * @notice Set the staking contract address
     * @param _stakingContract Address of staking contract
     */
    function setStakingContract(address _stakingContract) external onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        stakingContract = IVelirionStaking(_stakingContract);
    }

    /**
     * @notice Pause the DAO (emergency only)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the DAO
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // ============================================================================
    // Core Governance Functions
    // ============================================================================

    /**
     * @notice Create a new governance proposal
     * @param targets Contract addresses to call
     * @param values ETH values to send with calls
     * @param calldatas Encoded function calls
     * @param description Proposal description
     * @return proposalId The ID of the created proposal
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external override whenNotPaused nonReentrant returns (uint256 proposalId) {
        // Validate proposal data
        if (
            targets.length == 0 ||
            targets.length != values.length ||
            targets.length != calldatas.length
        ) revert InvalidProposalData();

        // Burn tokens to create proposal
        vlrToken.burnFrom(msg.sender, PROPOSAL_THRESHOLD);

        // Create proposal
        proposalId = ++proposalCount;
        Proposal storage newProposal = proposals[proposalId];
        
        newProposal.id = proposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = description;
        newProposal.targets = targets;
        newProposal.values = values;
        newProposal.calldatas = calldatas;
        newProposal.startBlock = block.number + (VOTING_DELAY / 12); // ~12s per block
        newProposal.endBlock = newProposal.startBlock + (VOTING_PERIOD / 12);
        newProposal.executed = false;
        newProposal.canceled = false;

        emit ProposalCreated(
            proposalId,
            msg.sender,
            targets,
            values,
            calldatas,
            newProposal.startBlock,
            newProposal.endBlock,
            description
        );

        return proposalId;
    }

    /**
     * @notice Cast a vote by burning VLR tokens
     * @param proposalId The proposal to vote on
     * @param support Vote type: 0=against, 1=for, 2=abstain
     * @param burnAmount Amount of VLR to burn for voting power
     * @param reason Optional reason for vote
     */
    function castVote(
        uint256 proposalId,
        uint8 support,
        uint256 burnAmount,
        string memory reason
    ) external override whenNotPaused nonReentrant {
        if (state(proposalId) != ProposalState.Active) revert ProposalNotActive();
        if (support > 2) revert InvalidVoteType();
        
        Receipt storage receipt = receipts[proposalId][msg.sender];
        if (receipt.hasVoted) revert AlreadyVoted();

        // Burn tokens and calculate voting power
        vlrToken.burnFrom(msg.sender, burnAmount);
        uint256 votes = getVotingPower(msg.sender, burnAmount);

        // Record vote
        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;
        receipt.burnedAmount = burnAmount;

        // Update proposal vote counts
        Proposal storage proposal = proposals[proposalId];
        if (support == 0) {
            proposal.againstVotes += votes;
        } else if (support == 1) {
            proposal.forVotes += votes;
        } else {
            proposal.abstainVotes += votes;
        }

        emit VoteCast(msg.sender, proposalId, support, votes, burnAmount, reason);
    }

    /**
     * @notice Queue a successful proposal for execution
     * @param proposalId The proposal to queue
     */
    function queue(uint256 proposalId) external override nonReentrant {
        if (state(proposalId) != ProposalState.Succeeded) revert ProposalNotSucceeded();

        Proposal storage proposal = proposals[proposalId];
        uint256 eta = block.timestamp + timelock.delay();
        proposalEta[proposalId] = eta;

        // Queue all transactions in the timelock
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            timelock.queueTransaction(
                proposal.targets[i],
                proposal.values[i],
                proposal.calldatas[i],
                eta
            );
        }

        emit ProposalQueued(proposalId, eta);
    }

    /**
     * @notice Execute a queued proposal after timelock
     * @param proposalId The proposal to execute
     */
    function execute(uint256 proposalId) external payable override nonReentrant {
        if (state(proposalId) != ProposalState.Queued) revert ProposalNotQueued();

        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;

        uint256 eta = proposalEta[proposalId];

        // Execute all transactions through timelock
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            timelock.executeTransaction{value: proposal.values[i]}(
                proposal.targets[i],
                proposal.values[i],
                proposal.calldatas[i],
                eta
            );
        }

        emit ProposalExecuted(proposalId);
    }

    /**
     * @notice Cancel a proposal (only by proposer)
     * @param proposalId The proposal to cancel
     */
    function cancel(uint256 proposalId) external override {
        Proposal storage proposal = proposals[proposalId];
        
        if (msg.sender != proposal.proposer) revert OnlyProposer();
        if (proposal.executed) revert ProposalAlreadyExecuted();

        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the current state of a proposal
     * @param proposalId The proposal ID
     * @return Current state of the proposal
     */
    function state(uint256 proposalId) public view override returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.number < proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposalEta[proposalId] != 0) {
            return ProposalState.Queued;
        } else if (proposalSucceeded(proposalId)) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    /**
     * @notice Get proposal details
     * @param proposalId The proposal ID
     * @return Proposal struct
     */
    function getProposal(uint256 proposalId) external view override returns (Proposal memory) {
        return proposals[proposalId];
    }

    /**
     * @notice Get voting receipt for an address
     * @param proposalId The proposal ID
     * @param voter The voter address
     * @return Receipt struct
     */
    function getReceipt(uint256 proposalId, address voter) 
        external 
        view 
        override 
        returns (Receipt memory) 
    {
        return receipts[proposalId][voter];
    }

    /**
     * @notice Calculate voting power for a user
     * @param user The user address
     * @param burnAmount Amount of VLR to burn
     * @return Voting power (burn amount × staking multiplier)
     */
    function getVotingPower(address user, uint256 burnAmount) 
        public 
        view 
        override 
        returns (uint256) 
    {
        if (address(stakingContract) == address(0)) {
            return burnAmount * NO_STAKE_MULTIPLIER;
        }

        // Get user's stake IDs
        uint256[] memory stakeIds = stakingContract.getUserStakes(user);
        
        // Check if user has Long or Elite tier stake
        bool hasLongOrElite = false;
        for (uint256 i = 0; i < stakeIds.length; i++) {
            (
                ,  // amount
                ,  // startTime
                ,  // lockDuration
                IVelirionStaking.StakingTier tier,
                ,  // apr
                ,  // renewed
                bool active
            ) = stakingContract.getStakeInfo(user, stakeIds[i]);
            
            if (
                active &&
                (tier == IVelirionStaking.StakingTier.Long ||
                 tier == IVelirionStaking.StakingTier.Elite)
            ) {
                hasLongOrElite = true;
                break;
            }
        }

        // Apply multiplier
        if (hasLongOrElite) {
            return burnAmount * LONG_STAKE_MULTIPLIER;  // 2x for Long/Elite
        } else {
            return burnAmount * NO_STAKE_MULTIPLIER;    // 1x for others
        }
    }

    /**
     * @notice Check if quorum is reached for a proposal
     * @param proposalId The proposal ID
     * @return True if quorum reached
     */
    function quorumReached(uint256 proposalId) public view override returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        return totalVotes >= QUORUM_VOTES;
    }

    /**
     * @notice Check if a proposal has succeeded
     * @param proposalId The proposal ID
     * @return True if proposal passed
     */
    function proposalSucceeded(uint256 proposalId) public view override returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        
        // Must reach quorum
        if (!quorumReached(proposalId)) {
            return false;
        }

        // For votes must exceed against votes
        return proposal.forVotes > proposal.againstVotes;
    }
}
