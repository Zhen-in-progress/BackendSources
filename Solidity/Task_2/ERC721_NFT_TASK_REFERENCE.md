# ERC721 NFT Implementation Task - Reference Guide

## Table of Contents

1. [Task Requirements](#task-requirements)
2. [Understanding ERC721 Standard](#1-understanding-erc721-standard)
   - [Core Functions](#core-functions-from-ierc721sol)
   - [Required Events](#required-events)
   - [Metadata Extension](#metadata-extension)
3. [Understanding NFT Metadata](#2-understanding-nft-metadata)
   - [What is Token URI?](#what-is-token-uri)
   - [OpenSea Metadata Standards](#opensea-metadata-standards)
   - [IPFS for Storage](#ipfs-for-storage)
4. [ERC721 Implementation Details](#3-erc721-implementation-details)
   - [State Variables and Mappings](#state-variables-and-mappings)
   - [Token Minting](#token-minting)
   - [URI Storage Extension](#uri-storage-extension)
5. [Import and Inheritance](#4-import-and-inheritance)
   - [Using OpenZeppelin ERC721](#using-openzeppelin-erc721)
   - [Available Extensions](#available-extensions)
6. [Implementation Example Structure](#5-implementation-example-structure)
   - [Basic NFT Contract](#basic-nft-contract)
   - [NFT with URI Storage](#nft-with-uri-storage)
7. [Preparing NFT Assets](#6-preparing-nft-assets)
   - [Image Requirements](#image-requirements)
   - [Creating Metadata JSON](#creating-metadata-json)
   - [Uploading to IPFS](#uploading-to-ipfs)
8. [Deploying to Sepolia Testnet](#7-deploying-to-sepolia-testnet)
   - [Prerequisites](#prerequisites)
   - [Deployment Steps](#deployment-steps)
9. [Minting and Viewing NFTs](#8-minting-and-viewing-nfts)
   - [Minting NFT](#minting-nft)
   - [View on OpenSea Testnet](#view-on-opensea-testnet)
   - [View on Etherscan](#view-on-etherscan)
   - [Add NFT to MetaMask](#add-nft-to-metamask)
10. [Testing Checklist](#9-testing-checklist)
11. [Key Concepts Summary](#10-key-concepts-summary)
12. [Common Pitfalls to Avoid](#11-common-pitfalls-to-avoid)
13. [References](#references)

---

## Task Requirements

> **Source**: Original task requirements (translated to English)

**Objective**: Issue an NFT with images and text on a testnet.

### Required Features:

1. **Write NFT Contract**: Use Solidity to write an ERC721 standard NFT contract
2. **Upload to IPFS**: Upload image and text data to IPFS, generate metadata link
3. **Deploy to Testnet**: Deploy contract to Ethereum testnet (Goerli or Sepolia)
4. **Mint NFT**: Mint NFT and view it in testnet environment

### Task Steps:

1. Write NFT contract using OpenZeppelin's ERC721 library
2. Contract should include:
   - Constructor: Set NFT name and symbol
   - mintNFT function: Allow users to mint NFT with metadata link (tokenURI)
3. Compile contract in Remix IDE
4. Prepare image and upload to IPFS (use Pinata or other tools)
5. Create JSON file describing NFT properties
6. Upload JSON to IPFS, get metadata link
7. Deploy contract to testnet
8. Mint NFT with metadata IPFS link
9. View NFT on OpenSea testnet or Etherscan

### JSON File Reference:
- [OpenSea Metadata Standards](https://docs.opensea.io/docs/metadata-standards)

---

## 1. Understanding ERC721 Standard

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol`

### Core Functions (from IERC721.sol)

```solidity
interface IERC721 is IERC165 {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Query token balance of an owner
    function balanceOf(address owner) external view returns (uint256 balance);

    // Query owner of a token
    function ownerOf(uint256 tokenId) external view returns (address owner);

    // Safe transfer with data
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    // Safe transfer
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    // Transfer token
    function transferFrom(address from, address to, uint256 tokenId) external;

    // Approve address to manage token
    function approve(address to, uint256 tokenId) external;

    // Set approval for all tokens
    function setApprovalForAll(address operator, bool approved) external;

    // Get approved address for token
    function getApproved(uint256 tokenId) external view returns (address operator);

    // Check if operator is approved for all
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
```

### Required Events

```solidity
// Emitted when tokenId is transferred from 'from' to 'to'
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

// Emitted when owner enables approved to manage tokenId
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

// Emitted when owner enables or disables operator to manage all tokens
event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
```

### Metadata Extension

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol`

```solidity
interface IERC721Metadata is IERC721 {
    // Returns token collection name
    function name() external view returns (string memory);

    // Returns token collection symbol
    function symbol() external view returns (string memory);

    // Returns the URI for tokenId token
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
```

**Key Point**: The `tokenURI` function returns the metadata link (usually IPFS link) for each NFT.

---

## 2. Understanding NFT Metadata

### What is Token URI?

Token URI is a link that points to a JSON file containing the NFT's metadata. This JSON file describes the NFT's properties, including:
- Name
- Description
- Image URL
- Attributes/Properties

### OpenSea Metadata Standards

> **Reference**: [OpenSea Metadata Standards](https://docs.opensea.io/docs/metadata-standards)

#### Basic Metadata Structure

```json
{
  "name": "My Awesome NFT",
  "description": "This is a detailed description of my NFT.",
  "image": "ipfs://QmXxxx.../image.png",
  "external_url": "https://mywebsite.com/nft/1",
  "attributes": [
    {
      "trait_type": "Background",
      "value": "Blue"
    },
    {
      "trait_type": "Rarity",
      "value": "Legendary"
    },
    {
      "trait_type": "Power",
      "value": 95,
      "max_value": 100
    }
  ]
}
```

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Name of the NFT |
| `description` | String | Human-readable description |
| `image` | String | URL to image (IPFS/HTTP) |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `external_url` | String | External website link |
| `attributes` | Array | Properties/traits of the NFT |
| `background_color` | String | Background color (6-char hex) |
| `animation_url` | String | URL to multimedia attachment |
| `youtube_url` | String | YouTube video URL |

### IPFS for Storage

**Why IPFS?**
- Decentralized storage
- Content-addressed (immutable)
- Permanent storage (when pinned)
- No single point of failure

**IPFS URL Formats:**
- Gateway: `https://ipfs.io/ipfs/QmXxxx...`
- Protocol: `ipfs://QmXxxx...`

**Pinning Services:**
- [Pinata](https://pinata.cloud/) - Popular, free tier available
- [NFT.Storage](https://nft.storage/) - Free, optimized for NFTs
- [Infura IPFS](https://infura.io/product/ipfs) - Enterprise option

---

## 3. ERC721 Implementation Details

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol`

### State Variables and Mappings

```solidity
// Token name
string private _name;

// Token symbol
string private _symbol;

// Mapping from token ID to owner address
mapping(uint256 tokenId => address) private _owners;

// Mapping owner address to token count
mapping(address owner => uint256) private _balances;

// Mapping from token ID to approved address
mapping(uint256 tokenId => address) private _tokenApprovals;

// Mapping from owner to operator approvals
mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;
```

**Key Differences from ERC20:**
- ERC20 tracks fungible token balances per address
- ERC721 tracks unique token ownership by token ID
- Each token has a unique ID and owner

### Token Minting

> **Source**: ERC721.sol lines 259-267

```solidity
/**
 * @dev Mints `tokenId` and transfers it to `to`.
 *
 * Requirements:
 * - `tokenId` must not exist.
 * - `to` cannot be the zero address.
 *
 * Emits a {Transfer} event.
 */
function _mint(address to, uint256 tokenId) internal {
    if (to == address(0)) {
        revert ERC721InvalidReceiver(address(0));
    }
    address previousOwner = _update(to, tokenId, address(0));
    if (previousOwner != address(0)) {
        revert ERC721InvalidSender(address(0));
    }
}
```

**Safe Mint (Recommended):**

```solidity
/**
 * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
 *
 * Requirements:
 * - `tokenId` must not exist.
 * - If `to` refers to a smart contract, it must implement
 *   {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
 *
 * Emits a {Transfer} event.
 */
function _safeMint(address to, uint256 tokenId) internal {
    _safeMint(to, tokenId, "");
}
```

**Key Point**: Use `_safeMint` to prevent tokens from being locked in contracts that can't handle NFTs.

### URI Storage Extension

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol`

```solidity
abstract contract ERC721URIStorage is IERC4906, ERC721 {
    // Optional mapping for token URIs
    mapping(uint256 tokenId => string) private _tokenURIs;

    /// Override tokenURI to return custom URI
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI
        if (bytes(_tokenURI).length > 0) {
            return string.concat(base, _tokenURI);
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     * Emits {IERC4906-MetadataUpdate}.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }
}
```

**Key Features:**
- Stores individual URI for each token ID
- Allows custom metadata per token
- Essential for NFTs with unique images/properties

---

## 4. Import and Inheritance

### Using OpenZeppelin ERC721

```solidity
// Basic ERC721
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// With URI Storage
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// With Access Control
import "@openzeppelin/contracts/access/Ownable.sol";
```

### Available Extensions

> **Source**: `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/extensions/`

| Extension | Purpose |
|-----------|---------|
| **ERC721URIStorage** | Store individual token URIs (essential for NFTs) |
| **ERC721Enumerable** | Add token enumeration (totalSupply, tokenByIndex) |
| **ERC721Burnable** | Allow token burning |
| **ERC721Pausable** | Emergency pause functionality |
| **ERC721Royalty** | Built-in royalty support (EIP-2981) |

**For NFT Task, Use:**
- `ERC721` - Base implementation
- `ERC721URIStorage` - For custom metadata per token
- `Ownable` - For access control on minting

---

## 5. Implementation Example Structure

### Basic NFT Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    function mintNFT(address recipient) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(recipient, tokenId);
        return tokenId;
    }
}
```

### NFT with URI Storage

> **Source**: Combined from ERC721.sol, ERC721URIStorage.sol, and `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/02Sepolia上发布NFT.md`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    // Constructor: Set NFT name and symbol
    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    /**
     * @dev Mint NFT with custom tokenURI (metadata link)
     * @param recipient Address to receive the NFT
     * @param tokenURI IPFS link to metadata JSON
     * @return tokenId The ID of the minted token
     */
    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = _nextTokenId++;
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }

    // Override required functions
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
```

**Key Components:**

1. **State Variable**: `_nextTokenId` - Auto-increment counter for token IDs
2. **Constructor**: Sets name ("MyNFT") and symbol ("MNFT")
3. **mintNFT Function**:
   - Takes recipient address and metadata URI
   - Mints token with next available ID
   - Associates metadata URI with token
   - Returns token ID
4. **Access Control**: `onlyOwner` modifier restricts minting

---

## 6. Preparing NFT Assets

### Image Requirements

**Recommended Specifications:**
- Format: PNG, JPG, GIF, or SVG
- Size: 350x350px minimum (square aspect ratio recommended)
- Max file size: 100MB (but smaller is better for loading)
- Resolution: 72-300 DPI

**Best Practices:**
- Use high-quality images for better display
- Optimize file size for faster loading
- Consider using PNG for transparency
- Avoid copyrighted material

### Creating Metadata JSON

**Example metadata.json:**

```json
{
  "name": "My Awesome NFT #1",
  "description": "This is a unique digital artwork showcasing a beautiful sunset over mountains. Created as part of my NFT collection.",
  "image": "ipfs://QmXxxxxYourImageHashHerexxxxx/image.png",
  "external_url": "https://myportfolio.com",
  "attributes": [
    {
      "trait_type": "Background",
      "value": "Sunset"
    },
    {
      "trait_type": "Theme",
      "value": "Nature"
    },
    {
      "trait_type": "Rarity",
      "value": "Rare"
    },
    {
      "display_type": "number",
      "trait_type": "Edition",
      "value": 1,
      "max_value": 100
    }
  ]
}
```

### Uploading to IPFS

#### Using Pinata (Recommended for Beginners)

**Step 1: Create Account**
- Go to [Pinata.cloud](https://pinata.cloud/)
- Sign up for free account

**Step 2: Upload Image**
- Click "Upload" button
- Select your image file
- Wait for upload to complete
- Copy the CID (Content Identifier)
- Image URL will be: `ipfs://YOUR_IMAGE_CID/filename.png`

**Step 3: Create and Upload Metadata**
- Create `metadata.json` file with the image IPFS link
- Replace `image` field with your image IPFS URL
- Upload `metadata.json` to Pinata
- Copy the metadata CID
- Metadata URL will be: `ipfs://YOUR_METADATA_CID/metadata.json`

**Step 4: Get IPFS URLs**
- Image: `ipfs://QmXxxxImageCIDxxx/my-nft-image.png`
- Metadata: `ipfs://QmYxxxMetadataCIDxxx/metadata.json`

**Note**: You can also use gateway URLs for testing:
- `https://gateway.pinata.cloud/ipfs/YOUR_CID/filename`

---

## 7. Deploying to Sepolia Testnet

> **Source**: `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/02Sepolia上发布NFT.md`

### Prerequisites

#### 7.1 Install MetaMask
- Install [MetaMask](https://metamask.io/) browser extension
- Create or import a wallet
- **Save your seed phrase securely!**

#### 7.2 Get Sepolia Test ETH
- Open MetaMask and switch to **Sepolia Test Network**
  - Click network dropdown → "Show test networks" → Select "Sepolia"
- Get test ETH from faucets:
  - [Sepolia Faucet](https://sepoliafaucet.com/)
  - [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)
  - [Infura Sepolia Faucet](https://www.infura.io/faucet/sepolia)
- Wait for transaction to confirm (~15 seconds)

#### 7.3 Open Remix IDE
- Visit [Remix IDE](https://remix.ethereum.org/)
- Or use desktop version for better stability

### Deployment Steps

#### Step 1: Create Contract File
- In Remix IDE's `File Explorer`, click `Create New File`
- Name it `MyNFT.sol`
- Copy your NFT contract code

#### Step 2: Compile Contract
- Go to `Solidity Compiler` tab (left sidebar)
- Select compiler version `0.8.24` or compatible version
- Click `Compile MyNFT.sol`
- Check for any errors (should show green checkmark)

#### Step 3: Configure Deployment Environment
- Go to `Deploy & Run Transactions` tab
- **Environment**: Select `Injected Provider - MetaMask`
- MetaMask will pop up asking to connect
- Click `Connect` and select your account
- Verify you see:
  - Network: "Sepolia (11155111)"
  - Account with balance

#### Step 4: Deploy Contract
- In `Contract` dropdown, select `MyNFT`
- No constructor parameters needed (name/symbol set in code)
- Click `Deploy` (orange button)
- MetaMask will pop up with transaction details:
  - Review gas fees
  - Click `Confirm`
- Wait for deployment (~15-30 seconds)

#### Step 5: Verify Deployment
- After successful deployment, see contract in `Deployed Contracts` section
- Copy contract address (looks like `0x1234...abcd`)
- Click contract address to verify on Etherscan Sepolia

**Save these details:**
- Contract Address: `0x...`
- Deployer Address: Your wallet address
- Transaction Hash: `0x...`
- Block Number: Noted in Etherscan

---

## 8. Minting and Viewing NFTs

### Minting NFT

> **Source**: `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/02Sepolia上发布NFT.md` (Section 4)

**Step 1: Prepare Metadata URI**
- Ensure you have uploaded image and metadata to IPFS
- Have metadata URI ready: `ipfs://QmYourMetadataCID/metadata.json`

**Step 2: Call mintNFT Function**
- In Remix's `Deployed Contracts`, expand your contract
- Find `mintNFT` function
- Input parameters:
  - `recipient`: Your wallet address (or recipient address)
  - `tokenURI`: Your IPFS metadata link
- Example:
  ```
  recipient: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
  tokenURI: ipfs://QmYQx7vfrD1QGTKCaoZySfLqmx43v1icKcBnMSt3VmW2EZ/metadata.json
  ```
- Click `transact` (orange button)

**Step 3: Confirm Transaction**
- MetaMask pops up with transaction
- Review gas fees (should be small on testnet)
- Click `Confirm`
- Wait for confirmation (~15-30 seconds)

**Step 4: Verify Minting**
- Transaction success message appears
- Note the returned `tokenId` (usually starts at 0)
- Check Etherscan for transaction details

### View on OpenSea Testnet

**Step 1: Go to OpenSea Testnet**
- Visit [testnets.opensea.io](https://testnets.opensea.io/)
- Connect your MetaMask wallet
- Ensure you're on Sepolia network

**Step 2: Find Your NFT**
- Click your profile icon → "Profile"
- Or directly navigate to:
  ```
  https://testnets.opensea.io/assets/sepolia/YOUR_CONTRACT_ADDRESS/TOKEN_ID
  ```
- Example:
  ```
  https://testnets.opensea.io/assets/sepolia/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb/0
  ```

**Step 3: View NFT Details**
- See your NFT image
- View metadata (name, description)
- Check attributes/properties
- View ownership and transaction history

**Note**: It may take a few minutes for OpenSea to index your NFT metadata.

### View on Etherscan

**Step 1: Go to Sepolia Etherscan**
- Visit [sepolia.etherscan.io](https://sepolia.etherscan.io/)
- Search for your contract address

**Step 2: Navigate to Token Tab**
- Click on your contract address
- Go to "Contract" tab to see verified code
- Go to "Token Tracker" to see NFT info

**Step 3: View Token Transfers**
- See all mint and transfer events
- Verify your minting transaction
- Check current holders

### Add NFT to MetaMask

**Step 1: Open MetaMask**
- Ensure you're on Sepolia network
- Go to "NFTs" tab

**Step 2: Import NFT**
- Click "Import NFT" or "+ Add NFT"
- Input:
  - **Contract Address**: Your NFT contract address
  - **Token ID**: The ID of your minted NFT (usually 0 for first)
- Click "Add"

**Step 3: View NFT**
- NFT should appear in your MetaMask NFTs tab
- Click to see details
- May take a moment to load image from IPFS

**Troubleshooting:**
- If image doesn't load, check IPFS link
- Try viewing on OpenSea first (better IPFS gateway)
- Verify metadata JSON is accessible

---

## 9. Testing Checklist

After implementation, test the following:

**Contract Deployment:**
- [ ] Deploy contract successfully to Sepolia testnet
- [ ] Verify contract address on Etherscan
- [ ] Contract name and symbol are correct

**Asset Preparation:**
- [ ] Image uploaded to IPFS successfully
- [ ] Image accessible via IPFS gateway
- [ ] Metadata JSON created with correct format
- [ ] Metadata uploaded to IPFS
- [ ] Metadata references correct image IPFS link

**Minting:**
- [ ] mintNFT function accessible (only by owner)
- [ ] Can mint NFT with recipient address and tokenURI
- [ ] Token ID increments correctly
- [ ] Transfer event emitted
- [ ] tokenURI returns correct metadata link

**Viewing:**
- [ ] NFT visible on OpenSea testnet
- [ ] Image displays correctly
- [ ] Metadata (name, description) shows properly
- [ ] Attributes display if included
- [ ] NFT appears in MetaMask wallet
- [ ] Transaction visible on Etherscan

**Ownership:**
- [ ] ownerOf returns correct owner address
- [ ] balanceOf shows correct count for owner
- [ ] Only contract owner can mint (access control works)

---

## 10. Key Concepts Summary

### ERC721 vs ERC20

| Aspect | ERC20 (Fungible) | ERC721 (Non-Fungible) |
|--------|------------------|----------------------|
| **Token Type** | All tokens identical | Each token unique |
| **Tracking** | Balance per address | Owner per token ID |
| **Transfer** | Transfer amount | Transfer specific token |
| **Use Case** | Currencies, points | NFTs, collectibles, art |
| **Metadata** | Same for all tokens | Unique per token |

### Token URI and Metadata

- **Token URI**: Link to JSON metadata file
- **Metadata**: Describes NFT properties (name, image, attributes)
- **IPFS**: Decentralized, permanent storage for assets
- **CID**: Content Identifier, unique hash for IPFS files

### Minting Process

1. Upload image to IPFS → Get image CID
2. Create metadata JSON with image link
3. Upload metadata to IPFS → Get metadata CID
4. Deploy NFT contract to testnet
5. Call mintNFT with recipient and metadata URI
6. Token minted with unique ID

### URI Storage

- **Base URI**: Common prefix for all tokens
- **Token URI**: Individual URI per token
- **ERC721URIStorage**: Extension for custom URIs
- **_setTokenURI**: Internal function to set URI

### Access Control

- **Ownable**: Restricts functions to contract owner
- **onlyOwner**: Modifier for protected functions
- **Constructor**: Sets initial owner
- **Security**: Prevents unauthorized minting

---

## 11. Common Pitfalls to Avoid

> **Source**: Best practices derived from OpenZeppelin ERC721 implementation and NFT development patterns

### Smart Contract Issues

1. **Forgetting URI Storage Extension**
   - ❌ Using only `ERC721` without `ERC721URIStorage`
   - ✅ Import and inherit `ERC721URIStorage` for custom metadata

2. **Not Using SafeMint**
   - ❌ Using `_mint()` directly
   - ✅ Use `_safeMint()` to prevent tokens locked in contracts

3. **Missing Access Control**
   - ❌ Allowing anyone to mint
   - ✅ Use `onlyOwner` or other access control

4. **Token ID Collisions**
   - ❌ Not tracking used token IDs
   - ✅ Use counter (`_nextTokenId++`) for unique IDs

5. **Not Overriding Required Functions**
   - ❌ Compilation errors from missing overrides
   - ✅ Override `tokenURI` and `supportsInterface` when using extensions

### Metadata and IPFS Issues

6. **Wrong IPFS Link Format**
   - ❌ Using gateway URL in metadata: `https://ipfs.io/ipfs/Qm...`
   - ✅ Use protocol format: `ipfs://Qm...` (more universal)

7. **Broken Image Links**
   - ❌ Forgetting to upload image before creating metadata
   - ✅ Upload image first, then reference in metadata

8. **Invalid JSON Format**
   - ❌ Missing quotes, commas, or brackets
   - ✅ Validate JSON before uploading (use JSONLint.com)

9. **Not Pinning Files**
   - ❌ Uploading to IPFS without pinning
   - ✅ Use Pinata or similar service to keep files permanently

### Deployment Issues

10. **Wrong Network**
    - ❌ Deploying to mainnet accidentally
    - ✅ Double-check you're on Sepolia testnet

11. **Insufficient Gas**
    - ❌ Setting gas too low
    - ✅ Use default or recommended gas from MetaMask

12. **Not Saving Contract Address**
    - ❌ Losing contract address after deployment
    - ✅ Save address, transaction hash, and Etherscan link

### Viewing Issues

13. **Expecting Instant OpenSea Indexing**
    - ❌ Thinking NFT appears immediately
    - ✅ Wait 5-15 minutes for OpenSea to index metadata

14. **IPFS Gateway Timeout**
    - ❌ Image not loading due to slow gateway
    - ✅ Try different IPFS gateways or use Pinata gateway

15. **Wrong Token ID**
    - ❌ Trying to view non-existent token
    - ✅ Token IDs start at 0 (or your starting value)

---

## References

### Local Reference Files Used:

1. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol` - ERC721 interface definition
2. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol` - ERC721 base implementation (lines 1-430)
3. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol` - Metadata interface
4. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol` - URI storage extension (lines 1-55)
5. `/Users/zanepan/WebstormProjects/Web3/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol` - Enumerable extension reference
6. `/Users/zanepan/WebstormProjects/Web3/Base2-Solidity/2-solidity-upgrade/2.2操作/05ERC系列/02Sepolia上发布NFT.md` - Sepolia NFT deployment guide

### External References:

- [OpenZeppelin ERC721 Documentation](https://docs.openzeppelin.com/contracts/erc721)
- [Ethereum EIP-721 Standard](https://eips.ethereum.org/EIPS/eip-721)
- [OpenSea Metadata Standards](https://docs.opensea.io/docs/metadata-standards)
- [IPFS Documentation](https://docs.ipfs.tech/)
- [Pinata Cloud](https://pinata.cloud/)
- [Remix IDE](https://remix.ethereum.org/)
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [OpenSea Testnet](https://testnets.opensea.io/)
- [Sepolia Etherscan](https://sepolia.etherscan.io/)
- [MetaMask](https://metamask.io/)

### Additional Learning Resources:

- [OpenZeppelin ERC721 Full Implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721)
- [EIP-721 Specification](https://eips.ethereum.org/EIPS/eip-721)
- [EIP-4906 (Metadata Update Event)](https://eips.ethereum.org/EIPS/eip-4906)
- [NFT School](https://nftschool.dev/) - Comprehensive NFT development tutorials
- [IPFS Best Practices](https://docs.ipfs.tech/how-to/best-practices-for-nft-data/)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-13
**Target Solidity Version**: ^0.8.24
**Target Network**: Sepolia Testnet
