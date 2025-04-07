/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;



contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function manager() public view override returns (address) {
        return _owner;
    }

    modifier onlyManager() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyManager() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyManager() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
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













contract OlympusBondDepository is Ownable {

    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event BondCreated( uint deposit, uint indexed payout, uint indexed expires, uint indexed priceInUSD );
    event BondRedeemed( uint indexed payout, uint indexed remaining );
    event BondPriceChanged( uint indexed priceInUSD, uint indexed internalPrice, uint indexed debtRatio );

    address public immutable OHM; // Token given as payment for bond
    address public immutable principle; // Token used to create bond
    address public immutable treasury; // Mints OHM when receives principle
    address public immutable DAO; // Receives profit share from bond

    bool public immutable isLiquidityBond; // LP and Reserve bonds are treated slightly different
    address public immutable bondCalculator; // Calculates value of LP tokens
    address public staking;

    constructor ( 
        address _OHM,
        address _principle,
        address _treasury, 
        address _DAO, 
        address _bondCalculator
    ) {
        require( _OHM != address(0) );
        OHM = _OHM;
        require( _principle != address(0) );
        principle = _principle;
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _DAO != address(0) );
        DAO = _DAO;
        // bondCalculator should be address(0) if not LP bond
        bondCalculator = _bondCalculator;
        isLiquidityBond = ( _bondCalculator != address(0) );
    }

    /*
        Bond holder information
     */

    struct Bond {
        uint valueRemaining; // value of principle given
        uint payoutRemaining; // OHM remaining to be paid
        uint vestingPeriod; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In DAI, for front end viewing
    }
    mapping( address => Bond ) public bondInfo; // Stores bond information for depositor

    /*
        New bond terms
     */

    struct Terms {
        uint controlVariable; // scaling variable for price
        uint vestingTerm; // in blocks
        uint minimumPrice; // vs principle value
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
    }
    Terms public terms; // Stores terms for new bonds
    
    // Total value of outstanding bonds
    uint public totalDebt; // Used for pricing
    
    

    /**
     * @notice sets initial bond terms - initialization function
     * @param _controlVariable uint
     * @param _minimumPrice uint
    */
    function initializeBondTerms( uint _controlVariable, uint _minimumPrice ) external onlyManager() {
        terms.controlVariable = _controlVariable;
        terms.minimumPrice = _minimumPrice;
    }
    
    /**
     * @notice sets staking contract if not yet set - initialization function
     * @param _staking address
     */
    function initializeStaking( address _staking ) external onlyManager() {
        require( staking == address(0) );
        require( _staking != address(0) );
        staking = _staking;
    }
    
    

    /**
        @notice set parameters of new bonds
        @param _vestingTerm uint
        @param _maxPayout uint
        @param _fee uint
        @return bool
     */
    function setBondTerms ( 
        uint _vestingTerm, // Length in blocks for bond to vest
        uint _maxPayout, // Maximum amount (as % of circ supply) a bond can pay out
        uint _fee // Amount of profits DAO takes
    ) external onlyManager() returns ( bool ) {
        require( _vestingTerm >= 10000, "Vesting must be longer than 36 hours" );
        require( _maxPayout <= 1000, "Payout cannot be above 1 percent" );
        require( _fee <= 10000, "DAO fee cannot exceed payout" );

        terms.vestingTerm = _vestingTerm;
        terms.maxPayout = _maxPayout;
        terms.fee = _fee;

        return true;
    }
    
    /**
        Info for incremental adjustments to control variable 
     */

    struct Adjust {
        bool add;
        uint rate;
        uint target;
    }
    Adjust public adjustment;

    /**
        @notice set control variable adjustment
        @param _addition bool
        @param _increment uint
        @param _target uint
     */
    function setAdjustment ( 
        bool _addition,
        uint _increment, 
        uint _target 
    ) external onlyManager() {
        require( _increment <= terms.controlVariable.mul( 25 ).div( 1000 ), "Increment too large" );

        adjustment = Adjust({
            add: _addition,
            rate: _increment,
            target: _target
        });
    }


    /**
        @notice deposit bond
        @param _amount uint
        @param _maxPrice uint
        @param _depositor address
        @return uint
     */
    function deposit( 
        uint _amount, 
        uint _maxPrice,
        address _depositor
    ) external returns ( uint ) {
        require( _depositor != address(0), "Invalid address" );
        
        uint priceInUSD = bondPriceInUSD(); // Stored in bond info
        uint nativePrice = _bondPrice();

        require( _maxPrice >= nativePrice, "Slippage limit: more than max price" ); // slippage protection

        uint value;
        if( isLiquidityBond ) { // LP is calculated at risk-free value
            value = IBondCalculator( bondCalculator ).valuation( principle, _amount ); 
        } else { // reserve is converted to OHM decimals
            value = _amount.mul( 10 ** IERC20( OHM ).decimals() ).div( 10 ** IERC20( principle ).decimals() ); 
        }
        uint payout = payoutFor( value ); // payout to bonder is computed

        require( payout >= 10000000, "Bond too small" ); // must be > 0.01 OHM ( underflow protection )
        require( payout <= maxPayout(), "Bond too large"); // size protection because there is no slippage

        // calculate profits
        uint fee = payout.mul( terms.fee ).div( 10000 );
        uint profit = value.sub( payout ).sub( fee );

        /**
            principle is transferred in
            approved and
            deposited into the treasury
            returning (_amount - profit) OHM
         */
        IERC20( principle ).safeTransferFrom( msg.sender, address(this), _amount );
        IERC20( principle ).approve( address( treasury ), _amount );
        ITreasury( treasury ).deposit( _amount, principle, profit );
        
        // fee is transferred to dao 
        IERC20( OHM ).safeTransfer( DAO, fee ); 
        
        // total debt is increased
        totalDebt = totalDebt.add( value ); 
                
        // depositor info is stored
        Bond memory info = bondInfo[ _depositor ];
        bondInfo[ _depositor ] = Bond({ 
            valueRemaining: info.valueRemaining.add( value ), // add on to previous 
            payoutRemaining: info.payoutRemaining.add( payout ), // amounts if they exist
            vestingPeriod: terms.vestingTerm,
            lastBlock: block.number,
            pricePaid: priceInUSD
        });

        // emit indexed events 
        emit BondCreated( _amount, payout, block.number.add( terms.vestingTerm ), priceInUSD );
        emit BondPriceChanged( bondPriceInUSD(), _bondPrice(), debtRatio() );

        adjust(); // adjustment control variable
        return payout; 
    }

    /** 
        @notice redeem all unvested bonds
        @param _stake bool
        @return payout_ uint
     */ 
    function redeem( bool _stake ) external returns ( uint ) {        
        Bond memory info = bondInfo[ msg.sender ];
        uint percentVested = percentVestedFor( msg.sender ); // (blocks since last interaction / vesting term remaining)

        if ( percentVested >= 10000 ) { // if fully vested
            delete bondInfo[msg.sender]; // delete user info
            totalDebt = totalDebt.sub( info.valueRemaining ); // reduce debt
            emit BondRedeemed( info.payoutRemaining, 0 ); // emit bond data
            return stakeOrSend( _stake, info.payoutRemaining ); // pay user everything due

        } else { // if unfinished
            // calculate payout vested
            uint value = info.valueRemaining.mul( percentVested ).div( 10000 );
            uint payout = info.payoutRemaining.mul( percentVested ).div( 10000 );
            uint blocksSinceLast = block.number.sub( info.lastBlock );

            // store updated deposit info
            bondInfo[ msg.sender ] = Bond({
                valueRemaining: info.valueRemaining.sub( value ),
                payoutRemaining: info.payoutRemaining.sub( payout ),
                vestingPeriod: info.vestingPeriod.sub( blocksSinceLast ),
                lastBlock: block.number,
                pricePaid: info.pricePaid
            });

            // reduce total debt by vested amount
            totalDebt = totalDebt.sub( value );

            emit BondRedeemed( payout, bondInfo[ msg.sender ].payoutRemaining );
            return stakeOrSend( _stake, payout );
        }
    }

    /**
        @notice allow user to stake payout automatically
        @param _stake bool
        @param _amount uint
        @return uint
     */
    function stakeOrSend( bool _stake, uint _amount ) internal returns ( uint ) {
        emit BondPriceChanged( bondPriceInUSD(), _bondPrice(), debtRatio() );

        if ( !_stake ) { // if user does not want to stake
            IERC20( OHM ).transfer( msg.sender, _amount ); // send payout
        } else { // if user wants to stake
            IERC20( OHM ).approve( staking, _amount );
            IStaking( staking ).stake( _amount, msg.sender ); // stake payout
        }
        return _amount;
    }

    /**
        @notice makes incremental adjustment to control variable
     */
    function adjust() internal {
        if( adjustment.rate != 0 ) {
            if ( adjustment.add ) {
                terms.controlVariable = terms.controlVariable.add( adjustment.rate );
                if ( terms.controlVariable >= adjustment.target ) {
                    adjustment.rate = 0;
                }
            } else {
                terms.controlVariable = terms.controlVariable.sub( adjustment.rate );
                if ( terms.controlVariable <= adjustment.target ) {
                    adjustment.rate = 0;
                }
            }
        }
    }

    /**
        @notice determine maximum bond size
        @return uint
     */
    function maxPayout() public view returns ( uint ) {
        return IERC20( OHM ).totalSupply().mul( terms.maxPayout ).div( 100000 );
    }

    /**
        @notice calculate current bond premium
        @return price_ uint
     */
    function bondPrice() public view returns ( uint price_ ) {        
        price_ = terms.controlVariable.mul( debtRatio() ).add( 1000000000 ).div( 1e7 );
        if ( price_ < terms.minimumPrice ) {
            price_ = terms.minimumPrice;
        }
    }

    /**
        @notice calculate current bond price and remove floor if above
        @return price_ uint
     */
    function _bondPrice() internal returns ( uint price_ ) {
        price_ = terms.controlVariable.mul( debtRatio() ).add( 1000000000 ).div( 1e7 );
        if ( price_ < terms.minimumPrice ) {
            price_ = terms.minimumPrice;        
        } else if ( terms.minimumPrice != 0 ) {
            terms.minimumPrice = 0;
        }
    }

    /**
        @notice converts bond price to DAI value
        @return price_ uint
     */
    function bondPriceInUSD() public view returns ( uint price_ ) {
        if( isLiquidityBond ) {
            price_ = bondPrice().mul( IBondCalculator( bondCalculator ).markdown( principle ) ).div( 100 );
        } else {
            price_ = bondPrice().mul( 10 ** IERC20( principle ).decimals() ).div( 100 );
        }
    }

    /**
        @notice calculate current ratio of payouts to OHM supply
        @return debtRatio_ uint
     */

    function debtRatio() public view returns ( uint debtRatio_ ) {   
        uint supply = IERC20( OHM ).totalSupply();
        debtRatio_ = FixedPoint.fraction( 
            totalDebt.mul( 1e9 ), 
            supply
        ).decode112with18().div( 1e18 );
    }

    /**
        @notice calculate interest due for new bond
        @param _value uint
        @return uint
     */
    function payoutFor( uint _value ) public view returns ( uint ) {
        return FixedPoint.fraction( _value, bondPrice() ).decode112with18().div( 1e16 );
    }

    /**
        @notice calculate how far into vesting a depositor is
        @param _depositor address
        @return percentVested_ uint
     */
    function percentVestedFor( address _depositor ) public view returns ( uint percentVested_ ) {
        Bond memory bond = bondInfo[ _depositor ];
        uint blocksSinceLast = block.number.sub( bond.lastBlock );
        uint vestingPeriod = bond.vestingPeriod;

        if ( vestingPeriod > 0 ) {
            percentVested_ = blocksSinceLast.mul( 10000 ).div( vestingPeriod );
        } else {
            percentVested_ = 0;
        }
    }

    /**
        @notice calculate amount of OHM available for claim by depositor
        @param _depositor address
        @return pendingPayout_ uint
     */
    function pendingPayoutFor( address _depositor ) external view returns ( uint pendingPayout_ ) {
        uint percentVested = percentVestedFor( _depositor );
        uint payoutRemaining = bondInfo[ _depositor ].payoutRemaining;

        if ( percentVested >= 10000 ) {
            pendingPayout_ = payoutRemaining;
        } else {
            pendingPayout_ = payoutRemaining.mul( percentVested ).div( 10000 );
        }
    }

    /**
        @notice allow anyone to send lost tokens (excluding principle or OHM) to the DAO
        @return bool
     */
    function recoverLostToken( address _token ) external returns ( bool ) {
        require( _token != OHM );
        require( _token != principle );
        IERC20( _token ).safeTransfer( DAO, IERC20( _token ).balanceOf( address(this) ) );
        return true;
    }
}