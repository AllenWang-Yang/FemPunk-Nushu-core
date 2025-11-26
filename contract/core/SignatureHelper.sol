// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SignatureHelper {
    bytes32 private constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant BUY_COLOR_TYPEHASH = keccak256("BuyColor(address buyer,uint256 colorId,string metadataURI,uint256 deadline)");
    
    function getDomainSeparator(address contractAddress) public view returns (bytes32) {
        return keccak256(abi.encode(
            DOMAIN_TYPEHASH,
            keccak256(bytes("FemColors")),
            keccak256(bytes("1")),
            block.chainid,
            contractAddress
        ));
    }
    
    function getStructHash(
        address buyer,
        uint256 colorId,
        string memory metadataURI,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(
            BUY_COLOR_TYPEHASH,
            buyer,
            colorId,
            keccak256(bytes(metadataURI)),
            deadline
        ));
    }
    
    function getTypedDataHash(
        address contractAddress,
        address buyer,
        uint256 colorId,
        string memory metadataURI,
        uint256 deadline
    ) public view returns (bytes32) {
        bytes32 domainSeparator = getDomainSeparator(contractAddress);
        bytes32 structHash = getStructHash(buyer, colorId, metadataURI, deadline);
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}