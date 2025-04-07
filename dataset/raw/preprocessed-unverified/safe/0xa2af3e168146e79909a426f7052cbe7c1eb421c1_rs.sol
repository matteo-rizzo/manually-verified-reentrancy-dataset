/**
 *Submitted for verification at Etherscan.io on 2021-07-28
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













contract TestTreasury is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    mapping( address => bool ) public isReserveToken;
    mapping( address => bool ) public isReserveDepositor;
    mapping( address => bool ) public isReserveSpender;
    mapping( address => bool ) public isReserveManager;

    function deposit( uint _amount, address _token, uint _profit ) external {
        require( isReserveToken[ _token ], "Not accepted" );
        IERC20( _token ).safeTransferFrom( msg.sender, address(this), _amount );
        require( isReserveDepositor[ msg.sender ], "Not approved" );
    }

    function withdraw( uint _amount, address _token ) external {
        require( isReserveToken[ _token ], "Not accepted" ); // Only reserves can be used for redemptions
        require( isReserveSpender[ msg.sender ] == true, "Not approved" );

        IERC20( _token ).safeTransfer( msg.sender, _amount );
    }

    function manage( address _token, uint _amount ) external {
        require( isReserveManager[ msg.sender ], "Not approved" );

        IERC20( _token ).safeTransfer( msg.sender, _amount );
    }

    function valueOfToken( address _token, uint _amount ) public view returns ( uint value_ ) {
        if ( isReserveToken[ _token ] ) {
            // convert amount to match decimals
            value_ = _amount.mul( 10 ** 9 ).div( 10 ** IERC20( _token ).decimals() );
        }
    }

    enum MANAGING { RESERVEDEPOSITOR, RESERVESPENDER, RESERVETOKEN, RESERVEMANAGER }

    function toggle( MANAGING _managing, address _address ) external onlyPolicy() {
        require( _address != address(0) );

        if ( _managing == MANAGING.RESERVEDEPOSITOR ) { // 0
            isReserveDepositor[ _address ] = !isReserveDepositor[ _address ];
        } else if ( _managing == MANAGING.RESERVESPENDER ) { // 1
            isReserveSpender[ _address ] = !isReserveSpender[ _address ];
        } else if ( _managing == MANAGING.RESERVETOKEN ) { // 2
            isReserveToken[ _address ] = !isReserveToken[ _address ];
        } else if ( _managing == MANAGING.RESERVEMANAGER ) { // 3
            isReserveManager[ _address ] = !isReserveManager[ _address ];
        } 
    }
}