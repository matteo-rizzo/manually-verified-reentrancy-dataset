/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


 





abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
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
}


contract Fintex is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private constant NAME = "Fintex";
    string private constant SYMBOL = "FTEX";
    uint8 private constant DECIMALS = 18;

 
    mapping(address => uint256) private actual;
    mapping(address => mapping(address => uint256)) private allowances;

    mapping(address => bool) private excludedFromFees;
    
   

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant ACTUAL_TOTAL = 10000 * 1e18;
   
   
    uint256 private rewardFeeTotal;
    uint256 private lotteryFeeTotal;
  

    uint256 public taxPercentage = 5;
    uint256 public rewardTaxAlloc = 70;
    uint256 public lotteryTaxAlloc = 30;
   
    uint256 public totalTaxAlloc = rewardTaxAlloc.add(lotteryTaxAlloc);

    address public rewardAddress;
    address public lotteryAddress;
    
    constructor(address _rewardAddress, address _lotteryAddress) {
        
        emit Transfer(address(0), _msgSender(), ACTUAL_TOTAL);
        actual[_msgSender()] = actual[_msgSender()].add(ACTUAL_TOTAL);
        rewardAddress = _rewardAddress;
        lotteryAddress = _lotteryAddress;

        excludeFromFees(rewardAddress);
        excludeFromFees(lotteryAddress);
        excludeFromFees(_msgSender());
       
 
    }

    function name() external pure returns (string memory) {
        return NAME;
    }

    function symbol() external pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() external pure override returns (uint256) {
        return ACTUAL_TOTAL;
    }

    function balanceOf(address _account) public view override returns (uint256) {
       
            return actual[_account];
      
    }

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        _transfer(_msgSender(), _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) public override returns (bool) {
        _approve(_msgSender(), _spender, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        require(allowances[_sender][_msgSender()] > _amount, 'Not Allowed' );
        allowances[_sender][_msgSender()] = allowances[_sender][_msgSender()].sub(_amount, "ERC20: decreased allowance below zero");
       
        _transfer(_sender, _recipient, _amount);

       

        return true;
    }




    

    function isExcludedFromFees(address _account) external view returns (bool) {
        return excludedFromFees[_account];
    }

  

 

    function totalRewardFees() external view returns (uint256) {
        return rewardFeeTotal;
    }

    function totalLotteryFees() external view returns (uint256) {
        return lotteryFeeTotal;
    }



    function excludeFromFees(address _account) public onlyOwner() {
        require(!excludedFromFees[_account], "Account is already excluded from fee");
        excludedFromFees[_account] = true;
    }

    function includeInFees(address _account) public onlyOwner() {
        require(excludedFromFees[_account], "Account is already included in fee");
        excludedFromFees[_account] = false;
    }

  

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        
        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        require(_amount > 0, "Transfer amount must be greater than zero");

 
        uint256 fee = 0;
        if (excludedFromFees[_sender] || excludedFromFees[_recipient]) {
             fee = 0;

        } else {
            fee = _getFee(_amount);
            uint256 rewardFee = _getrewardFee(fee);
            uint256 lotteryFee = _getLotteryFee(fee);
            
            _updateRewardFee(rewardFee);
            _updateLotteryFee(lotteryFee); 
        }

        uint256 actualTransferAmount = _amount.sub(fee) ;  
        actual[_recipient] = actual[_recipient].add(actualTransferAmount);
        actual[_sender] = actual[_sender].sub(_amount);

        emit Transfer(_sender, _recipient, actualTransferAmount);
 

       
    }
  
    function _updateRewardFee(uint256 _rewardFee) private {
        if (rewardAddress == address(0)) {
            return;
        }

        actual[rewardAddress] = actual[rewardAddress].add(_rewardFee);
        
    }

    function _updateLotteryFee(uint256 _lotteryFee) private {
        if (lotteryAddress == address(0)) {
            return;
        }
 
        actual[lotteryAddress] = actual[lotteryAddress].add(_lotteryFee);
        
    }
 
 
    function _getFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(taxPercentage).div(100);
    }
 

    function _getrewardFee(uint256 _tax) private view returns (uint256) {
        return _tax.mul(rewardTaxAlloc).div(totalTaxAlloc);
    }

    function _getLotteryFee(uint256 _tax) private view returns (uint256) {
        return _tax.mul(lotteryTaxAlloc).div(totalTaxAlloc);
    }

   

    function setTaxPercentage(uint256 _taxPercentage) external onlyOwner {
        taxPercentage = _taxPercentage;
    }

 function setlotteryTaxAlloc(uint256 alloc) external onlyOwner {
       
        lotteryTaxAlloc = alloc;
    }

 function setrewardTaxAlloc(uint256 alloc) external onlyOwner {
       
        rewardTaxAlloc = alloc;
    }
 

    function setRewardAddress(address _rewardAddress) external onlyOwner {
        rewardAddress = _rewardAddress;
    }

    function setLotetryAddress(address _lotteryAddress) external onlyOwner {
        lotteryAddress = _lotteryAddress;
    }

    
}