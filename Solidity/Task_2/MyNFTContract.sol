// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Task: Write an NFT contract
// Requirements:
// - Use OpenZeppelin's ERC721 library to write an NFT contract
// - Constructor: Set NFT name and symbol
// - mintNFT function: Allow users to mint NFT and associate metadata link (tokenURI)
// - Compile in Remix IDE

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleNFT
 * @dev NFT contract with minting functionality and metadata URI support
 */
contract SimpleNFT is ERC721, Ownable {
    // Token ID counter
    uint256 private _tokenIdCounter;

    // Mapping from token ID to token URI
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev Constructor - Set NFT name and symbol
     * @param name_ NFT collection name
     * @param symbol_ NFT collection symbol
     */
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        _tokenIdCounter = 0;
    }

    /**
     * @dev Mint NFT and associate metadata link (tokenURI)
     * @param to Address to receive the minted NFT
     * @param uri Metadata URI for the NFT (e.g., IPFS link)
     * @return tokenId The ID of the newly minted NFT
     */
    function mintNFT(address to, string memory uri) public returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        require(bytes(uri).length > 0, "URI cannot be empty");

        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;

        _mint(to, newTokenId);
        _tokenURIs[newTokenId] = uri;

        return newTokenId;
    }

    /**
     * @dev Returns the URI for a given token ID
     * @param tokenId The token ID to query
     * @return The token URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Returns the total number of tokens minted
     * @return The total supply
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
}
