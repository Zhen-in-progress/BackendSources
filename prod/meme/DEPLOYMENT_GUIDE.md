# Enhanced Meme Token - Deployment & Usage Guide

## Overview

This contract includes three major features:
1. **Tax Mechanism**: Automatic tax collection on buy/sell/transfer
2. **Liquidity Pool Integration**: Auto-liquidity and Uniswap V2 integration
3. **Trading Restrictions**: Anti-whale, anti-bot, and transaction limits

---

## Deployment Steps

### 1. Prerequisites

- Solidity compiler version: `^0.8.0`
- Network: Ethereum, BSC, or any EVM-compatible chain
- Tools: Remix, Hardhat, or Foundry

### 2. Constructor Parameters

```solidity
constructor(
    string memory _name,           // Token name, e.g., "MyMemeToken"
    string memory _symbol,         // Token symbol, e.g., "MMT"
    uint8 _decimals,               // Decimals, usually 18
    uint256 _initialSupply,        // Initial supply (without decimals), e.g., 1000000 for 1M tokens
    address _routerAddress         // Uniswap V2 Router address (see below)
)
```

### 3. Uniswap Router Addresses

**Ethereum Mainnet/Sepolia:**
```
0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
```

**BSC Mainnet/Testnet (PancakeSwap):**
```
0x10ED43C718714eb63d5aA57B78B54704E256024E
```

**Polygon (QuickSwap):**
```
0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
```

### 4. Example Deployment (Remix)

```solidity
// Deploy with:
// Name: "MyMemeToken"
// Symbol: "MMT"
// Decimals: 18
// Initial Supply: 1000000 (will become 1,000,000,000,000,000,000,000,000)
// Router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D (Ethereum)
```

### 5. Post-Deployment Configuration

After deployment, call these functions in order:

```javascript
// 1. Set tax wallets (optional, defaults to owner)
setTaxWallets(marketingAddress, devAddress, liquidityAddress)

// 2. Add initial liquidity
addLiquidityManual(tokenAmount) // Send ETH with this call

// 3. Enable trading
enableTrading()
```

---

## Feature Configuration

### Tax System

**Default Settings:**
- Buy Tax: 5%
- Sell Tax: 7%
- Transfer Tax: 3%

**Tax Distribution:**
- Marketing: 40%
- Development: 30%
- Liquidity: 30%

**Configure Taxes:**
```javascript
// Set tax rates (in basis points: 500 = 5%)
setTaxRates(
    500,  // Buy tax: 5%
    700,  // Sell tax: 7%
    300   // Transfer tax: 3%
)

// Set tax distribution (must total 10000)
setTaxDistribution(
    4000, // Marketing: 40%
    3000, // Dev: 30%
    3000  // Liquidity: 30%
)

// Set tax wallets
setTaxWallets(
    "0x...", // Marketing wallet
    "0x...", // Dev wallet
    "0x..."  // Liquidity wallet
)
```

**Manual Tax Distribution:**
```javascript
distributeTax() // Sends accumulated tax to wallets
```

---

### Liquidity Pool Integration

**Auto-Liquidity:**
- Automatically triggers when accumulated tax reaches threshold
- Default threshold: 1,000 tokens
- Can be disabled/enabled

**Configure Auto-Liquidity:**
```javascript
// Set threshold (in tokens with decimals)
setSwapTokensAtAmount(1000 * 10**18)

// Enable/disable auto-liquidity
setSwapAndLiquifyEnabled(true)
```

**Manual Liquidity Addition:**
Users can add liquidity directly:
```javascript
// User calls this with ETH
addLiquidityManual(tokenAmount) { value: ethAmount }
```

---

### Trading Restrictions

**Default Limits:**
- Max Transaction: 1% of total supply
- Max Wallet: 2% of total supply
- Max Daily Amount: 5% of total supply
- Max Daily Transactions: 10
- Cooldown: 30 seconds

