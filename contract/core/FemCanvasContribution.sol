// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interface/IFemCanvasContribution.sol";

contract FemCanvasContribution is IFemCanvasContribution, Ownable, ReentrancyGuard {
    // key is canvasId
    mapping(uint256 => mapping(address => uint256)) public contributions;
    // key is canvasId
    mapping(uint256 => uint256) public totalContributions;
    // key is canvasId,value is array of contributor addresses
    mapping(uint256 => address[]) public contributorsList;
    // key is canvasId, contributor address, value is whether is contributor
    mapping(uint256 => mapping(address => bool)) public isContributor;
    
    // authorized recorders
    mapping(address => bool) public authorizedRecorders;
    
    modifier onlyAuthorized() {
        require(authorizedRecorders[msg.sender] || msg.sender == owner(), "Not authorized");
        _;
    }
    
    constructor() Ownable(msg.sender) {
        authorizedRecorders[msg.sender] = true;
    }
    
    function setAuthorizedRecorder(address recorder, bool authorized) external onlyOwner {
        authorizedRecorders[recorder] = authorized;
    }
    
    function recordContribution(uint256 canvasId,address contributor,uint256 _contributions) external override onlyAuthorized {
        require(contributor != address(0), "Invalid contributor address");
        require(_contributions > 0, "Amount must be greater than 0");
        
        if (!isContributor[canvasId][contributor]) {
            contributorsList[canvasId].push(contributor);
            isContributor[canvasId][contributor] = true;
        }
        
        // update contributions
        contributions[canvasId][contributor] += _contributions;
        totalContributions[canvasId] += _contributions;
        
        emit ContributionRecorded(canvasId, contributor, _contributions);
    }
    
    function recordContributionsBatch(uint256 canvasId,address[] calldata contributors,uint256[] calldata _contributions) external override onlyAuthorized {
        require(contributors.length == _contributions.length, "Arrays length mismatch");
        require(contributors.length > 0, "Empty arrays");
        
        uint256 totalBatchAmount = 0;
        
        for (uint256 i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 amount = _contributions[i];
            
            require(contributor != address(0), "Invalid contributor address");
            require(amount > 0, "Amount must be greater than 0");
            
            if (!isContributor[canvasId][contributor]) {
                contributorsList[canvasId].push(contributor);
                isContributor[canvasId][contributor] = true;
            }
            
            // update contributions
            contributions[canvasId][contributor] += amount;
            totalBatchAmount += amount;
        }
        
        totalContributions[canvasId] += totalBatchAmount;
        
        emit ContributionsBatchRecorded(canvasId, contributors, _contributions);
    }
    
    function getContributionByIdAndAddress(uint256 canvasId,address contributor) external view override returns (uint256) {
        return contributions[canvasId][contributor];
    }
    
    function getTotalContribution(uint256 canvasId) external view override returns (uint256) {
        return totalContributions[canvasId];
    }
    
    function getContributors(uint256 canvasId) external view returns (address[] memory) {
        return contributorsList[canvasId];
    }
    
    function getContributorsCount(uint256 canvasId) external view returns (uint256) {
        return contributorsList[canvasId].length;
    }
    
    function getContributionRatio(
        uint256 canvasId,
        address contributor
    ) external view returns (uint256) {
        uint256 total = totalContributions[canvasId];
        if (total == 0) return 0;
        
        uint256 contributorAmount = contributions[canvasId][contributor];
        return (contributorAmount * 10000) / total;
    }
    
    function getContributionsBatch(
        uint256 canvasId,
        address[] calldata contributors
    ) external view returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](contributors.length);
        
        for (uint256 i = 0; i < contributors.length; i++) {
            amounts[i] = contributions[canvasId][contributors[i]];
        }
        
        return amounts;
    }
    

    function getCanvasContributionDetails(uint256 canvasId) external view returns (
            address[] memory contributors,
            uint256[] memory amounts,
            uint256 total
        ) 
    {
        contributors = contributorsList[canvasId];
        amounts = new uint256[](contributors.length);
        
        for (uint256 i = 0; i < contributors.length; i++) {
            amounts[i] = contributions[canvasId][contributors[i]];
        }
        
        total = totalContributions[canvasId];
        return (contributors, amounts, total);
    }
    

    function resetCanvasContributions(uint256 canvasId) external onlyOwner {
        address[] memory contributors = contributorsList[canvasId];
        
        for (uint256 i = 0; i < contributors.length; i++) {
            contributions[canvasId][contributors[i]] = 0;
            isContributor[canvasId][contributors[i]] = false;
        }
        
        delete contributorsList[canvasId];
        totalContributions[canvasId] = 0;
    }
}