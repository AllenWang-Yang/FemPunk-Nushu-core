// 手动部署脚本
import { ethers } from 'ethers';
import fs from 'fs';

async function main() {
  console.log("开始手动部署 FemPunk 合约...");

  // 连接到Base Sepolia
  const provider = new ethers.JsonRpcProvider("https://base-sepolia.g.alchemy.com/v2/t6ih1I9_BFd7TtaWHMtIGKVHo1jHywNc");
  const wallet = new ethers.Wallet("0x4659a2859bef8d1cbaeefc3fb75050d1033367750e08777679b0d9d04bcd2784", provider);
  
  console.log("部署账户:", wallet.address);
  console.log("网络:", await provider.getNetwork());

  // 读取编译后的合约
  const femCanvasArtifact = JSON.parse(fs.readFileSync('./artifacts/contract/core/FemCanvas.sol/FemCanvas.json', 'utf8'));
  const femColorsArtifact = JSON.parse(fs.readFileSync('./artifacts/contract/core/FemColors.sol/FemColors.json', 'utf8'));
  const femCanvasContributionArtifact = JSON.parse(fs.readFileSync('./artifacts/contract/core/FemCanvasContribution.sol/FemCanvasContribution.json', 'utf8'));
  const femCanvasRevenueArtifact = JSON.parse(fs.readFileSync('./artifacts/contract/core/FemCanvasRevenue.sol/FemCanvasRevenue.json', 'utf8'));

  try {
    // 1. 部署 FemCanvas
    console.log("\n1. 部署 FemCanvas...");
    const FemCanvas = new ethers.ContractFactory(femCanvasArtifact.abi, femCanvasArtifact.bytecode, wallet);
    const femCanvas = await FemCanvas.deploy("https://api.fempunk.com/canvas/{id}");
    await femCanvas.waitForDeployment();
    const femCanvasAddress = await femCanvas.getAddress();
    console.log("FemCanvas 地址:", femCanvasAddress);

    // 2. 部署 FemColors
    console.log("\n2. 部署 FemColors...");
    const FemColors = new ethers.ContractFactory(femColorsArtifact.abi, femColorsArtifact.bytecode, wallet);
    const femColors = await FemColors.deploy();
    await femColors.waitForDeployment();
    const femColorsAddress = await femColors.getAddress();
    console.log("FemColors 地址:", femColorsAddress);

    // 3. 部署 FemCanvasContribution
    console.log("\n3. 部署 FemCanvasContribution...");
    const FemCanvasContribution = new ethers.ContractFactory(femCanvasContributionArtifact.abi, femCanvasContributionArtifact.bytecode, wallet);
    const femCanvasContribution = await FemCanvasContribution.deploy();
    await femCanvasContribution.waitForDeployment();
    const femCanvasContributionAddress = await femCanvasContribution.getAddress();
    console.log("FemCanvasContribution 地址:", femCanvasContributionAddress);

    // 4. 部署 FemCanvasRevenue
    console.log("\n4. 部署 FemCanvasRevenue...");
    const FemCanvasRevenue = new ethers.ContractFactory(femCanvasRevenueArtifact.abi, femCanvasRevenueArtifact.bytecode, wallet);
    const femCanvasRevenue = await FemCanvasRevenue.deploy(
      femCanvasContributionAddress,
      femCanvasAddress,
      wallet.address
    );
    await femCanvasRevenue.waitForDeployment();
    const femCanvasRevenueAddress = await femCanvasRevenue.getAddress();
    console.log("FemCanvasRevenue 地址:", femCanvasRevenueAddress);

    // 5. 设置合约关联
    console.log("\n5. 设置合约关联...");
    await femCanvas.setRevenueContract(femCanvasRevenueAddress);
    console.log(" FemCanvas 已关联 Revenue 合约");

    // 输出部署摘要
    console.log("\n 部署完成！");
    console.log("==========================================");
    console.log("FemCanvas:", femCanvasAddress);
    console.log("FemColors:", femColorsAddress);
    console.log("FemCanvasContribution:", femCanvasContributionAddress);
    console.log("FemCanvasRevenue:", femCanvasRevenueAddress);
    console.log("==========================================");

    // 保存地址
    const addresses = {
      FemCanvas: femCanvasAddress,
      FemColors: femColorsAddress,
      FemCanvasContribution: femCanvasContributionAddress,
      FemCanvasRevenue: femCanvasRevenueAddress,
      deployer: wallet.address,
      network: "Base Sepolia",
      chainId: 84532
    };

    fs.writeFileSync('deployed-addresses.json', JSON.stringify(addresses, null, 2));
    console.log(" 合约地址已保存到 deployed-addresses.json");

  } catch (error) {
    console.error("部署失败:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });