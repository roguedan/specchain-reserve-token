---
name: tradfi-rwa-compliance
description: Bridge traditional finance concepts with blockchain technology, implementing compliant tokenization of real-world assets with proper regulatory alignment and reserve management
---

# TradFi Integration & RWA Compliance

Implement blockchain solutions that properly represent real-world assets while maintaining regulatory compliance and traditional finance standards. Focus on reserve requirements, audit trails, and legal framework alignment.

## Examples

### Reserve Requirement Implementation
```solidity
contract ReserveBacked {
    uint256 public constant RESERVE_RATIO = 10000; // 100% in basis points
    
    function checkReserveRequirement() public view returns (bool) {
        uint256 requiredReserve = (totalSupply * RESERVE_RATIO) / 10000;
        return reserveBalance >= requiredReserve;
    }
    
    modifier maintainReserve() {
        _;
        require(checkReserveRequirement(), "Reserve requirement not met");
    }
}
```

### Compliance Event Logging
```solidity
event ComplianceCheck(
    uint256 timestamp,
    uint256 totalSupply,
    uint256 reserveBalance,
    uint256 coverageRatio,
    bool compliant
);

function logComplianceStatus() public {
    uint256 ratio = (reserveBalance * 10000) / totalSupply;
    emit ComplianceCheck(
        block.timestamp,
        totalSupply,
        reserveBalance,
        ratio,
        ratio >= RESERVE_RATIO
    );
}
```

### KYC Integration Pattern
```solidity
mapping(address => bool) public kycApproved;
mapping(address => uint256) public kycExpiry;

modifier onlyKYC() {
    require(kycApproved[msg.sender], "KYC required");
    require(kycExpiry[msg.sender] > block.timestamp, "KYC expired");
    _;
}
```

## Guidelines

### Regulatory Alignment
- Map smart contract functions to legal requirements
- Implement clear audit trails for all operations
- Ensure reversibility for regulatory interventions
- Maintain compliance documentation
- Regular legal review of implementations

### Reserve Management
- Implement multi-sig controls for reserves
- Regular attestation requirements
- Clear liquidation procedures
- Transparent reporting mechanisms
- Integration with qualified custodians

### Asset Tokenization Standards
- 1:1 backing for stablecoins
- Fractional ownership for real estate
- Proper title transfer mechanisms
- Clear redemption processes
- Regulatory holds and freezes

### Compliance Frameworks
- Basel III for banking reserves
- MiCA for EU crypto assets
- SEC guidelines for securities
- AML/KYC requirements
- Cross-border considerations

### Documentation Requirements
- Legal opinion alignment
- Regulatory correspondence
- Audit trail preservation
- Compliance matrices
- Risk assessments