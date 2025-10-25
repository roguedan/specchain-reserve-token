// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RwaToken {
    address public issuer;
    address public reserveWallet;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event ReserveChecked(uint256 reserveBalance, uint256 totalSupply, uint256 ratioBps);

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer");
        _;
    }

    constructor(address _issuer, address _reserveWallet) {
        issuer = _issuer;
        reserveWallet = _reserveWallet;
    }

    function mint(address to, uint256 amount) external onlyIssuer {
        totalSupply += amount;
        balanceOf[to] += amount;
        
        // Check reserve backing after mint
        require(_checkReserveBacking(), "Reserve backing failed (post-mint)");
        
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // Check reserve backing before transfer
        require(_checkReserveBacking(), "Reserve backing failed");
        
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        // Check reserve backing before transfer
        require(_checkReserveBacking(), "Reserve backing failed");
        
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        require(balanceOf[from] >= amount, "Insufficient balance");
        
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _checkReserveBacking() internal returns (bool) {
        uint256 reserveBalance = reserveWallet.balance;
        uint256 supply = totalSupply;
        
        // Calculate ratio in basis points (100% = 10000 bps)
        uint256 ratioBps = supply > 0 ? (reserveBalance * 10000) / supply : 10000;
        
        emit ReserveChecked(reserveBalance, supply, ratioBps);
        
        // Require at least 100% coverage (reserve >= supply)
        return reserveBalance >= supply;
    }
}