// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EnhancedMemeToken
 * @dev Advanced ERC20 token with tax mechanism, liquidity integration, and trading restrictions
 *
 * Features:
 * 1. Token Tax System: Different tax rates for buy/sell/transfer
 * 2. Liquidity Pool Integration: Auto-liquidity and manual LP functions
 * 3. Trading Restrictions: Max transaction, max wallet, cooldown, daily limits
 * 4. Anti-bot Protection: Blacklist, anti-snipe, gas price limits
 */

// Uniswap V2 Interfaces
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract EnhancedMemeToken {
    // ========== TOKEN METADATA ==========
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // ========== OWNERSHIP ==========
    address public owner;

    // ========== BALANCES & ALLOWANCES ==========
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ========== TAX CONFIGURATION ==========
    uint256 public buyTaxRate = 500;        // 5% (500/10000)
    uint256 public sellTaxRate = 700;       // 7% (700/10000)
    uint256 public transferTaxRate = 300;   // 3% (300/10000)

    // Tax distribution wallets
    address public marketingWallet;
    address public devWallet;
    address public liquidityWallet;

    // Tax distribution percentages (out of 10000)
    uint256 public marketingShare = 4000;   // 40%
    uint256 public devShare = 3000;         // 30%
    uint256 public liquidityShare = 3000;   // 30%

    // Tax exemptions
    mapping(address => bool) public isExemptFromTax;

    // Accumulated tax for auto-liquidity
    uint256 public accumulatedTaxForLiquidity;

    // ========== LIQUIDITY POOL INTEGRATION ==========
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool public swapAndLiquifyEnabled = true;
    uint256 public swapTokensAtAmount = 1000 * 10**18; // Threshold to trigger auto-liquidity
    bool private inSwapAndLiquify;

    // ========== TRADING RESTRICTIONS ==========
    bool public tradingEnabled = false;
    uint256 public tradingEnabledTimestamp;

    // Transaction limits
    uint256 public maxTransactionAmount;    // Max tokens per transaction
    uint256 public maxWalletAmount;         // Max tokens per wallet

    // Cooldown mechanism
    mapping(address => uint256) public lastTransactionTime;
    uint256 public cooldownTime = 30 seconds;

    // Daily limits
    mapping(address => uint256) public dailyTransferCount;
    mapping(address => uint256) public dailyTransferAmount;
    mapping(address => uint256) public lastResetDay;
    uint256 public maxDailyTransactions = 10;
    uint256 public maxDailyAmount;

    // Limit exemptions
    mapping(address => bool) public isExemptFromLimits;

    // ========== ANTI-BOT PROTECTION ==========
    mapping(address => bool) public isBlacklisted;
    uint256 public launchBlock;
    uint256 public antiSnipeBlocks = 3;
    uint256 public maxGasPriceLimit = 15 gwei;

    // ========== EVENTS ==========
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event TaxCollected(address indexed from, uint256 amount);
    event TaxDistributed(address indexed wallet, uint256 amount);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event TradingEnabled(uint256 timestamp);
    event Blacklisted(address indexed account, bool isBlacklisted);

    // ========== MODIFIERS ==========
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /**
     * @dev Constructor - Initialize enhanced meme token
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        address _routerAddress
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        // Calculate total supply
        totalSupply = _initialSupply * (10 ** uint256(_decimals));

        // Set default wallets to owner (can be changed later)
        marketingWallet = msg.sender;
        devWallet = msg.sender;
        liquidityWallet = msg.sender;

        // Set default limits (1% and 2% of total supply)
        maxTransactionAmount = (totalSupply * 100) / 10000;  // 1%
        maxWalletAmount = (totalSupply * 200) / 10000;       // 2%
        maxDailyAmount = (totalSupply * 500) / 10000;        // 5%

        // Initialize Uniswap Router
        uniswapV2Router = IUniswapV2Router02(_routerAddress);

        // Create pair with WETH
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        // Exempt owner, contract, and wallets from taxes and limits
        isExemptFromTax[msg.sender] = true;
        isExemptFromTax[address(this)] = true;
        isExemptFromTax[marketingWallet] = true;
        isExemptFromTax[devWallet] = true;
        isExemptFromTax[liquidityWallet] = true;

        isExemptFromLimits[msg.sender] = true;
        isExemptFromLimits[address(this)] = true;
        isExemptFromLimits[uniswapV2Pair] = true;

        // Mint initial supply to contract creator
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // ========== CORE ERC20 FUNCTIONS ==========

    /**
     * @dev Transfer tokens with tax and limit checks
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Approve spender to spend tokens
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Cannot approve zero address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Internal transfer function with tax and limits
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf[from] >= amount, "Insufficient balance");

        // Anti-bot checks
        _antiBotCheck(from, to);

        // Trading restriction checks
        _checkTradingRestrictions(from, to, amount);

        // Check if we should swap and liquify
        bool shouldSwapAndLiquify = !inSwapAndLiquify &&
                                     swapAndLiquifyEnabled &&
                                     from != uniswapV2Pair &&
                                     accumulatedTaxForLiquidity >= swapTokensAtAmount;

        if (shouldSwapAndLiquify) {
            _swapAndLiquify(swapTokensAtAmount);
        }

        // Calculate tax
        uint256 taxAmount = 0;
        bool takeTax = !inSwapAndLiquify && !isExemptFromTax[from] && !isExemptFromTax[to];

        if (takeTax) {
            taxAmount = _calculateTax(from, to, amount);
        }

        uint256 amountAfterTax = amount - taxAmount;

        // Execute transfer
        balanceOf[from] -= amount;
        balanceOf[to] += amountAfterTax;

        // Collect tax
        if (taxAmount > 0) {
            balanceOf[address(this)] += taxAmount;
            accumulatedTaxForLiquidity += taxAmount;
            emit TaxCollected(from, taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        emit Transfer(from, to, amountAfterTax);
    }

    // ========== TAX MECHANISM ==========

    /**
     * @dev Calculate tax based on transaction type
     */
    function _calculateTax(address from, address to, uint256 amount) internal view returns (uint256) {
        uint256 taxRate = 0;

        if (to == uniswapV2Pair) {
            // Sell transaction
            taxRate = sellTaxRate;
        } else if (from == uniswapV2Pair) {
            // Buy transaction
            taxRate = buyTaxRate;
        } else {
            // Regular transfer
            taxRate = transferTaxRate;
        }

        return (amount * taxRate) / 10000;
    }

    /**
     * @dev Manually distribute accumulated tax
     */
    function distributeTax() external onlyOwner {
        uint256 taxBalance = balanceOf[address(this)];
        require(taxBalance > 0, "No tax to distribute");

        uint256 marketingAmount = (taxBalance * marketingShare) / 10000;
        uint256 devAmount = (taxBalance * devShare) / 10000;
        uint256 liquidityAmount = taxBalance - marketingAmount - devAmount;

        if (marketingAmount > 0) {
            balanceOf[address(this)] -= marketingAmount;
            balanceOf[marketingWallet] += marketingAmount;
            emit TaxDistributed(marketingWallet, marketingAmount);
            emit Transfer(address(this), marketingWallet, marketingAmount);
        }

        if (devAmount > 0) {
            balanceOf[address(this)] -= devAmount;
            balanceOf[devWallet] += devAmount;
            emit TaxDistributed(devWallet, devAmount);
            emit Transfer(address(this), devWallet, devAmount);
        }

        // Liquidity amount stays in contract for auto-liquidity
        if (liquidityAmount > 0) {
            emit TaxDistributed(address(this), liquidityAmount);
        }
    }

    // ========== LIQUIDITY POOL INTEGRATION ==========

    /**
     * @dev Swap tokens for ETH and add liquidity automatically
     */
    function _swapAndLiquify(uint256 tokens) private lockTheSwap {
        // Split tokens for liquidity
        uint256 liquidityPortion = (tokens * liquidityShare) / 10000;
        uint256 half = liquidityPortion / 2;
        uint256 otherHalf = liquidityPortion - half;
        uint256 tokensToSwap = tokens - otherHalf;

        uint256 initialBalance = address(this).balance;

        // Swap tokens for ETH
        _swapTokensForEth(tokensToSwap);

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 ethForLiquidity = (newBalance * otherHalf) / tokensToSwap;

        // Add liquidity
        if (otherHalf > 0 && ethForLiquidity > 0) {
            _addLiquidity(otherHalf, ethForLiquidity);
            emit SwapAndLiquify(half, ethForLiquidity, otherHalf);
        }

        // Send remaining ETH to wallets
        uint256 remainingEth = address(this).balance;
        if (remainingEth > 0) {
            uint256 marketingEth = (remainingEth * marketingShare) / (marketingShare + devShare);
            uint256 devEth = remainingEth - marketingEth;

            if (marketingEth > 0) payable(marketingWallet).transfer(marketingEth);
            if (devEth > 0) payable(devWallet).transfer(devEth);
        }

        accumulatedTaxForLiquidity = 0;
    }

    /**
     * @dev Swap tokens for ETH using Uniswap
     */
    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Add liquidity to Uniswap pool
     */
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityWallet,
            block.timestamp
        );
    }

    /**
     * @dev Manual liquidity addition (users can add liquidity)
     */
    function addLiquidityManual(uint256 tokenAmount) external payable {
        require(msg.value > 0, "Must send ETH");
        require(balanceOf[msg.sender] >= tokenAmount, "Insufficient token balance");

        // Transfer tokens from user to contract
        balanceOf[msg.sender] -= tokenAmount;
        balanceOf[address(this)] += tokenAmount;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            tokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp + 300
        );
    }

    // ========== TRADING RESTRICTIONS ==========

    /**
     * @dev Check all trading restrictions
     */
    function _checkTradingRestrictions(address from, address to, uint256 amount) internal {
        // Skip checks for exempted addresses
        if (isExemptFromLimits[from] || isExemptFromLimits[to]) {
            return;
        }

        // Check if trading is enabled
        require(tradingEnabled, "Trading not enabled yet");

        // Max transaction amount check
        require(amount <= maxTransactionAmount, "Exceeds max transaction amount");

        // Max wallet amount check (only for buys)
        if (from == uniswapV2Pair) {
            require(
                balanceOf[to] + amount <= maxWalletAmount,
                "Exceeds max wallet amount"
            );
        }

        // Cooldown check
        require(
            block.timestamp >= lastTransactionTime[from] + cooldownTime,
            "Cooldown period active"
        );
        lastTransactionTime[from] = block.timestamp;

        // Daily limits check
        _checkDailyLimits(from, amount);
    }

    /**
     * @dev Check and update daily transaction limits
     */
    function _checkDailyLimits(address user, uint256 amount) internal {
        uint256 currentDay = block.timestamp / 1 days;

        // Reset counters if new day
        if (lastResetDay[user] < currentDay) {
            dailyTransferCount[user] = 0;
            dailyTransferAmount[user] = 0;
            lastResetDay[user] = currentDay;
        }

        // Check limits
        require(
            dailyTransferCount[user] < maxDailyTransactions,
            "Daily transaction count limit reached"
        );
        require(
            dailyTransferAmount[user] + amount <= maxDailyAmount,
            "Daily amount limit reached"
        );

        // Update counters
        dailyTransferCount[user]++;
        dailyTransferAmount[user] += amount;
    }

    // ========== ANTI-BOT PROTECTION ==========

    /**
     * @dev Anti-bot checks
     */
    function _antiBotCheck(address from, address to) internal view {
        // Blacklist check
        require(!isBlacklisted[from] && !isBlacklisted[to], "Address is blacklisted");

        // Anti-snipe: Limit gas price in first blocks after launch
        if (tradingEnabled && block.number < launchBlock + antiSnipeBlocks) {
            if (from == uniswapV2Pair) {
                require(tx.gasprice <= maxGasPriceLimit, "Gas price too high");
            }
        }
    }

    // ========== ADMIN FUNCTIONS ==========

    /**
     * @dev Enable trading (can only be called once)
     */
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        tradingEnabledTimestamp = block.timestamp;
        launchBlock = block.number;
        emit TradingEnabled(block.timestamp);
    }

    /**
     * @dev Set tax rates
     */
    function setTaxRates(uint256 _buyTax, uint256 _sellTax, uint256 _transferTax) external onlyOwner {
        require(_buyTax <= 2000 && _sellTax <= 2000 && _transferTax <= 2000, "Tax too high (max 20%)");
        buyTaxRate = _buyTax;
        sellTaxRate = _sellTax;
        transferTaxRate = _transferTax;
    }

    /**
     * @dev Set tax distribution shares
     */
    function setTaxDistribution(uint256 _marketing, uint256 _dev, uint256 _liquidity) external onlyOwner {
        require(_marketing + _dev + _liquidity == 10000, "Shares must equal 10000");
        marketingShare = _marketing;
        devShare = _dev;
        liquidityShare = _liquidity;
    }

    /**
     * @dev Set tax wallets
     */
    function setTaxWallets(address _marketing, address _dev, address _liquidity) external onlyOwner {
        require(_marketing != address(0) && _dev != address(0) && _liquidity != address(0), "Zero address");
        marketingWallet = _marketing;
        devWallet = _dev;
        liquidityWallet = _liquidity;
    }

    /**
     * @dev Set transaction limits
     */
    function setTransactionLimits(uint256 _maxTx, uint256 _maxWallet) external onlyOwner {
        require(_maxTx >= (totalSupply * 10) / 10000, "Max tx too low (min 0.1%)");
        require(_maxWallet >= (totalSupply * 10) / 10000, "Max wallet too low (min 0.1%)");
        maxTransactionAmount = _maxTx;
        maxWalletAmount = _maxWallet;
    }

    /**
     * @dev Set daily limits
     */
    function setDailyLimits(uint256 _maxDailyTx, uint256 _maxDailyAmount) external onlyOwner {
        maxDailyTransactions = _maxDailyTx;
        maxDailyAmount = _maxDailyAmount;
    }

    /**
     * @dev Set cooldown time
     */
    function setCooldownTime(uint256 _seconds) external onlyOwner {
        require(_seconds <= 300, "Cooldown too long (max 5 minutes)");
        cooldownTime = _seconds;
    }

    /**
     * @dev Set swap threshold
     */
    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount;
    }

    /**
     * @dev Enable/disable auto liquidity
     */
    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    /**
     * @dev Set anti-snipe parameters
     */
    function setAntiSnipeConfig(uint256 _blocks, uint256 _maxGasPrice) external onlyOwner {
        antiSnipeBlocks = _blocks;
        maxGasPriceLimit = _maxGasPrice;
    }

    /**
     * @dev Blacklist/unblacklist address
     */
    function setBlacklist(address account, bool value) external onlyOwner {
        isBlacklisted[account] = value;
        emit Blacklisted(account, value);
    }

    /**
     * @dev Bulk blacklist
     */
    function bulkBlacklist(address[] calldata accounts, bool value) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlacklisted[accounts[i]] = value;
            emit Blacklisted(accounts[i], value);
        }
    }

    /**
     * @dev Set tax exemption
     */
    function setTaxExempt(address account, bool exempt) external onlyOwner {
        isExemptFromTax[account] = exempt;
    }

    /**
     * @dev Set limit exemption
     */
    function setLimitExempt(address account, bool exempt) external onlyOwner {
        isExemptFromLimits[account] = exempt;
    }

    /**
     * @dev Mint new tokens (only owner)
     */
    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        require(_to != address(0), "Cannot mint to zero address");

        totalSupply += _value;
        balanceOf[_to] += _value;

        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    /**
     * @dev Transfer ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        owner = newOwner;
    }

    /**
     * @dev Rescue stuck tokens (not this token)
     */
    function rescueTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(this), "Cannot rescue own token");
        // Transfer logic for other ERC20 tokens would go here
    }

    /**
     * @dev Rescue stuck ETH
     */
    function rescueETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // ========== VIEW FUNCTIONS ==========

    /**
     * @dev Get current tax for an address
     */
    function getCurrentTaxRate(address from, address to) external view returns (uint256) {
        if (to == uniswapV2Pair) return sellTaxRate;
        if (from == uniswapV2Pair) return buyTaxRate;
        return transferTaxRate;
    }

    /**
     * @dev Check if address can trade
     */
    function canTrade(address account) external view returns (bool) {
        return tradingEnabled && !isBlacklisted[account];
    }

    /**
     * @dev Get daily limit info for address
     */
    function getDailyLimitInfo(address account) external view returns (
        uint256 txCount,
        uint256 txAmount,
        uint256 remainingTx,
        uint256 remainingAmount
    ) {
        uint256 currentDay = block.timestamp / 1 days;

        if (lastResetDay[account] < currentDay) {
            return (0, 0, maxDailyTransactions, maxDailyAmount);
        }

        txCount = dailyTransferCount[account];
        txAmount = dailyTransferAmount[account];
        remainingTx = maxDailyTransactions > txCount ? maxDailyTransactions - txCount : 0;
        remainingAmount = maxDailyAmount > txAmount ? maxDailyAmount - txAmount : 0;
    }

    // ========== INTERNAL HELPERS ==========

    /**
     * @dev Internal approve function
     */
    function _approve(address _owner, address _spender, uint256 _value) internal {
        allowance[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    /**
     * @dev Receive ETH
     */
    receive() external payable {}
}
