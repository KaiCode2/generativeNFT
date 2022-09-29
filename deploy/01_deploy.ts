import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers } = hre;
  const Blobs = await ethers.getContractFactory("Filters");
  const tx = await Blobs.deploy("Filters", "FLT");
  console.log(tx);

  await tx.deployTransaction.wait();

  const mint = await tx.mint("https://upload.wikimedia.org/wikipedia/commons/3/34/Edvard-Munch-The-Scream.jpg");

  await mint.wait();

  console.log(await tx.tokenURI(0));

  if (hre.network.name == "goerli" || hre.network.name == "mainnet") {
    await hre.run("verify:verify", {
      address: tx.address,
      constructorArguments: ["Filters", "FLT"],
    });
  }
};

export default deploy;
