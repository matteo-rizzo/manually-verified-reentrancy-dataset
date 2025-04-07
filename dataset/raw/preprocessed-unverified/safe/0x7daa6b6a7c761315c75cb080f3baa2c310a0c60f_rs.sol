pragma solidity ^0.4.18;




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */






contract RapidProfit is Ownable {
    using SafeMath for uint256;
    IContractStakeToken public contractStakeToken;
    IContractErc20Token public contractErc20Token;

    uint256 public balanceTokenContract;

    event WithdrawEther(address indexed receiver, uint256 amount);
    event WithdrawToken(address indexed receiver, uint256 amount);

    function RapidProfit(address _owner) public {
        require(_owner != address(0));
        owner = _owner;
        //owner = msg.sender; // for test's
    }

    // fallback function can be used to buy tokens
    function() payable public {
    }

    function setContractStakeToken (address _addressContract) public onlyOwner {
        require(_addressContract != address(0));
        contractStakeToken = IContractStakeToken(_addressContract);
    }

    function setContractErc20Token (address _addressContract) public onlyOwner {
        require(_addressContract != address(0));
        contractErc20Token = IContractErc20Token(_addressContract);
    }

    function depositToken(address _investor, uint8 _stakeType, uint256 _value) external payable returns (bool){
        require(_investor != address(0));
        require(_value > 0);
        require(contractErc20Token.allowance(_investor, this) >= _value);

        bool resultStake = contractStakeToken.depositToken(_investor, _stakeType, now, _value);
        balanceTokenContract = balanceTokenContract.add(_value);
        bool resultErc20 = contractErc20Token.transferFrom(_investor, this, _value);

        return (resultStake && resultErc20);
    }

    function validWithdrawToken(address _address, uint256 _now) public returns (uint256 result){
        require(_address != address(0));
        require(_now > 0);
        result = contractStakeToken.validWithdrawToken(_address, _now);
    }

    function balanceOfToken(address _owner) public view returns (uint256 balance) {
        return contractStakeToken.balanceOfToken(_owner);
    }

    function getCountStakesToken() public view returns (uint256 result) {
        result = contractStakeToken.getCountStakesToken();
    }

    function getCountTransferInsToken(address _address) public view returns (uint256 result) {
        result = contractStakeToken.getCountTransferInsToken(_address);
    }

    function getTokenStakeByIndex(uint256 _index) public view returns (
        address _owner,
        uint256 _amount,
        uint8 _stakeType,
        uint256 _time,
        uint8 _status
    ) {
        (_owner, _amount, _stakeType, _time, _status) = contractStakeToken.getTokenStakeByIndex(_index);
    }

    function getTokenTransferInsByAddress(address _address, uint256 _index) public view returns (
        uint256 _indexStake,
        bool _isRipe
    ) {
        (_indexStake, _isRipe) = contractStakeToken.getTokenTransferInsByAddress(_address, _index);
    }

    function removeContract() public onlyOwner {
        selfdestruct(owner);
    }

    function calculator(uint8 _currentStake, uint256 _amount, uint256 _amountHours) public view returns (uint256 result){
        result = contractStakeToken.calculator(_currentStake, _amount, _amountHours);
    }

    function getBalanceEthContract() public view returns (uint256){
        return this.balance;
    }

    function getBalanceTokenContract() public view returns (uint256 result){
        return contractErc20Token.balanceOf(this);
    }

    function withdrawToken(address _address) public returns (uint256 result){
        uint256 amount = contractStakeToken.withdrawToken(_address);
        require(getBalanceTokenContract() >= amount);
        bool success = contractErc20Token.transfer(_address, amount);
        //require(success);
        WithdrawToken(_address, amount);
        result = amount;
    }

    function cancelToken(uint256 _index) public returns (bool result) {
        require(_index >= 0);
        require(msg.sender != address(0));
        result = contractStakeToken.cancel(_index, msg.sender);
    }

    function changeRatesToken(uint8 _numberRate, uint256 _percent) public onlyOwner returns (bool result) {
        result = contractStakeToken.changeRates(_numberRate, _percent);
    }

    function getTotalTokenDepositByAddress(address _owner) public view returns (uint256 result) {
        result = contractStakeToken.getTotalTokenDepositByAddress(_owner);
    }

    function getTotalTokenWithdrawByAddress(address _owner) public view returns (uint256 result) {
        result = contractStakeToken.getTotalTokenWithdrawByAddress(_owner);
    }

    function withdrawOwnerEth(uint256 _amount) public onlyOwner returns (bool) {
        require(this.balance >= _amount);
        owner.transfer(_amount);
        WithdrawEther(owner, _amount);
    }

    function withdrawOwnerToken(uint256 _amount) public onlyOwner returns (bool) {
        require(getBalanceTokenContract() >= _amount);
        contractErc20Token.transfer(owner, _amount);
        WithdrawToken(owner, _amount);
    }

}