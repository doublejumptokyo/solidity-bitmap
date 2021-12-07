import { HardhatUserConfig } from 'hardhat/config'

import '@nomiclabs/hardhat-waffle'
import '@nomiclabs/hardhat-etherscan'
import '@typechain/hardhat'
import 'hardhat-gas-reporter'

// const RINKEBY_PRIVATE_KEY = 'YOUR_KEY'
// const POLYGON_PRIVATE_KEY = 'YOUR_KEY'
// const ETHERSCAN_API_KEY = 'YOUR_KEY'

const config: HardhatUserConfig = {
    defaultNetwork: 'hardhat',
    networks: {
        hardhat: {},
        // rinkeby: {
        //     url: 'YOUR_URL',
        //     chainId: 4,
        //     gas: 3000000,
        //     gasPrice: 1000000001,
        //     timeout: 20000,
        //     accounts: [`0x${RINKEBY_PRIVATE_KEY}`],
        // },
        // polygon: {
        //     url: 'YOUR_URL',
        //     chainId: 137,
        //     accounts: [`0x${POLYGON_PRIVATE_KEY}`],
        // },
    },
    solidity: {
        version: '0.8.4',
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    gasReporter: {
        enabled: true,
        currency: 'ETH',
        gasPrice: 100,
    },
    // etherscan: {
    //     apiKey: `${ETHERSCAN_API_KEY}`,
    // },
}

export default config
