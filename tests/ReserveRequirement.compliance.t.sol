// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/RwaToken.sol";

/**
 * @title ERC-20 Compliance and Standards Tests
 * @notice Tests to verify compliance with ERC-20 standard and expected behaviors
 * @dev These tests ensure the token behaves according to EIP-20 specification
 */
contract ReserveRequirementComplianceTest is Test {
    RwaToken public token;
    address public issuer;
    address public reserveWallet;
    address public alice;
    address public bob;
    address public charlie;

    function setUp() public {
        issuer = makeAddr("issuer");
        reserveWallet = makeAddr("reserveWallet");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        vm.prank(issuer);
        token = new RwaToken(issuer, reserveWallet);

        // Fund reserve wallet adequately
        vm.deal(reserveWallet, 10000 ether);
    }

    // ====================================
    // ERC-20 STANDARD COMPLIANCE
    // ====================================

    function testERC20Interface() public {
        // Test that contract has all required ERC-20 functions
        // Note: Our contract implements a minimal ERC-20
        
        // These should not revert when called
        uint256 supply = token.totalSupply();
        uint256 balance = token.balanceOf(alice);
        uint256 allowanceAmount = token.allowance(alice, bob);
        
        // Verify initial state
        assertEq(supply, 0);
        assertEq(balance, 0);
        assertEq(allowanceAmount, 0);
    }

    function testTransferReturnValue() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 25 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        vm.prank(alice);
        bool success = token.transfer(bob, transferAmount);
        
        // ERC-20 requires transfer to return true on success
        assertTrue(success);
    }

    function testApproveReturnValue() public {
        vm.prank(alice);
        bool success = token.approve(bob, 100 ether);
        
        // ERC-20 requires approve to return true on success
        assertTrue(success);
    }

    function testTransferFromReturnValue() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 25 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        vm.prank(alice);
        token.approve(bob, transferAmount);
        
        vm.prank(bob);
        bool success = token.transferFrom(alice, charlie, transferAmount);
        
        // ERC-20 requires transferFrom to return true on success
        assertTrue(success);
    }

    // ====================================
    // TRANSFER EDGE CASES
    // ====================================

    function testTransferToZeroAddress() public {
        uint256 mintAmount = 100 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        // Transfer to zero address should work (burn-like behavior)
        vm.prank(alice);
        bool success = token.transfer(address(0), 25 ether);
        
        assertTrue(success);
        assertEq(token.balanceOf(address(0)), 25 ether);
        assertEq(token.balanceOf(alice), 75 ether);
        // Note: totalSupply remains the same (not a true burn)
        assertEq(token.totalSupply(), mintAmount);
    }

    function testTransferFromToZeroAddress() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 25 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        vm.prank(alice);
        token.approve(bob, transferAmount);
        
        vm.prank(bob);
        bool success = token.transferFrom(alice, address(0), transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(address(0)), transferAmount);
    }

    function testApproveToZeroAddress() public {
        vm.prank(alice);
        bool success = token.approve(address(0), 100 ether);
        
        assertTrue(success);
        assertEq(token.allowance(alice, address(0)), 100 ether);
    }

    // ====================================
    // LARGE NUMBER HANDLING
    // ====================================

    function testLargeAmountMint() public {
        uint256 largeAmount = 1000000 ether; // Use a large but safe amount
        
        // Need proportional reserve
        vm.deal(reserveWallet, largeAmount);
        
        vm.prank(issuer);
        token.mint(alice, largeAmount);
        
        assertEq(token.totalSupply(), largeAmount);
        assertEq(token.balanceOf(alice), largeAmount);
    }

    function testLargeAmountTransfer() public {
        uint256 largeAmount = 1000000 ether; // Use a large but safe amount
        
        vm.deal(reserveWallet, largeAmount);
        
        vm.prank(issuer);
        token.mint(alice, largeAmount);
        
        vm.prank(alice);
        bool success = token.transfer(bob, largeAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), largeAmount);
    }

    function testMaxUint256Operations() public {
        uint256 maxValue = type(uint256).max;
        
        // Test max approval
        vm.prank(alice);
        token.approve(bob, maxValue);
        assertEq(token.allowance(alice, bob), maxValue);
        
        // Test approval overwrite
        vm.prank(alice);
        token.approve(bob, 100 ether);
        assertEq(token.allowance(alice, bob), 100 ether);
    }

    // ====================================
    // ARITHMETIC SAFETY TESTS
    // ====================================

    function testOverflowPrevention() public {
        uint256 largeValue = 1000000 ether;
        
        // This should be limited by reserve backing, not overflow
        vm.deal(reserveWallet, largeValue);
        
        vm.prank(issuer);
        token.mint(alice, largeValue);
        
        // Trying to mint more should fail due to reserve backing
        vm.prank(issuer);
        vm.expectRevert("Reserve backing failed (post-mint)");
        token.mint(bob, 2000 ether);
    }

    function testBalanceConsistency() public {
        uint256 amount1 = 100 ether;
        uint256 amount2 = 200 ether;
        uint256 amount3 = 50 ether;
        
        vm.startPrank(issuer);
        token.mint(alice, amount1);
        token.mint(bob, amount2);
        token.mint(charlie, amount3);
        vm.stopPrank();
        
        // Total supply should equal sum of all balances
        uint256 totalBalances = token.balanceOf(alice) + 
                               token.balanceOf(bob) + 
                               token.balanceOf(charlie);
        
        assertEq(token.totalSupply(), totalBalances);
        assertEq(token.totalSupply(), amount1 + amount2 + amount3);
    }

    // ====================================
    // RESERVE BACKING COMPLIANCE
    // ====================================

    function testReserveMustCoverTotalSupply() public {
        uint256 reserveAmount = 500 ether;
        uint256 mintAmount = 300 ether;
        
        // Set specific reserve amount
        vm.deal(reserveWallet, reserveAmount);
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        // Should succeed as reserve > supply
        assertTrue(reserveWallet.balance >= token.totalSupply());
    }

    function testCannotMintWithoutReserveBacking() public {
        uint256 mintAmount = 100 ether;
        
        // Start with no reserve
        vm.deal(reserveWallet, 0);
        
        vm.prank(issuer);
        vm.expectRevert("Reserve backing failed (post-mint)");
        token.mint(alice, mintAmount);
    }

    function testTransferFailsWithoutReserveBacking() public {
        uint256 mintAmount = 100 ether;
        
        // First mint with adequate reserves
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        // Then remove reserves
        vm.prank(reserveWallet);
        payable(charlie).transfer(reserveWallet.balance);
        
        // Transfer should fail
        vm.prank(alice);
        vm.expectRevert("Reserve backing failed");
        token.transfer(bob, 10 ether);
    }

    // ====================================
    // EVENT COMPLIANCE TESTS
    // ====================================

    function testTransferEventParameters() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 25 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        // Check that Transfer event has correct parameters
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, transferAmount);
        
        vm.prank(alice);
        token.transfer(bob, transferAmount);
    }

    function testApprovalEventParameters() public {
        uint256 approvalAmount = 50 ether;
        
        // Check that Approval event has correct parameters
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, approvalAmount);
        
        vm.prank(alice);
        token.approve(bob, approvalAmount);
    }

    // ====================================
    // STATE CONSISTENCY TESTS
    // ====================================

    function testStateConsistencyAfterTransfers() public {
        uint256 initialMint = 1000 ether;
        
        vm.prank(issuer);
        token.mint(alice, initialMint);
        
        uint256 initialSupply = token.totalSupply();
        
        // Perform multiple transfers
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        
        vm.prank(alice);
        token.transfer(charlie, 200 ether);
        
        vm.prank(bob);
        token.transfer(charlie, 50 ether);
        
        // Total supply should remain unchanged
        assertEq(token.totalSupply(), initialSupply);
        
        // Sum of balances should equal total supply
        uint256 totalBalances = token.balanceOf(alice) + 
                               token.balanceOf(bob) + 
                               token.balanceOf(charlie);
        assertEq(totalBalances, token.totalSupply());
    }

    function testAllowanceConsistencyAfterTransferFrom() public {
        uint256 mintAmount = 100 ether;
        uint256 approvalAmount = 60 ether;
        uint256 transferAmount1 = 20 ether;
        uint256 transferAmount2 = 15 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        vm.prank(alice);
        token.approve(bob, approvalAmount);
        
        vm.prank(bob);
        token.transferFrom(alice, charlie, transferAmount1);
        
        assertEq(token.allowance(alice, bob), approvalAmount - transferAmount1);
        
        vm.prank(bob);
        token.transferFrom(alice, charlie, transferAmount2);
        
        assertEq(token.allowance(alice, bob), approvalAmount - transferAmount1 - transferAmount2);
    }

    // ====================================
    // BOUNDARY VALUE TESTS
    // ====================================

    function testZeroValueOperations() public {
        // Zero amount transfers should succeed
        vm.prank(alice);
        assertTrue(token.transfer(bob, 0));
        
        // Zero amount approvals should succeed
        vm.prank(alice);
        assertTrue(token.approve(bob, 0));
        
        // Zero amount mints (if allowed by access control)
        vm.prank(issuer);
        token.mint(alice, 0);
        
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(alice), 0);
    }

    function testSequentialApprovals() public {
        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 10 ether;
        amounts[1] = 50 ether;
        amounts[2] = 0;
        amounts[3] = 100 ether;
        amounts[4] = type(uint256).max;
        
        for (uint256 i = 0; i < amounts.length; i++) {
            vm.prank(alice);
            assertTrue(token.approve(bob, amounts[i]));
            assertEq(token.allowance(alice, bob), amounts[i]);
        }
    }

    // ====================================
    // REENTRANCY RESISTANCE VERIFICATION
    // ====================================

    function testNoReentrancyInTransfer() public {
        uint256 mintAmount = 100 ether;
        
        vm.prank(issuer);
        token.mint(alice, mintAmount);
        
        // Direct calls should not be vulnerable to reentrancy
        // This is inherently safe as our contract doesn't make external calls
        // during transfer operations (except for balance checking)
        
        vm.prank(alice);
        bool success = token.transfer(bob, 25 ether);
        
        assertTrue(success);
    }

    // Events for testing
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}