require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
    },
    eth: {
      url: process.env.ETH_RPC_PROVIDER,
      accounts: [process.env.PRIVATE_KEY]
    },
    fantom: {
      url: process.env.FANTOM_RPC_PROVIDER,
      accounts: [process.env.PRIVATE_KEY]
    },
    bsc: {
      url: process.env.BSC_RPC_PROVIDER,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      eth: process.env.ETH_API_KEY,
      fantom: process.env.FANTOM_API_KEY,
      bsc: process.env.BSCSCAN_API_KEY
    }
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
