/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity ^0.5.14;





contract hodlRich {
    
    using SafeMath for uint256;
    
    address public adminWallet;
    address public withdrawWallet;
    
    uint256 public unlockFee;  // prefer 10% 
    uint256 public depositFee; // prefer 0% 
    
    ERC20Token _token;
    
    modifier onlyAdmin() {
        require(msg.sender == adminWallet, 'you are not an admin');
        _;
    }
    
    function changeUnlockFee(uint256 _newFee) external onlyAdmin {
        unlockFee = _newFee;
    }

    function changeDepositkFee(uint256 _newFee) external onlyAdmin {
        depositFee = _newFee;
    }
    
    function changeWithdrawWallet(address _newWallet) external onlyAdmin {
        withdrawWallet = _newWallet;
    }
    
    function changeAdmin(address _newAdmin) external onlyAdmin {
        adminWallet = _newAdmin;
    }
    
    struct Deposit {
        address tokenAddress;
        uint256 tokenAmount;
        uint256 unlockTime;
    }
    
    mapping(address => Deposit[]) public deposits;
    
    //example input parameters: 20 / 200 / 0x.... (uint256/uint256/_adminWallet); 100 - 10%; 20
    constructor(uint256 _depositFee, uint256 _unlockFee, address _adminWallet) public {
        depositFee = _depositFee;
        unlockFee = _unlockFee;
        adminWallet = _adminWallet;
        withdrawWallet = _adminWallet;
    }

    function depositTokens(address _tokenAddress, uint256 _tokenAmount, uint256 _lockTime) external {
        _token = ERC20Token(_tokenAddress);
        uint256 approved = _token.allowance(msg.sender, address(this));
        require(approved >= _tokenAmount, 'you must allow this contract to transfer tokens on your behalf');
        
        //get tokens
        _token.transferFrom(msg.sender, address(this), _tokenAmount);
        uint256 fee = _tokenAmount.mul(depositFee).div(1000);
        uint256 _tokenAmountAfterFee = _tokenAmount.sub(fee);
        _token.transfer(withdrawWallet, fee);

        //create new deposit
        Deposit memory newDeposit;
        newDeposit.tokenAddress = _tokenAddress;
        newDeposit.tokenAmount = _tokenAmountAfterFee;
        newDeposit.unlockTime = now.add(_lockTime);

        //store deposit
        deposits[msg.sender].push(newDeposit);
        
    }

    
    function withdrawTokens(uint256 _depositID) external {
        require(deposits[msg.sender][_depositID].tokenAmount > 0, 'deposit doesnt exists');
        
        Deposit memory currentDeposit = deposits[msg.sender][_depositID];
        if (currentDeposit.unlockTime < now) {
            //return without substracting unlock fee
            uint256 amount = currentDeposit.tokenAmount;
            delete deposits[msg.sender][_depositID];
            _token.transfer(msg.sender, amount);
        } else {
            //return after substracting unlock fee for breaking the rules
            uint256 fee = currentDeposit.tokenAmount.mul(unlockFee).div(1000);
            uint256 _tokenAmountAfterFee = currentDeposit.tokenAmount.sub(fee);
            delete deposits[msg.sender][_depositID];
            _token.transfer(withdrawWallet, fee);
            _token.transfer(msg.sender, _tokenAmountAfterFee);
        }
    }
    
    function checkDepositByID(uint256 _depositID) external view returns (address tokenAddress, uint256 tokenAmount, uint256 unlockTime) {
        require(deposits[msg.sender].length > 0, 'you dont have deposits');
        require(deposits[msg.sender][_depositID].tokenAmount > 0, 'deposit doesnt exists');
        tokenAddress = deposits[msg.sender][_depositID].tokenAddress;
        tokenAmount = deposits[msg.sender][_depositID].tokenAmount;
        unlockTime = deposits[msg.sender][_depositID].unlockTime;
    }
    
    function latestDeposit() external view returns (uint256 _depositID) {
        require(deposits[msg.sender].length > 0, 'you dont have deposits');
        _depositID = deposits[msg.sender].length.sub(1);
    }

    
}