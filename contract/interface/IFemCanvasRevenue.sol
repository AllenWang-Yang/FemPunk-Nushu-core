// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFemCanvasRevenue {
    
    function receiveRevenue(uint256 canvasId) external payable;


    function distributeRevenue(uint256 canvasId) external;

    function claimRevenue(uint256 canvasId) external;

    function claimPlatformFees() external;

    function setPlatformFeeRate(uint256 newRate) external;

    function setPlatformFeeRecipient(address newRecipient) external;

    function getClaimableAmount(uint256 canvasId, address contributor) external view returns (uint256);

    function getTotalClaimableAmount(uint256[] calldata canvasIds, address contributor) external view returns (uint256 total);

    function getCanvasRevenueStatus(uint256 canvasId) external view returns (uint256 totalRevenue, bool distributed, uint256 contributorsCount);

    function emergencyWithdraw() external;

    function canvasRevenue(uint256 canvasId) external view returns (uint256);

    function claimableAmount(uint256 canvasId, address contributor) external view returns (uint256);

    function revenueDistributed(uint256 canvasId) external view returns (bool);

    function platformFeeRate() external view returns (uint256);

    function platformFeeRecipientAddress() external view returns (address);

    function totalPlatformFees() external view returns (uint256);


    event RevenueReceived(uint256 indexed canvasId, uint256 amount);
    event RevenueDistributed(uint256 indexed canvasId, uint256 totalAmount, uint256 contributorsCount);
    event RevenueClaimed(uint256 indexed canvasId, address indexed contributor, uint256 amount);
    event PlatformFeeUpdated(uint256 oldRate, uint256 newRate);
    event PlatformFeeRecipientUpdated(address oldRecipient, address newRecipient);

}
