---
name: blockchain-testing
description: Design and implement comprehensive test suites for smart contracts using modern testing frameworks, including unit tests, integration tests, fuzzing, and invariant testing
---

# Blockchain Testing & Security Validation

Create thorough test suites that validate smart contract functionality, security properties, and edge cases. Use modern testing frameworks to ensure code reliability before deployment.

## Examples

### Foundry Test Structure
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/Token.sol";

contract TokenTest is Test {
    Token token;
    address alice = address(0x1);
    address bob = address(0x2);
    
    function setUp() public {
        token = new Token();
        token.mint(alice, 1000 ether);
    }
    
    function testTransfer() public {
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }
}
```

### Testing Reverts
```solidity
function testTransferInsufficientBalance() public {
    vm.prank(alice);
    vm.expectRevert("Insufficient balance");
    token.transfer(bob, 2000 ether);
}
```

### Fuzz Testing
```solidity
function testTransferFuzz(address to, uint256 amount) public {
    vm.assume(to != address(0));
    vm.assume(amount <= token.balanceOf(alice));
    
    uint256 aliceBalanceBefore = token.balanceOf(alice);
    vm.prank(alice);
    token.transfer(to, amount);
    
    assertEq(token.balanceOf(alice), aliceBalanceBefore - amount);
}
```

### Invariant Testing
```solidity
function invariant_totalSupplyConstant() public {
    assertEq(token.totalSupply(), INITIAL_SUPPLY);
}

function invariant_reserveBacking() public {
    assertTrue(address(reserve).balance >= token.totalSupply());
}
```

## Guidelines

### Test Coverage Strategy
- Achieve 100% line coverage for critical functions
- Test all revert conditions explicitly
- Include edge cases (zero amounts, max values)
- Test interactions between contracts
- Validate event emissions

### Testing Patterns
- Use `setUp()` for test initialization
- One assertion per test for clarity
- Descriptive test function names
- Group related tests in contracts
- Use test helpers for complex setups

### Security Testing
- Test for reentrancy vulnerabilities
- Validate access control thoroughly
- Check for integer overflow/underflow
- Test delegate call interactions
- Verify storage collision resistance

### Performance Testing
- Measure gas consumption
- Benchmark against similar contracts
- Test with realistic data sizes
- Profile storage vs memory usage
- Optimize based on test results

### Integration Testing
- Test contract deployment sequences
- Validate upgrade mechanisms
- Test cross-contract calls
- Verify oracle integrations
- Simulate mainnet conditions with forks