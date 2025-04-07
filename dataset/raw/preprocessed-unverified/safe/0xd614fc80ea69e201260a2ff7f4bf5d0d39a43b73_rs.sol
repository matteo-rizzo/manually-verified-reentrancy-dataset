/**
 *Submitted for verification at Etherscan.io on 2021-08-03
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: UNLICENSED


 


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



contract BorrowLala is Ownable {
    using SafeMath for uint;
    
    // Event logs
    event Borrow( address indexed _vault, address indexed _token, uint _collateral, uint _borrowed, uint indexed _borrowID, uint _borrowTime);
    event Payback( address indexed _vault, address indexed _token, uint indexed _borrowID, uint _paybackToken, uint _collateral, uint _borrowTime);
    
    IERC20 public lala;
    PredictionLala public PredictionCon;
    
    struct token {
        uint _tokenPrice;
        uint _decimals;
        bool _isActive;
    }
    
    struct Vault {
        uint _borrowed;
        mapping(address => borrows)  _borrow;
    }
    
    struct borrows {
        uint borrowID;
        uint pastBorrowID;
        uint pastBorrows;
        uint pastLalaBorrows;
        uint recentBorrows;
        mapping(uint => borrowListStruct) listOfBorrows;
    }
    
    struct borrowListStruct{
        uint borrows;
        uint lalaBorrows;
        uint pastBorrowTime;
        bool isExpired;
    }
    
    mapping(address => token) public getToken;
    mapping(address => Vault) public vault;
    
    address public predictionContract;
    address[] public tokenList;
    
    address liquidateWallet;
    address public _dead = 0x000000000000000000000000000000000000dEaD;
    
    uint public estimatedLoop = 10; 
    uint public borrowTimeStamp = 7 days;
    
    constructor(PredictionLala _predictionContract, address _liquidateWallet) public {
        PredictionCon = _predictionContract;
        liquidateWallet = _liquidateWallet;
    }
    
    function setlala(IERC20 _lala) public onlyOwner { lala = _lala; }
    
    function updateLoopEstimation( uint _esLp) public onlyOwner { estimatedLoop = _esLp; }
    
    function updateBorrowTimeStamp( uint _borrowTimeStamp) public onlyOwner { borrowTimeStamp = _borrowTimeStamp; }
    
    function updatePrediction( PredictionLala _predict) public onlyOwner { PredictionCon = _predict; }
    
    function addToken( address _token, uint _decimal, uint _price) public onlyOwner {
        require(_price > 0, "lendingAndBorrow :: addToken : Price must be greater than zero");
        require(!getToken[_token]._isActive, "lendingAndBorrow :: addToken : Token already activated");
        require((_decimal >= 0) && (_decimal <= 18), "lendingAndBorrow :: addToken : decimals must be inbetween 0 to 18");
        
        getToken[_token] = token(_price,(10**(_decimal)),true);
        tokenList.push(_token);
    }
    
    function updateTokenPrice(address _token, uint _price) public onlyOwner {
        require(_price > 0, "lendingAndBorrow :: updateCollateralPrice : Price must be greater than zero");
        require(getToken[_token]._isActive, "lendingAndBupdateCollateralPriceorrow :: updateCollateralPrice : Token is not activated");
        
        getToken[_token]._tokenPrice = _price;
    }
    
    function borrow( address _token, uint _value, uint _leverage, bool _withUpdate) public payable {
        require(getToken[_token]._isActive, "lendingAndBorrow :: borrow : Token is not activated");
        require(_leverage <= 125, "lendingAndBorrow :: borrow : leverage must be between 1 to 125");
        
        if(_token == address(0)) { require((msg.value > 0) && (msg.value == _value), "lendingAndBorrow :: borrow : value must be equal to msg.value and msg.value must be greater than zero"); }
        else{
            require(IERC20(_token).balanceOf(msg.sender) > _value, "lendingAndBorrow :: borrow : insufficient balance");
            require(IERC20(_token).allowance(msg.sender, address(this)) >= _value, "lendingAndBorrow :: borrow : insufficient allowance");
            require(IERC20(_token).transferFrom(msg.sender, address(this), _value), "lendingAndBorrow :: borrow : transferFrom failed");
        }
        
        uint _borrow = cumulativePrice(_token, _value);
        _borrow = _borrow.add(cumulativePrice(_token, _value.mul(30).div(100))); // 30% more on investment
        
        if(_leverage >= 1)
            _borrow = _borrow.add(_borrow.mul(_leverage).div(100));
        
        lala.mint( address(PredictionCon), _borrow);
        PredictionCon.depositFor( msg.sender, _borrow);
        
        vault[msg.sender]._borrowed = vault[msg.sender]._borrowed.add(_borrow);
        
        if(_withUpdate) { updateTokenVaults( msg.sender,_token); }// With update. 
        
        vault[msg.sender]._borrow[_token].borrowID++;
        
        uint _collateralFee = _value.div(100);
        
        vault[msg.sender]._borrow[_token].listOfBorrows[vault[msg.sender]._borrow[_token].borrowID] = borrowListStruct(_value.sub(_collateralFee), _borrow, block.timestamp, false);
        vault[msg.sender]._borrow[_token].recentBorrows = vault[msg.sender]._borrow[_token].recentBorrows.add(_value.sub(_collateralFee));
        
        if(_token == address(0)) require(payable(liquidateWallet).send(_collateralFee), "borrow: _collateralFee transfer failed");
        else
            IERC20(_token).transfer(liquidateWallet,_collateralFee);
        
        emit Borrow( msg.sender, _token, _value, _borrow, vault[msg.sender]._borrow[_token].borrowID, block.timestamp);
    }
    
    function payBack( address _token, address _account, uint _borrowID, uint _amount) external {
        require(vault[_account]._borrow[_token].borrowID >= _borrowID);
        require(!vault[_account]._borrow[_token].listOfBorrows[_borrowID].isExpired, "lendingAndBorrow :: payBack : payback period ends");
        
        updateTokenVaults( _account,_token);
        
        require(vault[_account]._borrow[_token].recentBorrows > 0, "lendingAndBorrow :: payBack : There is no recent borrows to payback");
        require(_amount == vault[_account]._borrow[_token].listOfBorrows[_borrowID].lalaBorrows, "lendingAndBorrow :: payBack : payBack amount doesnot match");
        
        if(vault[_account]._borrow[_token].listOfBorrows[_borrowID].pastBorrowTime.add(borrowTimeStamp) > block.timestamp) {
        
            lala.transferFrom(msg.sender, _dead, _amount);
            
            uint _amountOut = vault[_account]._borrow[_token].listOfBorrows[_borrowID].borrows;
             uint _deduction;
             
            if(_amountOut > 0){
                _deduction = _amountOut.mul(3).div(100);
                if(_token == address(0)){
                    require(payable(_account).send(_amountOut.sub(_deduction)), "lendingAndBorrow :: payBack : value send failed");
                    require(payable(liquidateWallet).send(_deduction), "lendingAndBorrow :: payBack : payback commission value send failed");
                }
                else{
                    require(IERC20(_token).transfer(_account,_amountOut.sub(_deduction)), "lendingAndBorrow :: payBack : Token transfer failed");
                    require(IERC20(_token).transfer(liquidateWallet,_deduction), "lendingAndBorrow :: payBack : payback commission Token transfer failed");
                }
                
                vault[_account]._borrow[_token].recentBorrows = vault[_account]._borrow[_token].recentBorrows.sub(_amountOut);
                vault[_account]._borrow[_token].listOfBorrows[_borrowID].isExpired = true;
            }
            else{
                revert("lendingAndBorrow :: payBack : collateral returns zero");
            }
            
            emit Payback( _account, _token, _borrowID, _amount, _amountOut.sub(_deduction), block.timestamp);
        }
    }
    
    function updateTokenVaults(address _vault, address _token) public returns (bool) {
        if((vault[_vault]._borrow[_token].borrowID > 0) && (vault[_vault]._borrow[_token].pastBorrowID < vault[_vault]._borrow[_token].borrowID)){
            uint _workUntill = vault[_vault]._borrow[_token].borrowID;
            uint _start = vault[_vault]._borrow[_token].pastBorrowID;
            if(vault[_vault]._borrow[_token].borrowID.sub(vault[_vault]._borrow[_token].pastBorrowID) > estimatedLoop) _workUntill = vault[_vault]._borrow[_token].pastBorrowID.add(estimatedLoop);
            
            _start = (vault[_vault]._borrow[_token].pastBorrowID == 0) ? 1 : vault[_vault]._borrow[_token].pastBorrowID;
            
            for(uint i=_start;i <= _workUntill;i++){
                if((vault[_vault]._borrow[_token].listOfBorrows[i].pastBorrowTime.add(borrowTimeStamp) < block.timestamp) && (vault[_vault]._borrow[_token].listOfBorrows[i].pastBorrowTime != 0)){
                    if(!vault[_vault]._borrow[_token].listOfBorrows[i].isExpired){
                        vault[_vault]._borrow[_token].pastLalaBorrows = vault[_vault]._borrow[_token].pastLalaBorrows.add(vault[_vault]._borrow[_token].listOfBorrows[i].lalaBorrows);
                        vault[_vault]._borrow[_token].recentBorrows = vault[_vault]._borrow[_token].recentBorrows.sub(vault[_vault]._borrow[_token].listOfBorrows[i].borrows);
                        vault[_vault]._borrow[_token].pastBorrows = vault[_vault]._borrow[_token].pastBorrows.add(vault[_vault]._borrow[_token].listOfBorrows[i].borrows);
                        vault[_vault]._borrow[_token].listOfBorrows[i].isExpired = true;
                    }
                }
                else break;
                
                vault[_vault]._borrow[_token].pastBorrowID++;
            }
        }
        
        return true;
    }
    
    function liquidateVault( address _vault, address _token) public {
        if(updateTokenVaults( _vault, _token)){
            if(vault[_vault]._borrow[_token].pastBorrows > 0){
                uint _amount = vault[_vault]._borrow[_token].pastBorrows;
                vault[_vault]._borrow[_token].pastBorrows = 0;
                liquidate(_token, _amount);
            }
        }
    }
    
    function liquidate(address _token, uint _amount) internal returns (bool) {
        address _contract = address(this);
        
        if(_token == address(0)){
            if(_contract.balance < _amount) { return false; }
            require(payable(liquidateWallet).send(_amount), "lendingAndBorrow :: liquidate : value send failed");
        }
        else{
            if(IERC20(_token).balanceOf(_contract) < _amount) { return false; }
            require(IERC20(_token).transfer(liquidateWallet,_amount), "lendingAndBorrow :: liquidate : Token transfer failed");
        }
        
        return true;
    }
    
    function failsafe( address _token, address _to, uint amount) public onlyOwner returns (bool) {
        address _contractAdd = address(this);
        if(_token == address(0)){
            require(_contractAdd.balance >= amount,"insufficient ETH");
            address(uint160(_to)).transfer(amount);
        }
        else{
            require( IERC20(_token).balanceOf(_contractAdd) >= amount,"insufficient Token balance");
            IERC20(_token).transfer(_to, amount);
        }
    }
    
    
    function cumulativePrice( address _token, uint _amountIn) public view returns (uint){
          return _amountIn.mul(1e18).div(getToken[_token]._tokenPrice);
    }
    
    function cumulativePaybackPrice( address _token, uint _amountIn) public view returns (uint){
          uint _price = _amountIn.mul(1e12).mul(getToken[_token]._tokenPrice).div(1e18);
          return _price.div(1e12);
    }
    
    function getUserCurrentBorrowID( address _vault, address _token) public view returns (uint) {
        return vault[_vault]._borrow[_token].borrowID;
    }
    
    function getBorrowDetails( address _vault, address _token, uint _borrowID) public view returns ( uint pastBorrowID, uint pastBorrows, uint recentBorrows, uint borrowed, uint pastBorrowTime, bool _isexpired) {
        (pastBorrowID, pastBorrows, recentBorrows, borrowed, pastBorrowTime, _isexpired) = (
            vault[_vault]._borrow[_token].pastBorrowID,
            vault[_vault]._borrow[_token].pastBorrows,
            vault[_vault]._borrow[_token].recentBorrows,
            vault[_vault]._borrow[_token].listOfBorrows[_borrowID].borrows,
            vault[_vault]._borrow[_token].listOfBorrows[_borrowID].pastBorrowTime,
            vault[_vault]._borrow[_token].listOfBorrows[_borrowID].isExpired);
    }
    
    function getBorrowedLalaByID( address _vault, address _token, uint _borrowID) public view returns (uint _borrowedLala) {
        return vault[_vault]._borrow[_token].listOfBorrows[_borrowID].lalaBorrows;
    }
    
    function getBorrowedCurrentID( address _vault, address _token) public view returns (uint _borrowedID) {
        return vault[_vault]._borrow[_token].borrowID;
    }
}