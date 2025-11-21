const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("deployer address:", deployer);

  const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");
  const storeData = fs.readFileSync(storePath, "utf-8");
  const { proxyAddress, implAddress, abi } = JSON.parse(storeData);

  const NftAuctionV2 = await ethers.getContractFactory("NftAuctionV2");

  const NftAuctionProxyV2 = await upgrades.upgradeProxy(
    proxyAddress,
    NftAuctionV2
  );
  await NftAuctionProxyV2.waitForDeployment();
  const proxyAddressV2 = await NftAuctionProxyV2.getAddress();

  // fs.writeFileSync(
  //   storePath,
  //   JSON.stringify({
  //     proxyAddress: proxyAddressV2,
  //     implAddress,
  //     abi,
  //   })
  // );
  await save("NftAuctionProxyV2", {
    abi,
    address: proxyAddressV2,
  });
};
module.exports.tags = ["upgradeNftAuction"];
