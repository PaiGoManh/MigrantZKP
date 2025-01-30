// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Soulbound.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Verifier.sol";

interface IZkVerifier {
    function verify(bytes memory proof, bytes32 publicInputs) external view returns (bool);
}
contract ZkAttestNFT is ERC721URIStorage, ERC721Soulbound, Ownable {
contract ZkAttestNFT is ERC721URIStorage, Ownable {
    IZkVerifier public zkVerifier;
    uint256 public tokenIdCounter;
    string private _baseTokenURI;

    struct Attestation {
        bytes32 proofHash;
        bool verified;
    }

    mapping(address => Attestation) public attestations;
    
    event AttestationSubmitted(address indexed user);
    event AttestationVerified(address indexed user, bool success);
    event NFTMinted(address indexed user, uint256 tokenId);

    constructor(address _zkVerifier, string memory baseURI) 
        ERC721("ZkAttestNFT", "ZKAT") 
    {
        require(_zkVerifier != address(0), "Invalid verifier address");
        zkVerifier = IZkVerifier(_zkVerifier);
        _baseTokenURI = baseURI;
    }

    function submitAttestation(bytes32 _proofHash) external {
        require(attestations[msg.sender].proofHash == bytes32(0), "Already submitted");
        attestations[msg.sender] = Attestation(_proofHash, false);
        emit AttestationSubmitted(msg.sender);
    }

    function verifyProof(
        bytes memory _proof,
        bytes32 _publicInputs,
        address _user
    ) external  {
        Attestation storage attestation = attestations[_user];
        require(attestation.proofHash != bytes32(0), "No attestation");
        require(!attestation.verified, "Already verified");
        require(attestation.proofHash == _publicInputs, "Input mismatch");

        bool success = zkVerifier.verify(_proof, _publicInputs);
        require(success, "Proof verification failed");

        attestation.verified = true;
        emit AttestationVerified(_user, success);

        if (balanceOf(_user) == 0) {
            _mintReputationNFT(_user);
        }
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function _mintReputationNFT(address _user) internal {
        uint256 newTokenId = tokenIdCounter++;
        _safeMint(_user, newTokenId);
        _setTokenURI(newTokenId, string(abi.encodePacked(_baseTokenURI, "/", _toString(newTokenId))));
        emit NFTMinted(_user, newTokenId);
    }

    // Soulbound NFT implementation (non-transferable)
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(from == address(0), "Tokens are soulbound");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Helper function for URI conversion
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}