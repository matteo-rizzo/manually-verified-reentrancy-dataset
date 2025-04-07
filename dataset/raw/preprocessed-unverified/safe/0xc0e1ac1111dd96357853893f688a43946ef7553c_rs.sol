/**
 *Submitted for verification at Etherscan.io on 2021-02-11
*/

// SPDX-License-Identifier: unlicensed

pragma solidity ^0.5.12;









contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}

contract Context {
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor() internal {
        address payable msgSender = _msgSender();
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

    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require( newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



























contract BalancerAddLiquidity is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    bool public stopped = false;
    uint16 public goodwill = 0;

    address payable public goodwillAddress = 0x3CE37278de6388532C3949ce4e886F365B14fB56;
    IBFactory BalancerFactory = IBFactory(0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd);

       
    event AddedLiquidity(address userAddress, address balancerPool, uint256 LPBought);

    constructor(uint16 _goodwill, address payable _goodwillAddress) public {
        goodwill = _goodwill;
        goodwillAddress = _goodwillAddress;
    }

    // circuit breaker modifiers
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function AddLiquidity(
        address _FromTokenContractAddress,
        address _ToBalancerPoolAddress,
        address _toTokenContractAddress,
        uint256 _amount,
        uint256 _minPoolTokens,
        address _allowanceTarget,
        address _swapTarget,
        bytes calldata swapData
    ) external payable nonReentrant stopInEmergency returns (uint256) {
        uint256 toInvest;

        require(BalancerFactory.isBPool(_ToBalancerPoolAddress), "Invalid Balancer Pool");
        require(IBPool(_ToBalancerPoolAddress).isBound(_toTokenContractAddress), "Token not bound");

        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "ERR: No ETH sent");
            uint256 goodwillPortion = _transferGoodwill(address(0), msg.value);
            toInvest = msg.value.sub(goodwillPortion);
        } else {
            require(_amount > 0, "ERR: No ERC sent");
            require(msg.value == 0, "ERR: ETH sent with tokens");

            IERC20(_FromTokenContractAddress).safeTransferFrom(msg.sender, address(this), _amount);

            uint256 goodwillPortion = _transferGoodwill( _FromTokenContractAddress, _amount);

            toInvest = _amount.sub(goodwillPortion);
        }

        uint256 LPBought = _performAddLiquidity(
            _FromTokenContractAddress,
            _ToBalancerPoolAddress,
            toInvest,
            _toTokenContractAddress,
            _allowanceTarget,
            _swapTarget,
            swapData
        );

        require(LPBought >= _minPoolTokens, "ERR: High Slippage");
        IERC20(_ToBalancerPoolAddress).safeTransfer(msg.sender, LPBought);
        emit AddedLiquidity(msg.sender, _ToBalancerPoolAddress, LPBought);

        return LPBought;
    }

    function _performAddLiquidity(
        address _FromTokenContractAddress,
        address _ToBalancerPoolAddress,
        uint256 _amount,
        address _toTokenContractAddress,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapData
    ) internal returns (uint256 tokensBought) {
        bool isBound = IBPool(_ToBalancerPoolAddress).isBound(_FromTokenContractAddress);
        uint256 balancerTokens;

        if (isBound) {
            balancerTokens = _enter2Balancer(_ToBalancerPoolAddress, _FromTokenContractAddress, _amount);
        } else {
            uint256 tokenBought = _fillQuote( _FromTokenContractAddress, _toTokenContractAddress, _amount, _allowanceTarget, _swapTarget, swapData);
            balancerTokens = _enter2Balancer(_ToBalancerPoolAddress, _toTokenContractAddress, tokenBought); 
        }

        return balancerTokens;
    }

    function _fillQuote(
        address _fromTokenAddress,
        address _bestPoolToken,
        uint256 _amount,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapData
    ) internal returns (uint256 amountBought) {
        uint256 toInvest;

        if (_fromTokenAddress == address(0)) {
            toInvest = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);

            require(fromToken.balanceOf(address(this)) >= _amount, "Insufficient Balance");

            fromToken.safeApprove(address(_allowanceTarget), 0);
            fromToken.safeApprove(address(_allowanceTarget), _amount);
        }

        uint256 initialBalance = IERC20(_bestPoolToken).balanceOf(address(this));

        (bool success, ) = _swapTarget.call.value(toInvest)(swapData);
        require(success, "Error Swapping tokens");

        amountBought = IERC20(_bestPoolToken).balanceOf(address(this)).sub(initialBalance);

        require(amountBought > 0, "Swapped to Invalid Intermediate");
    }

    function _enter2Balancer(address _ToBalancerPoolAddress, address _FromTokenContractAddress, uint256 tokens2Trade) internal returns (uint256 poolTokensOut) {
        require(IBPool(_ToBalancerPoolAddress).isBound(_FromTokenContractAddress), "Token not bound");

        uint256 allowance = IERC20(_FromTokenContractAddress).allowance(address(this), _ToBalancerPoolAddress);

        if (allowance < tokens2Trade) {
            IERC20(_FromTokenContractAddress).safeApprove( _ToBalancerPoolAddress, tokens2Trade);  
        }

        poolTokensOut = IBPool(_ToBalancerPoolAddress).joinswapExternAmountIn(_FromTokenContractAddress, tokens2Trade, 1);

        require(poolTokensOut > 0, "Error in entering balancer pool");
    }

    function _transferGoodwill(address _tokenContractAddress, uint256 tokens2Trade) internal returns (uint256 goodwillPortion) {
        if (goodwill == 0) {
            return 0;
        }
        goodwillPortion = SafeMath.div(SafeMath.mul(tokens2Trade, goodwill), 10000);

        if (_tokenContractAddress == address(0)) {
            Address.sendValue(goodwillAddress, goodwillPortion);
        } else {
            IERC20(_tokenContractAddress).safeTransfer(goodwillAddress, goodwillPortion);  
        }
    }

    function setNewGoodwill(uint16 _new_goodwill) public onlyOwner {
        require(_new_goodwill >= 0 && _new_goodwill < 10000, "GoodWill Value not allowed");
        goodwill = _new_goodwill;
    }

    function setNewGoodwillAddress(address payable _newGoodwillAddress) public onlyOwner{
        goodwillAddress = _newGoodwillAddress;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        IERC20(address(_TokenAddress)).safeTransfer(owner(), qty);
    }

    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}