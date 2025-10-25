#!/bin/bash

echo "🔑 Setting up wallet for SpecChain Reserve Token deployment..."

# Check if .env already exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists. Backup created as .env.backup"
    cp .env .env.backup
fi

echo ""
echo "Choose wallet setup method:"
echo "1) Generate new wallet with Foundry (recommended for testing)"
echo "2) Use existing wallet (enter private key manually)"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    echo ""
    echo "🎲 Generating new wallet..."
    
    # Generate new wallet and capture output
    wallet_output=$(cast wallet new)
    
    # Extract address and private key
    address=$(echo "$wallet_output" | grep "Address:" | awk '{print $2}')
    private_key=$(echo "$wallet_output" | grep "Private key:" | awk '{print $3}' | sed 's/0x//')
    
    echo "✅ New wallet generated:"
    echo "Address: $address"
    echo "Private Key: 0x$private_key"
    echo ""
    echo "⚠️  SAVE THIS PRIVATE KEY SECURELY - IT WON'T BE SHOWN AGAIN!"
    echo ""
    
    # Create .env file
    cat > .env << EOF
# SpecChain Reserve Token Deployment Configuration
# Generated on $(date)

# Wallet Configuration
PRIVATE_KEY=$private_key
ISSUER=$address
RESERVE=$address

# Sepolia RPC (using public endpoint)
RPC_URL=https://rpc.sepolia.org

# Optional: Add your Etherscan API key for verification
ETHERSCAN_API_KEY=your_etherscan_api_key_here
EOF

    echo "📝 .env file created with your wallet details"
    echo ""
    echo "🚰 Next steps:"
    echo "1. Get Sepolia ETH from faucets:"
    echo "   - Google Cloud: https://cloud.google.com/application/web3/faucet/ethereum/sepolia"
    echo "   - Alchemy: https://sepoliafaucet.com/"
    echo "   - Chainlink: https://faucets.chain.link/sepolia"
    echo ""
    echo "2. Your address to fund: $address"
    echo "3. You'll need ~0.01 ETH for deployment"
    echo ""
    echo "✅ Run 'source .env && cast balance \$ISSUER --rpc-url \$RPC_URL' to check balance"

elif [ "$choice" == "2" ]; then
    echo ""
    read -p "Enter your private key (with or without 0x): " input_key
    
    # Remove 0x prefix if present
    private_key=$(echo "$input_key" | sed 's/0x//')
    
    # Get address from private key
    address=$(cast wallet address --private-key $private_key)
    
    echo "✅ Address derived: $address"
    
    # Create .env file
    cat > .env << EOF
# SpecChain Reserve Token Deployment Configuration
# Generated on $(date)

# Wallet Configuration  
PRIVATE_KEY=$private_key
ISSUER=$address
RESERVE=$address

# Sepolia RPC (using public endpoint)
RPC_URL=https://rpc.sepolia.org

# Optional: Add your Etherscan API key for verification
ETHERSCAN_API_KEY=your_etherscan_api_key_here
EOF

    echo "📝 .env file created with your wallet details"
    echo ""
    echo "🚰 Make sure your address has Sepolia ETH: $address"
    echo "✅ Run 'source .env && cast balance \$ISSUER --rpc-url \$RPC_URL' to check balance"

else
    echo "❌ Invalid choice. Please run the script again."
    exit 1
fi

echo ""
echo "🔒 Security reminder:"
echo "- Never share your private key"
echo "- Never commit .env to git (it's in .gitignore)"
echo "- This is for testnet only - use different wallet for mainnet"