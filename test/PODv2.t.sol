// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {PODv2} from "../src/PODv2.sol";

contract PODv2Test is Test {
    PODv2 internal pod;
    address internal owner = address(0x1);

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
}
