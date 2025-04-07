/**
 *Submitted for verification at Etherscan.io on 2021-07-01
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

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyPolicy() {
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













contract MockTreasury is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Deposit( address indexed token, uint amount, uint value, uint send );
    event Withdrawal( address indexed token, uint amount, uint value );

    address public immutable OHM;

    mapping( address => bool ) public isReserveToken;
    mapping( address => bool ) public isReserveDepositor;
    mapping( address => bool ) public isReserveSpender;
    mapping( address => bool ) public isReserveManager;

    mapping( address => bool ) public isLiquidityToken;
    mapping( address => bool ) public isLiquidityDepositor;
    mapping( address => bool ) public isLiquidityManager;

    mapping( address => address ) public bondCalculator; // bond calculator for liquidity token

    uint public totalReserves; // Risk-free value of all assets

    constructor( address _ohm ) {
        OHM = _ohm;
    }

    function deposit( uint _amount, address _token, uint _profit ) external returns ( uint send_ ) {
        require( isReserveToken[ _token ] || isLiquidityToken[ _token ], "Not accepted" );
        IERC20( _token ).safeTransferFrom( msg.sender, address(this), _amount );

        if ( isReserveToken[ _token ] ) {
            require( isReserveDepositor[ msg.sender ], "Not approved" );
        } else {
            require( isLiquidityDepositor[ msg.sender ], "Not approved" );
        }

        uint value = valueOf( _token, _amount );
        send_ = value.sub( _profit );

        totalReserves = totalReserves.add( value );

        emit Deposit( _token, _amount, value, send_ );
    }

    function withdraw( uint _amount, address _token ) external {
        require( isReserveToken[ _token ], "Not accepted" ); // Only reserves can be used for redemptions
        require( isReserveSpender[ msg.sender ] == true, "Not approved" );

        uint value = valueOf( _token, _amount );
        IOHMERC20( OHM ).burnFrom( msg.sender, value );

        totalReserves = totalReserves.sub( value );

        IERC20( _token ).safeTransfer( msg.sender, _amount );

        emit Withdrawal( _token, _amount, value );
    }

    function manage( address _token, uint _amount ) external {
        if( isLiquidityToken[ _token ] ) {
            require( isLiquidityManager[ msg.sender ], "Not approved" );
        } else {
            require( isReserveManager[ msg.sender ], "Not approved" );
        }

        uint value = valueOf( _token, _amount );
        totalReserves = totalReserves.sub( value );

        IERC20( _token ).safeTransfer( msg.sender, _amount );
    }

    function valueOf( address _token, uint _amount ) public view returns ( uint value_ ) {
        if ( isReserveToken[ _token ] ) {
            // convert amount to match OHM decimals
            value_ = _amount.mul( 10 ** IERC20( OHM ).decimals() ).div( 10 ** IERC20( _token ).decimals() );
        } else if ( isLiquidityToken[ _token ] ) {
            value_ = IBondCalculator( bondCalculator[ _token ] ).valuation( _token, _amount );
        }
    }

    enum MANAGING { RESERVEDEPOSITOR, RESERVESPENDER, RESERVETOKEN, RESERVEMANAGER, LIQUIDITYDEPOSITOR, LIQUIDITYTOKEN, LIQUIDITYMANAGER }

    function toggle( MANAGING _managing, address _address, address _calculator ) external onlyPolicy() {
        require( _address != address(0) );

        if ( _managing == MANAGING.RESERVEDEPOSITOR ) { // 0
            isReserveDepositor[ _address ] = !isReserveDepositor[ _address ];
        } else if ( _managing == MANAGING.RESERVESPENDER ) { // 1
            isReserveSpender[ _address ] = !isReserveSpender[ _address ];
        } else if ( _managing == MANAGING.RESERVETOKEN ) { // 2
            isReserveToken[ _address ] = !isReserveToken[ _address ];
        } else if ( _managing == MANAGING.RESERVEMANAGER ) { // 3
            isReserveManager[ _address ] = !isReserveManager[ _address ];
        } else if ( _managing == MANAGING.LIQUIDITYDEPOSITOR ) { // 4
            isLiquidityDepositor[ _address ] = !isLiquidityDepositor[ _address ];
        } else if ( _managing == MANAGING.LIQUIDITYTOKEN ) { // 5
            isLiquidityToken[ _address ] = !isLiquidityToken[ _address ];
            bondCalculator[ _address ] = _calculator;
        } else if ( _managing == MANAGING.LIQUIDITYMANAGER ) { // 6
            isLiquidityManager[ _address ] = !isLiquidityManager[ _address ];
        }
    }
}