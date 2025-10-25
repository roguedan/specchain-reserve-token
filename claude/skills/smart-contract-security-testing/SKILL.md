# Smart Contract Security Testing

A comprehensive security testing framework for Solidity smart contracts implementing automated red team methodologies, static analysis, fuzzing, and formal verification in CI/CD pipelines.

## Overview

This skill implements industry-standard security testing practices for smart contracts based on 2024-2025 best practices, including automated penetration testing methodologies that simulate real-world attack scenarios beyond traditional audits.

## Capabilities

### Automated Security Pipeline
- **Static Analysis**: Slither vulnerability detection (92+ detectors)
- **Property-Based Fuzzing**: Echidna invariant testing 
- **Symbolic Execution**: Mythril deep analysis
- **Formal Verification**: Halmos and Manticore integration
- **Code Quality**: Solhint linting and style validation

### Red Team Methodologies
- **Flash Loan Attack Simulation**: Test against DeFi attack vectors
- **Multi-layer Security Checks**: Beyond code review to behavioral testing
- **Coverage-Guided Fuzzing**: Parallel worker fuzzing with Medusa
- **Real-world Attack Scenarios**: Logic flaw and edge case discovery

### CI/CD Integration
- **GitHub Actions Workflows**: Ready-to-deploy security pipelines
- **Tiered Testing Approach**: Fast checks → Deep analysis → Professional pentesting
- **Automated Reporting**: Security badges and dashboard integration
- **Fail-Safe Configuration**: Pipeline protection with configurable thresholds

## Tools & Technologies

### Primary Security Stack (All Free/OSS)
- **Slither** - Static analysis framework (Trail of Bits)
- **Echidna** - Property-based fuzzing (Trail of Bits)  
- **Mythril** - Symbolic execution (ConsenSys)
- **Manticore** - Advanced symbolic execution (Trail of Bits)
- **Solhint** - Solidity linting and style validation

### Advanced Tools
- **Medusa** - Parallel fuzzing (most powerful public fuzzer)
- **Halmos** - Formal verification (a16z)
- **Aderyn** - Modern Rust-based static analysis
- **Securify** - ETH Zurich formal verification

### Integration Tools
- **GitHub Actions** - CI/CD automation
- **Docker** - Containerized security environments
- **Foundry** - Development framework integration

## Implementation Patterns

### Tiered Security Approach

#### Tier 1: Fast Checks (Every PR - <10 minutes)
```yaml
# .github/workflows/security-fast.yml
- Foundry forge test (unit + fuzz)
- Slither static analysis
- Solhint code quality
```

#### Tier 2: Deep Analysis (Nightly/Pre-release)
```yaml
# .github/workflows/security-deep.yml  
- Echidna property-based fuzzing
- Mythril symbolic execution
- Extended test suites
```

#### Tier 3: Advanced Testing (Pre-release only)
```yaml
# .github/workflows/security-advanced.yml
- Manticore symbolic execution
- Formal verification
- Professional penetration testing simulation
```

### Security Configuration Templates

#### Comprehensive GitHub Action
```yaml
name: Smart Contract Security Analysis
on: [push, pull_request]

jobs:
  security-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
        
      - name: Run Security Analysis
        uses: outdef/contract-vulnerability-action
        with:
          solc-version: 0.8.20
          target: "contracts/"
          fail-on: "medium"
          echidna-contract: "YourContract"
          slither-config: "slither.config.json"
          mythril-args: "--solc-json mythril.config.json"
```

#### Slither Configuration
```json
{
  "filter_paths": ["lib/", "node_modules/"],
  "exclude_informational": false,
  "exclude_low": false,
  "exclude_medium": false,
  "exclude_high": false,
  "exclude_dependencies": true,
  "show_ignored_findings": false
}
```

#### Echidna Property Testing
```solidity
// echidna/EchidnaTest.sol
pragma solidity ^0.8.0;

import "../contracts/YourContract.sol";

contract EchidnaTest is YourContract {
    
    // Invariant: Total supply should always equal sum of balances
    function echidna_total_supply_equals_balances() public view returns (bool) {
        // Implementation depends on contract logic
        return true;
    }
    
    // Invariant: Reserve should always cover total supply
    function echidna_reserve_covers_supply() public view returns (bool) {
        return address(this).balance >= totalSupply();
    }
    
    // Property: Transfer should preserve total supply
    function echidna_transfer_preserves_supply() public view returns (bool) {
        return totalSupply() > 0;
    }
}
```

## Security Testing Methodology

### 1. Vulnerability Classification
- **Critical**: Immediate fund loss, privilege escalation
- **High**: Significant economic impact, protocol manipulation
- **Medium**: Limited economic impact, DoS conditions  
- **Low**: Code quality, gas optimization
- **Informational**: Best practices, documentation

### 2. Attack Vector Coverage
- **Reentrancy**: Cross-function and single-function variants
- **Integer Overflow/Underflow**: Arithmetic safety validation
- **Access Control**: Privilege escalation and bypass attempts
- **Flash Loan Attacks**: Price manipulation and governance attacks
- **Front-running**: MEV and transaction ordering vulnerabilities
- **Logic Flaws**: Business logic and state machine errors

### 3. Testing Strategies
- **Unit Testing**: Individual function validation
- **Integration Testing**: Contract interaction validation  
- **Fuzz Testing**: Random input edge case discovery
- **Property Testing**: Invariant preservation validation
- **Symbolic Execution**: Path exploration and constraint solving
- **Formal Verification**: Mathematical proof of correctness

