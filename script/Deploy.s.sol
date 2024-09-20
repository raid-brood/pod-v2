// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {PODv2} from "../src/PODv2.sol";

contract Deploy is Script {
    address constant EXPECTED_POD = 0xB00B5D137709a301283E225e536E85882Cfadd55;
    address constant ownerSafe = vm.envAddress("OWNER_ADDRESS");

    function run() public {
        console2.log("Deploying on chain ID", block.chainid);

        if (EXPECTED_POD.code.length == 0) {
            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
            vm.startBroadcast(deployerPrivateKey);
            PODv2 pod = new PODv2(ownerSafe);
            assert(address(pod) == EXPECTED_POD);
            vm.stopBroadcast();
            console2.log("PODv2:", address(pod), "(deployed)");
        } else {
            console2.log("PODv2:", EXPECTED_POD, "(exists)");
        }
    }
}