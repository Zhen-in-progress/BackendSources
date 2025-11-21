const { ethers } = require("hardhat");
const { expect } = require("chai");
// describe("Starting", async function () {
//   it("should be able to deploy", async function () {
//     const Contract = await ethers.getContractFactory("NftAuction");
//     const contract = await Contract.deploy();
//     await contract.waitForDeployment();

//     await contract.createAuction(
//       100 * 1000,
//       ethers.parseEther("0.00000000000001"),
//       ethers.ZeroAddress,
//       1
//     );

//     const auction = await contract.auctions(0);

//     console.log(auction);
//   });
// });

describe("Test upgrade", async function () {
  it("Should be able to deploy", async function () {
    //1. deploy
    await deployments.fixture(["deployNftAuction"]);

    const NftAuctionProxy = await deployments.get("NftAuctionProxy");
    const NftAuction = await ethers.getContractAt(
      "NftAuction",
      NftAuctionProxy.address
    );
    //2. call createAuction
    await NftAuction.createAuction(
      100 * 1000,
      ethers.parseEther("0.00000000000001"),
      ethers.ZeroAddress,
      1
    );
    const auction = await NftAuction.auctions(0);
    console.log("Auction created successfully:: ", auction);
    //3. upgrade
    await deployments.fixture(["upgradeNftAuction"]);

    const NftAuctionV2 = await ethers.getContractAt(
      "NftAuctionV2",
      NftAuctionProxy.address
    );
    const hello = await NftAuctionV2.testHello();
    console.log("hello", hello);
    //4. print auction[0] from contract
    const auction2 = await NftAuctionV2.auctions(0);
    // console.log("Auction created successfully:: ", await NftAuctionV2.auctions(0));
    expect(auction2.startTime).to.equal(auction.startTime);
  });
});
