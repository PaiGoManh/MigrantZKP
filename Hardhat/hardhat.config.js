/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox")
require('dotenv').config();

module.exports = {
  defaultNetwork:"infura",
  networks:{
    localhost:{
      url:"http://127.0.0.1:8545/"
    },
    infura:{
      url:process.env.INFURA_URL,
      accounts: [process.env.PRIVATE_KEY],
    }
  },
  solidity: "0.8.20",
  etherscan: {
    apiKey: {
      sepolia: process.env.apiKey,
    }
  }
};