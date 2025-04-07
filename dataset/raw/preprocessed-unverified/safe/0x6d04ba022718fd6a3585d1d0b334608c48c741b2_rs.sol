/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity 0.5.17;



contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}







contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}

contract ERC20Mintable is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    function _mint(address to, uint256 amount) internal {
        _balances[to] = _balances[to].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(from, address(0), amount);
    }
}

contract stakingRateModel {
    using SafeMath for *;

    uint256 lastUpdateTimestamp;
    uint256 stakingRateStored;
    uint256 constant ratePerSecond = 21979553177; //(1+ratePerSecond)^(86400*365) = 2
    constructor() public {
        stakingRateStored = 1e18;
        lastUpdateTimestamp = block.timestamp;
    }

    function stakingRate(uint256 time) external returns (uint256 rate) {
        if(time == 30 days) return stakingRateMax().div(12);
        else if(time == 90 days) return stakingRateMax().div(4);
        else if(time == 180 days) return stakingRateMax().div(2);
        else if(time == 360 days) return stakingRateMax();
    }

    function stakingRateMax() public returns (uint256 rate) {
        uint256 timeElapsed = block.timestamp.sub(lastUpdateTimestamp);
        if(timeElapsed > 0) {
            lastUpdateTimestamp = block.timestamp;
            rate = timeElapsed.mul(ratePerSecond).add(1e18).mul(stakingRateStored).div(1e18);
            stakingRateStored = rate;
        }
        else rate = stakingRateStored;
    }

}

contract sHakka is Ownable, ERC20Mintable{
    using SafeMath for *;
    using SafeERC20 for IERC20;

    struct vault {
        uint256 hakkaAmount;
        uint256 wAmount;
        uint256 unlockTime;
    }

    event Stake(address indexed holder, address indexed depositor, uint256 amount, uint256 wAmount, uint256 time);
    event Unstake(address indexed holder, address indexed receiver, uint256 amount, uint256 wAmount);

    IERC20 public constant Hakka = IERC20(0x0E29e5AbbB5FD88e28b2d355774e73BD47dE3bcd);
    stakingRateModel public currentModel;

    mapping(address => mapping(uint256 => vault)) public vaults;
    mapping(address => uint256) public vaultCount;
    mapping(address => uint256) public stakedHakka;
    mapping(address => uint256) public votingPower;

    constructor() public {
        symbol = "sHAKKA";
        name = "Sealed Hakka";
        decimals = 18;
        _balances[address(this)] = uint256(-1);
        _balances[address(0)] = uint256(-1);
    }

    function getStakingRate(uint256 time) public returns (uint256 rate) {
        return currentModel.stakingRate(time);
    }

    function setStakingRateModel(address newModel) external onlyOwner {
        currentModel = stakingRateModel(newModel);
    }

    function stake(address to, uint256 amount, uint256 time) external returns (uint256 wAmount) {
        vault storage v = vaults[to][vaultCount[to]];
        wAmount = getStakingRate(time).mul(amount).div(1e18);
        require(wAmount > 0, "invalid lockup");

        v.hakkaAmount = amount;
        v.wAmount = wAmount;
        v.unlockTime = block.timestamp.add(time);
        
        stakedHakka[to] = stakedHakka[to].add(amount);
        votingPower[to] = votingPower[to].add(wAmount);
        vaultCount[to]++;

        _mint(to, wAmount);
        Hakka.safeTransferFrom(msg.sender, address(this), amount);

        emit Stake(to, msg.sender, amount, wAmount, time);
    }

    function unstake(address to, uint256 index, uint256 wAmount) external returns (uint256 amount) {
        vault storage v = vaults[msg.sender][index];
        require(block.timestamp >= v.unlockTime, "locked");
        require(wAmount <= v.wAmount, "exceed locked amount");
        amount = wAmount.mul(v.hakkaAmount).div(v.wAmount);

        v.hakkaAmount = v.hakkaAmount.sub(amount);
        v.wAmount = v.wAmount.sub(wAmount);

        stakedHakka[msg.sender] = stakedHakka[msg.sender].sub(amount);
        votingPower[msg.sender] = votingPower[msg.sender].sub(wAmount);

        _burn(msg.sender, wAmount);
        Hakka.safeTransfer(to, amount);
        
        emit Unstake(msg.sender, to, amount, wAmount);
    }

    function inCaseTokenGetsStuckPartial(IERC20 _TokenAddress, uint256 _amount) onlyOwner external {
        require(_TokenAddress != Hakka);
        _TokenAddress.safeTransfer(msg.sender, _amount);
    }

}