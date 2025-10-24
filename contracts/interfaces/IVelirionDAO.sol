// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IVelirionDAO
 * @notice Interface for Velirion DAO governance with burn-to-vote mechanism
 * 
 * Key Features:
 * - Burn VLR tokens to gain voting power
 * - Staking multiplier: 1x (no stake), 2x (Long/Elite tier)
 * - Proposal threshold: 10,000 VLR burned
 * - Voting period: 7 days
 * - Timelock: 2 days execution delay
 * - Quorum: 100,000 VLR total votes required
 */
interface IVelirionDAO {
    // ============================================================================
    // Enums
    // ============================================================================

    enum ProposalState {
        Pending,    // Created but voting not started
        Active,     // Voting in progress
        Defeated,   // Did not pass
        Succeeded,  // Passed, awaiting execution
        Queued,     // In timelock
        Executed,   // Executed successfully
        Canceled    // Canceled by proposer
    }

    // ============================================================================
    // Structs
    // ============================================================================

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        address[] targets;          // Contracts to call
        uint256[] values;           // ETH values to send
        bytes[] calldatas;          // Function calls encoded
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool executed;
        bool canceled;
    }

    struct Receipt {
        bool hasVoted;
        uint8 support;              // 0=against, 1=for, 2=abstain
        uint256 votes;              // Voting power used
        uint256 burnedAmount;       // VLR burned for this vote
    }

    // ============================================================================
    // Events
    // ============================================================================

    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        address[] targets,
        uint256[] values,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event VoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint8 support,
        uint256 votes,
        uint256 burnedAmount,
        string reason
    );

    event ProposalCanceled(uint256 indexed proposalId);
    event ProposalQueued(uint256 indexed proposalId, uint256 eta);
    event ProposalExecuted(uint256 indexed proposalId);

    // ============================================================================
    // Core Functions
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
    ) external returns (uint256 proposalId);

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
    ) external;

    /**
     * @notice Queue a successful proposal for execution
     * @param proposalId The proposal to queue
     */
    function queue(uint256 proposalId) external;

    /**
     * @notice Execute a queued proposal after timelock
     * @param proposalId The proposal to execute
     */
    function execute(uint256 proposalId) external payable;

    /**
     * @notice Cancel a proposal (only by proposer)
     * @param proposalId The proposal to cancel
     */
    function cancel(uint256 proposalId) external;

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the current state of a proposal
     * @param proposalId The proposal ID
     * @return Current state of the proposal
     */
    function state(uint256 proposalId) external view returns (ProposalState);

    /**
     * @notice Get proposal details
     * @param proposalId The proposal ID
     * @return Proposal struct
     */
    function getProposal(uint256 proposalId) external view returns (Proposal memory);

    /**
     * @notice Get voting receipt for an address
     * @param proposalId The proposal ID
     * @param voter The voter address
     * @return Receipt struct
     */
    function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory);

    /**
     * @notice Calculate voting power for a user
     * @param user The user address
     * @param burnAmount Amount of VLR to burn
     * @return Voting power (burn amount × staking multiplier)
     */
    function getVotingPower(address user, uint256 burnAmount) external view returns (uint256);

    /**
     * @notice Get total number of proposals
     * @return Total proposal count
     */
    function proposalCount() external view returns (uint256);

    /**
     * @notice Check if quorum is reached for a proposal
     * @param proposalId The proposal ID
     * @return True if quorum reached
     */
    function quorumReached(uint256 proposalId) external view returns (bool);

    /**
     * @notice Check if a proposal has succeeded
     * @param proposalId The proposal ID
     * @return True if proposal passed
     */
    function proposalSucceeded(uint256 proposalId) external view returns (bool);
}
