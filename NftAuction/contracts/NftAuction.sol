// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";
contract NftAuction is Initializable, UUPSUpgradeable {
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
        // biding unit
        // 0:eth
        // 1:ERC20
        //
        address tokenAddress;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public nextAuctionId;
    address public admin;
    mapping(address => AggregatorV3Interface) public priceETHFeed;

    function initialize() public initializer {
        admin = msg.sender;
    }

    function setPriceETHFeed(
        address tokenAddress,
        address _priceETHFeed
    ) public {
        priceETHFeed[tokenAddress] = AggregatorV3Interface(_priceETHFeed);
    }

    function getLChainlinkDataFeedLatestAnswer(
        address tokenAddress
    ) public view returns (int256) {
        (, int256 answer, , , ) = priceETHFeed[tokenAddress].latestRoundData();

        // emit PriceUpdated(price);
        return answer;
    }

    function createAuction(
        uint256 _duration,
        uint256 _startPrice,
        address _nftAddress,
        uint _tokenId
    ) public {
        require(msg.sender == admin, "Only admin can create auctions");
        require(_duration > 10, "Duration must be greater than 10 seconds");
        require(_startPrice > 0, "Starting price must be greater than zero");

        // Transfer NFT from seller to this contract
        // Note: Seller must approve this contract BEFORE calling createAuction
        IERC721(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        auctions[nextAuctionId] = Auction({
            seller: msg.sender,
            nftContract: _nftAddress,
            tokenId: _tokenId,
            duration: _duration,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            startTime: block.timestamp,
            tokenAddress: address(0) // 0 = ETH bidding
        });
        nextAuctionId++;
    }

    // buyer
    function placeBid(
        uint _auctionId,
        uint256 _amount,
        address _tokenAddress
    ) external payable {
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

        uint payValue;
        if (_tokenAddress != address(0)) {
            payValue =
                _amount *
                uint(getLChainlinkDataFeedLatestAnswer(_tokenAddress));
        } else {
            _amount = msg.value;
            payValue =
                _amount *
                uint(getLChainlinkDataFeedLatestAnswer(address(0)));
        }

        // check whether it is eth or erc20
        if (_tokenAddress != address(0)) {
            uint startPriceValue = auction.startPrice *
                uint(getLChainlinkDataFeedLatestAnswer(auction.tokenAddress));
            uint highestBidValue = auction.highestBid *
                uint(getLChainlinkDataFeedLatestAnswer(auction.tokenAddress));

            require(
                payValue >= startPriceValue && payValue > highestBidValue,
                "Bid must be higher than the current highest bid"
            );

            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (auction.tokenAddress == address(0)) {
                payable(auction.highestBidder).transfer(auction.highestBid);
            } else {
                IERC20(auction.tokenAddress).transfer(
                    auction.highestBidder,
                    auction.highestBid
                );
            }
            auction.tokenAddress = _tokenAddress;
            auction.highestBid = _amount;
        } else {
            payValue =
                msg.value *
                uint(getLChainlinkDataFeedLatestAnswer(address(0)));
        }

        // if (auction.highestBidder != address(0)) {
        //     payable(auction.highestBidder).transfer(auction.highestBid);
        // }
        auction.tokenAddress = _tokenAddress;
        auction.highestBidder = msg.sender;
        auction.highestBid = _amount;
    }

    // end auction
    function endAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        require(
            !auction.ended &&
                auction.startTime + auction.duration <= block.timestamp,
            "Auction has not ended"
        );
        //transfer NFT to HighestBidder
        IERC721(auction.nftContract).safeTransferFrom(
            address(this),
            auction.highestBidder,
            auction.tokenId
        );

        // Transfer bid amount to seller
        if (auction.tokenAddress == address(0)) {
            // ETH payment
            payable(auction.seller).transfer(auction.highestBid);
        } else {
            // ERC20 payment
            IERC20(auction.tokenAddress).transfer(
                auction.seller,
                auction.highestBid
            );
        }

        auction.ended = true;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal view override {
        require(msg.sender == admin, "Only admin can upgrade");
    }
}
