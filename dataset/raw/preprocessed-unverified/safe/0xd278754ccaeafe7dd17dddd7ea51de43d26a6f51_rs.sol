/**
 *Submitted for verification at Etherscan.io on 2021-04-13
*/

// SPDX-License-Identifier: MIT
/*
A simple gauge contract to measure the amount of tokens locked, and reward users in a different token.

This Gauge works for a "sharesOf" based rebalance token.
*/

pragma solidity ^0.6.11;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */


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

    constructor () internal {
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract GaugeD2_ETH is IERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address payable public governance = 0xdD7A75CC6c04031629f13848Bc0D07e89C3961Be; // STACK DAO Council Multisig
    address public constant acceptToken = 0x70e51DFc7A9FC391995C2B2f027BC49D4fe01577; // stackToken ETH rebase token

    address public constant STACK = 0xe0955F26515d22E347B17669993FCeFcc73c3a0a; // STACK DAO Token

    uint256 public emissionRate = 16806186020950591;

    uint256 public depositedShares;

    uint256 public constant startBlock = 12234861;
    uint256 public endBlock = startBlock + 1190038;

    uint256 public lastBlock; // last block the distribution has ran
    uint256 public tokensAccrued; // tokens to distribute per weight scaled by 1e18

    struct DepositState {
        uint256 userShares;
        uint256 tokensAccrued;
    }

    mapping(address => DepositState) public shares;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event STACKClaimed(address indexed to, uint256 amount);
    // emit mint/burn on deposit/withdraw
    event Transfer(address indexed from, address indexed to, uint256 value);
    // never emitted, only included here to align with ERC20 spec.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
    }

    function setGovernance(address payable _new) external {
        require(msg.sender == governance);
        governance = _new;
    }

    function setEmissionRate(uint256 _new) external {
        require(msg.sender == governance, "GAUGED2: !governance");
        _kick(); // catch up the contract to the current block for old rate
        emissionRate = _new;
    }

    function setEndBlock(uint256 _block) external {
        require(msg.sender == governance, "GAUGED2: !governance");
        require(block.number <= endBlock, "GAUGED2: distribution already done, must start another");
        require(block.number <= _block, "GAUGED2: can't set endBlock to past block");
        
        endBlock = _block;
    }

    /////////// NOTE: Our gauges now implement mock ERC20 functionality in order to interact nicer with block explorers...
    function name() external view returns (string memory){
        return string(abi.encodePacked("gauge-", IFarmTokenV1(acceptToken).name()));
    }
    
    function symbol() external view returns (string memory){
        return string(abi.encodePacked("gauge-", IFarmTokenV1(acceptToken).symbol()));
    }

    function decimals() external view returns (uint8){
        return IFarmTokenV1(acceptToken).decimals();
    }

    function totalSupply() external override view returns (uint256){
        return IFarmTokenV1(acceptToken).getUnderlyingForShares(depositedShares);
    }

    function balanceOf(address _account) public override view returns (uint256){
        return IFarmTokenV1(acceptToken).getUnderlyingForShares(shares[_account].userShares);
    }

    // transfer tokens, not shares
    function transfer(address _recipient, uint256 _amount) external override returns (bool){
        // to squelch
        _recipient;
        _amount;
        revert("transfer not implemented. please withdraw first.");
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns (bool){
        // to squelch
        _sender;
        _recipient;
        _amount;
        revert("transferFrom not implemented. please withdraw first.");
    }

    // allow tokens, not shares
    function allowance(address _owner, address _spender) external override view returns (uint256){
        // to squelch
        _owner;
        _spender;
        return 0;
    }

    // approve tokens, not shares
    function approve(address _spender, uint256 _amount) external override returns (bool){
        // to squelch
        _spender;
        _amount;
        revert("approve not implemented. please withdraw first.");
    }
    ////////// END MOCK ERC20 FUNCTIONALITY //////////

    function deposit(uint256 _amount) nonReentrant external {
        require(block.number <= endBlock, "GAUGED2: distribution over");

        _claimSTACK(msg.sender);

        // trusted contracts
        IERC20(acceptToken).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _sharesFor = IFarmTokenV1(acceptToken).getSharesForUnderlying(_amount);

        DepositState memory _state = shares[msg.sender];

        _state.userShares = _state.userShares.add(_sharesFor);
        depositedShares = depositedShares.add(_sharesFor);

        emit Deposit(msg.sender, _amount);
        emit Transfer(address(0), msg.sender, _amount);
        shares[msg.sender] = _state;
    }

    function withdraw(uint256 _amount) nonReentrant external {
        _claimSTACK(msg.sender);

        DepositState memory _state = shares[msg.sender];
        uint256 _sharesFor = IFarmTokenV1(acceptToken).getSharesForUnderlying(_amount);

        require(_sharesFor <= _state.userShares, "GAUGED2: insufficient balance");

        _state.userShares = _state.userShares.sub(_sharesFor);
        depositedShares = depositedShares.sub(_sharesFor);

        emit Withdraw(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
        shares[msg.sender] = _state;

        IERC20(acceptToken).safeTransfer(msg.sender, _amount);
    }

    function claimSTACK() nonReentrant external returns (uint256) {
        return _claimSTACK(msg.sender);
    }

    function _claimSTACK(address _user) internal returns (uint256) {
        _kick();

        DepositState memory _state = shares[_user];
        if (_state.tokensAccrued == tokensAccrued){ // user doesn't have any accrued tokens
            return 0;
        }
        else {
            uint256 _tokensAccruedDiff = tokensAccrued.sub(_state.tokensAccrued);
            uint256 _tokensGive = _tokensAccruedDiff.mul(_state.userShares).div(1e18);

            _state.tokensAccrued = tokensAccrued;
            shares[_user] = _state;

            // if the guage has enough tokens to grant the user, then send their tokens
            // otherwise, don't fail, just log STACK claimed, and a reimbursement can be done via chain events
            if (IERC20(STACK).balanceOf(address(this)) >= _tokensGive){
                IERC20(STACK).safeTransfer(_user, _tokensGive);
            }

            // log event
            emit STACKClaimed(_user, _tokensGive);

            return _tokensGive;
        }
    }

    function _kick() internal {
        uint256 _totalDeposited = depositedShares;
        // if there are no tokens committed, then don't kick.
        if (_totalDeposited == 0){
            return;
        }
        // already done for this block || already did all blocks || not started yet
        if (lastBlock == block.number || lastBlock >= endBlock || block.number < startBlock){
            return;
        }

        uint256 _deltaBlock;
        // edge case where kick was not called for entire period of blocks.
        if (lastBlock <= startBlock && block.number >= endBlock){
            _deltaBlock = endBlock.sub(startBlock);
        }
        // where block.number is past the endBlock
        else if (block.number >= endBlock){
            _deltaBlock = endBlock.sub(lastBlock);
        }
        // where last block is before start
        else if (lastBlock <= startBlock){
            _deltaBlock = block.number.sub(startBlock);
        }
        // normal case, where we are in the middle of the distribution
        else {
            _deltaBlock = block.number.sub(lastBlock);
        }

        uint256 _tokensToAccrue = _deltaBlock.mul(emissionRate);
        tokensAccrued = tokensAccrued.add(_tokensToAccrue.mul(1e18).div(_totalDeposited));

        // if not allowed to mint it's just like the emission rate = 0. So just update the lastBlock.
        // always update last block 
        lastBlock = block.number;
    }

    // decentralized rescue function for any stuck tokens, will return to governance
    function rescue(address _token, uint256 _amount) nonReentrant external {
        require(msg.sender == governance, "GAUGED2: !governance");

        if (_token != address(0)){
            IERC20(_token).safeTransfer(governance, _amount);
        }
        else { // if _tokenContract is 0x0, then escape ETH
            governance.transfer(_amount);
        }
    }
}