## Implementation Guide

### Quick Start (5 minutes)
1. **Copy security workflow**: Use the GitHub Action template
2. **Configure tools**: Add slither.config.json and echidna config
3. **Define properties**: Create Echidna invariant tests
4. **Set thresholds**: Configure fail-on levels for CI/CD

### Advanced Setup (30 minutes)
1. **Custom Echidna tests**: Define contract-specific invariants
2. **Mythril integration**: Configure symbolic execution parameters
3. **Multi-stage pipeline**: Implement tiered security approach
4. **Dashboard integration**: Add security badges and reporting

### Professional Integration (2 hours)
1. **Formal verification**: Implement Halmos/Manticore testing
2. **Red team simulation**: Create attack scenario testing
3. **Performance optimization**: Parallel execution and caching
4. **Security monitoring**: Continuous vulnerability assessment

## Best Practices

### CI/CD Pipeline Security
- **Fail-fast approach**: Stop on critical vulnerabilities
- **Parallel execution**: Run tests concurrently for speed
- **Artifact preservation**: Save detailed reports for analysis
- **Threshold configuration**: Customize security requirements per project

### Test Coverage Strategy
- **100% line coverage**: Ensure all code paths tested
- **Property coverage**: Validate all business logic invariants  
- **Attack vector coverage**: Test against known vulnerability patterns
- **Edge case coverage**: Fuzz testing for unexpected inputs

### Security Monitoring
- **Continuous assessment**: Regular re-testing with updated tools
- **Vulnerability tracking**: Monitor for new attack patterns
- **Performance monitoring**: Track gas usage and optimization opportunities
- **Compliance validation**: Ensure regulatory requirement adherence

## Common Patterns

### DeFi Security Testing
```solidity
// Price manipulation resistance
function echidna_price_manipulation_resistance() public view returns (bool);

// Flash loan attack prevention  
function echidna_flash_loan_protection() public view returns (bool);

// Liquidity drain prevention
function echidna_liquidity_protection() public view returns (bool);
```

### Access Control Testing
```solidity
// Role-based access control validation
function echidna_rbac_enforcement() public view returns (bool);

// Ownership transfer security
function echidna_ownership_security() public view returns (bool);

// Emergency function protection
function echidna_emergency_access_control() public view returns (bool);
```

### Economic Security Testing
```solidity
// Token supply invariants
function echidna_supply_invariants() public view returns (bool);

// Reserve backing validation
function echidna_reserve_backing() public view returns (bool);

// Economic attack resistance
function echidna_economic_security() public view returns (bool);
```

## Integration Examples

### Foundry Integration
```bash
# Run security testing with Foundry
forge test --fuzz-runs 10000
forge test --invariant-runs 1000 --invariant-depth 100
```

### Docker Integration
```dockerfile
FROM ghcr.io/crytic/eth-security-toolbox

COPY . /workspace
WORKDIR /workspace

RUN slither . --json slither-report.json
RUN echidna contracts/YourContract.sol --contract EchidnaTest
```

### Hardhat Integration
```javascript
// hardhat.config.js
module.exports = {
  plugins: ["@nomiclabs/hardhat-foundry"],
  // Security testing configuration
};
```

## Performance Considerations

### Execution Time Management
- **Fast checks**: <10 minutes for PR validation
- **Deep analysis**: 30-60 minutes for comprehensive testing
- **Advanced testing**: 2-4 hours for formal verification

### Resource Optimization  
- **Parallel execution**: Utilize multiple workers
- **Caching strategies**: Reuse analysis results when possible
- **Incremental testing**: Only test changed components

### Scalability Patterns
- **Modular testing**: Break large contracts into testable units
- **Selective execution**: Run appropriate tests based on changes
- **Progressive enhancement**: Start simple, add complexity over time

## Security Standards Compliance

### Industry Standards
- **OpenZeppelin**: Security pattern compliance
- **ConsenSys**: Smart contract best practices
- **Trail of Bits**: Security engineering guidelines
- **OWASP**: Web application security principles

### Regulatory Compliance
- **TradFi Integration**: Traditional finance security requirements
- **Audit Preparation**: Professional audit readiness
- **Documentation Standards**: Security documentation best practices
- **Transparency Requirements**: Public security validation

## Troubleshooting

### Common Issues
- **False positives**: Configure tool sensitivity appropriately
- **Performance bottlenecks**: Optimize test execution order
- **Integration conflicts**: Resolve tool compatibility issues
- **Configuration errors**: Validate tool-specific settings

### Debug Strategies
- **Verbose output**: Enable detailed logging for analysis
- **Isolated testing**: Test individual components separately
- **Tool validation**: Verify tool installation and configuration
- **Community resources**: Leverage tool-specific documentation

## Resources

### Official Documentation
- [Slither Documentation](https://github.com/crytic/slither)
- [Echidna Tutorial](https://github.com/crytic/echidna)
- [Mythril Documentation](https://github.com/ConsenSys/mythril)
- [Trail of Bits Security Guide](https://github.com/crytic/awesome-ethereum-security)

### Community Resources
- [Smart Contract Security Verification Standard](https://github.com/securing/SCSVS)
- [DeFi Security Best Practices](https://github.com/transmissions11/defi-sec)
- [Ethereum Security Tools](https://github.com/crytic/awesome-ethereum-security)

## Version Information
- **Created**: 2024-10-25
- **Framework Compatibility**: Foundry, Hardhat, Truffle
- **Solidity Version**: 0.8.x+ (configurable)
- **Tool Versions**: Latest stable releases of all security tools