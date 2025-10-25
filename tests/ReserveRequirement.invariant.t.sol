// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import "../contracts/RwaToken.sol";

contract ReserveRequirementInvariantTest is StdInvariant, Test {
    RwaToken token;
    Handler handler;
    address issuer = address(0x1111);
    address reserve = address(0x2222);
    
    function setUp() public {
        // Setup initial state
        vm.deal(issuer, 10 ether);
        vm.deal(reserve, 1000 ether); // Large reserve for invariant testing
        
        vm.startPrank(issuer);
        token = new RwaToken(issuer, reserve);
        vm.stopPrank();
        
        // Deploy handler for invariant testing
        handler = new Handler(token, issuer, reserve);
        
        // Set handler as target for invariant testing
        targetContract(address(handler));
        
        // Only call handler functions
        excludeSender(address(0));
        excludeSender(address(token));
    }
    
    // Invariant: Total supply should never exceed reserve balance
    function invariant_ReserveAlwaysCoversSupply() public {
        uint256 reserveBalance = reserve.balance;
        uint256 totalSupply = token.totalSupply();
        
        assertGe(reserveBalance, totalSupply, "Invariant violated: Reserve < Supply");
    }
    
    // Invariant: Sum of all balances equals total supply
    function invariant_BalancesEqualSupply() public {
        uint256 totalSupply = token.totalSupply();
        uint256 sumOfBalances = handler.getSumOfBalances();
        
        assertEq(sumOfBalances, totalSupply, "Invariant violated: Sum of balances != totalSupply");
    }
    
    // Invariant: No address can have more tokens than total supply
    function invariant_NoBalanceExceedsSupply() public {
        address[] memory users = handler.getUsers();
        uint256 totalSupply = token.totalSupply();
        
        for (uint256 i = 0; i < users.length; i++) {
            assertLe(
                token.balanceOf(users[i]), 
                totalSupply, 
                "Invariant violated: User balance > totalSupply"
            );
        }
    }
    
    // Call summary for debugging
    function invariant_callSummary() public view {
        console.log("Call summary:");
        console.log("Mints:", handler.mintCount());
        console.log("Transfers:", handler.transferCount());
        console.log("Failed mints:", handler.failedMintCount());
        console.log("Failed transfers:", handler.failedTransferCount());
    }
}

// Handler contract to perform actions for invariant testing
contract Handler is Test {
    RwaToken token;
    address issuer;
    address reserve;
    
    address[] public users;
    mapping(address => bool) public isUser;
    
    uint256 public mintCount;
    uint256 public transferCount;
    uint256 public failedMintCount;
    uint256 public failedTransferCount;
    
    constructor(RwaToken _token, address _issuer, address _reserve) {
        token = _token;
        issuer = _issuer;
        reserve = _reserve;
    }
    
    // Bounded mint function
    function mint(uint256 amount) public {
        // Bound amount to reasonable values
        amount = bound(amount, 0, 10 ether);
        
        // Select random user
        address to = _getRandomUser(amount);
        
        vm.startPrank(issuer);
        try token.mint(to, amount) {
            mintCount++;
        } catch {
            failedMintCount++;
        }
        vm.stopPrank();
    }
    
    // Bounded transfer function
    function transfer(uint256 userSeed, uint256 toSeed, uint256 amount) public {
        if (users.length == 0) return;
        
        // Select from and to addresses
        address from = users[userSeed % users.length];
        address to = users[toSeed % users.length];
        
        uint256 balance = token.balanceOf(from);
        if (balance == 0) return;
        
        // Bound amount to user's balance
        amount = bound(amount, 0, balance);
        
        vm.startPrank(from);
        try token.transfer(to, amount) {
            transferCount++;
        } catch {
            failedTransferCount++;
        }
        vm.stopPrank();
    }
    
    // Manipulate reserve balance
    function drainReserve(uint256 amount) public {
        uint256 reserveBalance = reserve.balance;
        if (reserveBalance == 0) return;
        
        amount = bound(amount, 0, reserveBalance);
        
        vm.prank(reserve);
        payable(address(0xdead)).transfer(amount);
    }
    
    // Refill reserve
    function fillReserve(uint256 amount) public {
        amount = bound(amount, 0, 100 ether);
        vm.deal(reserve, reserve.balance + amount);
    }
    
    // Helper to get random user
    function _getRandomUser(uint256 seed) internal returns (address) {
        if (users.length == 0 || seed % 10 == 0) {
            // Create new user
            address newUser = address(uint160(uint256(keccak256(abi.encode(seed, block.timestamp)))));
            users.push(newUser);
            isUser[newUser] = true;
            return newUser;
        } else {
            // Return existing user
            return users[seed % users.length];
        }
    }
    
    // Get sum of all balances
    function getSumOfBalances() public view returns (uint256 sum) {
        // Include issuer balance
        sum += token.balanceOf(issuer);
        
        // Add all user balances
        for (uint256 i = 0; i < users.length; i++) {
            sum += token.balanceOf(users[i]);
        }
    }
    
    function getUsers() public view returns (address[] memory) {
        return users;
    }
}