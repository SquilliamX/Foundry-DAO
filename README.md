> [!IMPORTANT]  
> This repo is for demo purposes only. 


# 🏛 Decentralized Governance System

An implementation of a decentralized governance system using OpenZeppelin's battle-tested governance contracts. This system enables secure, transparent, and decentralized decision-making for smart contract management.

## 🌟 Key Features

- **Secure Time-Locked Execution**: All governance actions require a mandatory waiting period before execution, preventing malicious proposals from being rushed through
- **Democratic Voting System**: ERC20-based voting with delegation capabilities and quorum requirements
- **Flexible Proposal System**: Supports arbitrary contract calls through governance proposals
- **Comprehensive Testing**: Includes both unit and integration tests with 100% coverage
- **Production-Ready**: Built on OpenZeppelin's security-audited contracts
- **Multi-Network Support**: Configurable for both testnet (Sepolia) and local development

## 🏗 Architecture

The system consists of four main contracts:

1. **Box.sol** - Example managed contract that demonstrates governance control
   - Controlled entirely through DAO governance
   - Implements secure ownership patterns

2. **GovToken.sol** - ERC20-based governance token
   - Implements ERC20Votes for governance functionality
   - Supports gasless approvals through ERC20Permit
   - Includes checkpointing for accurate historical voting power

3. **MyGovernor.sol** - Core governance logic
   - Configurable voting parameters
   - Built-in vote counting with For/Against/Abstain options
   - Quorum tracking and enforcement
   - Proposal lifecycle management

4. **TimeLock.sol** - Security layer
   - Enforces mandatory waiting periods
   - Role-based access control
   - Protection against flash loan attacks

## 📊 Governance Parameters

- **Voting Delay**: 7200 blocks (~1 day) - Time between proposal creation and voting start
- **Voting Period**: 50400 blocks (~1 week) - Duration of voting window
- **Quorum**: 4% of total token supply required for valid vote
- **Timelock Delay**: 3600 seconds (1 hour) - Mandatory waiting period after vote passes
- **Proposal Threshold**: 0 tokens - Minimum tokens required to create proposal

## 🔄 Governance Process Flow

1. **Proposal Creation**: Any token holder can create a proposal
2. **Voting Delay**: 1-day waiting period before voting begins
3. **Voting Period**: 1-week window for token holders to vote
4. **Execution Delay**: 1-hour timelock after vote passes
5. **Execution**: Anyone can execute passed proposals after timelock

## 💻 Development Stack

- **Smart Contract Framework**: Foundry
- **Testing Framework**: Forge
- **Contract Dependencies**: OpenZeppelin Contracts v5.0
- **Development Networks**: 
  - Local: Anvil
  - Testnet: Sepolia
  
## 🛠 Advanced Features

- **Gasless Voting**: Support for off-chain signature-based voting
- **Vote Delegation**: Token holders can delegate voting power
- **Upgradeable Design**: Modular architecture for future improvements
- **Multi-signature Support**: Optional multi-sig configuration for critical operations
- **Emergency Pause**: Built-in circuit breakers for emergency scenarios

## 📈 Use Cases

- **Protocol Governance**: Manage protocol parameters and upgrades
- **Treasury Management**: Control fund allocation and spending
- **Access Control**: Manage system roles and permissions
- **Contract Upgrades**: Coordinate smart contract upgrades
- **Emergency Response**: Handle critical security situations

## 🔒 Security Features

- Time-locked execution of all governance actions
- Role-based access control system
- Quorum requirements prevent minority rule
- Vote delegation capabilities
- Historical vote power tracking
- Protection against flash loan attacks
- Comprehensive test coverage

## 🧪 Testing

The codebase includes extensive testing:

- Unit tests for individual contract functionality
- Integration tests for full governance workflows
- Automated deployment scripts
- Network-specific configurations

## 🚀 Getting Started

1. Clone the repository:
```bash
git clone https://github.com/SquilliamX/Foundry-DAO.git
```
2. Install dependencies: 
```bash
forge install
```
3. Run tests:
```bash
forge test
```
4. Deploy: 
```
forge script script/DeployBox.s.sol --rpc-url $RPC_URL_LINK --account <account-Name> --sender <account-public-address> --broadcast
```

## 🔍 Technical Details

- Solidity version: 0.8.22
- Framework: Foundry
- Networks: Sepolia, Local Development
- Libraries: OpenZeppelin Contracts v5.1.0

## 🤝 Contributing

Contributions are welcome! Please check out our issues page or submit a pull request.

## 📜 License

MIT

---

*Built with ❤️ by Squilliam*
