const { ethers, deployments, network } = require("hardhat");
const { expect } = require("chai");
describe("Test auction", async function () {
  it("Should be ok", async function () {
    await main();
  });
});

async function main() {
  await deployments.fixture(["deployNftAuction"]);
  const nftAuctionProxy = await deployments.get("NftAuctionProxy");

  const [signer, buyer] = await ethers.getSigners();
  // 1. Deploy ERC721 contract
  const TestERC721 = await ethers.getContractFactory("TestERC721");
  const testERC721 = await TestERC721.deploy();
  await testERC721.waitForDeployment();
  const testERC721Address = await testERC721.getAddress();
  console.log("testERC721Address:", testERC721Address);

  //1.mint 10 nft
  for (let i = 0; i < 10; i++) {
    await testERC721.mint(signer.address, i + 1);
  }

  const tokenId = 1;
  // 2. Call createAuction to create an auction
  const nftAuction = await ethers.getContractAt(
    "NftAuction",
    nftAuctionProxy.address
  );

  //
  await testERC721
    .connect(signer)
    .setApprovalForAll(nftAuctionProxy.address, true);

  await nftAuction.createAuction(
    100 * 1000,  // 100 seconds
    ethers.parseEther("0.01"),
    testERC721Address,
    tokenId
  );

  const auction = await nftAuction.auctions(0);

  console.log("auction created sucessfully::", auction);
  //3. buyer participate
  // await testERC721.setApprovalForAll(nftAuctionProxy.address, true)
  await nftAuction
    .connect(buyer)
    .placeBid(0, { value: ethers.parseEther("0.02") });  // Higher than starting price

  //4. end auction
  // Fast-forward time by 100,001 seconds (past the 100,000-second auction duration)
  await network.provider.send("evm_increaseTime", [100001]);
  await network.provider.send("evm_mine");

  await nftAuction.connect(signer).endAuction(0);
  //verify results;
  const auctionResult = await nftAuction.auctions(0);
  expect(auctionResult.highestBidder).to.equal(buyer.address);
  expect(auctionResult.highestBid).to.equal(ethers.parseEther("0.02"));

  //verify NFT ownership
  const owner = await testERC721.ownerOf(tokenId);
  console.log("owner::", owner);
  expect(owner).to.equal(buyer.address);
}

main();
