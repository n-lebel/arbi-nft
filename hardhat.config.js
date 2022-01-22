require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config()


const mumbai_id = 'A0fTvH0AHgcGiM3CIwiy1PPYVOQevIiA';
const mainnet_id = 'NbsCB56je5gMLTOFTFu3ML1ZXDsU7k7h';

module.exports = {
  solidity: "0.8.11",
  networks: {
    hardhat: {
      chainid: 1337
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${mumbai_id}`,
      accounts: []
    },
    mainnet: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${mainnet_id}`,
      accounts: []
    },
    rinkarby: {
      url: 'https://rinkeby.arbitrum.io/rpc',
      accounts: [process.env.RINKARBY_PRIVATE_KEY]
    },
  }
};
