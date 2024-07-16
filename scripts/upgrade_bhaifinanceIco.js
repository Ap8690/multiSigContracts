const { ethers, upgrades } = require('hardhat');

async function main() {
  const ContractFactory = await ethers.getContractFactory('MultiSigWalletFactory');
  const mc = await upgrades.upgradeProxy(
    '0x9cdf42574e31CA0b0a9415ff4572dc50881dC023',
    ContractFactory,
  );

  await mc.waitForDeployment();
  console.log('Contract Upgraded:', await mc.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
