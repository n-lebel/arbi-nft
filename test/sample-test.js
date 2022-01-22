const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should create and execute market sales", async function () {
    const Market = await ethers.getContractFactory("NFTMarket")
    const market = await Market.deploy()
    await market.deployed()

    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy(market.address)
    await nft.deployed()

    let listingPrice = (await market.getListingPrice()).toString()
    const auctionPrice = ethers.utils.parseUnits('100', 'ether')

    await nft.createToken("http://www.mytokenlocation.com/")
    await nft.createToken("http://www.mytokenlocation2.com/")

    await market.createMarketItem(nft.address, 1, auctionPrice, { value: listingPrice })
    await market.createMarketItem(nft.address, 2, auctionPrice, { value: listingPrice })

    const [_, address1, address2, address3] = await ethers.getSigners()

    await market.connect(address1).createMarketSale(nft.address, 1, { value: auctionPrice })

    const items = await market.fetchMarketItems();
    console.log("Items: ", items)

    await Promise.all(items.map(async i => {
      //console.log(i)
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))

  });
});
