/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "infura",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545/"
    },
    infura: { // Should typically be named "sepolia" for Sepolia testnet
      url: process.env.INFURA_URL,
      accounts: [process.env.PRIVATE_KEY],
    }
  },
  solidity: "0.8.20",
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY, // More standard name
    }
  }
};