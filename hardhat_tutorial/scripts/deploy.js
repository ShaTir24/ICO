const { ethers } = require("hardhat");
require("deotenv").config({ path: ".env"});
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  //address of the cryptoDev NFT contract
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;

  const cryptoDevsTokenContract = await ethers.getContractFactory("CryptoDevToken");
  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(cryptoDevsNFTContract);
  await deployedCryptoDevsTokenContract.deployed();

  //printing the address of the generated contract after compiling
  console.log(
    "Crypto Devs Token Contract Address: ", 
    deployedCryptoDevsTokenContract.address
  );
}

//calling the main function and checking for errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });