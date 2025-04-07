/**
 *Submitted for verification at Etherscan.io on 2020-11-03
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-22
*/

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ---------------------FSI - an indepedent fork based on YFI technology. ----------------
// -----------------------------Official website : fansi.finance----------------
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// Safe Math Library 
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); 
        c = a - b; 
    } 
    function safeMul(uint a, uint b) public pure returns (uint c) { 
        c = a * b; 
        require(a == 0 || c / a == b); 
    } 
    function safeDiv(uint a, uint b) public pure returns (uint c) { 
        require(b > 0);
        c = a / b;
    }
}

contract Sale {
    uint256 public rate;
    address public admin;
    bool public saleStatus;
    IERC20 token;
    
    event TkSale(
        uint256 indexed ethWeiValue,
        uint256 indexed rate
    );

    constructor(IERC20 _token, uint256 _rate) public {
        token = _token;
        rate = _rate;
        saleStatus = true;
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Only admin can do this."
        );
        _;
    }
    
    modifier saleEnable() {
        require (
            saleStatus,
            "TK Sale is off"
        );
        _;
    }
    
    // @dev Fallback payable function
    function() external payable {}
    
    function buyTk(uint256 amount) 
        external
        payable 
        returns (uint256)
    {
        require(msg.value == amount);
        uint256 tokenAmount = amount * rate;
        require(tokenAmount < token.balanceOf(address(this)), 'out of order');
        
        token.transfer(msg.sender, tokenAmount);
        
        emit TkSale({
            ethWeiValue: amount,
            rate: rate
        });
        
        return tokenAmount;
    }
    
    function setRate(uint256 _rate)
    external
    onlyAdmin
    {
        rate = _rate;
    }
    
    function setSaleStatus(bool _status)
    external
    onlyAdmin
    {
        saleStatus = _status;
    }
    
    function withdrawEther(uint amount, address payable sendTo) 
    external 
    onlyAdmin 
    {
        sendTo.transfer(amount);
    }
    
    function withdrawToken(uint amount, address to)
    external
    onlyAdmin
    {
        token.transfer(to, amount);
    }
    
    function changeAdmin(address _admin)
    external
    onlyAdmin
    {
        admin = _admin;
    }
}