/**
 *Submitted for verification at Etherscan.io on 2021-05-12
*/

pragma solidity ^0.5.0;



contract GnGOwnable {
    address public guardianAddress;
    address public governorAddress;
    
    event GuardianTransferred(address indexed oldGuardianAddress, address indexed newGuardianAddress);
    event GovernorTransferred(address indexed oldGuardianAddress, address indexed newGuardianAddress);
    
    constructor() public{
        guardianAddress = msg.sender;
    }
    
    modifier onlyGovOrGur{
        require(msg.sender == governorAddress || msg.sender == guardianAddress, "caller is not governor or guardian");
        _;
    }
    
    
    function transfeerGuardian(address newGuardianAddress) public onlyGovOrGur {
        emit GuardianTransferred(guardianAddress, newGuardianAddress);
        guardianAddress = newGuardianAddress;
    }
    
    function transfeerGovernor(address newGovernorAddress) public onlyGovOrGur {
        emit GuardianTransferred(governorAddress, newGovernorAddress);
        governorAddress = newGovernorAddress;
    }
}






contract MT_Claim is ICourtStake{
    using SafeMath for uint256;
    
    IERC20 public courtToken = IERC20(0x0538A9b4f4dcB0CB01A7fA34e17C0AC947c22553); 
    uint8 public courtDecimals = 18;
    
    IERC20 public usdtToken = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    uint256 public usdtDecimals = 6;
    
    uint256 public numerator = 30;
    uint256 public denominator = 1; // usdt is 6 decimals so 1 usdt = 1e12 other 
    
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
        
        courtToken.transferFrom(msg.sender,address(this), courtAmount); // msg sender here is the HTStake contracte
        
        uint256 usdtAmount = getRequiredAmount(courtAmount);
        
        usdtToken.transferFrom(beneficiar,address(this),usdtAmount); // user need to approve this contract 
        usdtToken.transfer(owner,usdtAmount);
        
        courtToken.transfer(beneficiar,courtAmount); //beneficiar the one who claim court
    }
    
    function getRequiredAmount(uint256 amount) public view returns(uint256){
        return amount.mul(numerator).div(denominator.mul(10 ** (courtDecimals - usdtDecimals) ));
    }
    
    function changeRecvToken(address newAddress, uint8 newDecimalsCount) public{
        require(msg.sender == owner, "caller is not owner");
        
        usdtToken = IERC20(newAddress);
        usdtDecimals = newDecimalsCount;
    }
}