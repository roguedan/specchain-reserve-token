---
name: solidity-smart-contracts
description: Develop secure and efficient smart contracts in Solidity, implementing token standards, access controls, and business logic invariants for blockchain applications
---

# Solidity Smart Contract Development

Develop production-ready smart contracts following security best practices and gas optimization patterns. Focus on implementing business logic as enforceable on-chain rules with proper access controls and event emissions.

## Examples

### Basic ERC-20 Token Implementation
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Token {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
    
    function transfer(address to, uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
}
```

### Access Control Pattern
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not authorized");
    _;
}

function mint(address to, uint256 amount) external onlyOwner {
    totalSupply += amount;
    balanceOf[to] += amount;
}
```

### Business Logic Invariant
```solidity
function _checkInvariant() internal view returns (bool) {
    // Example: Ensure reserves always back token supply
    return address(reserve).balance >= totalSupply;
}

function transfer(address to, uint256 amount) external {
    require(_checkInvariant(), "Invariant violated");
    // ... transfer logic
}
```

## Guidelines

### Security First
- Always use Checks-Effects-Interactions pattern
- Validate all inputs and state transitions
- Implement proper access controls
- Use OpenZeppelin contracts when available
- Consider reentrancy guards for external calls

### Gas Optimization
- Pack struct variables efficiently
- Use `immutable` and `constant` where applicable
- Minimize storage operations
- Batch operations when possible
- Avoid loops with unbounded iterations

### Code Quality
- Follow Solidity style guide
- Use descriptive variable and function names
- Add NatSpec comments for all public functions
- Emit events for all state changes
- Write comprehensive unit tests

### Common Patterns
- Factory pattern for contract deployment
- Proxy pattern for upgradability
- Pull payment pattern for withdrawals
- Circuit breaker for emergency stops
- Time-locked administration

### Testing Requirements
- Unit tests for all functions
- Edge case coverage
- Fuzzing for numeric operations
- Integration tests for contract interactions
- Gas consumption benchmarks