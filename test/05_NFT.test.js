const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Velirion NFT Reward System", function () {
    let vlrToken;
    let referralContract;
    let stakingContract;
    let referralNFT;
    let guardianNFT;
    let owner, user1, user2, user3, user4;

    const TIER_2_BRONZE = 2;
    const TIER_3_SILVER = 3;
    const TIER_4_GOLD = 4;
    const TIER_5_GUARDIAN = 5;

    beforeEach(async function () {
        [owner, user1, user2, user3, user4] = await ethers.getSigners();

        // Deploy VLR Token
        const VelirionToken = await ethers.getContractFactory("VelirionToken");
        vlrToken = await VelirionToken.deploy();
        await vlrToken.deployed();

        // Deploy mock Referral contract (we'll use owner as referral contract for testing)
        // In production, this would be the actual VelirionReferral contract

        // Deploy Referral NFT
        const VelirionReferralNFT = await ethers.getContractFactory("VelirionReferralNFT");
        referralNFT = await VelirionReferralNFT.deploy(
            "Velirion Referral Badge",
            "VLR-REF",
            "ipfs://QmReferral/",
            owner.address
        );
        await referralNFT.deployed();

        // Deploy Guardian NFT
        const VelirionGuardianNFT = await ethers.getContractFactory("VelirionGuardianNFT");
        guardianNFT = await VelirionGuardianNFT.deploy(
            "Velirion Guardian",
            "VLR-GUARD",
            "ipfs://QmGuardian/",
            owner.address
        );
        await guardianNFT.deployed();

        // Set owner as referral/staking contract for testing
        await referralNFT.setReferralContract(owner.address);
        await guardianNFT.setStakingContract(owner.address);
    });

    describe("Referral NFT - Deployment", function () {
        it("Should set correct name and symbol", async function () {
            expect(await referralNFT.name()).to.equal("Velirion Referral Badge");
            expect(await referralNFT.symbol()).to.equal("VLR-REF");
        });

        it("Should set correct base URI", async function () {
            expect(await referralNFT.baseTokenURI()).to.equal("ipfs://QmReferral/");
        });

        it("Should set referral contract", async function () {
            expect(await referralNFT.referralContract()).to.equal(owner.address);
        });

        it("Should not be soulbound by default", async function () {
            expect(await referralNFT.isSoulbound()).to.be.false;
        });
    });

    describe("Referral NFT - Minting", function () {
        it("Should mint Bronze NFT (Tier 2)", async function () {
            const tx = await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            await expect(tx)
                .to.emit(referralNFT, "NFTMinted");

            expect(await referralNFT.balanceOf(user1.address)).to.equal(1);
            expect(await referralNFT.ownerOf(1)).to.equal(user1.address);
        });

        it("Should mint Silver NFT (Tier 3)", async function () {
            await referralNFT.mintNFT(user1.address, TIER_3_SILVER);
            
            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_3_SILVER);
        });

        it("Should mint Gold NFT (Tier 4)", async function () {
            await referralNFT.mintNFT(user1.address, TIER_4_GOLD);
            
            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_4_GOLD);
        });

        it("Should fail to mint with invalid tier", async function () {
            await expect(
                referralNFT.mintNFT(user1.address, 1)
            ).to.be.revertedWithCustomError(referralNFT, "InvalidTier");

            await expect(
                referralNFT.mintNFT(user1.address, 5)
            ).to.be.revertedWithCustomError(referralNFT, "InvalidTier");
        });

        it("Should fail if user already has NFT", async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);

            await expect(
                referralNFT.mintNFT(user1.address, TIER_3_SILVER)
            ).to.be.revertedWithCustomError(referralNFT, "UserAlreadyHasNFT");
        });

        it("Should fail if not called by referral contract", async function () {
            await expect(
                referralNFT.connect(user1).mintNFT(user1.address, TIER_2_BRONZE)
            ).to.be.revertedWithCustomError(referralNFT, "OnlyReferralContract");
        });

        it("Should set correct metadata on mint", async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);

            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_2_BRONZE);
            expect(metadata.referralCount).to.equal(0);
            expect(metadata.totalEarned).to.equal(0);
            expect(metadata.isActive).to.be.true;
        });

        it("Should generate correct token URI", async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            
            const tokenURI = await referralNFT.tokenURI(1);
            expect(tokenURI).to.equal("ipfs://QmReferral/2.json");
        });
    });

    describe("Referral NFT - Upgrading", function () {
        beforeEach(async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
        });

        it("Should upgrade Bronze to Silver", async function () {
            const tx = await referralNFT.upgradeNFT(1, TIER_3_SILVER);
            await expect(tx)
                .to.emit(referralNFT, "NFTUpgraded");

            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_3_SILVER);
        });

        it("Should upgrade Silver to Gold", async function () {
            await referralNFT.upgradeNFT(1, TIER_3_SILVER);
            await referralNFT.upgradeNFT(1, TIER_4_GOLD);

            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_4_GOLD);
        });

        it("Should fail to downgrade tier", async function () {
            await referralNFT.upgradeNFT(1, TIER_3_SILVER);

            await expect(
                referralNFT.upgradeNFT(1, TIER_2_BRONZE)
            ).to.be.revertedWithCustomError(referralNFT, "CannotDowngradeTier");
        });

        it("Should fail to upgrade to same tier", async function () {
            await expect(
                referralNFT.upgradeNFT(1, TIER_2_BRONZE)
            ).to.be.revertedWithCustomError(referralNFT, "CannotDowngradeTier");
        });

        it("Should update token URI on upgrade", async function () {
            await referralNFT.upgradeNFT(1, TIER_3_SILVER);
            
            const tokenURI = await referralNFT.tokenURI(1);
            expect(tokenURI).to.equal("ipfs://QmReferral/3.json");
        });
    });

    describe("Referral NFT - Metadata Updates", function () {
        beforeEach(async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
        });

        it("Should update referral count and total earned", async function () {
            await expect(
                referralNFT.updateMetadata(1, 15, ethers.utils.parseEther("5000"))
            ).to.emit(referralNFT, "MetadataUpdated")
            .withArgs(1, 15, ethers.utils.parseEther("5000"));

            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.referralCount).to.equal(15);
            expect(metadata.totalEarned).to.equal(ethers.utils.parseEther("5000"));
        });
    });

    describe("Referral NFT - Tier Upgrade Handler", function () {
        it("Should mint NFT if user doesn't have one", async function () {
            await referralNFT.handleTierUpgrade(user1.address, TIER_2_BRONZE);

            expect(await referralNFT.balanceOf(user1.address)).to.equal(1);
            expect(await referralNFT.getUserNFT(user1.address)).to.equal(1);
        });

        it("Should upgrade NFT if user already has one", async function () {
            await referralNFT.handleTierUpgrade(user1.address, TIER_2_BRONZE);
            await referralNFT.handleTierUpgrade(user1.address, TIER_3_SILVER);

            const metadata = await referralNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_3_SILVER);
            expect(await referralNFT.balanceOf(user1.address)).to.equal(1); // Still only 1 NFT
        });
    });

    describe("Referral NFT - View Functions", function () {
        it("Should return correct user NFT", async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            expect(await referralNFT.getUserNFT(user1.address)).to.equal(1);
        });

        it("Should return 0 if user has no NFT", async function () {
            expect(await referralNFT.getUserNFT(user1.address)).to.equal(0);
        });

        it("Should check if user has NFT", async function () {
            expect(await referralNFT.hasNFT(user1.address)).to.be.false;
            
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            
            expect(await referralNFT.hasNFT(user1.address)).to.be.true;
        });

        it("Should return correct tier names", async function () {
            expect(await referralNFT.getTierName(TIER_2_BRONZE)).to.equal("Bronze");
            expect(await referralNFT.getTierName(TIER_3_SILVER)).to.equal("Silver");
            expect(await referralNFT.getTierName(TIER_4_GOLD)).to.equal("Gold");
        });
    });

    describe("Referral NFT - Soulbound Functionality", function () {
        it("Should allow transfers when not soulbound", async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            
            await referralNFT.connect(user1).transferFrom(user1.address, user2.address, 1);
            
            expect(await referralNFT.ownerOf(1)).to.equal(user2.address);
        });

        it("Should prevent transfers when soulbound", async function () {
            await referralNFT.setSoulbound(true);
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            
            await expect(
                referralNFT.connect(user1).transferFrom(user1.address, user2.address, 1)
            ).to.be.revertedWithCustomError(referralNFT, "SoulboundToken");
        });
    });

    describe("Guardian NFT - Deployment", function () {
        it("Should set correct name and symbol", async function () {
            expect(await guardianNFT.name()).to.equal("Velirion Guardian");
            expect(await guardianNFT.symbol()).to.equal("VLR-GUARD");
        });

        it("Should set correct base URI", async function () {
            expect(await guardianNFT.baseTokenURI()).to.equal("ipfs://QmGuardian/");
        });

        it("Should set staking contract", async function () {
            expect(await guardianNFT.stakingContract()).to.equal(owner.address);
        });
    });

    describe("Guardian NFT - Minting", function () {
        it("Should mint Guardian NFT for Elite staker", async function () {
            const tx = await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
            await expect(tx)
                .to.emit(guardianNFT, "NFTMinted");

            expect(await guardianNFT.balanceOf(user1.address)).to.equal(1);
        });

        it("Should fail to mint with wrong tier", async function () {
            await expect(
                guardianNFT.mintNFT(user1.address, TIER_2_BRONZE)
            ).to.be.reverted;
        });

        it("Should fail if user already has Guardian NFT", async function () {
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);

            await expect(
                guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN)
            ).to.be.revertedWithCustomError(guardianNFT, "UserAlreadyHasNFT");
        });

        it("Should set correct metadata", async function () {
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);

            const metadata = await guardianNFT.getMetadata(1);
            expect(metadata.tier).to.equal(TIER_5_GUARDIAN);
            expect(metadata.isActive).to.be.true;
        });

        it("Should fail if not called by staking contract", async function () {
            await expect(
                guardianNFT.connect(user1).mintNFT(user1.address, TIER_5_GUARDIAN)
            ).to.be.revertedWithCustomError(guardianNFT, "OnlyStakingContract");
        });
    });

    describe("Guardian NFT - Staking Integration", function () {
        beforeEach(async function () {
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
        });

        it("Should update staked amount", async function () {
            await guardianNFT.updateStakedAmount(user1.address, ethers.utils.parseEther("250000"));

            const metadata = await guardianNFT.getMetadata(1);
            expect(metadata.stakedAmount).to.equal(ethers.utils.parseEther("250000"));
        });

        it("Should deactivate NFT on unstake", async function () {
            await guardianNFT.deactivateNFT(user1.address);

            const metadata = await guardianNFT.getMetadata(1);
            expect(metadata.isActive).to.be.false;
        });

        it("Should reactivate NFT on re-stake", async function () {
            await guardianNFT.deactivateNFT(user1.address);
            await guardianNFT.reactivateNFT(user1.address);

            const metadata = await guardianNFT.getMetadata(1);
            expect(metadata.isActive).to.be.true;
        });

        it("Should check if Guardian NFT is active", async function () {
            expect(await guardianNFT.isActive(user1.address)).to.be.true;

            await guardianNFT.deactivateNFT(user1.address);
            expect(await guardianNFT.isActive(user1.address)).to.be.false;
        });
    });

    describe("Guardian NFT - Soulbound (Always)", function () {
        it("Should prevent transfers (always soulbound)", async function () {
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
            
            await expect(
                guardianNFT.connect(user1).transferFrom(user1.address, user2.address, 1)
            ).to.be.revertedWithCustomError(guardianNFT, "SoulboundToken");
        });
    });

    describe("Guardian NFT - View Functions", function () {
        it("Should return total guardians count", async function () {
            expect(await guardianNFT.totalGuardians()).to.equal(0);

            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
            await guardianNFT.mintNFT(user2.address, TIER_5_GUARDIAN);
            await guardianNFT.mintNFT(user3.address, TIER_5_GUARDIAN);

            expect(await guardianNFT.totalGuardians()).to.equal(3);
        });

        it("Should return correct user NFT", async function () {
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
            expect(await guardianNFT.getUserNFT(user1.address)).to.equal(1);
        });

        it("Should check if user has Guardian NFT", async function () {
            expect(await guardianNFT.hasNFT(user1.address)).to.be.false;
            
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
            
            expect(await guardianNFT.hasNFT(user1.address)).to.be.true;
        });
    });

    describe("Admin Functions", function () {
        it("Should allow owner to update base URI", async function () {
            await referralNFT.setBaseTokenURI("ipfs://NewHash/");
            expect(await referralNFT.baseTokenURI()).to.equal("ipfs://NewHash/");
        });

        it("Should allow owner to toggle soulbound", async function () {
            await referralNFT.setSoulbound(true);
            expect(await referralNFT.isSoulbound()).to.be.true;

            await referralNFT.setSoulbound(false);
            expect(await referralNFT.isSoulbound()).to.be.false;
        });

        it("Should fail if non-owner tries to set referral contract", async function () {
            await expect(
                referralNFT.connect(user1).setReferralContract(user2.address)
            ).to.be.reverted;
        });

        it("Should fail if non-owner tries to set staking contract", async function () {
            await expect(
                guardianNFT.connect(user1).setStakingContract(user2.address)
            ).to.be.reverted;
        });
    });

    describe("Multiple Users", function () {
        it("Should mint NFTs for multiple users", async function () {
            await referralNFT.mintNFT(user1.address, TIER_2_BRONZE);
            await referralNFT.mintNFT(user2.address, TIER_3_SILVER);
            await referralNFT.mintNFT(user3.address, TIER_4_GOLD);

            expect(await referralNFT.balanceOf(user1.address)).to.equal(1);
            expect(await referralNFT.balanceOf(user2.address)).to.equal(1);
            expect(await referralNFT.balanceOf(user3.address)).to.equal(1);

            expect((await referralNFT.getMetadata(1)).tier).to.equal(TIER_2_BRONZE);
            expect((await referralNFT.getMetadata(2)).tier).to.equal(TIER_3_SILVER);
            expect((await referralNFT.getMetadata(3)).tier).to.equal(TIER_4_GOLD);
        });

        it("Should mint Guardian NFTs for multiple Elite stakers", async function () {
            await guardianNFT.mintNFT(user1.address, TIER_5_GUARDIAN);
            await guardianNFT.mintNFT(user2.address, TIER_5_GUARDIAN);
            await guardianNFT.mintNFT(user3.address, TIER_5_GUARDIAN);

            expect(await guardianNFT.totalGuardians()).to.equal(3);
        });
    });
});
