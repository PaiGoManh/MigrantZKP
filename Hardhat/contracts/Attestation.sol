// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IVerifier.sol";

contract LaborerAttestation is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    IVerifier public verifier;
    mapping(bytes32 => bool) private usedHashes;

    constructor(address _verifierAddress) ERC721("LaborerAttestation", "LAT") {
        verifier = IVerifier(_verifierAddress);
    }

    function verifyAndMint(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory input
    ) public {
        bytes32 hash = keccak256(abi.encodePacked(input[0]));
        require(!usedHashes[hash], "Proof already used");
        require(verifier.verifyProof(a, b, c, input), "Invalid proof");
        
        usedHashes[hash] = true;
        _tokenIds.increment();
        _mint(msg.sender, _tokenIds.current());
    }

    function hasAttestation(address user) public view returns (bool) {
        return balanceOf(user) > 0;
    }
}
