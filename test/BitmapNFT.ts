import { ethers } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BitmapNFT } from 'typechain'

describe('Token contract', function () {
    let bmpnft: BitmapNFT
    let owner: SignerWithAddress

    describe('Test', async () => {
        it('Test', async () => {
            [owner] = await ethers.getSigners()
            bmpnft = await (await ethers.getContractFactory('BitmapNFT')).connect(owner).deploy() as BitmapNFT
            await bmpnft.deployed()
            console.log(await bmpnft.getSVG(1))
            console.log(await bmpnft.tokenURI(1))
            // console.log(await bmpnft.getSVG(2))
            // console.log(await bmpnft.getSVG(3))
            // console.log(await bmpnft.getSVG(4))
            // console.log(await bmpnft.getSVG(5))
            // console.log(await bmpnft.getSVG(6))
            // console.log(await bmpnft.getSVG(7))
            // console.log(await bmpnft.getSVG(8))
            // console.log(await bmpnft.getSVG(9))
            // console.log(await bmpnft.getSVG(10))
        })
    })
})
