#!/bin/bash

# Velirion SPL Token - Devnet Deployment Script
# Anchor CLI 0.30.1 | Solana CLI 2.3.13

set -e

echo "Velirion SPL Token - Devnet Deployment"
echo "=========================================="
echo ""

# Check versions
echo "Checking tool versions..."
ANCHOR_VERSION=$(anchor --version | grep -oP '(?<=anchor-cli )\d+\.\d+\.\d+')
SOLANA_VERSION=$(solana --version | grep -oP '\d+\.\d+\.\d+')

echo "Anchor CLI: $ANCHOR_VERSION"
echo "Solana CLI: $SOLANA_VERSION"

if [ "$ANCHOR_VERSION" != "0.30.1" ]; then
    echo "⚠️  Warning: Anchor CLI version is $ANCHOR_VERSION, expected 0.30.1"
    echo "   Install with: cargo install --git https://github.com/coral-xyz/anchor --tag v0.30.1 anchor-cli --locked"
fi

echo ""

# Configure Solana
echo "🔧 Configuring Solana for devnet..."
solana config set --url https://api.devnet.solana.com

# Check wallet
echo ""
echo "Checking wallet..."
WALLET_ADDRESS=$(solana address)
echo "Wallet: $WALLET_ADDRESS"

BALANCE=$(solana balance | grep -oP '^\d+\.\d+')
echo "Balance: $BALANCE SOL"

if (( $(echo "$BALANCE < 2" | bc -l) )); then
    echo "⚠️  Low balance. Requesting airdrop..."
    solana airdrop 2 || echo "Airdrop failed. Please fund wallet manually."
    sleep 2
    BALANCE=$(solana balance | grep -oP '^\d+\.\d+')
    echo "New balance: $BALANCE SOL"
fi

echo ""

# Clean and build
echo "Building program..."
echo "This may take 5-10 minutes..."
anchor clean
rm -rf target/

anchor build

if [ ! -f "target/deploy/velirion_spl.so" ]; then
    echo "❌ Build failed. Check errors above."
    exit 1
fi

echo "✅ Build successful"
echo ""

# Verify program ID
PROGRAM_ID=$(solana address -k target/deploy/velirion_spl-keypair.json)
echo "Program ID: $PROGRAM_ID"

if [ "$PROGRAM_ID" != "CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr" ]; then
    echo "⚠️  Warning: Program ID mismatch!"
    echo "   Expected: CehR3hndPUMTtLJe2hzQo9Hu538KTb2TdbjPugVP72Tr"
    echo "   Got: $PROGRAM_ID"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Set environment
export ANCHOR_PROVIDER_URL=https://api.devnet.solana.com
export ANCHOR_WALLET=~/.config/solana/id.json

# Deploy
echo "Deploying to devnet..."
anchor deploy --provider.cluster devnet

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "Program Details:"
    echo "   Program ID: $PROGRAM_ID"
    echo "   Network: Devnet"
    echo "   Explorer: https://explorer.solana.com/address/$PROGRAM_ID?cluster=devnet"
    echo ""
    
    # Verify deployment
    echo "Verifying deployment..."
    solana program show $PROGRAM_ID --url devnet
    
    echo ""
    echo "Next Steps:"
    echo "   1. Initialize the SPL mint: anchor test --skip-local-validator"
    echo "   2. Record the mint address"
    echo "   3. Test transfers to verify 0.5% burn"
    echo "   4. Update BACKEND_INTEGRATION.md with Solana details"
    echo ""
else
    echo "❌ Deployment failed. Check errors above."
    exit 1
fi
