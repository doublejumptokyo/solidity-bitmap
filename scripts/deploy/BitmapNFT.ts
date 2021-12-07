import { ethers } from 'hardhat'

const main = async () => {
    const [owner] = await ethers.getSigners()
  
    console.log("Deploying contracts with the account:", owner.address)
    console.log("Account balance:", (await owner.getBalance()).toString())
  
    const BitmapNFT = await ethers.getContractFactory("BitmapNFT")
    const bitmapNFT = await BitmapNFT.connect(owner).deploy()
    await bitmapNFT.deployed()
  
    console.log("Token address:", bitmapNFT.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
