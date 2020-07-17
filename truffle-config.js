require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');
const infuraProjectId = process.env.INFURA_PROJECT_ID;

module.exports = {

    networks: {
        development: {
            host: "127.0.0.1",
            gas: "6000000",
            network_id: "*",
            port: "8545",
        },
        rinkeby: {
            provider: () => new HDWalletProvider(process.env.DEV_MNEMONIC, "https://rinkeby.infura.io/v3/" + infuraProjectId),
            networkId: 4,       // Rinkeby's id
        },
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.5.17",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 10000,
                },
            },
        },
    },
}

