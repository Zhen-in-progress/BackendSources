# ERC20 Token Implementation Task - Reference Guide

## Table of Contents

1. [Task Requirements](#task-requirements)
2. [Understanding IERC20 Interface](#1-understanding-ierc20-interface)
   - [Core Functions](#core-functions-from-ierc20sol)
   - [Required Events](#required-events)
3. [Understanding Events in Solidity](#2-understanding-events-in-solidity)
   - [What are Events?](#what-are-events)
   - [Defining Events](#defining-events)
   - [Emitting Events](#emitting-events)
   - [Event Benefits](#event-benefits)
4. [Data Storage Structures](#3-data-storage-structures)
   - [Using Mappings](#using-mappings)
5. [Import and Inheritance](#4-import-and-inheritance)
   - [Import Syntax](#import-syntax)
   - [Inheritance](#inheritance)
   - [Using OpenZeppelin](#using-openzeppelin)
6. [Implementation Example Structure](#5-implementation-example-structure)
   - [Basic Token Structure](#basic-token-structure)
7. [Deploying to Sepolia Testnet](#6-deploying-to-sepolia-testnet)
   - [Prerequisites](#prerequisites)
   - [Deployment Steps](#deployment-steps)
8. [Interacting with Deployed Token](#7-interacting-with-deployed-token)
   - [Add Token to MetaMask](#add-token-to-metamask)
   - [View Token Balance](#view-token-balance)
   - [Transfer Tokens](#transfer-tokens)
9. [Testing Checklist](#8-testing-checklist)
10. [Key Concepts Summary](#9-key-concepts-summary)
11. [Common Pitfalls to Avoid](#10-common-pitfalls-to-avoid)
12. [References](#references)

---

## Task Requirements

> **Source**: Original task requirements (provided by user)

**Objective**: Implement a simple ERC20 token contract based on OpenZeppelin's IERC20.sol interface.

### Required Features:

1. **balanceOf**: Query account balance
2. **transfer**: Transfer tokens
3. **approve** and **transferFrom**: Authorization and delegated transfers
4. Use **events** to record transfer and approval operations
5. Provide **mint** function to allow contract owner to mint new tokens

### Implementation Tips:

- Use `mapping` to store account balances and authorization information
- Use `event` to define `Transfer` and `Approval` events
- Deploy to Sepolia testnet and import to your wallet

---

## 1. Understanding IERC20 Interface

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol`

### Core Functions (from IERC20.sol)

```solidity
interface IERC20 {
    // Query total supply
    function totalSupply() external view returns (uint256);

    // Query account balance
    function balanceOf(address account) external view returns (uint256);

    // Transfer tokens
    function transfer(address to, uint256 value) external returns (bool);

    // Query allowance
    function allowance(address owner, address spender) external view returns (uint256);

    // Approve spender
    function approve(address spender, uint256 value) external returns (bool);

    // Transfer from authorized account
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
```

### Required Events

```solidity
// Emitted when tokens are transferred
event Transfer(address indexed from, address indexed to, uint256 value);

// Emitted when approval is granted
event Approval(address indexed owner, address indexed spender, uint256 value);
```

---

## 2. Understanding Events in Solidity

> **Source**: `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.1理论/06.什么是 event.md`

### What are Events?

`event` is a **logging mechanism** provided by Solidity that records specific behaviors on-chain (such as transfers, votes, transactions, etc.). They are written to transaction logs and can be **read and responded to by clients or monitoring programs (such as DApps)**.

### Defining Events

```solidity
event EventName(parameter_type parameter_name, ...);
```

#### Example:

```solidity
event Deposit(address indexed sender, uint256 amount);
```

- `Deposit` is the event name
- Parameters are `sender` and `amount`
- `indexed` keyword allows **filtering queries** on this field (max 3 indexed parameters)

### Emitting Events

After defining events, you need to **trigger** them in your logic using the `emit` keyword:

```solidity
emit Deposit(msg.sender, msg.value);
```

This statement writes a log entry on-chain that can be monitored by frontend applications using Web3.js or Ethers.js.

### Event Benefits

| Feature | Description |
|---------|-------------|
| Purpose | Record key events (transfers, votes, etc.) |
| Storage Location | Blockchain transaction logs (doesn't count toward storage gas) |
| Query Efficiency | `indexed` parameters improve filtering efficiency |
| Frontend | Can listen to these events for UI updates or notifications |

---

## 3. Data Storage Structures

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol` (lines 30-37)

### Using Mappings

```solidity
// Store account balances
mapping(address => uint256) private _balances;

// Store allowances: owner => (spender => amount)
mapping(address => mapping(address => uint256)) private _allowances;

// Store total supply
uint256 private _totalSupply;
```

---

## 4. Import and Inheritance

> **Source**: `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.1理论/04导包、继承、openzeppelin.md`

### Import Syntax

```solidity
// Import local file
import "./MyContract.sol";

// Import from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import and rename
import { MyContract as MC } from "./MyContract.sol";
```

### Inheritance

```solidity
contract MyToken is IERC20 {
    // Implement interface functions
}
```

### Using OpenZeppelin

OpenZeppelin provides audited smart contract templates:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
```

---

## 5. Implementation Example Structure

> **Source**: Combined from IERC20.sol and ERC20.sol structures

### Basic Token Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {
    // State variables
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    address public owner;

    // Mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor
    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    // Implement IERC20 functions here...
}
```

---

## 6. Deploying to Sepolia Testnet

> **Source**: `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/01在Sepolia上发行 ERC20 代币.md`

### Prerequisites

#### 6.1 Install MetaMask
- Install [MetaMask](https://metamask.io/) browser extension
- Create or import a wallet

#### 6.2 Get Sepolia Test ETH
- Open MetaMask and switch to Sepolia testnet
- Get test ETH from [Sepolia Faucet](https://sepoliafaucet.com/)

#### 6.3 Open Remix IDE
- Visit [Remix IDE](https://remix.ethereum.org/)

### Deployment Steps

#### Step 1: Write Contract
- In Remix IDE's `File Explorers`, click `Create New File`, name it `MyToken.sol`
- Write your ERC20 contract code

#### Step 2: Compile Contract
- In `Solidity Compiler` tab, select `0.8.0` or higher compiler version
- Click `Compile MyToken.sol`

#### Step 3: Configure MetaMask
- Ensure MetaMask is connected to Sepolia testnet
- Ensure account has sufficient Sepolia ETH

#### Step 4: Deploy Contract
- In `Deploy & Run Transactions` tab, select `Injected Provider - MetaMask` as environment
- In `Contract` dropdown, select your token contract
- Enter constructor parameters (e.g., initial supply: `1000000`)
- Click `Deploy`, MetaMask will pop up confirmation window, click `Confirm`

#### Step 5: Get Contract Address
- After successful deployment, you can see the contract address in `Deployed Contracts` section

---

## 7. Interacting with Deployed Token

> **Source**: `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/01在Sepolia上发行 ERC20 代币.md` (Section 4)

### Add Token to MetaMask

1. Open MetaMask, click `Add Token`
2. Select `Custom Token`, enter contract address
3. Click `Next`, then `Add Tokens`

### View Token Balance

- In MetaMask, switch to Sepolia testnet
- You should see your token balance

### Transfer Tokens

1. In Remix IDE's `Deployed Contracts` section, expand your token contract
2. In `transfer` function, enter recipient address and amount
3. Click `transact`, MetaMask will pop up confirmation window, click `Confirm`

---

## 8. Testing Checklist

> **Source**: Derived from task requirements and ERC20 standard best practices

After implementation, test the following:

- [ ] Deploy contract successfully to Sepolia
- [ ] Verify initial supply is minted to deployer
- [ ] Check `balanceOf` returns correct balance
- [ ] Test `transfer` function works
- [ ] Test `approve` grants allowance
- [ ] Test `transferFrom` works with allowance
- [ ] Test `mint` function (only owner can mint)
- [ ] Verify `Transfer` events are emitted
- [ ] Verify `Approval` events are emitted
- [ ] Import token to MetaMask wallet

---

## 9. Key Concepts Summary

> **Source**: Synthesized from multiple reference materials (event.md, IERC20.sol, ERC20.sol, inheritance.md)

### Events
- Used for logging on-chain activities
- Cheaper than storage
- Can be monitored by frontend applications
- Use `indexed` for filterable parameters

### Mappings
- Key-value store in Solidity
- Used for balances and allowances
- Cannot be iterated

### Access Control
- Use modifiers like `onlyOwner`
- Restrict sensitive functions (like `mint`)

### ERC20 Standard
- Interface defines required functions
- Implementation provides actual logic
- Events notify external observers

---

## 10. Common Pitfalls to Avoid

> **Source**: Best practices derived from OpenZeppelin ERC20.sol implementation and Solidity security patterns

1. **Don't forget to emit events** after state changes
2. **Check for zero address** in transfer/approve functions
3. **Ensure sufficient balance** before transfers
4. **Check allowance** before transferFrom
5. **Use SafeMath** (or Solidity 0.8+) to prevent overflow/underflow
6. **Add access control** to mint function
7. **Test thoroughly** before deploying to mainnet

---

## References

### Local Reference Files Used:
1. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol` - ERC20 interface definition
2. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol` - ERC20 implementation reference
3. `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.1理论/06.什么是 event.md` - Events explanation
4. `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.1理论/04导包、继承、openzeppelin.md` - Import and inheritance guide
5. `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/01在Sepolia上发行 ERC20 代币.md` - Sepolia deployment guide

### External References:
- [OpenZeppelin ERC20 Documentation](https://docs.openzeppelin.com/contracts/erc20)
- [Ethereum EIP-20 Standard](https://eips.ethereum.org/EIPS/eip-20)
- [Remix IDE](https://remix.ethereum.org/)
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [MetaMask](https://metamask.io/)
