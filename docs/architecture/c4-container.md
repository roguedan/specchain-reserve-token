# C4 Container Diagram - SpecChain Reserve Token

**Level 2: Container Architecture**  
**Audience**: Software architects, senior developers, DevOps engineers  
**Purpose**: Show high-level technology choices and how containers communicate

## Container Diagram

```mermaid
graph TB
    %% External Actors
    Users[👤 Users<br/>Web3 Wallets]
    Issuer[🏛️ Issuer<br/>Administrative EOA]
    Auditors[👨‍💼 Auditors<br/>Monitoring Tools]
    
    %% Core System Containers
    subgraph "SpecChain Reserve Token System"
        SmartContract[📜 RwaToken Smart Contract<br/>Technology: Solidity 0.8.20<br/>Platform: Ethereum Virtual Machine<br/>- ERC-20 implementation<br/>- Reserve requirement validation<br/>- Access control<br/>- Event emission]
        
        EventSystem[📢 Blockchain Event System<br/>Technology: Ethereum Events<br/>Protocol: JSON-RPC<br/>- ReserveChecked events<br/>- Transfer events<br/>- Approval events<br/>- Compliance logging]
    end
    
    %% External Containers
    ReserveWallet[🏦 Reserve Wallet<br/>Technology: EOA/Multi-sig<br/>Blockchain: Ethereum<br/>- Holds backing ETH<br/>- Balance queries<br/>- Multi-sig control (future)]
    
    EthereumNode[⛓️ Ethereum Node<br/>Technology: Geth/Nethermind<br/>Network: Mainnet/Sepolia<br/>- Transaction processing<br/>- State management<br/>- Event emission]
    
    BlockExplorer[🔍 Block Explorer<br/>Technology: React/Next.js<br/>Provider: Etherscan<br/>- Transaction history<br/>- Contract verification<br/>- Public audit interface]
    
    MonitoringService[📊 Monitoring Service<br/>Technology: The Graph/Dune<br/>Protocol: GraphQL/SQL<br/>- Reserve ratio tracking<br/>- Alert systems<br/>- Compliance dashboards]
    
    TestingSuite[🧪 Testing Infrastructure<br/>Technology: Foundry<br/>Framework: Forge/Anvil<br/>- Unit tests<br/>- Fuzz testing<br/>- Invariant testing<br/>- Security validation]
    
    %% Future Containers (dashed)
    PriceOracle[🔮 Price Oracle<br/>Technology: Chainlink<br/>Protocol: AggregatorV3<br/>- Real-time pricing<br/>- Decentralized feeds]
    
    %% Relationships
    Users -->|"transfer() calls<br/>JSON-RPC"| SmartContract
    Issuer -->|"mint() calls<br/>JSON-RPC"| SmartContract
    
    SmartContract -->|"balance queries<br/>eth_getBalance"| ReserveWallet
    SmartContract -->|"emit events<br/>LOG opcodes"| EventSystem
    SmartContract -->|"state changes<br/>SSTORE opcodes"| EthereumNode
    
    EventSystem -->|"event indexing<br/>WebSocket"| MonitoringService
    EventSystem -->|"log queries<br/>eth_getLogs"| BlockExplorer
    
    Auditors -->|"HTTPS requests<br/>REST API"| BlockExplorer
    Auditors -->|"GraphQL queries<br/>HTTPS"| MonitoringService
    
    TestingSuite -->|"deploy & test<br/>JSON-RPC"| SmartContract
    
    %% Future connections (dashed)
    SmartContract -.->|"price feeds<br/>aggregator calls"| PriceOracle
    
    %% Styling
    classDef actor fill:#e1f5fe,stroke:#0288d1,stroke-width:2px
    classDef container fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef external fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef future fill:#fff3e0,stroke:#f57c00,stroke-width:2px,stroke-dasharray: 5 5
    
    class Users,Issuer,Auditors actor
    class SmartContract,EventSystem container
    class ReserveWallet,EthereumNode,BlockExplorer,MonitoringService,TestingSuite external
    class PriceOracle future
```

## Container Responsibilities

### Core System Containers

