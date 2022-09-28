import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers } = hre;
  const Blobs = await ethers.getContractFactory("Blobs");
  const tx = await Blobs.deploy("Blobs", "BLB");
  console.log(tx);

  await tx.deployTransaction.wait();

  await hre.run("verify:verify", {
    address: tx.address,
    constructorArguments: ["Blobs", "BLB"],
  });
};

export default deploy;
