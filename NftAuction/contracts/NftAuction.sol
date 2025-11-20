// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract NftAuction {
    struct Auction {
        address seller;
        uint256 duration;
        uint startPrice;
        bool ended;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public nextAuctionId;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function createAuction(uint256 duration, uint256 startPrice) external {}
}
