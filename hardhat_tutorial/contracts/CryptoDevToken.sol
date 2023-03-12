//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    //price of one CryptoDev Token
    uint256 public constant tokenPrice = 0.001 ether;

    //each NFT would give 10tokens to the user.abi
    uint256 public constant tokensPerNFT = 10 * 10**18;

    //max total supply is 10000 for CryptoDev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    //instance of CryptoDev contract instance
    ICryptoDevs CryptoDevsNFT;

    //keeping track of which token ids have already claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevContract) ERC20("CryptoDev Token", "CDT") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevContract);
    }

    //function to mint amount of tokens specified in the args
    //in our case it will be 10
    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ehter sent is incorrect");
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the Max. total supply."
        );
        _mint(msg.sender, amountWithDecimals);  //internal function from openzappelin's ERC20 contract
    }

    //fuction to mint the tokens on the based on number of NFTs held by the user
    function claim() public {
        address sender = msg.sender;
        //get the number of NFT held by a given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender);

        //reverting the transaction if no NFT found
        require(balance > 0, "You don't own any Crypto Dev NFT!");

        //keepuing track of unclaimed tokenID
        uint256 amount = 0;

        //getting tokenId and balance owned by the sender at a given index
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            //if tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        //revert the transaction if all transactions have been claimed
        require(amount > 0, "You have already claimed all the tokens!");

        //calling the internal function from ERC20
        _mint(msg.sender, amount * tokensPerNFT);
    }

    //function to send all ETH from contract to owner address
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, Contract balance is empty");

        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send the ETH.");
    }

    //function to recieve ether by contract when msg.data is empty
    receive() external payable {}

    //function fallback when msg.data is not empty
    fallback() external payable {}
}