// contracts/BuyBackToken.sol
// SPDX-License-Identifier: Apache-2.0
/*

      __   __        __   __   __   __  ___  __   __   __
|__/ /  \ |  \  /\  |__) /  \ |__) /  \  |  |  \ /  \ / _`
|  \ \__/ |__/ /~~\ |  \ \__/ |__) \__/  |  |__/ \__/ \__>

t.me/kodarobotdogtoken
https://kodarobot.dog/

*/
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./UniswapInterfaces.sol";

/**
 * @title BuyBackToken
 */
contract BuyBackToken is Ownable, ReentrancyGuard, IERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant MAX = ~uint256(0);
    address private constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNISWAP_LOCKER_ADDRESS = 0x663A5C229c09b049E36dCc11a9B0d4a8Eb9db214;
    address private constant LOCK_REFERRAL_ADDRESS = 0x0000000000000000000000000000000000000000;

    uint256 private constant LOCK_PERIOD = 2592000; // 3 months

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping (address => uint) private cooldown;

    string private _name;
    string private  _symbol;
    uint256 private constant _tTotal = 1e12 * 10**9;
    uint8 private constant _decimals = 9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 private _taxFee;
    uint256 private _teamFee;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousteamFee = _teamFee;
    address payable private _FeeAddress;
    address payable private _marketingWalletAddress;
    IUniswapV2Router02 private uniswapV2Router;
    IUniswapV2Locker private uniswapV2Locker;

    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    uint256 private _maxTxAmount = _tTotal;

    uint256 public lockFees;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    /**
     * @dev Creates a new buy back token.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address payable addr1,
        address payable addr2,
        uint256 lockFees_
    ) {
        _name = name_;
        _symbol = symbol_;
        _FeeAddress = addr1;
        _marketingWalletAddress = addr2;
        lockFees = lockFees_;
        _rOwned[msg.sender] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_FeeAddress] = true;
        _isExcludedFromFee[_marketingWalletAddress] = true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function setCooldownEnabled(bool onoff) external onlyOwner() {
        cooldownEnabled = onoff;
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _teamFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousteamFee = _teamFee;
        _taxFee = 0;
        _teamFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _teamFee = _previousteamFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _taxFee = 5;
        _teamFee = 10;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] && cooldownEnabled) {
                require(amount <= _maxTxAmount);
                require(cooldown[to] < block.timestamp);
                cooldown[to] = block.timestamp + (30 seconds);
            }
            if (to == uniswapV2Pair && from != address(uniswapV2Router) && ! _isExcludedFromFee[from]) {
                _taxFee = 5;
                _teamFee = 20;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && swapEnabled) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _FeeAddress.transfer(amount.div(2));
        _marketingWalletAddress.transfer(amount.div(2));
    }

    function openTradingAndLockLiquidity() external onlyOwner {
        require(!tradingOpen,"trading is already open");
        uint256 contractBalanceEth = address(this).balance;
        // TODO dynamically fetch the amount of fees and adjust liquidity provisioning accordingly
        // IUniswapV2Locker.FeeStruct memory fees = getFees();
        // uint256 ethFee = fees.ethFee;
        uint256 ethFee = lockFees;
        // Check that the balance is higher than the lock fees
        require(contractBalanceEth > ethFee, "not enough ETH to pay lock fees");
        uint256 liquidityEthAmount = contractBalanceEth.sub(ethFee);

        // Get Uniswap router contract
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        uniswapV2Router = _uniswapV2Router;
        // Allow the router to spend contract tokens
        _approve(address(this), address(uniswapV2Router), _tTotal);
        // Create the pair using the Uniswap router
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        // Add the ETH liquidity (contract balance minus the fees required to lock the LP tokens)
        uniswapV2Router.addLiquidityETH{value: liquidityEthAmount}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        // Allow the router to transfer LP tokens
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        // Get UniswapV2Locker contract
        uniswapV2Locker = IUniswapV2Locker(UNISWAP_LOCKER_ADDRESS);
        // Allow the locker to transfer LP tokens
        IERC20(uniswapV2Pair).approve(UNISWAP_LOCKER_ADDRESS, type(uint).max);
        // Get the number of LP tokens
        uint256 lpAmount = IERC20(uniswapV2Pair).balanceOf(owner());
        // Unlock date is set to now + the lock period
        uint256 unlockDate = block.timestamp.add(LOCK_PERIOD);
        address payable referral = payable(LOCK_REFERRAL_ADDRESS);
        // Set the withdrawer to the owner address
        address payable withdrawer = payable(owner());
        // Lock LP tokens
        uniswapV2Locker.lockLPToken{value:ethFee}(uniswapV2Pair, lpAmount, unlockDate, referral, true, withdrawer);

        // Open trading with the right parameters
        swapEnabled = true;
        cooldownEnabled = true;
        setMaxTxPercent(15);
        tradingOpen = true;

        // And finally renounce the ownership of the contract
        renounceOwnership();
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen,"trading is already open");
        uint256 contractBalanceEth = address(this).balance;
        // Get Uniswap router contract
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        uniswapV2Router = _uniswapV2Router;
        // Allow the router to spend contract tokens
        _approve(address(this), address(uniswapV2Router), _tTotal);
        // Create the pair using the Uniswap router
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        // Add the ETH liquidity (contract balance minus the fees required to lock the LP tokens)
        uniswapV2Router.addLiquidityETH{value: contractBalanceEth}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        // Allow the router to transfer LP tokens
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        // Open trading with the right parameters
        swapEnabled = true;
        cooldownEnabled = true;
        setMaxTxPercent(15);
        tradingOpen = true;
        renounceOwnership();
    }

    function getFees() public view returns(IUniswapV2Locker.FeeStruct memory){
        return IUniswapV2Locker(UNISWAP_LOCKER_ADDRESS).gFees();
    }


    function setBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBot(address notbot) public onlyOwner {
        bots[notbot] = false;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        _transferStandard(sender, recipient, amount);
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function manualswap() external {
        require(msg.sender == _FeeAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() external {
        require(msg.sender == _FeeAddress);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }


    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _taxFee, _teamFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 TeamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {
        require(maxTxPercent > 0, "Amount must be greater than 0");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit MaxTxAmountUpdated(_maxTxAmount);
    }

    receive() external payable {}

    fallback() external payable {}

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
    * @notice Withdraw the specified amount if possible.
    */
    function withdraw()
        public
        nonReentrant
        onlyOwner{
        uint256 contractBalance = address(this).balance;
        address payable ownerWallet = payable(owner());
        bool success = ownerWallet.send(contractBalance);
        require(success, "withdraw failed.");
    }

    function setLockFees(uint256 newLockFees) external onlyOwner{
        lockFees = newLockFees;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


// contracts/UniswapInterfaces.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.6;







// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}