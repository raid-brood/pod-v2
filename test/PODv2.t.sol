// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {PODv2} from "../src/PODv2.sol";

contract PODv2Test is Test {
    PODv2 internal pod;
    address internal owner = address(0x1);

    // Mock claim data
    string[] internal claimCodes = ["randomClaimCode1", "randomClaimCode2"];
    bytes32 internal merkleRoot = 0xf655031d86398a1795d61dbfde8dc580055d425e1189ad27f91122ab76b3ea8a;
    bytes32[] internal merkleProof = [bytes32(0x16194519b413b5592f3cc85d14c03c252445f323ccf53e24380ef4cfdcb0b4ea)];

    function setUp() public {
        pod = new PODv2(owner);
    }

    function test_owner() public view {
        assertEq(pod.owner(), owner);
    }

    function test_create() public {
        bytes32 root = keccak256("merkleroot");
        string memory uri = "ipfs://testtesttest";

        // Revert if non-owner
        vm.expectRevert();
        pod.create(root, uri);

        // Should execute and emit event
        vm.startPrank(owner);
        vm.expectEmit();
        emit PODv2.Created(1, root, uri);

        uint256 id = pod.create(root, uri);
        vm.stopPrank();

        vm.assertEq(id, 1);
        vm.assertEq(pod.merkleRootOf(1), root);
        vm.assertEq(pod.uri(1), uri);
    }

    function test_setMerkleRoot() public {
        vm.prank(owner);
        pod.create(keccak256("merkleroot"), "ipfs://testtesttest");

        bytes32 newRoot = keccak256("new_merkleroot");
        
        // Revert if non-owner
        vm.expectRevert();
        pod.setMerkleRoot(1, newRoot);

        // Revert if id not created yet
        vm.expectRevert();
        pod.setMerkleRoot(2, newRoot);

        // Should execute and emit event
        vm.startPrank(owner);
        vm.expectEmit();
        emit PODv2.MerkleRootSet(1, newRoot);

        pod.setMerkleRoot(1, newRoot);
        vm.stopPrank();

        vm.assertEq(pod.merkleRootOf(1), newRoot);
    }

    function test_setTokenURI() public {
        vm.prank(owner);
        pod.create(keccak256("merkleroot"), "ipfs://testtesttest");

        string memory newUri = "ipfs://newnewnewnew";

        // Revert if non-owner
        vm.expectRevert();
        pod.setTokenURI(1, newUri);

        // Revert if id not created yet
        vm.expectRevert();
        pod.setTokenURI(2, newUri);

        // Should execute and emit event
        vm.startPrank(owner);
        vm.expectEmit();
        emit PODv2.TokenURISet(1, newUri);

        pod.setTokenURI(1, newUri);
        vm.stopPrank();

        vm.assertEq(pod.uri(1), newUri);
    }

    function test_claim() public {
        vm.prank(owner);
        pod.create(merkleRoot, "ipfs://testtesttest");

        address recipient = address(0x420);

        // Should execute and emit event
        vm.expectEmit();
        emit PODv2.Claimed(recipient, 1, claimCodes[0]);

        pod.claim(recipient, 1, claimCodes[0], merkleProof);

        vm.assertEq(pod.balanceOf(recipient, 1), 1);

        // Revert if claim code already used
        vm.expectRevert();
        pod.claim(recipient, 1, claimCodes[0], merkleProof);

        // Revert if invalid proof
        vm.expectRevert();
        pod.claim(recipient, 1, claimCodes[1], merkleProof); // merkle proof is for claimCodes[0]

        // Revert if merkle root not set
        vm.expectRevert();
        pod.claim(recipient, 2, claimCodes[0], merkleProof); // id 2 not created yet
    }
}
