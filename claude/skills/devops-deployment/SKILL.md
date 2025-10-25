---
name: devops-deployment
description: Deploy and manage smart contracts across multiple networks with proper verification, monitoring, and operational security practices
---

# Smart Contract DevOps & Deployment

Implement robust deployment pipelines for smart contracts including multi-chain deployment, verification, monitoring, and incident response procedures.

## Examples

### Foundry Deployment Script
```solidity
// script/Deploy.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/Token.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER_ADDRESS");
        
        vm.startBroadcast(deployerKey);
        
        Token token = new Token(owner);
        console.log("Token deployed to:", address(token));
        
        vm.stopBroadcast();
    }
}
```

### Multi-Chain Deployment
```bash
# Deploy to multiple networks
for network in sepolia arbitrum optimism; do
    forge script script/Deploy.s.sol:Deploy \
        --rpc-url $network \
        --broadcast \
        --verify \
        --etherscan-api-key ${network}_KEY
done
```

### Monitoring Configuration
```javascript
// monitoring/config.js
module.exports = {
    contracts: {
        token: {
            address: process.env.TOKEN_ADDRESS,
            events: ['Transfer', 'Approval', 'ComplianceCheck'],
            alerts: {
                lowReserve: {
                    condition: 'reserveRatio < 10000',
                    severity: 'critical'
                }
            }
        }
    }
};
```

### CI/CD Pipeline
```yaml
# .github/workflows/test-deploy.yml
name: Test and Deploy
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
      - name: Run tests
        run: forge test -vvv
      - name: Check coverage
        run: forge coverage --report lcov
```

## Guidelines

### Deployment Best Practices
- Use deterministic deployment addresses
- Verify contracts on block explorers
- Save deployment artifacts and logs
- Test on testnets before mainnet
- Use hardware wallets for mainnet

### Security Operations
- Multi-signature wallet controls
- Time-locked administrative functions
- Emergency pause mechanisms
- Key rotation procedures
- Incident response playbooks

### Monitoring Requirements
- Real-time event monitoring
- Balance tracking alerts
- Failed transaction notifications
- Gas price optimization
- Performance metrics dashboard

### Infrastructure Setup
- Redundant RPC endpoints
- IPFS for metadata storage
- Backup and recovery procedures
- Load balancing for APIs
- DDoS protection measures

### Operational Procedures
- Deployment checklists
- Rollback procedures
- Communication protocols
- Audit trail maintenance
- Regular security reviews