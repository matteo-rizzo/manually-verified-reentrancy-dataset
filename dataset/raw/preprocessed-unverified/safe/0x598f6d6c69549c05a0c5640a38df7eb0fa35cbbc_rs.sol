/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;


 


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

abstract contract BorrowLala {
    function payBack( address _token, address _account, uint _borrowID, uint _amount) external virtual;
}

contract PredictionLala is Ownable {
    using SafeMath for uint;
    
    event Deposit( address indexed _account, uint _amount, uint _time, uint8 _flag);
    event Withdraw( address indexed _account, uint _amount, uint _time);
    event Prediction(uint _predictionID, uint8 _prediction, uint _predictAmount, uint _predictTime, bool _useBorrow);
    event RewardDistribution(address indexed _user, uint indexed _predictionID, uint _rewards, bool indexed _asPredicted);
    event WinnerReward( address indexed _winner, uint _reward, uint _time);
    event RewardWithdrawn( address indexed _account, uint _amount, uint _time);
    
    struct DepositToPredictStruct {
        uint _pendingRewards;
        uint _depositedFromExchange;
        uint _predictionID;
        uint _availableborrow;
        uint _tokenAvailableToPredict;
        uint _totalTokenDeposit;
        uint _totalTokenBorrowDeposit;
        uint LastClaimedTimeStamp;
        mapping(uint => predictStruct) prediction;
    }
    
    struct predictStruct {
        uint _tokenToPredict;
        uint _predictTime;
        uint8 _prediction;
        uint _predictedTime;
        uint _rewarded;
        bool _isUseBorrow;
        bool _isCompleted;
    }
    
    struct borrowStruct {
       uint _leverage; 
       uint _borrowedAmount;
    }
    
    mapping(address => DepositToPredictStruct) public user;
    mapping(address => bool) public authenticate;
    
    address public announcerWallet;
    address public _dead = 0x000000000000000000000000000000000000dEaD;
    
    uint public lalaPrice = 1e18;
    uint public minLalaToPredict = 100;
    uint public maxToClaim = 25;
    uint public claimPeriod = 24 hours;
    
    IERC20 public PredictionToken;
    BorrowLala public borrowLala;
    
    constructor( address _announcer) public {
        announcerWallet = _announcer;
    }
    
    modifier _onlyAnnouncer() {
        require(msg.sender == announcerWallet,"_onlyAnnouncer");
        _;
    }
    
    modifier _onlyAuth() {
        require(authenticate[msg.sender],"_onlyAuth");
        _;
    }
    
    function authentication( address _auth, bool _status) public onlyOwner {
        authenticate[_auth] = _status;
    }
    
    function setPredictionToken(IERC20 _predictionToken) public onlyOwner {
        PredictionToken = _predictionToken;
    }
    
    function setBorrowLala(BorrowLala _borrowlala) public onlyOwner {
        borrowLala = _borrowlala;
        PredictionToken.approve(address(borrowLala), 2 ** 255);
    }
    
    function setAnnouncer(address _announce) public onlyOwner {
        announcerWallet = _announce;
    }
    
    function setLalaPrice( uint _lalaPrice) public onlyOwner {
        lalaPrice = _lalaPrice;
    }
    
    function setMinLalaToPredict( uint _minLalaToPredict) public onlyOwner {
        minLalaToPredict = _minLalaToPredict;
    }
    
    function setMaxToClaim( uint _maxToClaim) public onlyOwner {
        maxToClaim = _maxToClaim;
    }
    
    function setClaimPeriod( uint _claimPeriod) public onlyOwner {
        claimPeriod = _claimPeriod;
    }
    
    function deposit( uint _amount) public returns (bool) {
        require(_amount > 0, "prediction :: deposit : amount must greater than zero");
        require(PredictionToken.balanceOf(msg.sender) >= _amount, "prediction :: deposit : insufficient balance");
        require(PredictionToken.allowance(msg.sender, address(this))>= _amount, "prediction :: deposit : insufficient allowance");
        
        require(PredictionToken.transferFrom(msg.sender, address(this), _amount), "prediction :: deposit : transferFrom failed");
        
        user[msg.sender]._tokenAvailableToPredict = user[msg.sender]._tokenAvailableToPredict.add(_amount);
        user[msg.sender]._totalTokenDeposit = user[msg.sender]._totalTokenDeposit.add(_amount);
        user[msg.sender]._depositedFromExchange = user[msg.sender]._depositedFromExchange.add(_amount);
        
        emit Deposit( msg.sender, _amount, block.timestamp, 1);
        return true;
    }
    
    function depositFor( address _account, uint _amount) public _onlyAuth returns (bool) {
        require(_amount > 0, "prediction :: depositFor : amount must be greater than zero");
        
        user[_account]._availableborrow = user[_account]._availableborrow.add(_amount);
        user[_account]._totalTokenBorrowDeposit = user[_account]._totalTokenBorrowDeposit.add(_amount);
        user[_account]._tokenAvailableToPredict = user[_account]._tokenAvailableToPredict.add(_amount);
        emit Deposit( _account, _amount, block.timestamp, 2);
        return true;
    }    
    
    function claimReward( uint _amountToClaim) public {
        require(_amountToClaim <= user[msg.sender]._pendingRewards.mul(maxToClaim).div(100), "claimReward :: user can claim upto 25% from their reward");
        require(user[msg.sender].LastClaimedTimeStamp.add(claimPeriod) < block.timestamp, "claimReward :: user has to wait 24 hr to claim");
        
        user[msg.sender]._pendingRewards = user[msg.sender]._pendingRewards.sub(_amountToClaim);
        PredictionToken.transfer(msg.sender,_amountToClaim);
        user[msg.sender].LastClaimedTimeStamp = block.timestamp;
        emit RewardWithdrawn( msg.sender, _amountToClaim, block.timestamp);
    }

    function withdraw( uint _amountOut) public returns (bool) {
        require(_amountOut <= user[msg.sender]._depositedFromExchange, "insufficent amount to withdraw");                                                                                                                                                                       
        
        user[msg.sender]._depositedFromExchange = user[msg.sender]._depositedFromExchange.sub(_amountOut);
        PredictionToken.transfer(msg.sender,_amountOut);
        emit Withdraw( msg.sender, _amountOut, block.timestamp);
        return true;
    }    
    
    function paybackBorrow( address _collateral, uint _borrowID, uint _amount) public {
        uint _paybackLala;
        
        if(_amount > user[msg.sender]._availableborrow) {
            _paybackLala =  user[msg.sender]._availableborrow;
            user[msg.sender]._availableborrow = 0;
            
            if((user[msg.sender]._pendingRewards >= _amount.sub(_paybackLala)) && ( _amount != _paybackLala) && (_amount.sub(_paybackLala) > 0)){
               user[msg.sender]._pendingRewards = user[msg.sender]._pendingRewards.sub(_amount.sub(_paybackLala));
               _paybackLala = _paybackLala.add(_amount.sub(_paybackLala));
            } 
        }
        else{
            user[msg.sender]._availableborrow =  user[msg.sender]._availableborrow.sub(_amount);
            _paybackLala = _amount;
        }
        
        require(_paybackLala == _amount, "paybackBorrow :: borrow lala doesnt match");
        
        BorrowLala(borrowLala).payBack( _collateral, msg.sender, _borrowID, _amount);
    }
    
    function predict( uint8 _prediction, uint _predictAmount, uint _predictTime, bool _useBorrow) public returns (bool) {
        require(_predictAmount >= lalaPrice.mul(minLalaToPredict));
       
        if(_useBorrow){
           require((_predictAmount > 0) && (_predictAmount <= user[msg.sender]._availableborrow), "prediction :: predict : amount to predict is exceed borrowed amount");  
        }
        else{ require((_predictAmount > 0) && (_predictAmount <= user[msg.sender]._depositedFromExchange), "prediction :: predict : amount to predict is exceed deposited amount from exchange"); }
       
        predictStruct memory _predictStruct = predictStruct({
           _tokenToPredict : _predictAmount,
           _predictTime : _predictTime,
           _prediction : _prediction,
           _predictedTime : block.timestamp,
           _rewarded : 0,
           _isUseBorrow : _useBorrow,
           _isCompleted : false
        });
       
        user[msg.sender]._predictionID++;
        user[msg.sender].prediction[user[msg.sender]._predictionID] = _predictStruct;
       
        if(!_useBorrow)
            user[msg.sender]._depositedFromExchange = user[msg.sender]._depositedFromExchange.sub(_predictAmount);
        else
            user[msg.sender]._availableborrow = user[msg.sender]._availableborrow.sub(_predictAmount);

        user[msg.sender]._tokenAvailableToPredict = user[msg.sender]._tokenAvailableToPredict.sub(_predictAmount);
        emit Prediction(user[msg.sender]._predictionID , _prediction, _predictAmount, _predictTime,  _useBorrow);
    }
    
    function distributePredictionRewards( address[] memory _user, uint[] memory _predictionID, uint[] memory _rewards, bool[] memory _asPredicted) public _onlyAnnouncer returns (bool) {
        require((_user.length == _rewards.length) && (_rewards.length == _asPredicted.length) && (_rewards.length == _predictionID.length),"prediction :: distributePredictionRewards : invalid length");
        
        for(uint i=0;i<_user.length;i++){
            require(_user[i] != address(0),"prediction :: distributePredictionRewards : address must not be a zero address");
            require(_predictionID[i] > 0,"prediction :: distributePredictionRewards : prediction ID must be greater than zero");
            require(!user[_user[i]].prediction[_predictionID[i]]._isCompleted, "prediction :: distributePredictionRewards : completed prediction");
            require(user[_user[i]]._predictionID >= _predictionID[i], "prediction :: distributePredictionRewards : invalid prediction ID");
            require(user[_user[i]].prediction[_predictionID[i]]._rewarded == 0,"prediction :: distributePredictionRewards : reward already received");
            require(user[_user[i]].prediction[_predictionID[i]]._predictTime <= block.timestamp,"prediction :: distributePredictionRewards : predict time didnt exceed");
            
            if(_asPredicted[i])
                require(_rewards[i] > 0,"prediction :: distributePredictionRewards : _rewards must be greater than zero");
            
            if(_rewards[i] > 0){
                user[_user[i]].prediction[_predictionID[i]]._rewarded = _rewards[i];
                user[_user[i]]._pendingRewards = user[_user[i]]._pendingRewards.add(_rewards[i]); 
                PredictionToken.mint( address(this), _rewards[i]);
            } 
            
            if(!_asPredicted[i]){
                PredictionToken.burn( _dead, user[_user[i]].prediction[_predictionID[i]]._tokenToPredict);
            }
            else{    
                user[_user[i]]._tokenAvailableToPredict = user[_user[i]]._tokenAvailableToPredict.add(user[_user[i]].prediction[_predictionID[i]]._tokenToPredict);
                
                if(!user[_user[i]].prediction[_predictionID[i]]._isUseBorrow){
                    user[_user[i]]._depositedFromExchange = user[_user[i]]._depositedFromExchange.add(user[_user[i]].prediction[_predictionID[i]]._tokenToPredict);
                }
                else{
                    user[_user[i]]._availableborrow = user[_user[i]]._availableborrow.add(user[_user[i]].prediction[_predictionID[i]]._tokenToPredict);
                }
            }
            
            user[_user[i]].prediction[_predictionID[i]]._isCompleted = true;
            emit RewardDistribution( _user[i], _predictionID[i], _rewards[i], _asPredicted[i]);
        }
    }
    
    function distributeWinnerReward( address[] memory _winners, uint[] memory _rewards) external _onlyAnnouncer returns (bool) {
        require(_winners.length == _rewards.length,"distributeWinnerReward :: _rewards length mismatch");
        for(uint i=0; i< _winners.length; i++){
            user[_winners[i]]._pendingRewards = user[_winners[i]]._pendingRewards.add(_rewards[i]); 
            PredictionToken.mint( address(this), _rewards[i]);
            emit WinnerReward( _winners[i],_rewards[i], block.timestamp);
        }
    }
    
    function getPredictionDetails( address _user, uint _predictID) public view returns (predictStruct memory) {
        return user[_user].prediction[_predictID];
    }
    
    function viewBorrowAvailable( address _user) external view returns ( uint) {
        return user[_user]._availableborrow;
    }
}