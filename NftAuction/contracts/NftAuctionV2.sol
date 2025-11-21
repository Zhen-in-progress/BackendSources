// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
contract NftAuctionV2 is Initializable {
    struct Auction {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 duration;
        uint startPrice;
        uint startTime;
        bool ended;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public nextAuctionId;
    address public admin;

    function initialize() public initializer {
        admin = msg.sender;
    }

    function createAuction(
        uint256 _duration,
        uint256 _startPrice,
        address _nftAdress,
        uint _tokenId
    ) public {
        require(msg.sender == admin, "Only admin can create auctions");
        require(
            _duration > 1000 * 60,
            "Duration must be greater than 1 minute"
        );
        require(_startPrice > 0, "Starting price must be greater than zero");
        auctions[nextAuctionId] = Auction({
            seller: msg.sender,
            nftContract: _nftAdress,
            tokenId: _tokenId,
            duration: _duration,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            startTime: block.timestamp
        });
        nextAuctionId++;
    }

    // buyer
    function placeBid(uint _auctionId) external payable {
        Auction storage auction = auctions[_auctionId];
        require(
            auction.startTime <= block.timestamp,
            "Auction has not started yet"
        );
        require(
            !auction.ended &&
                auction.startTime + auction.duration > block.timestamp,
            "Auction has ended"
        );
        require(
            msg.value > auction.highestBid && msg.value > auction.startPrice,
            "Bid must be higher than the current highest bid"
        );

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }
    function testHello() public pure returns (string memory) {
        return "Hello, World! upgrading to V2";
    }
}