**Configure Limits:**
```javascript
// Set transaction limits
setTransactionLimits(
    maxTransactionAmount, // e.g., 10000 * 10**18
    maxWalletAmount       // e.g., 20000 * 10**18
)

// Set daily limits
setDailyLimits(
    10,                   // Max transactions per day
    50000 * 10**18        // Max amount per day
)

// Set cooldown (in seconds, max 300)
setCooldownTime(30)
```

**Exempt Addresses:**
```javascript
// Exempt from taxes
setTaxExempt(address, true)

// Exempt from limits
setLimitExempt(address, true)
```

---

### Anti-Bot Protection

**Features:**
- Blacklist functionality
- Anti-snipe protection (limits gas price in first blocks)
- Trading enable/disable

**Configure Anti-Bot:**
```javascript
// Set anti-snipe parameters
setAntiSnipeConfig(
    3,        // Number of blocks to restrict
    15 gwei   // Max gas price during anti-snipe
)

// Blacklist address
setBlacklist(address, true)

// Bulk blacklist
bulkBlacklist([addr1, addr2, addr3], true)
```

---

## Admin Functions

### Essential Admin Operations

```javascript
// 1. Enable trading (call once ready)
enableTrading()

// 2. Update tax rates
setTaxRates(buyTax, sellTax, transferTax)

// 3. Update wallets
setTaxWallets(marketing, dev, liquidity)

// 4. Adjust limits
setTransactionLimits(maxTx, maxWallet)

// 5. Mint new tokens (if needed)
mint(address, amount)

// 6. Transfer ownership
transferOwnership(newOwner)

// 7. Rescue stuck ETH
rescueETH()
```

---

## Testing Checklist

### Pre-Launch
- [ ] Deploy contract on testnet
- [ ] Verify all constructor parameters
- [ ] Set custom tax wallets (if not using owner)
- [ ] Add initial liquidity
- [ ] Test buy transaction (should apply buy tax)
- [ ] Test sell transaction (should apply sell tax)
- [ ] Test transfer transaction (should apply transfer tax)
- [ ] Verify tax distribution
- [ ] Test max transaction limit
- [ ] Test max wallet limit
- [ ] Test cooldown mechanism
- [ ] Test daily limits
- [ ] Enable trading
- [ ] Test anti-snipe (gas price limit)
- [ ] Test blacklist functionality

### Post-Launch Monitoring
- [ ] Monitor liquidity pool
- [ ] Check tax collection
- [ ] Verify auto-liquidity triggers
- [ ] Monitor for suspicious wallets
- [ ] Check transaction limits are working

---

## View Functions (For Frontend Integration)

```javascript
// Get current tax rate for a transaction
getCurrentTaxRate(from, to)

// Check if address can trade
canTrade(address)

// Get daily limit info for address
getDailyLimitInfo(address)
// Returns: (txCount, txAmount, remainingTx, remainingAmount)

// Check exemptions
isExemptFromTax(address)
isExemptFromLimits(address)

// Check blacklist
isBlacklisted(address)
```

---

## Security Considerations

### Best Practices

1. **Tax Limits**: Keep taxes reasonable (< 20%)
2. **Transaction Limits**: Don't set too restrictive (min 0.1%)
3. **Cooldown**: Max 5 minutes to avoid user frustration
4. **Testing**: Always test on testnet first
5. **Audit**: Consider professional audit before mainnet
6. **Ownership**: Transfer to multisig after launch
7. **Liquidity**: Lock liquidity to prevent rug pulls

### Potential Risks

1. **Centralization**: Owner has significant control
2. **Blacklist Power**: Owner can blacklist any address
3. **Tax Changes**: Owner can change tax rates
4. **Limit Changes**: Owner can adjust transaction limits

### Mitigation Strategies

```solidity
// After launch, consider:
// 1. Renouncing ownership (irreversible!)
renounceOwnership() // Add this function if needed

// 2. Transfer to timelock contract
transferOwnership(timelockAddress)

// 3. Transfer to multisig
transferOwnership(multisigAddress)
```

