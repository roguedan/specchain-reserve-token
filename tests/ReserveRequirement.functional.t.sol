// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/RwaToken.sol";

contract ReserveRequirementFunctionalTest is Test {
    RwaToken public token;
    address public issuer;
    address public reserveWallet;
    address public user1;
    address public user2;
    address public user3;

    // Events to test
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event ReserveChecked(uint256 reserveBalance, uint256 totalSupply, uint256 ratioBps);

    function setUp() public {
        issuer = makeAddr("issuer");
        reserveWallet = makeAddr("reserveWallet");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        vm.prank(issuer);
        token = new RwaToken(issuer, reserveWallet);

        // Fund reserve wallet
        vm.deal(reserveWallet, 1000 ether);
    }

    // ====================================
    // ERC-20 COMPLIANCE TESTS
    // ====================================

    function testTotalSupplyInitialization() public {
        assertEq(token.totalSupply(), 0);
    }

    function testBalanceOfInitialization() public {
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(issuer), 0);
        assertEq(token.balanceOf(address(0)), 0);
    }

    function testAllowanceInitialization() public {
        assertEq(token.allowance(user1, user2), 0);
        assertEq(token.allowance(issuer, user1), 0);
    }

    function testMintIncreasesTotalSupply() public {
        uint256 mintAmount = 100 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        assertEq(token.totalSupply(), mintAmount);
        assertEq(token.balanceOf(user1), mintAmount);
    }

    function testMultipleMints() public {
        uint256 amount1 = 50 ether;
        uint256 amount2 = 30 ether;
        uint256 amount3 = 20 ether;
        
        vm.startPrank(issuer);
        token.mint(user1, amount1);
        token.mint(user2, amount2);
        token.mint(user3, amount3);
        vm.stopPrank();
        
        assertEq(token.totalSupply(), amount1 + amount2 + amount3);
        assertEq(token.balanceOf(user1), amount1);
        assertEq(token.balanceOf(user2), amount2);
        assertEq(token.balanceOf(user3), amount3);
    }

    // ====================================
    // APPROVAL AND ALLOWANCE TESTS
    // ====================================

    function testApproveBasic() public {
        uint256 approvalAmount = 50 ether;
        
        vm.prank(user1);
        bool success = token.approve(user2, approvalAmount);
        
        assertTrue(success);
        assertEq(token.allowance(user1, user2), approvalAmount);
    }

    function testApproveZero() public {
        // First approve some amount
        vm.prank(user1);
        token.approve(user2, 100 ether);
        
        // Then approve zero (should reset)
        vm.prank(user1);
        bool success = token.approve(user2, 0);
        
        assertTrue(success);
        assertEq(token.allowance(user1, user2), 0);
    }

    function testApproveOverwrite() public {
        uint256 initialAmount = 50 ether;
        uint256 newAmount = 75 ether;
        
        vm.startPrank(user1);
        token.approve(user2, initialAmount);
        assertEq(token.allowance(user1, user2), initialAmount);
        
        token.approve(user2, newAmount);
        assertEq(token.allowance(user1, user2), newAmount);
        vm.stopPrank();
    }

    function testTransferFromBasic() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 30 ether;
        
        // Setup: mint tokens and approve
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        vm.prank(user1);
        token.approve(user2, transferAmount);
        
        // Execute transferFrom
        vm.prank(user2);
        bool success = token.transferFrom(user1, user3, transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(user1), mintAmount - transferAmount);
        assertEq(token.balanceOf(user3), transferAmount);
        assertEq(token.allowance(user1, user2), 0); // Should be reduced to 0
    }

    function testTransferFromPartialAllowance() public {
        uint256 mintAmount = 100 ether;
        uint256 approvalAmount = 50 ether;
        uint256 transferAmount = 30 ether;
        
        // Setup
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        vm.prank(user1);
        token.approve(user2, approvalAmount);
        
        // Execute transferFrom
        vm.prank(user2);
        bool success = token.transferFrom(user1, user3, transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(user1), mintAmount - transferAmount);
        assertEq(token.balanceOf(user3), transferAmount);
        assertEq(token.allowance(user1, user2), approvalAmount - transferAmount);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 mintAmount = 100 ether;
        uint256 approvalAmount = 30 ether;
        uint256 transferAmount = 50 ether; // More than approved
        
        // Setup
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        vm.prank(user1);
        token.approve(user2, approvalAmount);
        
        // Should revert
        vm.prank(user2);
        vm.expectRevert("Insufficient allowance");
        token.transferFrom(user1, user3, transferAmount);
    }

    // ====================================
    // RESERVE MANAGEMENT TESTS
    // ====================================

    function testReserveRatioCalculation() public {
        uint256 mintAmount = 100 ether;
        
        // Reserve has 1000 ether, mint 100 ether tokens
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Reserve ratio should be 1000/100 = 10x = 100,000 bps
        // But we only check that it's >= 100% (10,000 bps)
        assertTrue(reserveWallet.balance >= token.totalSupply());
    }

    function testReserveDepletionPreventsTransfers() public {
        uint256 mintAmount = 100 ether;
        
        // Mint tokens
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Drain reserve wallet (simulate loss)
        vm.prank(reserveWallet);
        payable(user3).transfer(reserveWallet.balance);
        
        // Transfer should fail due to insufficient reserves
        vm.prank(user1);
        vm.expectRevert("Reserve backing failed");
        token.transfer(user2, 10 ether);
    }

    function testReserveDepletionPreventsMinting() public {
        // Drain reserve wallet first
        vm.prank(reserveWallet);
        payable(user3).transfer(reserveWallet.balance);
        
        // Minting should fail
        vm.prank(issuer);
        vm.expectRevert("Reserve backing failed (post-mint)");
        token.mint(user1, 10 ether);
    }

    function testExactReserveCoverage() public {
        uint256 reserveAmount = 100 ether;
        uint256 mintAmount = 100 ether;
        
        // Set exact reserve amount
        vm.prank(reserveWallet);
        payable(user3).transfer(reserveWallet.balance - reserveAmount);
        
        // Should be able to mint exactly the reserve amount
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        assertEq(token.totalSupply(), mintAmount);
        assertEq(reserveWallet.balance, reserveAmount);
    }

    // ====================================
    // EVENT EMISSION TESTS
    // ====================================

    function testTransferEventEmission() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 30 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Expect Transfer event
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user2, transferAmount);
        
        vm.prank(user1);
        token.transfer(user2, transferAmount);
    }

    function testMintEventEmission() public {
        uint256 mintAmount = 50 ether;
        
        // Expect Transfer event from zero address
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user1, mintAmount);
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
    }

    function testApprovalEventEmission() public {
        uint256 approvalAmount = 75 ether;
        
        // Expect Approval event
        vm.expectEmit(true, true, false, true);
        emit Approval(user1, user2, approvalAmount);
        
        vm.prank(user1);
        token.approve(user2, approvalAmount);
    }

    function testReserveCheckedEventEmission() public {
        uint256 mintAmount = 100 ether;
        uint256 reserveBalance = reserveWallet.balance;
        uint256 expectedRatio = (reserveBalance * 10000) / mintAmount;
        
        // Expect ReserveChecked event
        vm.expectEmit(false, false, false, true);
        emit ReserveChecked(reserveBalance, mintAmount, expectedRatio);
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
    }

    // ====================================
    // INTEGRATION AND WORKFLOW TESTS
    // ====================================

    function testCompleteTokenLifecycle() public {
        uint256 initialMint = 100 ether;
        uint256 transferAmount = 25 ether;
        uint256 approvalAmount = 50 ether;
        
        // 1. Mint tokens
        vm.prank(issuer);
        token.mint(user1, initialMint);
        
        // 2. Direct transfer
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        // 3. Approve and transferFrom
        vm.prank(user1);
        token.approve(user3, approvalAmount);
        
        vm.prank(user3);
        token.transferFrom(user1, user2, transferAmount);
        
        // Verify final state
        assertEq(token.balanceOf(user1), initialMint - (2 * transferAmount));
        assertEq(token.balanceOf(user2), 2 * transferAmount);
        assertEq(token.allowance(user1, user3), approvalAmount - transferAmount);
    }

    function testMultipleApprovals() public {
        uint256 mintAmount = 200 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // User1 approves multiple spenders
        vm.startPrank(user1);
        token.approve(user2, 50 ether);
        token.approve(user3, 75 ether);
        token.approve(issuer, 25 ether);
        vm.stopPrank();
        
        // Verify all allowances
        assertEq(token.allowance(user1, user2), 50 ether);
        assertEq(token.allowance(user1, user3), 75 ether);
        assertEq(token.allowance(user1, issuer), 25 ether);
    }

    function testChainedTransfers() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 20 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Chain transfers: user1 -> user2 -> user3
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        vm.prank(user2);
        token.transfer(user3, transferAmount);
        
        // Verify final balances
        assertEq(token.balanceOf(user1), mintAmount - transferAmount);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(user3), transferAmount);
    }

    // ====================================
    // BOUNDARY AND EDGE CASE TESTS
    // ====================================

    function testZeroAmountTransfer() public {
        uint256 mintAmount = 100 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Zero amount transfer should succeed
        vm.prank(user1);
        bool success = token.transfer(user2, 0);
        
        assertTrue(success);
        assertEq(token.balanceOf(user1), mintAmount);
        assertEq(token.balanceOf(user2), 0);
    }

    function testSelfTransfer() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 25 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Self transfer should work
        vm.prank(user1);
        bool success = token.transfer(user1, transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(user1), mintAmount); // Balance unchanged
    }

    function testMaxUint256Approval() public {
        uint256 maxApproval = type(uint256).max;
        
        vm.prank(user1);
        bool success = token.approve(user2, maxApproval);
        
        assertTrue(success);
        assertEq(token.allowance(user1, user2), maxApproval);
    }

    function testTransferEntireBalance() public {
        uint256 mintAmount = 100 ether;
        
        vm.prank(issuer);
        token.mint(user1, mintAmount);
        
        // Transfer entire balance
        vm.prank(user1);
        bool success = token.transfer(user2, mintAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), mintAmount);
    }

    // ====================================
    // ACCESS CONTROL VERIFICATION
    // ====================================

    function testNonIssuerCannotMint() public {
        vm.prank(user1);
        vm.expectRevert("Only issuer");
        token.mint(user2, 100 ether);
    }

    function testIssuerFieldImmutable() public {
        address originalIssuer = token.issuer();
        
        // Try to call from different address
        vm.prank(user1);
        vm.expectRevert("Only issuer");
        token.mint(user1, 100 ether);
        
        // Issuer field should be unchanged
        assertEq(token.issuer(), originalIssuer);
    }

    function testReserveWalletFieldImmutable() public {
        address originalReserve = token.reserveWallet();
        
        // No function exists to change reserve wallet
        // This is by design - it's immutable
        assertEq(token.reserveWallet(), originalReserve);
        assertEq(token.reserveWallet(), reserveWallet);
    }
}