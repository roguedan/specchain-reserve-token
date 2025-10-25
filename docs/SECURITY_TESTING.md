# Security Testing Guide

This document outlines the comprehensive security testing approach for the Reserve-Backed Token contract.

## Testing Categories

### 1. Static Analysis
Run Slither for automated vulnerability detection:
```bash
pip install slither-analyzer
slither . --config slither.config.json
```

### 2. Unit Security Tests
Located in `tests/ReserveRequirement.security.t.sol`:
- Access control verification
- Overflow/underflow protection
- Reentrancy resistance
- Edge case handling
- Gas consumption limits

Run with:
```bash
forge test --match-path tests/ReserveRequirement.security.t.sol -vvv
```

### 3. Invariant Testing
Located in `tests/ReserveRequirement.invariant.t.sol`:
- Reserve always covers supply
- Sum of balances equals total supply
- No balance exceeds total supply

Run with:
```bash
forge test --match-path tests/ReserveRequirement.invariant.t.sol -vvv
```

### 4. Fuzz Testing
Located in `tests/ReserveRequirement.fuzz.t.sol`:
- Random amount minting
- Random transfers
- Reserve manipulation scenarios
- Multiple operation sequences

Run with:
```bash
# Standard fuzz run (256 runs)
forge test --match-path tests/ReserveRequirement.fuzz.t.sol -vvv

# Extended fuzz run (10,000 runs)
forge test --match-path tests/ReserveRequirement.fuzz.t.sol --fuzz-runs 10000 -vvv
```

## Security Checklist

### Access Control
- [x] Only issuer can mint
- [x] Cannot mint to zero address
- [x] Proper modifier implementation

### Arithmetic Safety
- [x] Using Solidity 0.8+ automatic overflow protection
- [x] Tested with extreme values
- [x] No unchecked blocks

### External Calls
- [x] No external calls in critical paths
- [x] Check-Effects-Interactions pattern followed
- [x] No reentrancy vulnerabilities

### Reserve Invariant
- [x] Checked before every state change
- [x] Cannot be bypassed
- [x] Events logged for monitoring

### Gas Optimization
- [x] Reasonable gas costs
- [x] No unbounded loops
- [x] Efficient storage usage

## Running All Security Tests

```bash
# Run all security-related tests
forge test --match-path "tests/ReserveRequirement.security.t.sol|tests/ReserveRequirement.invariant.t.sol|tests/ReserveRequirement.fuzz.t.sol" -vvv

# Generate gas report
forge test --gas-report

# Run slither
slither .

# Check coverage
forge coverage --report summary
```

## Known Issues & Mitigations

1. **Simple Reserve Check**: Currently uses `balance` directly
   - Mitigation: Future oracle integration for real-world reserves

2. **No Pause Mechanism**: Cannot halt operations in emergency
   - Mitigation: Add pause functionality in production

3. **Single Issuer**: Centralized minting control
   - Mitigation: Multi-sig or DAO governance in production

4. **Post-Mint Reserve Drain**: Reserve can be drained after minting
   - Finding: Invariant tests reveal that minting tokens and then draining reserves breaks the invariant
   - Impact: Existing token holders can be left without backing
   - Mitigation: Implement timelock on reserve withdrawals, multi-sig control, or pause mechanism

## Audit Preparation

Before external audit:
1. Run all test suites with maximum fuzz runs
2. Generate and review coverage report
3. Document all assumptions and limitations
4. Create threat model diagram
5. Prepare deployment scripts for testnet

## Continuous Security

- Set up CI/CD to run tests on every commit
- Monitor deployed contracts with Forta agents
- Regular security reviews for upgrades
- Incident response plan in place