/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;



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















contract OlympusDAIDepository is IBondDepo, Ownable {

    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    struct DepositInfo {
        uint value; // Value
        uint payoutRemaining; // OHM remaining to be paid
        uint lastBlock; // Last interaction
        uint vestingPeriod; // Blocks left to vest
    }

    mapping( address => DepositInfo ) public depositorInfo; 

    uint public DAOShare; // % = 1 / DAOShare
    uint public bondControlVariable; // Premium scaling variable
    uint public vestingPeriodInBlocks; 
    uint public minPremium; // Floor for the premium

    //  Max a payout can be compared to the circulating supply, in hundreths. i.e. 50 = 0.5%
    uint public maxPayoutPercent;

    address public treasury;
    address public DAI;
    address public OHM;

    uint256 public totalDebt; // Total value of outstanding bonds

    address public stakingContract;
    address public DAOWallet;
    address public circulatingOHMContract; // calculates circulating supply

    bool public useCircForDebtRatio; // Use circulating or total supply to calc total debt

    constructor ( 
        address DAI_, 
        address OHM_,
        address treasury_, 
        address stakingContract_, 
        address DAOWallet_, 
        address circulatingOHMContract_
    ) {
        DAI = DAI_;
        OHM = OHM_;
        treasury = treasury_;
        stakingContract = stakingContract_;
        DAOWallet = DAOWallet_;
        circulatingOHMContract = circulatingOHMContract_;
    }

    /**
        @notice set parameters of new bonds
        @param bondControlVariable_ uint
        @param vestingPeriodInBlocks_ uint
        @param minPremium_ uint
        @param maxPayout_ uint
        @param DAOShare_ uint
        @return bool
     */
    function setBondTerms( 
        uint bondControlVariable_, 
        uint vestingPeriodInBlocks_, 
        uint minPremium_, 
        uint maxPayout_,
        uint DAOShare_ ) 
    external onlyOwner() returns ( bool ) {
        bondControlVariable = bondControlVariable_;
        vestingPeriodInBlocks = vestingPeriodInBlocks_;
        minPremium = minPremium_;
        maxPayoutPercent = maxPayout_;
        DAOShare = DAOShare_;
        return true;
    }

    /**
        @notice deposit bond
        @param amount_ uint
        @param maxPremium_ uint
        @param depositor_ address
        @return bool
     */
    function deposit( 
        uint amount_, 
        uint maxPremium_,
        address depositor_ ) 
    external override returns ( bool ) {
        _deposit( amount_, maxPremium_, depositor_ ) ;
        return true;
    }

    /**
        @notice deposit bond with permit
        @param amount_ uint
        @param maxPremium_ uint
        @param depositor_ address
        @param v uint8
        @param r bytes32
        @param s bytes32
        @return bool
     */
    function depositWithPermit( 
        uint amount_, 
        uint maxPremium_,
        address depositor_, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s ) 
    external override returns ( bool ) {
        ERC20Permit( DAI ).permit( msg.sender, address(this), amount_, deadline, v, r, s );
        _deposit( amount_, maxPremium_, depositor_ ) ;
        return true;
    }

    /**
        @notice deposit function like mint
        @param amount_ uint
        @param maxPremium_ uint
        @param depositor_ address
        @return bool
     */
    function _deposit( 
        uint amount_, 
        uint maxPremium_, 
        address depositor_ ) 
    internal returns ( bool ) {
        // slippage protection
        require( maxPremium_ >= _calcPremium(), "Slippage protection: more than max premium" );

        IERC20( DAI ).safeTransferFrom( msg.sender, address(this), amount_ );

        uint value_ = amount_.div( 1e9 );
        uint payout_ = calculateBondInterest( value_ );

        require( payout_ >= 10000000, "Bond too small" ); // must be > 0.01 OHM
        require( payout_ <= getMaxPayoutAmount(), "Bond too large");

        totalDebt = totalDebt.add( value_ );

        // Deposit token to mint OHM
        IERC20( DAI ).approve( address( treasury ), amount_ );
        ITreasury( treasury ).depositReserves( amount_ ); // Returns OHM

        uint profit_ = value_.sub( payout_ );
        uint DAOProfit_ = FixedPoint.fraction( profit_, DAOShare ).decode();
        // Transfer profits to staking distributor and dao
        IERC20( OHM ).safeTransfer( stakingContract, profit_.sub( DAOProfit_ ) );
        IERC20( OHM ).safeTransfer( DAOWallet, DAOProfit_ );

        // Store depositor info
        depositorInfo[ depositor_ ] = DepositInfo({
            value: depositorInfo[ depositor_ ].value.add( value_ ),
            payoutRemaining: depositorInfo[ depositor_ ].payoutRemaining.add( payout_ ),
            lastBlock: block.number,
            vestingPeriod: vestingPeriodInBlocks
        });
        return true;
    }

    /** 
        @notice redeem bond
        @return bool
     */ 
    function redeem() external override returns ( bool ) {
        uint payoutRemaining_ = depositorInfo[ msg.sender ].payoutRemaining;

        require( payoutRemaining_ > 0, "Sender is not due any interest." );

        uint value_ = depositorInfo[ msg.sender ].value;
        uint percentVested_ = _calculatePercentVested( msg.sender );

        if ( percentVested_ >= 10000 ) { // if fully vested
            delete depositorInfo[msg.sender];
            IERC20( OHM ).safeTransfer( msg.sender, payoutRemaining_ );
            totalDebt = totalDebt.sub( value_ );
            return true;
        }

        // calculate and send vested OHM
        uint payout_ = payoutRemaining_.mul( percentVested_ ).div( 10000 );
        IERC20( OHM ).safeTransfer( msg.sender, payout_ );

        // reduce total debt by vested amount
        uint valueUsed_ = value_.mul( percentVested_ ).div( 10000 );
        totalDebt = totalDebt.sub( valueUsed_ );

        uint vestingPeriod_ = depositorInfo[msg.sender].vestingPeriod;
        uint blocksSinceLast_ = block.number.sub( depositorInfo[ msg.sender ].lastBlock );

        // store updated deposit info
        depositorInfo[msg.sender] = DepositInfo({
            value: value_.sub( valueUsed_ ),
            payoutRemaining: payoutRemaining_.sub( payout_ ),
            lastBlock: block.number,
            vestingPeriod: vestingPeriod_.sub( blocksSinceLast_ )
        });
        return true;
    }

    /**
        @notice get info of depositor
        @param address_ info
     */
    function getDepositorInfo( address address_ ) external view override returns ( 
        uint _value, 
        uint _payoutRemaining, 
        uint _lastBlock, 
        uint _vestingPeriod ) 
    {
        DepositInfo memory info = depositorInfo[ address_ ];
        _value = info.value;
        _payoutRemaining = info.payoutRemaining;
        _lastBlock = info.lastBlock;
        _vestingPeriod = info.vestingPeriod;
    }

    /**
        @notice set contract to use circulating or total supply to calc debt
     */
    function toggleUseCircForDebtRatio() external onlyOwner() returns ( bool ) {
        useCircForDebtRatio = !useCircForDebtRatio;
        return true;
    }

    /**
        @notice use maxPayoutPercent to determine maximum bond available
        @return uint
     */
    function getMaxPayoutAmount() public view returns ( uint ) {
        uint circulatingOHM = ICirculatingOHM( circulatingOHMContract ).OHMCirculatingSupply();

        uint maxPayout = circulatingOHM.mul( maxPayoutPercent ).div( 10000 );

        return maxPayout;
    }

    /**
        @notice view function for _calculatePercentVested
        @param depositor_ address
        @return _percentVested uint
     */
    function calculatePercentVested( address depositor_ ) external view override returns ( uint _percentVested ) {
        _percentVested = _calculatePercentVested( depositor_ );
    }

    /**
        @notice calculate how far into vesting period depositor is
        @param depositor_ address
        @return _percentVested uint ( in hundreths - i.e. 10 = 0.1% )
     */
    function _calculatePercentVested( address depositor_ ) internal view returns ( uint _percentVested ) {
        uint vestingPeriod_ = depositorInfo[ depositor_ ].vestingPeriod;
        if ( vestingPeriod_ > 0 ) {
            uint blocksSinceLast_ = block.number.sub( depositorInfo[ depositor_ ].lastBlock );
            _percentVested = blocksSinceLast_.mul( 10000 ).div( vestingPeriod_ );
        } else {
            _percentVested = 0;
        }
    }

    /**
        @notice calculate amount of OHM available for claim by depositor
        @param depositor_ address
        @return uint
     */
    function calculatePendingPayout( address depositor_ ) external view override returns ( uint ) {
        uint percentVested_ = _calculatePercentVested( depositor_ );
        uint payoutRemaining_ = depositorInfo[ depositor_ ].payoutRemaining;
        
        uint pendingPayout = payoutRemaining_.mul( percentVested_ ).div( 10000 );

        if ( percentVested_ >= 10000 ) {
            pendingPayout = payoutRemaining_;
        } 
        return pendingPayout;
    }

    /**
        @notice calculate interest due to new bonder
        @param value_ uint
        @return _interestDue uint
     */
    function calculateBondInterest( uint value_ ) public view override returns ( uint _interestDue ) {
        _interestDue = FixedPoint.fraction( value_, _calcPremium() ).decode112with18().div( 1e16 );
    }

    /**
        @notice view function for _calcPremium()
        @return _premium uint
     */
    function calculatePremium() external view override returns ( uint _premium ) {
        _premium = _calcPremium();
    }

    /**
        @notice calculate current bond premium
        @return _premium uint
     */
    function _calcPremium() internal view returns ( uint _premium ) {
        _premium = bondControlVariable.mul( _calcDebtRatio() ).add( uint(1000000000) ).div( 1e7 );
        if ( _premium < minPremium ) {
            _premium = minPremium;
        }
    }

    /**
        @notice calculate current debt ratio
        @return _debtRatio uint
     */
    function _calcDebtRatio() internal view returns ( uint _debtRatio ) {   
        uint supply;

        if( useCircForDebtRatio ) {
            supply = ICirculatingOHM( circulatingOHMContract ).OHMCirculatingSupply();
        } else {
            supply = IERC20( OHM ).totalSupply();
        }

        _debtRatio = FixedPoint.fraction( 
            // Must move the decimal to the right by 9 places to avoid math underflow error
            totalDebt.mul( 1e9 ), 
            supply
        ).decode112with18().div( 1e18 );
        // Must move the decimal to the left 18 places to account for the 9 places added above and the 19 signnificant digits added by FixedPoint.
    }
}