#### 1. RwaToken Smart Contract
- **Technology**: Solidity 0.8.20, deployed on EVM
- **Responsibilities**:
  - Implement ERC-20 token standard
  - Enforce reserve requirement on every transfer
  - Manage access control (only issuer can mint)
  - Emit compliance events for monitoring
- **Data Stores**: Balances, total supply, allowances
- **Key Interfaces**: transfer(), mint(), approve(), _checkReserveBacking()

#### 2. Blockchain Event System
- **Technology**: Ethereum event logs, JSON-RPC
- **Responsibilities**:
  - Log all state changes for audit trails
  - Provide real-time compliance monitoring
  - Enable off-chain indexing and analysis
- **Event Types**: Transfer, Approval, ReserveChecked
- **Storage**: Immutable blockchain logs

### External Containers

#### 3. Reserve Wallet
- **Technology**: Externally Owned Account (EOA)
- **Future**: Multi-signature wallet (Gnosis Safe)
- **Responsibilities**:
  - Hold backing assets (ETH)
  - Provide balance for reserve ratio calculations
  - Enable controlled reserve management
- **Security**: Private key management, future multi-sig

#### 4. Ethereum Node
- **Technology**: Geth, Nethermind, or Infura/Alchemy
- **Responsibilities**:
  - Process and validate transactions
  - Maintain blockchain state
  - Emit events to event system
- **Networks**: Mainnet, Sepolia testnet

#### 5. Testing Infrastructure
- **Technology**: Foundry (Forge, Anvil, Cast)
- **Responsibilities**:
  - Validate contract functionality
  - Security testing and fuzzing
  - Gas optimization verification
  - Continuous integration
- **Test Types**: Unit, integration, invariant, fuzz

## Communication Patterns

### Synchronous Communication
- **User → Smart Contract**: Direct function calls via JSON-RPC
- **Smart Contract → Reserve Wallet**: Balance queries
- **Testing → Smart Contract**: Test execution

### Asynchronous Communication
- **Smart Contract → Event System**: Event emission
- **Event System → Monitoring**: Event indexing
- **Event System → Block Explorer**: Log aggregation

### Data Protocols
- **JSON-RPC**: Primary blockchain communication
- **WebSocket**: Real-time event streaming
- **HTTP/HTTPS**: Web interface communication
- **GraphQL**: Structured data queries

## Technology Stack

### Blockchain Layer
- **Smart Contract**: Solidity 0.8.20
- **Virtual Machine**: Ethereum EVM
- **Networks**: Ethereum Mainnet, Sepolia

### Development Tools
- **Build System**: Foundry
- **Testing**: Forge with fuzzing
- **Deployment**: Forge scripts
- **Verification**: Etherscan API

### Monitoring & Analytics
- **Indexing**: The Graph Protocol
- **Analytics**: Dune Analytics
- **Alerts**: Custom monitoring service

### Future Enhancements
- **Oracles**: Chainlink price feeds
- **Layer 2**: Arbitrum, Optimism deployment
- **Governance**: Multi-sig, DAO integration

## Deployment Architecture

### Testnet Deployment
```
Sepolia Testnet
├── RwaToken Contract
├── Test Reserve Wallet
└── Monitoring Dashboard
```

### Mainnet Deployment
```
Ethereum Mainnet
├── RwaToken Contract (verified)
├── Multi-sig Reserve Wallet
├── Production Monitoring
└── Emergency Pause (future)
```

## Non-Functional Considerations

### Scalability
- **Throughput**: Limited by Ethereum (~15 TPS)
- **Future**: Layer 2 deployment for higher throughput
- **Optimization**: Batch operations for institutional users

### Security
- **Smart Contract**: Immutable after deployment
- **Reserve Wallet**: Multi-sig control planned
- **Access Control**: Role-based permissions

### Reliability
- **Blockchain**: 99.9%+ uptime via Ethereum network
- **Monitoring**: Real-time alerting on reserve ratio
- **Fallback**: Manual intervention procedures

---

**Previous Level**: [Context Diagram](./c4-context.md)  
**Next Level**: [Component Diagram](./c4-component.md) - Internal contract structure