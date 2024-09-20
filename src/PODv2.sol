// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title PODv2
 * @author geovgy
 * @notice The Proof of Drink contract, 2nd edition
 */
contract PODv2 is ERC1155, Ownable {
    mapping(uint256 id => bytes32 root) internal _merkleRoots;
    mapping(uint256 id => string uri) internal _tokenURIs;
    mapping(uint256 id => mapping(string claimCode => bool)) internal _claimed;
    uint256 internal _idCounter;

    event Claimed(address indexed account, uint256 indexed id, string claimCode);
    event Created(uint256 indexed id, bytes32 root, string uri);
    event MerkleRootSet(uint256 indexed id, bytes32 root);
    event TokenURISet(uint256 indexed id, string uri);

    constructor(address _owner) ERC1155("") Ownable(_owner) {}

    function hasClaimed(uint256 id, string calldata claimCode) external view returns (bool) {
        return _claimed[id][claimCode];
    }

    function merkleRootOf(uint256 id) external view returns (bytes32) {
        return _merkleRoots[id];
    }

    function uri(uint256 id) public view override virtual returns (string memory) {
        return _tokenURIs[id];
    }

    function claim(
        address account, 
        uint256 id, 
        string calldata claimCode,
        bytes32[] calldata proof
    ) external {
        require(_merkleRoots[id] != 0, "ProofOfDrink: Merkle root not set");
        require(!_claimed[id][claimCode], "ProofOfDrink: Claim code already used");
        require(
            MerkleProof.verify(proof, _merkleRoots[id], _toLeaf(claimCode)), 
            "ProofOfDrink: Invalid proof"
        );
        _claimed[id][claimCode] = true;
        _mint(account, id, 1, "");
        emit Claimed(account, id, claimCode);
    }

    function create(bytes32 root, string calldata uri_) external onlyOwner returns (uint256 id) {
        _idCounter++;
        id = _idCounter;
        _setMerkleRoot(id, root);
        _setTokenURI(id, uri_);
        emit Created(id, root, uri_);
    }

    function setMerkleRoot(uint256 id, bytes32 root) external onlyOwner {
        require(id <= _idCounter, "ProofOfDrink: Invalid id");
        _setMerkleRoot(id, root);
        emit MerkleRootSet(id, root);
    }

    function setTokenURI(uint256 id, string calldata uri_) external onlyOwner {
        require(id <= _idCounter, "ProofOfDrink: Invalid id");
        _setTokenURI(id, uri_);
        emit TokenURISet(id, uri_);
    }

    function _setMerkleRoot(uint256 id, bytes32 root) internal {
        _merkleRoots[id] = root;
    }

    function _setTokenURI(uint256 id, string calldata uri_) internal {
        _tokenURIs[id] = uri_;
    }

    function _toLeaf(string calldata claimCode) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(claimCode))));
    }
}