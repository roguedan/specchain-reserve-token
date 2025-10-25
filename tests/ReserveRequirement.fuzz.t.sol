// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/RwaToken.sol";

contract ReserveRequirementFuzzTest is Test {
    RwaToken token;
    address issuer = address(0x1111);
    address reserve = address(0x2222);
    
    function setUp() public {
        vm.deal(issuer, 10 ether);
        vm.deal(reserve, 1000 ether); // Large reserve for fuzz testing
        
        vm.startPrank(issuer);
        token = new RwaToken(issuer, reserve);
        vm.stopPrank();
    }
    
    // Fuzz test: Minting with random amounts
    function testFuzz_MintAmount(uint256 amount) public {
        // Skip if amount would overflow
        if (amount > type(uint256).max - token.totalSupply()) return;
        
        vm.startPrank(issuer);
        
        // Calculate if mint should succeed
        bool shouldSucceed = (token.totalSupply() + amount) <= reserve.balance;
        
        if (shouldSucceed) {
            token.mint(address(0x7777), amount);
            assertEq(token.balanceOf(address(0x7777)), amount);
            assertEq(token.totalSupply(), amount);
        } else {
            vm.expectRevert("Reserve backing failed (post-mint)");
            token.mint(address(0x7777), amount);
        }
        
        vm.stopPrank();
    }
    
    // Fuzz test: Transfer with random amounts and addresses
    function testFuzz_Transfer(
        address from,
        address to,
        uint256 mintAmount,
        uint256 transferAmount
    ) public {
        // Setup constraints
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        vm.assume(from != to);
        mintAmount = bound(mintAmount, 1, 100 ether);
        
        // Mint tokens to 'from' address
        vm.startPrank(issuer);
        token.mint(from, mintAmount);
        vm.stopPrank();
        
        // Attempt transfer
        vm.startPrank(from);
        
        if (transferAmount <= mintAmount && reserve.balance >= token.totalSupply()) {
            token.transfer(to, transferAmount);
            assertEq(token.balanceOf(from), mintAmount - transferAmount);
            assertEq(token.balanceOf(to), transferAmount);
        } else if (transferAmount > mintAmount) {
            vm.expectRevert("Insufficient balance");
            token.transfer(to, transferAmount);
        }
        
        vm.stopPrank();
    }
    
    // Fuzz test: Reserve manipulation
    function testFuzz_ReserveManipulation(uint256 drainAmount) public {
        // Mint some tokens first
        vm.startPrank(issuer);
        token.mint(address(0x8888), 50 ether);
        vm.stopPrank();
        
        uint256 initialReserve = reserve.balance;
        drainAmount = bound(drainAmount, 0, initialReserve);
        
        // Drain reserve
        vm.prank(reserve);
        payable(address(0xdead)).transfer(drainAmount);
        
        // Check if transfers still work
        bool shouldWork = (initialReserve - drainAmount) >= token.totalSupply();
        
        vm.startPrank(address(0x8888));
        if (shouldWork) {
            token.transfer(address(0x9999), 1 ether);
        } else {
            vm.expectRevert("Reserve backing failed");
            token.transfer(address(0x9999), 1 ether);
        }
        vm.stopPrank();
    }
    
    // Fuzz test: Multiple operations
    function testFuzz_MultipleOperations(
        uint256[5] memory amounts,
        address[5] memory recipients,
        uint256 reserveDrain
    ) public {
        // Setup
        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i] == address(0)) {
                recipients[i] = address(uint160(i + 1000));
            }
            amounts[i] = bound(amounts[i], 0, 10 ether);
        }
        
        // Perform mints
        vm.startPrank(issuer);
        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 newSupply = token.totalSupply() + amounts[i];
            if (newSupply <= reserve.balance) {
                token.mint(recipients[i], amounts[i]);
            }
        }
        vm.stopPrank();
        
        // Drain some reserve
        reserveDrain = bound(reserveDrain, 0, reserve.balance / 2);
        vm.prank(reserve);
        payable(address(0xdead)).transfer(reserveDrain);
        
        // Verify invariant still holds
        assertGe(reserve.balance, token.totalSupply(), "Reserve invariant broken");
    }
    
    // Fuzz test: Approval and transferFrom
    function testFuzz_TransferFrom(
        address owner,
        address spender,
        address recipient,
        uint256 amount,
        uint256 approval
    ) public {
        // Setup constraints
        vm.assume(owner != address(0));
        vm.assume(spender != address(0));
        vm.assume(recipient != address(0));
        vm.assume(owner != spender);
        amount = bound(amount, 1, 100 ether);
        
        // Mint tokens to owner
        vm.startPrank(issuer);
        token.mint(owner, amount);
        vm.stopPrank();
        
        // Owner approves spender
        vm.startPrank(owner);
        token.approve(spender, approval);
        vm.stopPrank();
        
        // Spender attempts transfer
        vm.startPrank(spender);
        
        if (approval >= amount && reserve.balance >= token.totalSupply()) {
            token.transferFrom(owner, recipient, amount);
            assertEq(token.balanceOf(owner), 0);
            assertEq(token.balanceOf(recipient), amount);
            assertEq(token.allowance(owner, spender), approval - amount);
        } else if (approval < amount) {
            vm.expectRevert("Insufficient allowance");
            token.transferFrom(owner, recipient, amount);
        }
        
        vm.stopPrank();
    }
}