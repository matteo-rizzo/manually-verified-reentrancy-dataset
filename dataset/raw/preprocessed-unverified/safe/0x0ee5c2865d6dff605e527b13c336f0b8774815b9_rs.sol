/**
 *Submitted for verification at Etherscan.io on 2021-03-30
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;



contract Ownable is IOwnable {
    
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred( address(0), _owner );
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceOwnership() public virtual override onlyOwner() {
        emit OwnershipTransferred( _owner, address(0) );
        _owner = address(0);
    }

    function transferOwnership( address newOwner_ ) public virtual override onlyOwner() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred( _owner, newOwner_ );
        _owner = newOwner_;
    }
}







abstract contract ERC20 is IERC20 {

    using SafeMath for uint256;

    // TODO comment actual hash value.
    bytes32 constant private ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256( "ERC20Token" );
    
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    
    string internal _symbol;
    
    uint8 internal _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

    function _mint(address account_, uint256 ammount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address( this ), account_, ammount_);
        _totalSupply = _totalSupply.add(ammount_);
        _balances[account_] = _balances[account_].add(ammount_);
        emit Transfer(address( this ), account_, ammount_);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
}





abstract contract ERC20Permit is ERC20, IERC2612Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")), // Version
                chainID,
                address(this)
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "Permit: expired deadline");

        bytes32 hashStruct =
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner].current(), deadline));

        bytes32 _hash = keccak256(abi.encodePacked(uint16(0x1901), DOMAIN_SEPARATOR, hashStruct));

        address signer = ecrecover(_hash, v, r, s);
        require(signer != address(0) && signer == owner, "ZeroSwapPermit: Invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, amount);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }
}




















contract OHMPrincipleDepository is IPrincipleDepository, Ownable {

    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    struct DepositInfo {
        uint principleAmount;
        uint principleValue;
        uint interestDue;
        uint maturationBlock;
    }

    mapping( address => DepositInfo ) public depositorInfo;

    uint public bondControlVariable;
    uint public bondingPeriodInBlocks; 
    uint public minPremium;

    address public treasury;
    address public bondCalculator;
    address public principleToken;
    address public OHM;

    uint256 public totalDebt;

    address public stakingContract;
    address public DAOWallet;
    uint public DAOShare;

    bool public isInitialized;

    function initialize ( address principleToken_, address OHM_ ) external onlyOwner() returns ( bool ) {
        require( isInitialized == false );
        principleToken = principleToken_;
        OHM = OHM_;

        isInitialized = true;

        return  true;
    }

    function setAddresses( address bondCalculator_, address treasury_, address stakingContract_, 
    address DAOWallet_, uint DAOShare_ ) external onlyOwner() returns ( bool ) {
        bondCalculator = bondCalculator_;
        treasury = treasury_;
        stakingContract = stakingContract_;
        DAOWallet = DAOWallet_;
        DAOShare = DAOShare_;
        return true;
    }

    function setBondTerms( uint bondControlVariable_, uint bondingPeriodInBlocks_, uint minPremium_ ) 
    external onlyOwner() returns ( bool ) {
        bondControlVariable = bondControlVariable_;
        bondingPeriodInBlocks = bondingPeriodInBlocks_;
        minPremium = minPremium_;
        return true;
    }

    function getDepositorInfo( address depositorAddress_ ) 
    external view override returns ( uint _principleAmount, uint _principleValue, uint _interestDue, uint _maturationBlock ) {
        DepositInfo memory depositorInfo_ = depositorInfo[ depositorAddress_ ];
        _principleAmount = depositorInfo_.principleAmount;
        _principleValue = depositorInfo_.principleValue;
        _interestDue = depositorInfo_.interestDue;
        _maturationBlock = depositorInfo_.maturationBlock;
    }

    function depositBondPrinciple( uint amountToDeposit_ ) external override returns ( bool ) {
        _depositBondPrinciple( amountToDeposit_ ) ;
        return true;
    }

    function depositBondPrincipleWithPermit( uint amountToDeposit_, uint deadline, uint8 v, bytes32 r, bytes32 s ) 
    external override returns ( bool ) {
        ERC20Permit( principleToken ).permit( msg.sender, address(this), amountToDeposit_, deadline, v, r, s );
        _depositBondPrinciple( amountToDeposit_ ) ;
        return true;
    }

    function _depositBondPrinciple( uint amountToDeposit_ ) internal returns ( bool ){
        IERC20( principleToken ).safeTransferFrom( msg.sender, address(this), amountToDeposit_ );

        uint principleValue_ = IBondingCalculator( bondCalculator )
            .principleValuation( principleToken, amountToDeposit_ ).div( 1e9 );

        uint interestDue_ = _calculateBondInterest( principleValue_ );

        require( interestDue_ >= 10000000, "Bond too small" );

        totalDebt = totalDebt.add( principleValue_ );

        depositorInfo[msg.sender] = DepositInfo({
            principleAmount: depositorInfo[msg.sender].principleAmount.add( amountToDeposit_ ),
            principleValue: depositorInfo[msg.sender].principleValue.add( principleValue_ ),
            interestDue: depositorInfo[msg.sender].interestDue.add( interestDue_ ),
            maturationBlock: block.number.add( bondingPeriodInBlocks )
        });
        return true;
    }

    function redeemBond() external override returns ( bool ) {
        require( depositorInfo[msg.sender].interestDue > 0, "Sender is not due any interest." );
        require( block.number >= depositorInfo[msg.sender].maturationBlock, "Bond has not matured." );

        uint principleAmount_ = depositorInfo[msg.sender].principleAmount;
        uint principleValue_ = depositorInfo[msg.sender].principleValue;
        uint interestDue_ = depositorInfo[msg.sender].interestDue;

        delete depositorInfo[msg.sender];

        uint profit_ = principleValue_.sub( interestDue_ );
        uint DAOProfit_ = FixedPoint.fraction( profit_, DAOShare ).decode();

        IUniswapV2ERC20( principleToken ).approve( address( treasury ), principleAmount_ );

        ITreasury( treasury ).depositPrinciple( principleAmount_ );

        IERC20( OHM ).safeTransfer( msg.sender, interestDue_ );
        IERC20( OHM ).safeTransfer( stakingContract, profit_.sub( DAOProfit_ ) );
        IERC20( OHM ).safeTransfer( DAOWallet, IERC20( OHM ).balanceOf( address(this) ) );

        totalDebt = totalDebt.sub( principleValue_ );
        return true;
    }

    function withdrawPrincipleAndForfeitInterest() external override returns ( bool ) {
        uint amountToWithdraw_ = depositorInfo[msg.sender].principleAmount;
        uint principleValue_ = depositorInfo[msg.sender].principleValue;

        require( amountToWithdraw_ > 0, "user has no principle to withdraw" );

        delete depositorInfo[msg.sender];

        IERC20( principleToken ).safeTransfer( msg.sender, amountToWithdraw_ );

        totalDebt = totalDebt.sub( principleValue_ );
        return true;
    }

    function calculateBondInterest( uint amountToDeposit_ ) external view override returns ( uint _interestDue ) {
        uint principleValue_ = IBondingCalculator( bondCalculator ).principleValuation( principleToken, amountToDeposit_ ).div( 1e9 );
        _interestDue = _calculateBondInterest( principleValue_ );
    }

    function _calculateBondInterest( uint principleValue_ ) internal view returns ( uint _interestDue ) {
        _interestDue = FixedPoint.fraction( principleValue_, _calcPremium() ).decode112with18().div( 1e16 );
    }

    function calculatePremium() external view override returns ( uint _premium ) {
        _premium = _calcPremium();
    }

    function _calcPremium() internal view returns ( uint _premium ) {
        _premium = bondControlVariable.mul( _calcDebtRatio() ).add( uint(1000000000) ).div( 1e7 );
        if ( _premium < minPremium ) {
            _premium = minPremium;
        }
    }

    function _calcDebtRatio() internal view returns ( uint _debtRatio ) {    
        _debtRatio = FixedPoint.fraction( 
            // Must move the decimal to the right by 9 places to avoid math underflow error
            totalDebt.mul( 1e9 ), 
            IERC20( OHM ).totalSupply()
        ).decode112with18().div( 1e18 );
        // Must move the decimal tot he left 18 places to account for the 9 places added above and the 19 signnificant digits added by FixedPoint.
    }
}