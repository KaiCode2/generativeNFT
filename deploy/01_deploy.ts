import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers } = hre;
  const Blobs = await ethers.getContractFactory("Diamonds");
  const tx = await Blobs.deploy("Diamonds", "DMD");
  console.log(tx);

  await tx.deployTransaction.wait();

  if (hre.network.name == "goerli" || hre.network.name == "mainnet") {
    await hre.run("verify:verify", {
        address: tx.address,
        constructorArguments: ["Diamonds", "DMD"],
      });
  } else {
    await tx.mint(0);
    console.log(await tx.tokenURI(0));
  }
};

export default deploy;
