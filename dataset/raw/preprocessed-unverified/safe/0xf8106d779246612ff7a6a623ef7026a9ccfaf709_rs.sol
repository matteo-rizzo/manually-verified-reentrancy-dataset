/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


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






contract YearnV1EarnKeep3rV2 {
    using SafeMath for uint;
    
    uint constant public THRESHOLD = 500;
    uint constant public BASE = 10000;
    
    IYERC20[] internal _tokens;
    
    constructor() public {
        _tokens.push(IYERC20(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e));
        _tokens.push(IYERC20(0x83f798e925BcD4017Eb265844FDDAbb448f1707D));
        _tokens.push(IYERC20(0x73a052500105205d34Daf004eAb301916DA8190f));
        _tokens.push(IYERC20(0xC2cB1040220768554cf699b0d863A3cd4324ce32));
        _tokens.push(IYERC20(0x26EA744E5B887E5205727f55dFBE8685e3b21951));
        _tokens.push(IYERC20(0xE6354ed5bC4b393a5Aad09f21c46E101e692d447));
        _tokens.push(IYERC20(0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE));
        _tokens.push(IYERC20(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01));
    }
    
    function tokens() external view returns (IYERC20[] memory) {
        return _tokens;
    }
    
    modifier upkeep() {
        require(KP3R.isKeeper(msg.sender), "::isKeeper: keeper is not registered");
        _;
        KP3R.worked(msg.sender);
    }
    
    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    
    function workable() public view returns (bool) {
        for (uint i = 0; i < _tokens.length; i++) {
            if (shouldRebalance(_tokens[i])) {
                return true;
            }
        }
        return false;
    }
    
    function shouldRebalance(IYERC20 _token) public view returns (bool) {
        uint _total = _token.calcPoolValueInToken();
        uint _available = IERC20(_token.token()).balanceOf(address(_token));
        return _available >= _total.mul(THRESHOLD).div(BASE);
    }
    
    function work() external upkeep {
        require(workable(), "YearnV1EarnKeep3r::work: !workable()");
        for (uint i = 0; i < _tokens.length; i++) {
            if (shouldRebalance(_tokens[i])) {
                _tokens[i].rebalance();
            }
        }
    }
}