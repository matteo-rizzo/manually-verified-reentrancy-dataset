/**
 *Submitted for verification at Etherscan.io on 2021-03-14
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

contract OHMPreSale is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;  
    
    address public aOHM;
    address public DAI;
    address public addressToSendDai;
    
    uint public salePrice;
    uint public totalWhiteListed;
    uint public endOfSale;

    bool public saleStarted;

    mapping(address => bool) boughtOHM;
    mapping(address => bool) whiteListed;

    function whiteListBuyers( address[] memory _buyers ) external onlyOwner() returns ( bool ) {
        require(saleStarted == false, 'Already initialized');

        totalWhiteListed = totalWhiteListed.add( _buyers.length );

        for( uint i; i < _buyers.length; i++ ) {
            whiteListed[_buyers[i]] = true;
        }

        return true;

    }
    
    function initialize ( address _addressToSendDai, address _dai, address _aOHM, uint _salePrice, uint _saleLength ) external onlyOwner() returns(bool) {
        require(saleStarted == false, 'Already initialized');

        aOHM = _aOHM;
        DAI = _dai;

        salePrice = _salePrice;
        
        endOfSale = _saleLength.add(block.timestamp);

        saleStarted = true;

        addressToSendDai = _addressToSendDai;

        return true;
    }

    function getAllotmentPerBuyer() public view returns (uint) {
        return IERC20( aOHM ).balanceOf(address(this)).div(totalWhiteListed);
    }

    function purchaseaOHM(uint _amountDAI) external returns(bool) {
        require (saleStarted == true, 'Not started');
        require(whiteListed[msg.sender] == true, 'Not whitelisted');
        require(boughtOHM[msg.sender] == false, 'Already participated');
        require(block.timestamp < endOfSale, 'Sale over');

        boughtOHM[msg.sender] = true;

        uint _purchaseAmount = _calculateSaleQuote( _amountDAI );

        require(_purchaseAmount <= getAllotmentPerBuyer(), 'More than alloted');
        totalWhiteListed = totalWhiteListed.sub(1);

        IERC20( DAI ).safeTransferFrom(msg.sender, addressToSendDai, _amountDAI);
        IERC20( aOHM ).safeTransfer(msg.sender, _purchaseAmount);

        return true;
    }

    function sendRemainingaOHM() external onlyOwner() returns(bool) {
        require (saleStarted == true, 'Not started');
        require (block.timestamp >= endOfSale, 'Not ended');

        IERC20( aOHM ).safeTransfer(msg.sender, IERC20( aOHM ).balanceOf(address(this)));

        return true;

    }

    function _calculateSaleQuote( uint paymentAmount_ ) internal view returns ( uint ) {
      return uint(1e9).mul(paymentAmount_).div(salePrice);
    }

    function calculateSaleQuote( uint paymentAmount_ ) external view returns ( uint ) {
      return _calculateSaleQuote( paymentAmount_ );
    }
}