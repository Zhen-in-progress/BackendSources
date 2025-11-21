const { deployments, upgrades } = require("hardhat");

const fs = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("deployer:", deployer);
  const NftAuction = await ethers.getContractFactory("NftAuction");
  const nftAuctionProxy = await upgrades.deployProxy(NftAuction, [], {
    initializer: "initialize",
  });

  await nftAuctionProxy.waitForDeployment();

  const proxyAddress = await nftAuctionProxy.getAddress();
  console.log("proxyAddress:", proxyAddress);
  console.log(
    "nftAuctionProxy:",
    await upgrades.erc1967.getImplementationAddress(proxyAddress)
  );

  const implAddress = await upgrades.erc1967.getImplementationAddress(
    proxyAddress
  );

  // Create .cache directory if it doesn't exist
  const cacheDir = path.resolve(__dirname, "./.cache");
  if (!fs.existsSync(cacheDir)) {
    fs.mkdirSync(cacheDir, { recursive: true });
  }

  const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");

  fs.writeFileSync(
    storePath,
    JSON.stringify({
      proxyAddress,
      implAddress,
      abi: NftAuction.interface.format("json"),
    })
  );

  await save("NftAuctionProxy", {
    abi: NftAuction.interface.format("json"),
    address: proxyAddress,
    args: [],
    log: true,
  });

  // await deploy("MyContract", {
  //   from: deployer,
  //   args: ["Hello"],
  //   log: true,
  // });
};

// add tags and dependencies
module.exports.tags = ["deployNftAuction"];
