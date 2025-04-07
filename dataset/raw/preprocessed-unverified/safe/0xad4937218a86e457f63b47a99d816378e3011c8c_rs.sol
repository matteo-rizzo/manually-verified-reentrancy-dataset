/**
 *Submitted for verification at Etherscan.io on 2021-05-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-05-12
*/

pragma solidity ^0.5.0;








//todo: rename
contract MT_Claim is ICourtStake{
    using SafeMath for uint256;
    
    
    IERC20 public courtToken = IERC20(0x0538A9b4f4dcB0CB01A7fA34e17C0AC947c22553); 
    uint8 public courtDecimals = 18;
    
    IERC20 public usdtToken = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    uint256 public usdtDecimals = 6;
    
    //todo: set numerator
    uint256 public numerator = 30;
    uint256 public denominator = 1; // usdt is 6 decimals so 1 usdt = 1e12 other 
    
    
    mapping(address => bool) hasPermissionToCallLockedStake;
    address public owner;
    
    constructor() public{
        owner = msg.sender ;
    }
    
    function changeParameters(address courtAddress, address usdtAddress, uint256 decimals,uint256 _numerator, uint256 _denominator) public{
        require(msg.sender == owner, "only owner can change Numerator and Denominator");
        require(denominator != 0, "denominator can not be 0"); //can not div by zero
        courtToken = IERC20(courtAddress);
        usdtToken = IERC20(usdtAddress);
        usdtDecimals = decimals;
        numerator = _numerator;
        denominator = _denominator;
    }
    
    
    function lockedStake(uint256 courtAmount, address beneficiar,  uint256, uint256, uint256) public{
        require(hasPermissionToCallLockedStake[msg.sender] == true, "caller has no permission to call courtAmount");
        
        courtToken.transferFrom(msg.sender,address(this), courtAmount); // msg sender here is the HTStake contracte
        
        uint256 usdtAmount = getRequiredAmount(courtAmount);
        
        usdtToken.transferFrom(beneficiar,address(this),usdtAmount); // user need to approve this contract 
        usdtToken.transfer(owner,usdtAmount);
        
        courtToken.transfer(beneficiar,courtAmount); //beneficiar the one who claim court
    }
    
    function getRequiredAmount(uint256 amount) public view returns(uint256){
        return amount.mul(numerator).div(denominator.mul(10 ** (courtDecimals - usdtDecimals) ));
    }
    
    
    function setLockedStakePermission(address account, bool permissionFlag) public{
        require(msg.sender == owner, "only owner can change Numerator and Denominator");
        hasPermissionToCallLockedStake[account] = permissionFlag;
    }
    
}