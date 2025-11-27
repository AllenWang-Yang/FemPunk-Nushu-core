import "@nomicfoundation/hardhat-ethers";

/** @type import('hardhat/config').HardhatUserConfig */
export default {
  solidity: "0.8.20",
  paths: {
    sources: "./contract",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  networks: {
    baseSepolia: {
      type: "http",
      url: "https://base-sepolia.g.alchemy.com/v2/t6ih1I9_BFd7TtaWHMtIGKVHo1jHywNc",
      accounts: ["0x4659a2859bef8d1cbaeefc3fb75050d1033367750e08777679b0d9d04bcd2784"]
    }
  }
};