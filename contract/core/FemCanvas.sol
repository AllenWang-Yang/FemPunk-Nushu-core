// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interface/IFemCanvas.sol";

contract FemCanvas is IFemCanvas, ERC1155, Ownable, ReentrancyGuard {
    uint256 public canvasCounter;
    // canvasCounter:canvasId
    mapping(uint256 => uint256) canvasCounterMapping;
    // canvasId => Canvas
    mapping(uint256 => Canvas) public canvases;
    // dayTimestamp => canvasId      
    mapping(uint256 => uint256) public dayToCanvasId;
    mapping(address => bool) public authorizedMinters;

    modifier onlyAuthorized() {
        require(authorizedMinters[msg.sender] || msg.sender == owner(), "Not authorized");
        _;
    }

    constructor(string memory initialURI) ERC1155(initialURI) Ownable(msg.sender) {
        authorizedMinters[msg.sender] = true;
    }

    function setAuthorizedMinter(address minter, bool authorized) external onlyOwner {
        authorizedMinters[minter] = authorized;
    }

    function mintCanvas(uint256 canvasId,uint256 dayTimestamp,string calldata _metadataURI,uint256 supply) external payable override{
        require(canvases[canvasId].canvasId == 0, "Canvas already exists");
        require(dayToCanvasId[dayTimestamp] == 0, "Canvas for this day already exists");
        require(bytes(_metadataURI).length > 0, "Invalid IPFS URI");
        require(supply > 0, "Supply must be greater than zero");
        require(msg.value > 0, "Payment required");

        canvases[canvasId] = Canvas({
            canvasId: canvasId,
            dayTimestamp: dayTimestamp,
            metadataURI: _metadataURI,
            creator: 0x92Ae87507658451736821bfFa913BAC0e184d4e2,// todo
            totalRaised: 0,
            finalized: false
        });

        dayToCanvasId[dayTimestamp] = canvasId;
        canvasCounter++;
        canvasCounterMapping[canvasId] = canvasCounter;

        _mint(msg.sender, canvasId, supply, "");
        canvases[canvasId].totalRaised += msg.value;
        payable(owner()).transfer(msg.value);
        
        emit CanvasCreated(canvasId, dayTimestamp, _metadataURI, msg.sender,canvasCounter);
    }

    function finalized(uint256 canvasId) external override onlyAuthorized {
        require(canvases[canvasId].canvasId != 0, "Canvas does not exist");
        require(!canvases[canvasId].finalized, "Canvas already finalized");

        canvases[canvasId].finalized = true;
        emit CanavasFinalized(canvasId, canvases[canvasId].dayTimestamp);
    }

    function updateCanvasURI(uint256 canvasId, string calldata newURI) external onlyAuthorized {
        require(canvases[canvasId].canvasId != 0, "Canvas does not exist");
        require(!canvases[canvasId].finalized, "Cannot update finalized canvas");

        canvases[canvasId].metadataURI = newURI;
        emit CanvasURIUpdate(canvasId, newURI);
    }

    function getCanvasIdByDay(uint256 dayTimestamp) external view override returns (uint256) {
        return dayToCanvasId[dayTimestamp];
    }

    function getCanvas(uint256 canvasId) external view override returns (Canvas memory) {
        require(canvases[canvasId].canvasId != 0, "Canvas does not exist");
        return canvases[canvasId];
    }

    function updateTotalRaised(uint256 canvasId, uint256 amount) external onlyAuthorized {
        require(canvases[canvasId].canvasId != 0, "Canvas does not exist");
        require(amount > 0, "Amount must be greater than zero");
        canvases[canvasId].totalRaised += amount;
    }

    function mintToContributor(address to, uint256 canvasId, uint256 contributions) external onlyAuthorized {
        require(canvases[canvasId].canvasId != 0, "Canvas does not exist");
        require(canvases[canvasId].finalized, "Canvas not finalized");

        _mint(to, canvasId, contributions, "");
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(canvases[tokenId].canvasId != 0, "Canvas does not exist");
        return canvases[tokenId].metadataURI;
    }

    function canvasExists(uint256 canvasId) external view returns (bool) {
        return canvases[canvasId].canvasId != 0;
    }

    function getCurrentCanvasCounter() external view returns (uint256) {
        return canvasCounter;
    }
}
