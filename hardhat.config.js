require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

/** @type import('hardhat/config').HardhatUserConfig */
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const BSC_MAINNET_KEY = process.env.BSC_MAINNET_KEY;
const POLYGON_API_KEY = process.env.POLYGON_API_KEY;
const SEPOLIA_API_KEY=process.env.SEPOLIA_API_KEY
// const MIANNET_RPC = process.env.MIANNET_RPC
module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: {
      bscTestnet: BSC_MAINNET_KEY,
      polygon: POLYGON_API_KEY,
      // mainnet: SEPOLIA_API_KEY,
      bsc: BSC_MAINNET_KEY,
      sepolia: SEPOLIA_API_KEY
    },
    customChains: [
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io/",
        },
      },
    ],
  },

  defaultNetwork: "sepolia",
  networks: {
    hardhat: {
      gas: "auto",
    },

    ganache: {
      url: "HTTP://127.0.0.1:8545",
      chainId: 1337,
      accounts: [PRIVATE_KEY],
      gas: "auto",
    },

    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [PRIVATE_KEY],
    },

    sepolia: {
      url: "https://cosmopolitan-cool-putty.ethereum-sepolia.quiknode.pro/be161061138c769d3e759fcbe0cf52c6d9059f71/",
      chainId: 11155111,
      accounts: [PRIVATE_KEY],
    },

    bscTestnet: {
      url: "https://data-seed-prebsc-1-s3.binance.org:8545/",
      chainId: 97,
      accounts: [PRIVATE_KEY],
    },

    polygon: {
      url: "https://rpc.ankr.com/polygon",
      chainId: 137,
      accounts: [PRIVATE_KEY],
    },

    // mainnet: {
    //   url: MIANNET_RPC,
    //   chainId: 1,
    //   accounts: [PRIVATE_KEY],
    // },
  },
};