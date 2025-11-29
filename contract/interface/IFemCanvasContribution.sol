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
    
    function getUserCanvases(address user) external view returns (uint256[] memory);
    
    function getUserContributionDetails(address user, uint256 canvasId) external view returns (
        uint256 contribution, 
        uint256 ratio, 
        bool hasContribution
    );
    
    function getUserAllContributions(address user) external view returns (
        uint256[] memory canvasIds,
        uint256[] memory contributionAmounts,
        uint256[] memory ratios
    );
}