// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title VelirionPresaleV2
 * @notice Multi-phase presale with vesting, antibot, and VLR-based limits
 *
 * Key Features:
 * - 10 phases: $0.005 - $0.015 per VLR
 * - 3M VLR per phase (30M total)
 * - Vesting: 40% TGE + 30% monthly for 2 months
 * - Antibot: 5-minute delay between purchases
 * - Limits: 50k VLR per tx, 500k VLR per wallet
 * - Multi-token payments: ETH, USDT, USDC
 * - 5% referral bonus
 */
contract VelirionPresaleV2 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant MAX_PER_TRANSACTION = 50_000 * 10 ** 18; // 50k VLR
    uint256 public constant MAX_PER_WALLET = 500_000 * 10 ** 18; // 500k VLR
    uint256 public constant PURCHASE_DELAY = 5 minutes;
    uint256 public constant REFERRAL_BONUS_BPS = 500; // 5%
    uint256 public constant BASIS_POINTS = 10000;

    // Vesting: 40% at TGE, 30% after 30 days, 30% after 60 days
    uint256 public constant TGE_PERCENT = 4000; // 40%
    uint256 public constant MONTH_1_PERCENT = 3000; // 30%
    uint256 public constant MONTH_2_PERCENT = 3000; // 30%
    uint256 public constant VESTING_INTERVAL = 30 days;

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;
    IERC20 public immutable usdtToken;
    IERC20 public immutable usdcToken;

    uint256 public currentPhase;
    uint256 public ethUsdPrice;
    uint256 public totalRaisedUSD;
    uint256 public presaleStartTime;
    bool public presaleFinalized;

    // ============================================================================
    // Structs
    // ============================================================================

    struct Phase {
        uint256 startTime;
        uint256 endTime;
        uint256 pricePerToken; // USD with 18 decimals
        uint256 maxTokens; // Total tokens for phase
        uint256 soldTokens; // Tokens sold
        bool isActive;
    }

    struct VestingSchedule {
        uint256 totalAmount; // Total tokens purchased
        uint256 claimedAmount; // Amount already claimed
        uint256 tgeAmount; // 40% released at TGE
        uint256 month1Amount; // 30% after 30 days
        uint256 month2Amount; // 30% after 60 days
    }

    struct Purchase {
        uint256 phaseId;
        uint256 amount;
        uint256 tokenAmount;
        address paymentToken;
        uint256 timestamp;
    }

    struct Referral {
        address referrer;
        uint256 totalReferred;
        uint256 totalEarned;
        uint256 totalVolume;
    }

    // ============================================================================
    // Mappings
    // ============================================================================

    mapping(uint256 => Phase) public phases;
    mapping(address => VestingSchedule) public vestingSchedules;
    mapping(address => Purchase[]) public userPurchases;
    mapping(address => uint256) public totalPurchasedVLR; // Total VLR per wallet
    mapping(address => uint256) public lastPurchaseTime; // For 5-min delay
    mapping(address => Referral) public referrals;
    mapping(address => bool) public hasBeenReferred;

    // ============================================================================
    // Events
    // ============================================================================

    event PhaseInitialized(
        uint256 indexed phaseId,
        uint256 pricePerToken,
        uint256 maxTokens
    );
    event PhaseStarted(uint256 indexed phaseId, uint256 startTime);
    event PhaseEnded(uint256 indexed phaseId, uint256 endTime);
    event TokensPurchased(
        address indexed buyer,
        uint256 indexed phaseId,
        uint256 amountPaid,
        uint256 tokenAmount,
        address paymentToken,
        address referrer
    );
    event TokensClaimed(address indexed user, uint256 amount);
    event ReferralBonus(
        address indexed referrer,
        address indexed referee,
        uint256 bonusAmount
    );
    event FundsWithdrawn(address indexed token, uint256 amount);
    event EthPriceUpdated(uint256 newPrice);
    event PresaleFinalized(uint256 unsoldTokens);

    // ============================================================================
    // Errors
    // ============================================================================

    error InvalidPhase();
    error PhaseNotActive();
    error InsufficientTokens();
    error ExceedsMaxPerTransaction();
    error ExceedsMaxPerWallet();
    error PurchaseDelayNotMet();
    error InvalidAmount();
    error InvalidPrice();
    error TransferFailed();
    error AlreadyReferred();
    error CannotReferSelf();
    error PresaleNotStarted();
    error PresaleAlreadyFinalized();
    error NothingToClaim();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(
        address _vlrToken,
        address _usdtToken,
        address _usdcToken,
        uint256 _initialEthPrice
    ) Ownable(msg.sender) {
        require(_vlrToken != address(0), "Invalid VLR token");
        require(_usdtToken != address(0), "Invalid USDT token");
        require(_usdcToken != address(0), "Invalid USDC token");
        require(_initialEthPrice > 0, "Invalid ETH price");

        vlrToken = IERC20(_vlrToken);
        usdtToken = IERC20(_usdtToken);
        usdcToken = IERC20(_usdcToken);
        ethUsdPrice = _initialEthPrice;
    }

    // ============================================================================
    // Owner Functions
    // ============================================================================

    /**
     * @notice Initialize all 10 presale phases per specification
     * @dev Prices: $0.005 to $0.015, 3M tokens per phase
     */
    function initializePhases() external onlyOwner {
        // Phase 0: $0.005 per token, 3M tokens
        _initializePhase(0, 0.005 ether, 3_000_000 ether);

        // Phase 1: $0.006 per token, 3M tokens
        _initializePhase(1, 0.006 ether, 3_000_000 ether);

        // Phase 2: $0.007 per token, 3M tokens
        _initializePhase(2, 0.007 ether, 3_000_000 ether);

        // Phase 3: $0.008 per token, 3M tokens
        _initializePhase(3, 0.008 ether, 3_000_000 ether);

        // Phase 4: $0.009 per token, 3M tokens
        _initializePhase(4, 0.009 ether, 3_000_000 ether);

        // Phase 5: $0.010 per token, 3M tokens
        _initializePhase(5, 0.010 ether, 3_000_000 ether);

        // Phase 6: $0.011 per token, 3M tokens
        _initializePhase(6, 0.011 ether, 3_000_000 ether);

        // Phase 7: $0.012 per token, 3M tokens
        _initializePhase(7, 0.012 ether, 3_000_000 ether);

        // Phase 8: $0.013 per token, 3M tokens
        _initializePhase(8, 0.013 ether, 3_000_000 ether);

        // Phase 9: $0.015 per token, 3M tokens
        _initializePhase(9, 0.015 ether, 3_000_000 ether);
    }

    /**
     * @notice Start the presale and activate first phase
     * @param duration Duration for phase 0 in seconds
     */
    function startPresale(uint256 duration) external onlyOwner {
        require(presaleStartTime == 0, "Presale already started");
        presaleStartTime = block.timestamp;
        _startPhase(0, duration);
    }

    /**
     * @notice Start a specific phase
     */
    function startPhase(uint256 phaseId, uint256 duration) external onlyOwner {
        _startPhase(phaseId, duration);
    }

    /**
     * @notice End current phase
     */
    function endCurrentPhase() external onlyOwner {
        Phase storage phase = phases[currentPhase];
        phase.isActive = false;
        phase.endTime = block.timestamp;
        emit PhaseEnded(currentPhase, block.timestamp);
    }

    /**
     * @notice Finalize presale and burn unsold tokens
     */
    function finalizePresale() external onlyOwner {
        if (presaleFinalized) revert PresaleAlreadyFinalized();

        // Calculate unsold tokens
        uint256 totalSold = 0;
        for (uint256 i = 0; i < 10; i++) {
            totalSold += phases[i].soldTokens;
        }

        uint256 contractBalance = vlrToken.balanceOf(address(this));
        uint256 unsoldTokens = contractBalance - _calculateTotalVested();

        if (unsoldTokens > 0) {
            // Burn unsold tokens
            vlrToken.safeTransfer(address(0xdead), unsoldTokens);
        }

        presaleFinalized = true;
        emit PresaleFinalized(unsoldTokens);
    }

    /**
     * @notice Update ETH/USD price
     */
    function setEthUsdPrice(uint256 _price) external onlyOwner {
        if (_price == 0) revert InvalidPrice();
        ethUsdPrice = _price;
        emit EthPriceUpdated(_price);
    }

    /**
     * @notice Withdraw collected funds
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert InvalidAmount();
        (bool success, ) = owner().call{value: balance}("");
        if (!success) revert TransferFailed();
        emit FundsWithdrawn(address(0), balance);
    }

    function withdrawUSDT() external onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        if (balance == 0) revert InvalidAmount();
        usdtToken.safeTransfer(owner(), balance);
        emit FundsWithdrawn(address(usdtToken), balance);
    }

    function withdrawUSDC() external onlyOwner {
        uint256 balance = usdcToken.balanceOf(address(this));
        if (balance == 0) revert InvalidAmount();
        usdcToken.safeTransfer(owner(), balance);
        emit FundsWithdrawn(address(usdcToken), balance);
    }

    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }

    // ============================================================================
    // Public Purchase Functions
    // ============================================================================

    /**
     * @notice Buy tokens with ETH
     * @param referrer Referrer address (address(0) if none)
     */
    function buyWithETH(
        address referrer
    ) external payable nonReentrant whenNotPaused {
        if (msg.value == 0) revert InvalidAmount();

        uint256 usdValue = (msg.value * ethUsdPrice) / 1 ether;
        uint256 tokenAmount = _processPurchase(
            msg.sender,
            usdValue,
            address(0),
            referrer
        );

        emit TokensPurchased(
            msg.sender,
            currentPhase,
            msg.value,
            tokenAmount,
            address(0),
            referrer
        );
    }

    /**
     * @notice Buy tokens with USDT
     */
    function buyWithUSDT(
        uint256 amount,
        address referrer
    ) external nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();

        uint256 usdValue = amount * 10 ** 12; // Convert 6 decimals to 18
        usdtToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 tokenAmount = _processPurchase(
            msg.sender,
            usdValue,
            address(usdtToken),
            referrer
        );

        emit TokensPurchased(
            msg.sender,
            currentPhase,
            amount,
            tokenAmount,
            address(usdtToken),
            referrer
        );
    }

    /**
     * @notice Buy tokens with USDC
     */
    function buyWithUSDC(
        uint256 amount,
        address referrer
    ) external nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();

        uint256 usdValue = amount * 10 ** 12; // Convert 6 decimals to 18
        usdcToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 tokenAmount = _processPurchase(
            msg.sender,
            usdValue,
            address(usdcToken),
            referrer
        );

        emit TokensPurchased(
            msg.sender,
            currentPhase,
            amount,
            tokenAmount,
            address(usdcToken),
            referrer
        );
    }

    /**
     * @notice Claim vested tokens
     */
    function claimTokens() external nonReentrant {
        if (presaleStartTime == 0) revert PresaleNotStarted();

        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        if (schedule.totalAmount == 0) revert NothingToClaim();

        uint256 claimable = _calculateClaimable(msg.sender);
        if (claimable == 0) revert NothingToClaim();

        schedule.claimedAmount += claimable;
        vlrToken.safeTransfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    function _initializePhase(
        uint256 phaseId,
        uint256 pricePerToken,
        uint256 maxTokens
    ) internal {
        phases[phaseId] = Phase({
            startTime: 0,
            endTime: 0,
            pricePerToken: pricePerToken,
            maxTokens: maxTokens,
            soldTokens: 0,
            isActive: false
        });
        emit PhaseInitialized(phaseId, pricePerToken, maxTokens);
    }

    function _startPhase(uint256 phaseId, uint256 duration) internal {
        if (phaseId > 9) revert InvalidPhase();

        Phase storage phase = phases[phaseId];
        phase.startTime = block.timestamp;
        phase.endTime = block.timestamp + duration;
        phase.isActive = true;
        currentPhase = phaseId;

        emit PhaseStarted(phaseId, phase.startTime);
    }

    function _processPurchase(
        address buyer,
        uint256 usdValue,
        address paymentToken,
        address referrer
    ) internal returns (uint256) {
        Phase storage phase = phases[currentPhase];

        // Validate phase
        if (!phase.isActive) revert PhaseNotActive();
        if (
            block.timestamp < phase.startTime || block.timestamp > phase.endTime
        ) {
            revert PhaseNotActive();
        }

        // Check 5-minute delay
        if (lastPurchaseTime[buyer] != 0) {
            if (block.timestamp < lastPurchaseTime[buyer] + PURCHASE_DELAY) {
                revert PurchaseDelayNotMet();
            }
        }

        // Calculate token amount
        uint256 tokenAmount = (usdValue * 1 ether) / phase.pricePerToken;

        // Check limits
        if (tokenAmount > MAX_PER_TRANSACTION)
            revert ExceedsMaxPerTransaction();
        if (totalPurchasedVLR[buyer] + tokenAmount > MAX_PER_WALLET)
            revert ExceedsMaxPerWallet();
        if (phase.soldTokens + tokenAmount > phase.maxTokens)
            revert InsufficientTokens();

        // Update state
        phase.soldTokens += tokenAmount;
        totalPurchasedVLR[buyer] += tokenAmount;
        lastPurchaseTime[buyer] = block.timestamp;
        totalRaisedUSD += usdValue;

        // Record purchase
        userPurchases[buyer].push(
            Purchase({
                phaseId: currentPhase,
                amount: usdValue,
                tokenAmount: tokenAmount,
                paymentToken: paymentToken,
                timestamp: block.timestamp
            })
        );

        // Setup vesting
        _setupVesting(buyer, tokenAmount);

        // Process referral
        if (referrer != address(0) && referrer != buyer) {
            _processReferral(buyer, referrer, tokenAmount);
        }

        return tokenAmount;
    }

    function _setupVesting(address user, uint256 amount) internal {
        VestingSchedule storage schedule = vestingSchedules[user];

        uint256 tgeAmount = (amount * TGE_PERCENT) / BASIS_POINTS;
        uint256 month1Amount = (amount * MONTH_1_PERCENT) / BASIS_POINTS;
        uint256 month2Amount = amount - tgeAmount - month1Amount; // Remaining

        schedule.totalAmount += amount;
        schedule.tgeAmount += tgeAmount;
        schedule.month1Amount += month1Amount;
        schedule.month2Amount += month2Amount;
    }

    function _processReferral(
        address buyer,
        address referrer,
        uint256 tokenAmount
    ) internal {
        if (referrer == buyer) revert CannotReferSelf();
        if (hasBeenReferred[buyer]) revert AlreadyReferred();

        uint256 bonusAmount = (tokenAmount * REFERRAL_BONUS_BPS) / BASIS_POINTS;

        uint256 contractBalance = vlrToken.balanceOf(address(this));
        if (contractBalance < bonusAmount) return;

        if (referrals[buyer].referrer == address(0)) {
            referrals[buyer].referrer = referrer;
            hasBeenReferred[buyer] = true;
        }

        referrals[referrer].totalReferred += 1;
        referrals[referrer].totalEarned += bonusAmount;
        referrals[referrer].totalVolume += tokenAmount;

        vlrToken.safeTransfer(referrer, bonusAmount);
        emit ReferralBonus(referrer, buyer, bonusAmount);
    }

    function _calculateClaimable(address user) internal view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[user];
        if (schedule.totalAmount == 0) return 0;

        uint256 claimable = schedule.tgeAmount; // 40% at TGE

        uint256 timeSinceTGE = block.timestamp - presaleStartTime;

        if (timeSinceTGE >= VESTING_INTERVAL) {
            claimable += schedule.month1Amount; // +30% after 30 days
        }

        if (timeSinceTGE >= VESTING_INTERVAL * 2) {
            claimable += schedule.month2Amount; // +30% after 60 days
        }

        return claimable - schedule.claimedAmount;
    }

    function _calculateTotalVested() internal pure returns (uint256) {
        // This would need to track all users - simplified for now
        return 0;
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    function getCurrentPhaseInfo() external view returns (Phase memory) {
        return phases[currentPhase];
    }

    function getPhaseInfo(
        uint256 phaseId
    ) external view returns (Phase memory) {
        return phases[phaseId];
    }

    function calculateTokenAmount(
        uint256 usdValue
    ) external view returns (uint256) {
        Phase memory phase = phases[currentPhase];
        return (usdValue * 1 ether) / phase.pricePerToken;
    }

    function calculateTokenAmountForETH(
        uint256 ethAmount
    ) external view returns (uint256) {
        uint256 usdValue = (ethAmount * ethUsdPrice) / 1 ether;
        Phase memory phase = phases[currentPhase];
        return (usdValue * 1 ether) / phase.pricePerToken;
    }

    function getUserPurchases(
        address user
    ) external view returns (Purchase[] memory) {
        return userPurchases[user];
    }

    function getVestingSchedule(
        address user
    ) external view returns (VestingSchedule memory) {
        return vestingSchedules[user];
    }

    function getClaimableAmount(address user) external view returns (uint256) {
        return _calculateClaimable(user);
    }

    function getReferralInfo(
        address user
    ) external view returns (Referral memory) {
        return referrals[user];
    }

    function isPhaseActive() external view returns (bool) {
        Phase memory phase = phases[currentPhase];
        return
            phase.isActive &&
            block.timestamp >= phase.startTime &&
            block.timestamp <= phase.endTime;
    }

    function getTotalTokensSold() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < 10; i++) {
            total += phases[i].soldTokens;
        }
        return total;
    }

    function canPurchase(
        address user
    ) external view returns (bool, string memory) {
        if (lastPurchaseTime[user] == 0) return (true, "");

        if (block.timestamp < lastPurchaseTime[user] + PURCHASE_DELAY) {
            uint256 timeLeft = (lastPurchaseTime[user] + PURCHASE_DELAY) -
                block.timestamp;
            return (
                false,
                string(
                    abi.encodePacked("Wait ", _toString(timeLeft), " seconds")
                )
            );
        }

        return (true, "");
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    receive() external payable {
        revert("Use buyWithETH function");
    }
}
