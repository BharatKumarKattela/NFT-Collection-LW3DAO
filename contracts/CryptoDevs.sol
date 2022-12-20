//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {

    IWhitelist whitelist;

    string _baseTokenURI;

    // _price: price of one NFT
    uint256 public _price = 0.01 ether;

    //_paused: to pause the contract
    bool public _paused;

    // maxTokenIds: maximum number of token IDs
    uint public maxTokenIds = 20;

    //tokenIds: total number of tokens minted
    uint public tokenIds;

    //preSaleStarted: boolean to keep track of presale started or not
    bool public preSaleStarted;

    //preSaleEndTime: Timestamp of end time of presale
    uint public preSaleEndTime;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract current paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        preSaleStarted = true;

        preSaleEndTime = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(preSaleStarted && block.timestamp < preSaleEndTime, "Presale is Ended");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "All NFT are minted");
        require(msg.value >= _price, "Minimum NFT price is 0.01 ether. Please send more than 0.01 ether");

        tokenIds += 1;

        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable onlyWhenNotPaused {
        require(preSaleStarted && block.timestamp >= preSaleEndTime, "Presale has nt ended yet");
        require(tokenIds < maxTokenIds, "Exceeded Max supply");
        require(msg.value >= _price, "Minimum NFT price is 0.01 ether. Please send more than 0.01 ether");

        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool value) public onlyOwner {
        _paused = value;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to withdraw");
    }

    receive() external payable {}

    fallback() external payable{}


}
