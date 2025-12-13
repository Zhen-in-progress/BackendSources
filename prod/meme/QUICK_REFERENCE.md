# Enhanced Meme Token - Quick Reference

## Contract Features Summary

| Feature | Status | Description |
|---------|--------|-------------|
| ✅ Tax System | Enabled | Buy/Sell/Transfer taxes with configurable rates |
| ✅ Auto-Liquidity | Enabled | Automatic liquidity addition from collected taxes |
| ✅ Transaction Limits | Enabled | Max transaction and max wallet limits |
| ✅ Cooldown | Enabled | Time delay between transactions |
| ✅ Daily Limits | Enabled | Max daily transactions and amounts |
| ✅ Anti-Snipe | Enabled | Gas price limits in first blocks |
| ✅ Blacklist | Enabled | Ban malicious addresses |
| ✅ Tax Exemptions | Enabled | Whitelist addresses from taxes |
| ✅ Limit Exemptions | Enabled | Whitelist addresses from limits |

---

## Default Configuration

```javascript
// Tax Rates (out of 10000)
buyTaxRate       = 500    // 5%
sellTaxRate      = 700    // 7%
transferTaxRate  = 300    // 3%

// Tax Distribution (out of 10000)
marketingShare   = 4000   // 40%
devShare         = 3000   // 30%
liquidityShare   = 3000   // 30%

// Transaction Limits (% of total supply)
maxTransactionAmount = 1%
maxWalletAmount      = 2%
maxDailyAmount       = 5%

// Other Limits
maxDailyTransactions = 10
cooldownTime         = 30 seconds

// Auto-Liquidity
swapTokensAtAmount   = 1000 tokens
swapAndLiquifyEnabled = true

// Anti-Snipe
antiSnipeBlocks      = 3 blocks
maxGasPriceLimit     = 15 gwei

// Trading
tradingEnabled       = false (manual enable required)
```

---

## Essential Functions (Owner Only)

### Deployment & Initial Setup

```solidity
// 1. Deploy contract
constructor(name, symbol, decimals, initialSupply, routerAddress)

// 2. Configure wallets (optional)
setTaxWallets(marketing, dev, liquidity)

// 3. Add initial liquidity
addLiquidityManual(tokenAmount) payable

// 4. Enable trading (IMPORTANT!)
enableTrading()
```

---

## Tax Management

```solidity
// View current rates
buyTaxRate()      // Returns: uint256 (e.g., 500 = 5%)
sellTaxRate()     // Returns: uint256
transferTaxRate() // Returns: uint256

// Change tax rates (max 20%)
setTaxRates(buyTax, sellTax, transferTax)
// Example: setTaxRates(300, 500, 200) // 3% buy, 5% sell, 2% transfer

// Change tax distribution (must total 10000)
setTaxDistribution(marketing, dev, liquidity)
// Example: setTaxDistribution(5000, 2500, 2500) // 50%, 25%, 25%

// Update tax wallets
setTaxWallets(marketingAddress, devAddress, liquidityAddress)

// Manually distribute accumulated tax
distributeTax()

// Exempt address from taxes
setTaxExempt(address, true)

// View tax for specific transaction
getCurrentTaxRate(from, to) // Returns: uint256
```

---

## Liquidity Management

```solidity
// Auto-liquidity settings
swapAndLiquifyEnabled()      // View status
swapTokensAtAmount()         // View threshold
accumulatedTaxForLiquidity() // View accumulated tax

// Configure auto-liquidity
setSwapAndLiquifyEnabled(true/false)
setSwapTokensAtAmount(amount) // e.g., 1000 * 10**18

// Manual liquidity addition (anyone can call)
addLiquidityManual(tokenAmount) payable

// View pair address
uniswapV2Pair() // Returns: address
```

---

## Trading Restrictions

```solidity
// View current limits
maxTransactionAmount()  // Returns: uint256
maxWalletAmount()       // Returns: uint256
maxDailyAmount()        // Returns: uint256
maxDailyTransactions()  // Returns: uint256
cooldownTime()          // Returns: uint256

// Change transaction limits (min 0.1%)
setTransactionLimits(maxTx, maxWallet)
// Example: setTransactionLimits(10000 * 10**18, 20000 * 10**18)

// Change daily limits
setDailyLimits(maxDailyTx, maxDailyAmount)
// Example: setDailyLimits(20, 100000 * 10**18)

// Change cooldown (max 300 seconds)
setCooldownTime(seconds)
// Example: setCooldownTime(60) // 1 minute

// Exempt address from limits
setLimitExempt(address, true)

// View daily limit info for address
getDailyLimitInfo(address)
// Returns: (txCount, txAmount, remainingTx, remainingAmount)
```

---

## Anti-Bot & Security

```solidity
// Trading control
tradingEnabled()         // View status
tradingEnabledTimestamp() // View enable time
launchBlock()            // View launch block

// Enable trading (can only call once)
enableTrading()

// Anti-snipe configuration
setAntiSnipeConfig(blocks, maxGasPrice)
// Example: setAntiSnipeConfig(5, 10 gwei)

// Blacklist management
isBlacklisted(address)           // Check if blacklisted
setBlacklist(address, true/false) // Blacklist/unblacklist
bulkBlacklist([addr1, addr2], true) // Batch blacklist

// Check if address can trade
canTrade(address) // Returns: bool
```

---

## User Functions (No Owner Required)

```solidity
// Standard ERC20
balanceOf(address)
totalSupply()
transfer(to, amount)
approve(spender, amount)
transferFrom(from, to, amount)
allowance(owner, spender)

// Liquidity
addLiquidityManual(tokenAmount) payable // Anyone can add liquidity
```

