# Project Skills Overview

This directory contains skill definitions following the [Anthropic Skills format](https://github.com/anthropics/skills) for the SpecChain Reserve Token project. Each skill is self-contained in its own directory with a `SKILL.md` file.

## Core Skills

### 1. [Solidity Smart Contracts](./solidity-smart-contracts/SKILL.md)
Develop secure and efficient smart contracts in Solidity, implementing token standards, access controls, and business logic invariants for blockchain applications.

### 2. [Blockchain Testing](./blockchain-testing/SKILL.md)
Design and implement comprehensive test suites for smart contracts using modern testing frameworks, including unit tests, integration tests, fuzzing, and invariant testing.

### 3. [TradFi RWA Compliance](./tradfi-rwa-compliance/SKILL.md)
Bridge traditional finance concepts with blockchain technology, implementing compliant tokenization of real-world assets with proper regulatory alignment and reserve management.

### 4. [DevOps Deployment](./devops-deployment/SKILL.md)
Deploy and manage smart contracts across multiple networks with proper verification, monitoring, and operational security practices.

### 5. [Technical Documentation](./technical-documentation/SKILL.md)
Create comprehensive technical documentation for blockchain projects including user guides, API references, architecture diagrams, and compliance documentation for multiple audiences.

### 6. [C4 Architecture Diagrams](./c4-architecture-diagrams/SKILL.md)
Create comprehensive C4 model diagrams for software architecture documentation using Context, Container, Component, and Code levels to visualize system structure and relationships.

## Skill Application Matrix

| Skill Area | Applied In Project | Priority |
|------------|-------------------|----------|
| Solidity Development | Core token contract with reserve checking | Critical |
| Testing Framework | Comprehensive test suite with edge cases | Critical |
| Security Patterns | Invariant protection, access control | Critical |
| TradFi Knowledge | Reserve requirement implementation | High |
| Technical Writing | README, specs, skill docs, diagrams | High |
| C4 Architecture | Complete system documentation (4 levels) | High |
| Deployment Skills | Testnet deployment, verification | High |
| Monitoring | Event logging, reserve tracking | Medium |

## Learning Path

For developers looking to contribute to similar RWA projects:

1. **Start with Solidity basics** - Understand the language and EVM
2. **Master testing** - Learn Foundry/Hardhat for robust test coverage
3. **Study security** - Review common vulnerabilities and best practices
4. **Understand finance** - Learn reserve requirements and tokenization
5. **Practice deployment** - Deploy to testnets and verify contracts
6. **Documentation skills** - Clear technical writing for multiple audiences

## Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/)
- [RWA Tokenization Guide](https://www.coinbase.com/institutional/research-insights/research/market-intelligence/guide-to-tokenizing-real-world-assets)
- [MiCA Regulation](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:52020PC0593)