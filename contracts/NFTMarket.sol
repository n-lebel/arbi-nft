// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable private _owner;
    uint256 private _listingPrice = 0.025 ether;

    constructor() {
        _owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private _idToMarketItem;

    event MarketItemCreated(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return _listingPrice;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be nonzero");
        require(
            msg.value == _listingPrice,
            "msg.value does not equal listing price"
        );

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        _idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        console.log("tokenID: ", tokenId);

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
    {
        uint256 price = _idToMarketItem[itemId].price;
        address payable seller = _idToMarketItem[itemId].seller;
        require(msg.value == price, "msg.value is not equal to item price");

        _idToMarketItem[itemId].sold = true;
        _idToMarketItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();

        IERC721(nftContract).transferFrom(
            address(this),
            msg.sender,
            _idToMarketItem[itemId].tokenId
        );

        (bool success, ) = seller.call{value: msg.value}("");
        require(success, "Payment to owner failed");
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = itemCount - _itemsSold.current();

        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (_idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = _idToMarketItem[i + 1].itemId;
                MarketItem storage item = _idToMarketItem[currentId];
                items[currentIndex] = item;
                currentIndex++;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToMarketItem[i + 1].owner == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToMarketItem[i + 1].owner == msg.sender) {
                uint256 itemIndex = _idToMarketItem[i + 1].itemId;
                MarketItem storage item = _idToMarketItem[itemIndex];
                items[currentIndex] = item;
                currentIndex++;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToMarketItem[i + 1].seller == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToMarketItem[i + 1].seller == msg.sender) {
                uint256 itemIndex = _idToMarketItem[i + 1].itemId;
                MarketItem storage item = _idToMarketItem[itemIndex];
                items[currentIndex] = item;
                currentIndex++;
            }
        }
        return items;
    }
}
