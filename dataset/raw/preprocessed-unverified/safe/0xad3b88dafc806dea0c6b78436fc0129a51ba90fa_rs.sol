/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.15;


contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}









contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}

contract Crowdsale is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
    IERC20 private _token;

    
    address payable private _wallet;

    
    
    
    
    uint256 private _rate;

    
    uint256 private _weiRaised;

    
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    
    function () external payable {
        buyTokens(_msgSender());
    }

    
    function token() public view returns (IERC20) {
        return _token;
    }

    
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    
    function rate() public view returns (uint256) {
        return _rate;
    }

    
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        
        uint256 tokens = _getTokenAmount(weiAmount);

        
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; 
    }

    
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        
    }

    
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }

    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}



contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is Context, PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract PausableCrowdsale is Crowdsale, Pausable {
    
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view whenNotPaused {
        return super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}

contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _cap;

    
    constructor (uint256 cap) public {
        require(cap > 0, "CappedCrowdsale: cap is 0");
        _cap = cap;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function capReached() public view returns (bool) {
        return weiRaised() >= _cap;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiRaised().add(weiAmount) <= _cap, "CappedCrowdsale: cap exceeded");
    }
}

contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    
    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

    
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    
    constructor (uint256 openingTime, uint256 closingTime) public {
        
        require(openingTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        
        require(closingTime > openingTime, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    
    function isOpen() public view returns (bool) {
        
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    
    function hasClosed() public view returns (bool) {
        
        return block.timestamp > _closingTime;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    
    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}

contract FinalizableCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    bool private _finalized;

    event CrowdsaleFinalized();

    constructor () internal {
        _finalized = false;
    }

    
    function finalized() public view returns (bool) {
        return _finalized;
    }

    
    function finalize() public {
        require(!_finalized, "FinalizableCrowdsale: already finalized");
        require(hasClosed(), "FinalizableCrowdsale: not closed");

        _finalized = true;

        _finalization();
        emit CrowdsaleFinalized();
    }

    
    function _finalization() internal {
        
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract HYBOCrowdsaleLap1 is Crowdsale, CappedCrowdsale, TimedCrowdsale, FinalizableCrowdsale, PausableCrowdsale, Ownable {

    uint256 private _changeableRate;
    IERC777 __token;

    constructor()
        Ownable()
        FinalizableCrowdsale()
        PausableCrowdsale()
        CappedCrowdsale(
          10000000 * 10 ** 18      
        )
        TimedCrowdsale(
          1584270000,
          1594638000
        )
        Crowdsale(
          2000,                    
          0x230660DD3beF18cCeCD529786944050E11b99681, 
          IERC20(0xe9C1495189B7b6b1E23aa7A9aEF17bD83253EE46)
        ) public
    {
      _changeableRate = 2000;
      __token = IERC777(0xe9C1495189B7b6b1E23aa7A9aEF17bD83253EE46);
    }

    event RateChanged(uint256 newRate);

    function setRate(uint256 newRate) public onlyOwner {
        require(newRate > 0, "Crowdsale: rate is 0");
        _changeableRate = newRate;
        emit RateChanged(newRate);
    }

    function rate() public view returns (uint256) {
        return _changeableRate;
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_changeableRate);
    }

    function _finalization() internal {
        __token.burn(__token.balanceOf(address(this)), "");
        super._finalization();
    }

}