---

## View Functions (For DApps/Frontends)

```solidity
// Token info
name()
symbol()
decimals()
totalSupply()
balanceOf(address)

// Ownership
owner()

// Tax info
buyTaxRate()
sellTaxRate()
transferTaxRate()
marketingWallet()
devWallet()
liquidityWallet()
marketingShare()
devShare()
liquidityShare()
getCurrentTaxRate(from, to)

// Limits info
maxTransactionAmount()
maxWalletAmount()
maxDailyTransactions()
maxDailyAmount()
cooldownTime()
getDailyLimitInfo(address)

// Exemptions
isExemptFromTax(address)
isExemptFromLimits(address)

// Trading status
tradingEnabled()
canTrade(address)
isBlacklisted(address)

// Liquidity info
uniswapV2Pair()
uniswapV2Router()
swapAndLiquifyEnabled()
swapTokensAtAmount()
accumulatedTaxForLiquidity()
```

---

## Common Scenarios

### Scenario: Launch Token

```solidity
// 1. Deploy contract
// 2. setTaxWallets(0x..., 0x..., 0x...)
// 3. approve(routerAddress, liquidityTokens)
// 4. addLiquidityManual(liquidityTokens) { value: liquidityETH }
// 5. enableTrading()
```

### Scenario: Reduce Taxes After Launch

```solidity
// Week 1: High taxes
setTaxRates(1000, 1500, 500) // 10% buy, 15% sell, 5% transfer

// Week 2: Lower taxes
setTaxRates(500, 700, 300)   // 5% buy, 7% sell, 3% transfer

// Week 4: Minimal taxes
setTaxRates(300, 300, 100)   // 3% buy, 3% sell, 1% transfer
```

### Scenario: Relax Limits as Project Grows

```solidity
// Launch: Strict limits
setTransactionLimits(totalSupply * 1 / 100, totalSupply * 2 / 100)
// 1% max tx, 2% max wallet

// After week 1: Relax
setTransactionLimits(totalSupply * 2 / 100, totalSupply * 5 / 100)
// 2% max tx, 5% max wallet

// After month 1: Remove wallet limit
setTransactionLimits(totalSupply * 5 / 100, totalSupply)
// 5% max tx, 100% max wallet
```

### Scenario: Handle Bot Attack

```solidity
// 1. Identify bot addresses
// 2. bulkBlacklist([bot1, bot2, bot3], true)
// 3. setAntiSnipeConfig(10, 5 gwei) // Strict gas limit
```

### Scenario: Community Takeover

```solidity
// 1. Set taxes to 0 (no revenue)
setTaxRates(0, 0, 0)

// 2. Remove all limits
setCooldownTime(0)
setTransactionLimits(totalSupply, totalSupply)

// 3. Transfer ownership to multisig
transferOwnership(multisigAddress)
```

---

## Emergency Procedures

### Rescue Stuck ETH
```solidity
rescueETH()
```

### Distribute Remaining Tax
```solidity
distributeTax()
```

### Transfer Ownership
```solidity
transferOwnership(newOwner)
```

---

## Gas Estimates (Approximate)

| Operation | Gas Cost |
|-----------|----------|
| Transfer (no tax) | ~50,000 |
| Transfer (with tax) | ~80,000 |
| Buy (with tax + auto-liquidity) | ~120,000-200,000 |
| Sell (with tax) | ~100,000 |
| Add Liquidity | ~150,000 |
| Enable Trading | ~50,000 |
| Set Tax Rates | ~30,000 |
| Blacklist | ~25,000 |

---

## Network-Specific Router Addresses

```javascript
// Ethereum Mainnet & Testnets
const UNISWAP_V2_ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

// BSC Mainnet & Testnet
const PANCAKESWAP_ROUTER = "0x10ED43C718714eb63d5aA57B78B54704E256024E";

// Polygon
const QUICKSWAP_ROUTER = "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff";

// Arbitrum
const SUSHISWAP_ROUTER = "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506";

// Avalanche
const TRADERJOE_ROUTER = "0x60aE616a2155Ee3d9A68541Ba4544862310933d4";
```

---

## Calculation Helpers

### Convert Percentage to Basis Points
```
1%   = 100
5%   = 500
10%  = 1000
15%  = 1500
20%  = 2000 (max allowed)
```

### Convert Tokens to Wei
```javascript
// For 18 decimals
1 token       = 1 * 10**18
1000 tokens   = 1000 * 10**18
1M tokens     = 1000000 * 10**18
```

### Calculate % of Total Supply
```javascript
// 1% of 1M supply
maxTx = (1000000 * 10**18 * 1) / 100 = 10000 * 10**18

// 2% of 1M supply
maxWallet = (1000000 * 10**18 * 2) / 100 = 20000 * 10**18
```

---

## Safety Checklist

Before Mainnet:
- [ ] Test all functions on testnet
- [ ] Verify tax calculations
- [ ] Test auto-liquidity trigger
- [ ] Verify limit checks work
- [ ] Test blacklist functionality
- [ ] Check exemptions work correctly
- [ ] Add initial liquidity
- [ ] Set correct tax wallets
- [ ] Enable trading only when ready

After Launch:
- [ ] Monitor tax collection
- [ ] Watch for bot activity
- [ ] Verify auto-liquidity triggers
- [ ] Check transaction limits effective
- [ ] Monitor daily limits
- [ ] Gradually relax restrictions
- [ ] Communicate changes to community

---

## Support Resources

- Contract: `EnhancedMemeToken.sol`
- Deployment Guide: `DEPLOYMENT_GUIDE.md`
- Original Contract: `ERC20Token.sol`
