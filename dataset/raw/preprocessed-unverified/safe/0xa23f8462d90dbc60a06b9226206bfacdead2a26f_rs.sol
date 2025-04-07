/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

pragma solidity ^0.5.16;

/**
  * @title ArtDeco Finance
  *
  * @notice ARTD Contract
  * 
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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see ERC20_infos.
 */


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20_infos is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract Governance {

    address public governance;

    constructor() public {
        governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == governance, "Sender not governance");
        _;
    }

    function setGovernance(address _governance)  public  onlyGovernance
    {
        require(_governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(governance, _governance);
        governance = _governance;
    }

}


contract ArtDeco is Governance, ERC20_infos{

    using SafeMath for uint256;

    address public _burnPool = 0x6666666666666666666666666666666666666666;
    address public _rewardPool = 0x4D732FA01032b41eE0fA152398B22Bfab6689DCb;
    
    uint256 internal _totalSupply;
    uint256 public  _maxSupply = 0;
    bool public _openTransfer = false;

    uint256 public constant _maxGovernValueRate = 2000;
    uint256 public constant _minGovernValueRate = 10; 
    uint256 public constant _rateBase = 10000; 

    uint256 public  _burnRate = 250;       
    uint256 public  _rewardRate = 250;   
    uint256 public  _totalBurnToken = 0;
    uint256 public  _totalRewardToken = 0;


    event SetRate(uint256 burn_rate, uint256 reward_rate);
    event RewardPool(address rewardPool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => bool) public _minters;
    mapping(address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    
    constructor () public ERC20_infos("ArtDeco", "ARTD", 18) {
         _maxSupply = 9000000 * (10**18);
    }
    

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param spender The address which will spend the funds.
    * @param amount The amount of tokens to be spent.
    */
    function approve(address spender, uint256 amount) external 
    returns (bool) 
    {
        require(msg.sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /**
    * @dev Function to check the amount of tokens than an owner _allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address owner, address spender) external view 
    returns (uint256) 
    {
        return _allowances[owner][spender];
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) external  view 
    returns (uint256) 
    {
        return _balances[owner];
    }

    /**
    * @dev the token starting to transfer
    */
    function enableOpenTransfer() public onlyGovernance  
    {
        _openTransfer = true;
    }
    
    /**
    * @dev return the token total supply
    */
    function totalSupply() external view 
    returns (uint256) 
    {
        return _totalSupply;
    }

    /**
    * @dev return the token maximum limit supply
    */
    function maxLimitSupply() external view 
    returns (uint256) 
    {
        return _maxSupply;
    }
    
    /**
    * @dev for mint function
    */
    function mint(address account, uint256 amount) external 
    {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_minters[msg.sender], "!minter");

        uint256 curMintSupply = _totalSupply.add(_totalBurnToken);
        uint256 newMintSupply = curMintSupply.add(amount);
        require( newMintSupply <= _maxSupply,"supply is max!");
      
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        emit Mint(address(0), account, amount);
        emit Transfer(address(0), account, amount);
    }

    function addMinter(address _minter) public onlyGovernance 
    {
        _minters[_minter] = true;
    }
    
    function removeMinter(address _minter) public onlyGovernance 
    {
        _minters[_minter] = false;
    }
    

    function setRate(uint256 burn_rate, uint256 reward_rate) public 
        onlyGovernance 
    {
        
        require(_maxGovernValueRate >= burn_rate && burn_rate >= _minGovernValueRate,"invalid burn rate");
        require(_maxGovernValueRate >= reward_rate && reward_rate >= _minGovernValueRate,"invalid reward rate");

        _burnRate = burn_rate;
        _rewardRate = reward_rate;

        emit SetRate(burn_rate, reward_rate);
    }

    /**
    * @dev for set reward
    */
    function setRewardPool(address rewardPool) public 
        onlyGovernance 
    {
        require(rewardPool != address(0x0));

        _rewardPool = rewardPool;

        emit RewardPool(_rewardPool);
    }
    
    /**
    * @dev transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
   function transfer(address to, uint256 value) external 
   returns (bool)  
   {
        return _transfer(msg.sender,to,value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address from, address to, uint256 value) external 
    returns (bool) 
    {
        uint256 allow = _allowances[from][msg.sender];
        _allowances[from][msg.sender] = allow.sub(value);
        
        return _transfer(from,to,value);
    }

 
    /**
    * @dev Transfer tokens with fee
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256s the amount of tokens to be transferred
    */
    function _transfer(address from, address to, uint256 value) internal 
    returns (bool) 
    {
        require(_openTransfer || from == governance, "The transfer closed");

        require(from != address(0), "Invalid: transfer from the 0 address");
        require(to != address(0), "Invalid: transfer to the 0 address");

        uint256 sendAmount = value;
        uint256 burnFee = (value.mul(_burnRate)).div(_rateBase);
        if (burnFee > 0) {
            
            _balances[_burnPool] = _balances[_burnPool].add(burnFee);
            _totalSupply = _totalSupply.sub(burnFee);
            sendAmount = sendAmount.sub(burnFee);

            _totalBurnToken = _totalBurnToken.add(burnFee);

            emit Transfer(from, _burnPool, burnFee);
        }

        uint256 rewardFee = (value.mul(_rewardRate)).div(_rateBase);
        if (rewardFee > 0) {
           
            _balances[_rewardPool] = _balances[_rewardPool].add(rewardFee);
            sendAmount = sendAmount.sub(rewardFee);

            _totalRewardToken = _totalRewardToken.add(rewardFee);

            emit Transfer(from, _rewardPool, rewardFee);
        }

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(sendAmount);

        emit Transfer(from, to, sendAmount);

        return true;
    }

    function calcSendamount(uint256 value) view external returns (uint256)  
    {
        uint256 sendAmount = value;
        uint256 burnFee = (value.mul(_burnRate)).div(_rateBase);
        if (burnFee > 0) {
           sendAmount = sendAmount.sub(burnFee);    
        }
        uint256 rewardFee = (value.mul(_rewardRate)).div(_rateBase);
        if (rewardFee > 0) {
           sendAmount = sendAmount.sub(rewardFee);    
        }
        return sendAmount;
    }    

    function getburnRate() view external returns (uint256)  
    {
         return _burnRate;
    }

    function getrewardRate() view external returns (uint256)  
    {
         return _rewardRate;
    }  

    function totalBurn() view external returns (uint256)  
    {
         return _totalBurnToken;
    }  
    
    function totalReward() view external returns (uint256)  
    {
         return _totalRewardToken;
    }  
    
    function() external payable {
        revert();
    }
}