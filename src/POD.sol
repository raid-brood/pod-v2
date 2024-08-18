// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ProofOfDrinkV2 is ERC1155, Ownable {
    mapping(uint256 id => bytes32 root) internal _merkleRoots;
    mapping(uint256 id => string uri) internal _tokenURIs;
    mapping(uint256 id => mapping(string claimCode => bool)) internal _claimed;
    uint256 internal _idCounter;

    event Claimed(address indexed account, uint256 indexed id, string claimCode);
    event Created(uint256 indexed id, bytes32 root, string uri);
    event MerkleRootSet(uint256 indexed id, bytes32 root);
    event TokenURISet(uint256 indexed id, string uri);

    constructor(address _owner) ERC1155("") Ownable(_owner) {}

    function claim(
        address account, 
        uint256 id, 
        string calldata claimCode,
        bytes32[] calldata proof
    ) external {
        require(_merkleRoots[id] != 0, "ProofOfDrink: Merkle root not set");
        require(!_claimed[id][claimCode], "ProofOfDrink: Claim code already used");
        require(
            MerkleProof.verify(proof, _merkleRoots[id], keccak256(abi.encodePacked(claimCode))), 
            "ProofOfDrink: Invalid proof"
        );
        _claimed[id][claimCode] = true;
        _mint(account, id, 1, "");
        emit Claimed(account, id, claimCode);
    }

    function create(bytes32 root, string calldata uri) external onlyOwner {
        _idCounter++;
        _merkleRoots[_idCounter] = root;
        _tokenURIs[_idCounter] = uri;
        emit Created(_idCounter, root, uri);
    }

    function setMerkleRoot(uint256 id, bytes32 root) external onlyOwner {
        _setMerkleRoot(id, root);
        emit MerkleRootSet(id, root);
    }

    function setTokenURI(uint256 id, string calldata uri) external onlyOwner {
        _setTokenURI(id, uri);
        emit TokenURISet(id, uri);
    }

    function _setMerkleRoot(uint256 id, bytes32 root) internal {
        _merkleRoots[id] = root;
    }

    function _setTokenURI(uint256 id, string calldata uri) internal {
        _tokenURIs[id] = uri;
    }
}