import { HardhatUserConfig, task } from "hardhat/config";
import "tsconfig-paths/register";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "hardhat-circom";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-storage-layout";
import "solidity-coverage";
import { config as configEnv } from "dotenv";

configEnv();

const INFURA_PROJECT_ID = process.env.INFURA_PROJECT_ID;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const MNEMONIC = process.env.MNEMONIC
const testnetAccounts = {
  mnemonic: MNEMONIC,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 10,
  passphrase: "",
};

task("layout", "Prints the contracts memory layout", async (taskArgs, hre) => {
  await hre.storageLayout.export();
});

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      accounts: testnetAccounts,
      // loggingEnabled: true,
      forking: {
        url: `https://goerli.infura.io/v3/${INFURA_PROJECT_ID}`,
        blockNumber: 7378872
      }
    },
    ganache: {
      url: 'http://127.0.0.1:7545',
      accounts: testnetAccounts,
      loggingEnabled: true
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: testnetAccounts,
      chainId: 4
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: testnetAccounts,
      chainId: 5
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [], // TODO: set
      chainId: 1
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"],
            },
          },
        },
      },
    ]
  },
  circom: {
    inputBasePath: "./circuits",
    ptau: "https://hermezptau.blob.core.windows.net/ptau/powersOfTau28_hez_final_15.ptau",
    circuits: [
      {
        name: "hash",
        protocol: "groth16", // protocol: "plonk",
      },
    ],
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
};

export default config;
