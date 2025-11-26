// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFemCanvasContribution {

    event ContributionRecorded(uint256 indexed canvasId,address indexed contributor,uint256 contributions);

    event ContributionsBatchRecorded(uint256 indexed canvasId,address[] contributors,uint256[] contributions);

    function recordContribution(uint256 canvasId,address contributor,uint256 amount) external;

    function recordContributionsBatch(uint256 canvasId,address[] calldata contributors,uint256[] calldata contributions) external;

    function getContributionByIdAndAddress(uint256 canvasId,address contributor) external view returns(uint256);

    function getTotalContribution(uint256 canvasId) external view returns(uint256);

    function getCanvasContributionDetails(uint256 canvasId) external view returns (address[] memory contributors,
    uint256[] memory amounts,uint256 totalContributions);
    
}