---

## Common Use Cases

### Scenario 1: Standard Meme Token Launch

```javascript
// 1. Deploy with 1M supply
// 2. Set marketing wallet
setTaxWallets(marketingWallet, devWallet, address(this))

// 3. Add 50% of supply to liquidity
approve(router, 500000 * 10**18)
addLiquidityManual(500000 * 10**18) { value: 10 ETH }

// 4. Enable trading
enableTrading()
```

### Scenario 2: Fair Launch with Anti-Snipe

```javascript
// 1. Deploy contract
// 2. Set strict anti-snipe
setAntiSnipeConfig(10, 5 gwei) // First 10 blocks, max 5 gwei

// 3. Add liquidity
addLiquidityManual(amount) { value: ethAmount }

// 4. Enable trading
enableTrading()

// 5. After 10 blocks, relax limits
setAntiSnipeConfig(0, 100 gwei)
```

### Scenario 3: Adjusting Post-Launch

```javascript
// Reduce sell tax after week 1
setTaxRates(500, 500, 300) // 5% buy, 5% sell, 3% transfer

// Increase limits as market cap grows
setTransactionLimits(
    totalSupply * 2 / 100,  // 2% max tx
    totalSupply * 5 / 100   // 5% max wallet
)

// Remove cooldown for better UX
setCooldownTime(0)
```

---

## Emergency Procedures

### If Needed to Pause Trading

```javascript
// Blacklist malicious contracts
setBlacklist(maliciousAddress, true)

// Note: There's no pause function, but you can:
// - Blacklist problematic addresses
// - Set very restrictive limits temporarily
```

### If Contract Has Issues

```javascript
// Rescue stuck ETH
rescueETH()

// Distribute remaining tax
distributeTax()

// Transfer ownership to new contract/multisig
transferOwnership(safeAddress)
```

---

## Gas Optimization Tips

1. **Batch Operations**: Use `bulkBlacklist()` instead of multiple calls
2. **Auto-Liquidity**: Set higher threshold to reduce frequency
3. **Exemptions**: Exempt high-volume wallets from limits

---

## Integration Examples

### Web3.js Example

```javascript
const contract = new web3.eth.Contract(ABI, contractAddress);

// Get tax rate for buy
const buyTaxRate = await contract.methods.buyTaxRate().call();
console.log("Buy Tax:", buyTaxRate / 100, "%");

// Check if can trade
const canTrade = await contract.methods.canTrade(userAddress).call();

// Get daily limits
const limits = await contract.methods.getDailyLimitInfo(userAddress).call();
console.log("Remaining daily transactions:", limits.remainingTx);
```

### Ethers.js Example

```javascript
const contract = new ethers.Contract(contractAddress, ABI, signer);

// Enable trading (owner only)
await contract.enableTrading();

// Add liquidity
await contract.addLiquidityManual(
    ethers.utils.parseEther("1000"),
    { value: ethers.utils.parseEther("1") }
);
```

---

## FAQ

**Q: Can I change the router after deployment?**
A: No, the router and pair are set in constructor. Deploy a new contract if needed.

**Q: How do I disable taxes completely?**
A: Set all tax rates to 0: `setTaxRates(0, 0, 0)`

**Q: Can users remove liquidity?**
A: Yes, if they hold LP tokens. Consider locking liquidity for trust.

**Q: What happens if I set cooldown to 0?**
A: Cooldown is disabled, allowing back-to-back transactions.

**Q: How do I calculate tax in basis points?**
A: 1% = 100, 5% = 500, 10% = 1000, 20% = 2000 (out of 10000)

---

## Support & Resources

- Uniswap V2 Docs: https://docs.uniswap.org/contracts/v2/overview
- Solidity Docs: https://docs.soliditylang.org/
- OpenZeppelin: https://docs.openzeppelin.com/

---

## License

MIT License - Use at your own risk. Always test thoroughly before mainnet deployment.
