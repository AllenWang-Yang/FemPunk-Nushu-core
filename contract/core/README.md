# FemCanvas 合约系统

## 系统概述

FemCanvas 是一个多人协作创作画布的 Web3 平台，支持每日画布创作、贡献记录和收益分润。

## 合约架构

### 核心合约

1. **FemCanvasFactory.sol** - 工厂合约，统一管理整个系统
2. **FemCanvas.sol** - 画布合约，管理ERC1155 NFT和画布生命周期
3. **FemCanvasContribution.sol** - 贡献记录合约，记录用户贡献量
4. **FemCanvasRevenue.sol** - 收益分润合约，管理销售收益分配

### 接口定义

- **IFemCanvas.sol** - 画布合约接口
- **IFemCanvasContribution.sol** - 贡献记录接口
- **IFemColors.sol** - 颜色NFT接口（可选扩展）

## 系统流程

### 1. 创作期 (Creation Phase)

```solidity
// 创建每日画布
factory.createDailyCanvas(dayTimestamp, ipfsURI);

// 记录用户贡献
factory.recordUserContribution(canvasId, contributor, amount);
```

### 2. 结算期 (Settlement Phase)

```solidity
// 批量记录最终贡献
factory.recordContributionsBatch(canvasId, contributors, amounts);

// 完成画布
factory.finalizeCanvas(canvasId);
```

### 3. 销售期 (Sales Phase)

```solidity
// 接收销售收益
revenueContract.receiveRevenue{value: amount}(canvasId);

// 分配收益
factory.distributeCanvasRevenue(canvasId);

// 用户提取收益
revenueContract.claimRevenue(canvasId);
```

## 部署指南

### 1. 环境准备

```bash
npm install --save-dev hardhat @openzeppelin/contracts
```

### 2. 部署系统

```bash
npx hardhat run contract/core/deploy.js --network <network>
```

### 3. 验证合约

```bash
npx hardhat verify --network <network> <contract_address>
```

## 使用示例

### 创建画布

```javascript
const factory = await ethers.getContractAt("FemCanvasFactory", factoryAddress);

// 创建今日画布
const dayTimestamp = Math.floor(Date.now() / 1000 / 86400) * 86400;
await factory.createDailyCanvas(dayTimestamp, "QmIPFSHash...");
```

### 记录贡献

```javascript
// 单个贡献记录
await factory.recordUserContribution(canvasId, userAddress, pixelCount);

// 批量贡献记录（结算时使用）
await factory.recordContributionsBatch(
    canvasId,
    [user1, user2, user3],
    [100, 200, 150]
);
```

### 收益分润

```javascript
const revenueContract = await ethers.getContractAt("FemCanvasRevenue", revenueAddress);

// 接收销售收益
await revenueContract.receiveRevenue(canvasId, {value: ethers.parseEther("1.0")});

// 分配收益
await factory.distributeCanvasRevenue(canvasId);

// 用户提取收益
await revenueContract.claimRevenue(canvasId);
```

## 查询接口

### 画布信息

```javascript
// 获取画布详情
const canvas = await canvasContract.getCanvas(canvasId);

// 根据日期查询画布ID
const canvasId = await canvasContract.getCanvasIdByDay(dayTimestamp);
```

### 贡献信息

```javascript
// 查询用户贡献
const contribution = await contributionContract.getContributionByIdAndAddress(canvasId, userAddress);

// 查询总贡献
const totalContribution = await contributionContract.getTotalContribution(canvasId);

// 查询贡献比例
const ratio = await contributionContract.getContributionRatio(canvasId, userAddress);
```

### 收益信息

```javascript
// 查询可提取金额
const claimable = await revenueContract.getClaimableAmount(canvasId, userAddress);

// 查询已提取金额
const claimed = await revenueContract.getClaimedAmount(canvasId, userAddress);
```

## 权限管理

### 系统管理员

```javascript
// 设置系统管理员
await factory.setSystemAdmin(adminAddress, true);

// 移除系统管理员
await factory.setSystemAdmin(adminAddress, false);
```

### 合约授权

```javascript
// 设置画布合约授权铸造者
await canvasContract.setAuthorizedMinter(minterAddress, true);

// 设置贡献合约授权记录者
await contributionContract.setAuthorizedRecorder(recorderAddress, true);
```

## 安全考虑

1. **重入攻击防护** - 所有涉及资金转移的函数都使用了 `ReentrancyGuard`
2. **权限控制** - 关键函数只能由授权地址调用
3. **输入验证** - 所有外部输入都进行了严格验证
4. **溢出保护** - 使用 Solidity 0.8+ 的内置溢出检查

## 升级策略

当前合约设计为不可升级，确保去中心化和安全性。如需升级：

1. 部署新版本合约
2. 迁移数据（如需要）
3. 更新前端接口

## Gas 优化

1. **批量操作** - 提供批量记录贡献和提取收益功能
2. **存储优化** - 合理设计存储结构，减少存储槽使用
3. **事件日志** - 使用事件记录重要操作，减少链上存储

## 测试

```bash
# 运行测试
npx hardhat test

# 生成覆盖率报告
npx hardhat coverage
```

## 许可证

MIT License