// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/RwaToken.sol";

contract Deploy is Script {
    function run() external {
        address issuer = vm.envAddress("ISSUER");
        address reserve = vm.envAddress("RESERVE");

        vm.startBroadcast();
        RwaToken token = new RwaToken(issuer, reserve);
        vm.stopBroadcast();

        console2.log("RwaToken deployed:", address(token));
        console2.log("Issuer:", issuer);
        console2.log("Reserve:", reserve);
    }
}