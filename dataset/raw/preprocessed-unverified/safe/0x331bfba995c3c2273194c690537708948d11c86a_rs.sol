pragma solidity ^0.5.9;



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




contract vnxDCR is Ownable {
    using SafeMath for uint256;

    //-----------------------------------------------------------------------------------
    // Variables, Instances, Mappings
    //-----------------------------------------------------------------------------------
    uint256 constant BULK_LENGTH = 50;
    uint256 private _totalSupplyAmount;
    uint8 public decimals; // ERC20 standard, usually used 18 inline with Ethereum

    string public name; // the name of the token -- ERC20 standard
    string public symbol; // ticker of the token -- ERC20 standard

    ITransferProvider private _transferProvider;

    bool public isClosed;

    mapping (address => uint256) private _balances;

    //-----------------------------------------------------------------------------------
    // Smart contract Constructor
    //-----------------------------------------------------------------------------------
    /**
        IMPORTANT : totalTokenAmount is in integer tokens without consideration "decimals" property
                    The value param to transfer functions, etc is taking into account "decimals" property!!
        According to standard emits the event Transfer(0, initOwner, supply)
     */
    constructor(address _initTransferProvider, uint256 _totalTokenAmount,
             string memory _name, string memory _symbol, uint8 _decimals) public
    {
        require(_initTransferProvider != address(0), "Initial transfer provider should not be zero");
        require(_totalTokenAmount > 0, "Total TokenAmount should be larger than zero");
        require(bytes(_symbol).length > 0, "Symbol should not be empty string");
        require(bytes(_name).length > 0, "Name should not be empty string");

        _transferProvider = ITransferProvider(_initTransferProvider);
        _totalSupplyAmount = _totalTokenAmount.mul(10**uint(_decimals));
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _transferProvider.considerTransfer(address(0), msg.sender, _totalSupplyAmount);
        _balances[msg.sender] = _totalSupplyAmount;
        emit Transfer(address(0), msg.sender, _totalSupplyAmount);
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupplyAmount;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) external view returns (uint256) {
        // In case owner is not exist in the list the mapping return 0 automatically
        return _balances[owner];     
    }

    //-----------------------------------------------------------------------------------
    // Transact Functions
    //-----------------------------------------------------------------------------------
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // Transfer is standard ERC20 Event issued by transfer function

    /**
    * @dev Transfer token for a specified address
    * @param _from The address to transfer from.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _from, address _to, uint256 _value) external returns (bool) {
        require(_from != address(0), "Wrong from address");
        require(_to != address(0), "Wrong to address");
        require(_value > 0, "Value should be greater than zero");
        require(isClosed == false, "Token is closed");

        return _doTransfer(_from, _to, _value);
    }

    event BatchTransferComplete(uint256 indexed batchId, uint8 count);

    /**
    * @dev Transfers token to/from a specified addresses listed in the arrays. The size of arrays chould be not more than BULK_LENGTH
    * @param _batchId The unique ID of the bulk which is calculated on the client side (by the admin) as a hash of some bulk bids' data
    * @param _from The array of addresses to transfer from.
    * @param _to The array of addresses to transfer to.
    * @param _value The array of amounts to be transferred.
    */
    function transferBatch(uint256 _batchId, address[] calldata _from,
            address[] calldata _to, uint256[] calldata _value) external onlyOwner returns (bool)
    {
        uint8 _procCount = 0;
        require(isClosed == false, "The token is closed");
        require(_from.length <= BULK_LENGTH, "The length of array is more than BULK_LENGTH");
        require(_from.length == _to.length && _from.length == _value.length, "The length of param arrays should be the same");

        for (uint j = 0; j < _from.length; j++ ) {
            if (_doTransfer(_from[j], _to[j], _value[j])) {
                _procCount++;
            }
        }

        emit BatchTransferComplete(_batchId, _procCount);
        return _procCount > 0;
    }

    function _doTransfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_value > 0, "Value should be positive non-zero integer");
        require(_value <= _balances[_from], "Not enough balance on source account");

        _balances[_from] = _balances[_from].sub( _value );
        _balances[_to] = _balances[_to].add( _value );

        require(_transferProvider.approveTransfer(_from, _to, _value, msg.sender), "Transfer was declined by transfer provider");
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     * caller must be owner
     *
     * See {ERC20-_burn}.
     */
	 
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "DCR: burn amount exceeds balance");
        _totalSupplyAmount = _totalSupplyAmount.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    event TokenClosed();

    function closeToken() external onlyOwner returns (bool) {
        require(isClosed == false, "Token is already closed");

        isClosed = true; //_isClosed;
        emit TokenClosed();
        return true;
    }

    event TransferProviderChanged(address indexed _newProvider);

    function changeTransferProvider(address _provider) external onlyOwner returns(bool) {
     	_transferProvider = ITransferProvider(_provider);

        emit TransferProviderChanged(_provider);
        return true;
    }
}