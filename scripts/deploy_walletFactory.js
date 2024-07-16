const { ethers, upgrades } = require("hardhat");

async function main() {

  const ContractFactory = await ethers.getContractFactory("MultiSigWalletFactory");
  const mc = await upgrades.deployProxy(ContractFactory);

  await mc.waitForDeployment();
  console.log("Contract deployed to:", await mc.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
  