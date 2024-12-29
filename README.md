
# LFGenesis (LFGEN) Token Documentation

## Overview
LFGenesis is an innovative ERC20 token developed on the Avalanche C-Chain with unique tokenomics and distribution mechanics.

## Contract Details
- **Address**: `0xaC6487fF5063bF4249594B150aB95E1867BEc9d3`
- **Network**: Avalanche C-Chain
- **Standard**: ERC20, UUPS Upgradeable

## Token Metrics
- **Total Supply**: 1,000,000 LFGEN
- **Owner Allocation**: 100,000 LFGEN (10%)
- **Mint Pool**: 900,000 LFGEN (90%)

## Distribution Mechanics

### Mint System
- **Initial Mint Amount**: 10 LFGEN
- **Distribution**:
  - 50% to minting wallet
  - 45% to holder reflection pool
  - 5% to active users pool
  - 10% burn from reflection amount

### Phase System
- Phase changes every 1,000 wallets
- Each phase:
  - Mint amount halves
  - Reflection rate halves
  - Cooldown period doubles
  - Transaction limits adjust dynamically

### Reflection Mechanism
- **Top Holders**: 300 wallets receive primary rewards
- **Active Users**: 33 wallets receive additional benefits
- **Memecoin Holders**: Special allocation for specific memecoin holders
  - TECH
  - COQ
  - NOCHILL
  - ARENA

## Technical Architecture

### Smart Contract Features
1. **Upgradeable Design**
   - UUPS (Universal Upgradeable Proxy Standard)
   - Allows contract upgrades while preserving state

2. **Security Measures**
   - Reentrancy Guard
   - SafeMath Implementation
   - Access Control
   - Pausable Mechanism
   - Upgradeable Security

3. **Gas Optimizations**
   - Storage Layout Optimization
   - Memory vs Storage Usage
   - Batch Transaction Support

### Key Functions
```solidity
function mint() external
function getCurrentPhase() public view returns (uint256)
function getCurrentMintAmount() public view returns (uint256)
function getCurrentReflectionRate() public view returns (uint256)
function getDetailedTokenInfo() public view returns (...)
function getMintSessionInfo() public view returns (...)
```

## Mint Rules
1. One-time mint per wallet
2. Dynamic cooldown periods
3. Phase-based transaction limits
4. Fair distribution algorithm
5. Automatic reflection distribution

## Tokenomics Features
1. **Dynamic Supply Control**
   - Automatic burn mechanism
   - Reflection-based distribution
   - Phase-based mint reduction

2. **Anti-Whale Mechanics**
   - Limited mint per wallet
   - Cooldown periods
   - Transaction limits

3. **Community Rewards**
   - Holder reflections
   - Active user bonuses
   - Memecoin holder benefits

## Technical Integration
```javascript
// Contract Initialization
const CONTRACT_ADDRESS = "0xaC6487fF5063bF4249594B150aB95E1867BEc9d3";
const web3 = new Web3('https://api.avax.network/ext/bc/C/rpc');
const contract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);

// Mint Function Call
await contract.methods.mint().send({from: userAddress});

// Get Token Info
const info = await contract.methods.getDetailedTokenInfo().call();
```

## Development Tools
- Solidity ^0.8.19
- OpenZeppelin Contracts
- Web3.js
- Avalanche Network

## Monitoring & Updates
- Real-time metrics updates every 5 seconds
- Automatic phase transitions
- Dynamic reflection calculations
- Live holder statistics

## Security Considerations
1. Smart contract audited
2. Upgradeable architecture
3. Access control implementation
4. Anti-bot measures
5. Fair distribution mechanisms

This documentation provides a comprehensive overview of the LFGenesis token system. For specific implementation details or technical questions, refer to the smart contract code or contact the development team.
