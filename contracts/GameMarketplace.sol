// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool private _nonReentrant;
    constructor() { _nonReentrant = false; }
    modifier nonReentrant() {
        require(!_nonReentrant, "ReentrancyGuard: reentrant call");
        _nonReentrant = true;
        _;
        _nonReentrant = false;
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _owner = msg.sender; emit OwnershipTransferred(address(0), _owner); }
    modifier onlyOwner() { require(_owner == msg.sender, "Ownable: caller is not the owner"); _; }
    function owner() public view returns (address) { return _owner; }
}

interface IGameNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
}
contract GameMarketplace is ReentrancyGuard, Ownable {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
        bool sold;
    }
    Listing[] public listings;
    mapping(uint256 => bool) public listingExists;
    uint256 public listingCount;
    uint256 public totalVolume;

    event ListingCreated(uint256 indexed lid, address indexed seller, address nftContract, uint256 tokenId, uint256 price);
    event ListingBought(uint256 indexed lid, address indexed buyer, address indexed seller, uint256 price);
    event ListingCancelled(uint256 indexed lid, address indexed seller);

    function listItem(address nftContract, uint256 tokenId, uint256 price)
        external nonReentrant returns (uint256) {
        require(price > 0, "Zero price");
        require(nftContract.code.length > 0, "Invalid NFT contract");
        require(IGameNFT(nftContract).ownerOf(tokenId) == msg.sender, "Not NFT owner");
        IGameNFT(nftContract).transferFrom(msg.sender, address(this), tokenId);
        require(IGameNFT(nftContract).ownerOf(tokenId) == address(this), "NFT escrow failed");
        Listing storage l = listings.push();
        l.seller = msg.sender;
        l.nftContract = nftContract;
        l.tokenId = tokenId;
        l.price = price;
        l.active = true;
        l.sold = false;
        uint256 lid = listings.length - 1;
        listingCount = lid + 1;
        listingExists[lid] = true;
        emit ListingCreated(lid, msg.sender, nftContract, tokenId, price);
        return lid;
    }

    function buyItem(uint256 lid) external payable nonReentrant {
        Listing storage l = listings[lid];
        require(l.active, "Not active");
        require(!l.sold, "Already sold");
        require(msg.value == l.price, "Incorrect price");
        l.sold = true;
        l.active = false;
        totalVolume += l.price;
        IGameNFT(l.nftContract).transferFrom(address(this), msg.sender, l.tokenId);
        // FIX: pay the seller the sale proceeds — was a one-way lockbox before.
        (bool ok,) = payable(l.seller).call{value: l.price}("");
        require(ok, "ETH transfer failed");
        emit ListingBought(lid, msg.sender, l.seller, l.price);
    }

    function cancelListing(uint256 lid) external nonReentrant {
        Listing storage l = listings[lid];
        require(l.active, "Not active");
        require(!l.sold, "Already sold");
        require(l.seller == msg.sender, "Not seller");
        l.active = false;
        IGameNFT(l.nftContract).transferFrom(address(this), l.seller, l.tokenId);
        emit ListingCancelled(lid, msg.sender);
    }

    function getListing(uint256 lid) external view returns (address seller, address nftContract, uint256 tokenId, uint256 price, bool active, bool sold) {
        Listing storage l = listings[lid];
        return (l.seller, l.nftContract, l.tokenId, l.price, l.active, l.sold);
    }
}
