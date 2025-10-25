// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/RwaToken.sol";

contract ReserveRequirementTest is Test {
    RwaToken token;
    address issuer = address(0x1111);
    address reserve = address(0x2222);
    address alice   = address(0x3333);
    address bob     = address(0x4444);

    function setUp() public {
        vm.deal(issuer, 10 ether);
        vm.deal(reserve, 100 ether); // fund reserve wallet for coverage
        vm.startPrank(issuer);
        token = new RwaToken(issuer, reserve);
        token.mint(alice, 1 ether); // supply = 1e18
        vm.stopPrank();
    }

    function testTransferSucceedsWhenReserveCoversSupply() public {
        // reserve (100 ETH) >= supply (1 token) → OK
        vm.startPrank(alice);
        bool ok = token.transfer(bob, 0.1 ether);
        vm.stopPrank();
        assertTrue(ok, "transfer should succeed with coverage");
    }

    function testTransferRevertsWhenReserveBelowSupply() public {
        // Drain reserve so coverage fails
        vm.prank(reserve);
        payable(address(0xdead)).transfer(reserve.balance); // now reserve == 0
        vm.startPrank(alice);
        vm.expectRevert(bytes("Reserve backing failed"));
        token.transfer(bob, 0.1 ether);
        vm.stopPrank();
    }

    function testMintGatedByCoverage() public {
        // Happy path: reserve is high, mint succeeds (post-mint check passes)
        vm.startPrank(issuer);
        token.mint(bob, 0.5 ether);
        vm.stopPrank();

        // Now break coverage and ensure mint reverts
        vm.prank(reserve);
        payable(address(0xbeef)).transfer(reserve.balance);
        vm.startPrank(issuer);
        vm.expectRevert(bytes("Reserve backing failed (post-mint)"));
        token.mint(bob, 0.5 ether);
        vm.stopPrank();
    }
}