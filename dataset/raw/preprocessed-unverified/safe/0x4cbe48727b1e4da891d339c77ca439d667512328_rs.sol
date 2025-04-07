/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

pragma solidity ^0.6.0;


// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

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
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



contract LynStaking is Ownable {
    using SafeMath for uint256;
    bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant TRANSFER_FROM_SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    bytes4 private constant BALANCE_OF_SELECTOR = bytes4(keccak256(bytes('balanceOf(address)')));

    uint256 private marketPrice;
    uint256 private lockTime;
    uint256 private startDepositTime;

    uint256 private dayInterestRate;
    uint256 private secondInterestRate;
    uint256 private PERCENT_DECIMAL = 1e18;
    uint256 private DECIMAL = 1e18;

    uint256 private totalFund;

    uint256 public totalDeposit;

    address public depositToken;
    address public rewardToken;

    bool private stakable;

    mapping(address=>uint256) capitals;
    mapping(address=>uint256) lastDepositTime;
    mapping(address=>uint256) lastActivityTime;
    mapping(address=>uint256) accumulationInterest;

    event DepositStart();
    event DepositStop();
    event UpdatePrice(uint256 newPrice);
    event UpdateInterestRate(uint256 newRate);
    event AddFund(uint256 amount);

    event Deposit(address indexed staker, uint256 amount);
    event Withdraw(address indexed staker, uint256 amount);
    event Claim(address indexed staker, uint256 amount);

    modifier onlyStakable() {
        require(stakable, "Not start staking yet");
        _;
    }

    /**
     * IMPORTANT
     * _dayInterestRate
     * Since not supporting float point number of Solidity the input of this function should be multiplied by 10^18.
     * Eg:
     *   1% = 1/100 * 10^18 = 10000000000000000
     *   1.2% = 1.2/100 * 10^18 = 12000000000000000
     *   0.00556% = 0.00556/100 * 10^18 = 55600000000000
     * Use this tool https://keisan.casio.com/calculator to calculate the rate
     */
    constructor(
        address _depositTokenAddr,
        address _rewardTokenAddr,
        uint256 _lockTime,
        uint256 _dayInterestRate
    ) public {
        depositToken = _depositTokenAddr;
        rewardToken = _rewardTokenAddr;
        lockTime = _lockTime;
        dayInterestRate = _dayInterestRate;
        secondInterestRate = _dayInterestRate.div(86400);
    }

    //////////////////////////////////////
    // OPERATION FUNCTIONS
    //////////////////////////////////////
    function depositStart() external onlyOwner() {
        stakable = true;
        emit DepositStart();
    }

    function depositStop() external onlyOwner() {
        stakable = false;
        emit DepositStop();
    }

    /**
     * The input must be multiplied by 10^decimals
     */
    function updateMarketPrice(uint256 _newPrice) external onlyOwner() {
        marketPrice = _newPrice;
        emit UpdatePrice(_newPrice);
    }

    // Add fund to contract
    function adminFund(uint256 _amount) external onlyOwner() {
        _safeTransferFrom(rewardToken, msg.sender, address(this), _amount);
        totalFund = totalFund.add(_amount);
        emit AddFund(_amount);
    }

    // Send all reward token to owner's address in urgent case
    function drain() external onlyOwner() {
        uint256 balance = _getBalanceOf(rewardToken, address(this));
        _safeTransfer(rewardToken, msg.sender, balance);
    }

    // Transfer USDT to owner address
    function transfer(uint256 _amount) external onlyOwner() {
        _safeTransfer(depositToken, msg.sender, _amount);
    }

    //////////////////////////////////////
    // PUBLIC FUNCTIONS
    //////////////////////////////////////

    function deposit(uint256 _amount) onlyStakable() external {
        _safeTransferFrom(depositToken, msg.sender, address(this), _amount);
        uint256 interest = _estimateInterest(msg.sender);
        accumulationInterest[msg.sender] = interest;// accumulationInterest[msg.sender].add(interest);

        capitals[msg.sender] = capitals[msg.sender].add(_amount);
        lastDepositTime[msg.sender] = block.timestamp;
        lastActivityTime[msg.sender] = block.timestamp;

        totalDeposit = totalDeposit.add(_amount);

        emit Deposit(msg.sender, _amount);
    }

    function claimReward() external {
        uint256 reward = checkLynReward(msg.sender);
        require(reward > 0, "Small reward");

        lastActivityTime[msg.sender] = block.timestamp;
        accumulationInterest[msg.sender] = 0;

        _safeTransfer(rewardToken, msg.sender, reward);
        emit Claim(msg.sender, reward);
    }

    // Withdraw all deposit + reward
    function withdraw() external {
        require(lastDepositTime[msg.sender].add(lockTime) <= block.timestamp, "Not expired");

        uint256 reward = checkLynReward(msg.sender);
        lastActivityTime[msg.sender] = block.timestamp;
        accumulationInterest[msg.sender] = 0;

        totalDeposit = totalDeposit.sub(capitals[msg.sender]);

        uint256 returnAmount = capitals[msg.sender].mul(DECIMAL).div(marketPrice);
        capitals[msg.sender] = 0;

        returnAmount = returnAmount.add(reward);

        _safeTransfer(rewardToken, msg.sender, returnAmount);
        emit Withdraw(msg.sender, returnAmount);
    }

    function _estimateInterest(address _staker) internal view returns (uint256) {
        uint256 d = block.timestamp.sub(lastActivityTime[_staker]);
        uint256 interest = _caculateInterest(capitals[_staker], d);
        return interest.add(accumulationInterest[_staker]);
    }

    function _caculateInterest(uint256 capital, uint d) internal view returns (uint256) {
        return capital.mul(d).mul(secondInterestRate).div(PERCENT_DECIMAL).mul(DECIMAL);
    }

    //////////////////////////////////////
    // GET FUNCTIONS
    //////////////////////////////////////
    function checkUserCapital(address _address) public view returns (uint256){
        return capitals[_address];
    }

    function checkUserCapitalLyn(address _address) public view returns (uint256){
        return capitals[_address].mul(DECIMAL).div(marketPrice);
    }

    function checkLynReward(address _staker) public view returns (uint256) {
        return _estimateInterest(_staker).div(marketPrice);
    }

    function checkReward(address _staker) public view returns (uint256) {
        return _estimateInterest(_staker).div(DECIMAL);
    }

    function checkDepositStart() public view returns (bool) {
        return stakable;
    }

    function checkPrice() public view returns(uint256) {
        return marketPrice;
    }

    function checkStakeRateYear() public view returns(uint256) {
        return dayInterestRate.mul(365);
    }

    function checkStakeRateDay() public view returns(uint256) {
        return dayInterestRate;
    }

    //////////////////////////////////////
    // UTILITY FUNCTIONS
    //////////////////////////////////////

    // ERC20:
    // Functions `transfer`, `transferFrom` should return bool
    // but some token returns void instead of following the standard
    // Since, we need to accept void return as a successful transfer
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }

    function _safeTransferFrom(address token, address from, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_FROM_SELECTOR, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FROM_FAILED');
    }

    function _getBalanceOf(address token, address account) private returns(uint256) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(BALANCE_OF_SELECTOR, account));
        require(success, 'BALACE_OF_FAILED');
        uint256 balance = abi.decode(data,(uint256));
        return balance;
    }
}