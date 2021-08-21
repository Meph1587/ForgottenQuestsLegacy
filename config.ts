import {NetworksUserConfig} from 'hardhat/types';
import {EtherscanConfig} from '@nomiclabs/hardhat-etherscan/dist/src/types';
import * as dotenv from 'dotenv'

dotenv.config();

const defaultAccount = {
    mnemonic: "test test test test test test test test test test test junk",
    initialIndex: 0,
    path: "m/44'/60'/0'/0",
    count: 20,
    accountsBalance: "10000000000000000000000"
}

const defaultAccountRinkeby = {
    mnemonic: process.env.MNEMONIC,
    initialIndex: 0,
    path: "m/44'/60'/0'/0",
    count: 20,
    accountsBalance: "10000000000000000000000"
}

export const networks: NetworksUserConfig = {
    // Needed for `solidity-coverage`
    coverage: {
        url: 'http://localhost:8555',
    },

    ganache: {
        url: 'http://localhost:7545',
        chainId: 5777,
        accounts: defaultAccount,
        gas: 'auto',
        gasPrice: 20000000000, // 1 gwei
        gasMultiplier: 1.5,
    },

    rinkeby: {
        url: process.env.RINEKBY_API,
        accounts: defaultAccountRinkeby,
        gas: 'auto'
    },

    hardhat: {
        accounts: defaultAccount,
        mining: {
            auto: true
        },
        forking: {
            // I know, I know. Not a good practice to add tokens to git repos.
            // For development, I don't care. :-)
            url: process.env.MAINNET_API,
            enabled: (process.env.MAINNET_ALCHEMY_ENABLED) ? (process.env.MAINNET_ALCHEMY_ENABLED == "true") : false
        }
    },
};

// Use to verify contracts on Etherscan
// https://buidler.dev/plugins/nomiclabs-buidler-etherscan.html
export const etherscan: EtherscanConfig = {
    apiKey: '',
};
