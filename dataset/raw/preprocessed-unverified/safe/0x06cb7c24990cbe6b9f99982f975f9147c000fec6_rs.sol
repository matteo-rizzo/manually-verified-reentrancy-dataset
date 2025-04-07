/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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
 * @dev Collection of functions related to the address type
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
















contract DSMath {
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }
}

contract Helpers is DSMath {
    using SafeERC20 for IERC20;

    address constant internal instaIndex = 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;
    address constant internal oldInstaPool = 0x1879BEE186BFfBA9A8b1cAD8181bBFb218A5Aa61;
    
    address constant internal comptrollerAddr = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address constant internal ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant internal cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    mapping (address => bool) public isTknAllowed;
    mapping (address => address) public tknToCTkn;

    mapping (address => uint) public borrowedToken;
    address[] public tokensAllowed;

    bool public checkOldPool = true;

    IndexInterface indexContract = IndexInterface(instaIndex);
    ListInterface listContract = ListInterface(indexContract.list());
    CheckInterface oldInstaPoolContract = CheckInterface(oldInstaPool);

    /**
     * FOR SECURITY PURPOSE
     * only Smart DEFI Account can access the liquidity pool contract
     */
    modifier isDSA {
        uint64 id = listContract.accountID(msg.sender);
        require(id != 0, "not-dsa-id");
        require(indexContract.isClone(AccountInterface(msg.sender).version(), msg.sender), "not-dsa-clone");
        _;
    }

    function tokenBal(address token) internal view returns (uint _bal) {
        _bal = token == ethAddr ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    function _transfer(address token, uint _amt) internal {
        token == ethAddr ?
            msg.sender.transfer(_amt) :
            IERC20(token).safeTransfer(msg.sender, _amt);
    }
}


contract CompoundResolver is Helpers {

    function borrowAndSend(address[] memory tokens, uint[] memory tknAmt) internal {
        if (tokens.length > 0) {
            for (uint i = 0; i < tokens.length; i++) {
                address token = tokens[i];
                address cToken = tknToCTkn[token];
                require(isTknAllowed[token], "token-not-listed");
                if (cToken != address(0) && tknAmt[i] > 0) {
                    require(CTokenInterface(cToken).borrow(tknAmt[i]) == 0, "borrow-failed");
                    borrowedToken[token] += tknAmt[i];
                    _transfer(token, tknAmt[i]);
                }
            }
        }
    }

    function payback(address[] memory tokens) internal {
        if (tokens.length > 0) {
            for (uint i = 0; i < tokens.length; i++) {
                address token = tokens[i];
                address cToken = tknToCTkn[token];
                if (cToken != address(0)) {
                    CTokenInterface ctknContract = CTokenInterface(cToken);
                    if(token != ethAddr) {
                        require(ctknContract.repayBorrow(uint(-1)) == 0, "payback-failed");
                    } else {
                        CETHInterface(cToken).repayBorrow.value(ctknContract.borrowBalanceCurrent(address(this)))();
                        require(ctknContract.borrowBalanceCurrent(address(this)) == 0, "ETH-flashloan-not-paid");
                    }
                    delete borrowedToken[token];
                }
            }
        }
    }
}

contract AccessLiquidity is CompoundResolver {
    event LogPoolBorrow(address indexed user, address[] tknAddr, uint[] amt);
    event LogPoolPayback(address indexed user, address[] tknAddr);

    /**
     * @dev borrow tokens and use them on DSA.
     * @param tokens Array of tokens.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amounts Array of tokens amount.
    */
    function accessLiquidity(address[] calldata tokens, uint[] calldata amounts) external isDSA {
        require(tokens.length == amounts.length, "length-not-equal");
        borrowAndSend(tokens, amounts);
        emit LogPoolBorrow(
            msg.sender,
            tokens,
            amounts
        );
    }
   
    /**
     * @dev Payback borrowed tokens.
     * @param tokens Array of tokens.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
    */
    function returnLiquidity(address[] calldata tokens) external payable isDSA {
        payback(tokens);
        emit LogPoolPayback(msg.sender, tokens);
    }
    
    function isOk() public view returns(bool ok) {
        ok = true;
        for (uint i = 0; i < tokensAllowed.length; i++) {
            uint tknBorrowed = borrowedToken[tokensAllowed[i]];
            if(tknBorrowed > 0){
                ok = false;
                break;
            }
        }
        if(checkOldPool && ok) {
            bool isOldPoolOk = oldInstaPoolContract.isOk();
            ok = isOldPoolOk;
        }
    }
}


contract ProvideLiquidity is  AccessLiquidity {
    event LogDeposit(address indexed user, address indexed token, uint amount, uint cAmount);
    event LogWithdraw(address indexed user, address indexed token, uint amount, uint cAmount);

    mapping (address => mapping (address => uint)) public liquidityBalance;

    /**
     * @dev Deposit Liquidity.
     * @param token token address.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount.
    */
    function deposit(address token, uint amt) external payable returns (uint _amt) {
        require(isTknAllowed[token], "token-not-listed");
        require(amt > 0 || msg.value > 0, "amt-not-valid");

        if (msg.value > 0) require(token == ethAddr, "not-eth-addr");

        address cErc20 = tknToCTkn[token];
        uint initalBal = tokenBal(cErc20);
        if (token == ethAddr) {
            _amt = msg.value;
            CETHInterface(cErc20).mint.value(_amt)();
        } else {
            _amt = amt == (uint(-1)) ? IERC20(token).balanceOf(msg.sender) : amt;
            IERC20(token).safeTransferFrom(msg.sender, address(this), _amt);
            require(CTokenInterface(cErc20).mint(_amt) == 0, "mint-failed");
        }
        uint finalBal = tokenBal(cErc20);
        uint ctokenAmt = sub(finalBal, initalBal);

        liquidityBalance[token][msg.sender] += ctokenAmt;

        emit LogDeposit(msg.sender, token, _amt, ctokenAmt);
    }

    
    /**
     * @dev Withdraw Liquidity.
     * @param token token address.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount.
    */
    function withdraw(address token, uint amt) external returns (uint _amt) {
        uint _userLiq = liquidityBalance[token][msg.sender];
        require(_userLiq > 0, "nothing-to-withdraw");

        uint _cAmt;

        address ctoken = tknToCTkn[token];
        if (amt == uint(-1)) {
            uint initknBal = tokenBal(token);
            require(CTokenInterface(ctoken).redeem(_userLiq) == 0, "redeem-failed");
            uint finTknBal = tokenBal(token);
            _cAmt = _userLiq;
            delete liquidityBalance[token][msg.sender];
            _amt = sub(finTknBal, initknBal);
        } else {
            uint iniCtknBal = tokenBal(ctoken);
            require(CTokenInterface(ctoken).redeemUnderlying(amt) == 0, "redeemUnderlying-failed");
            uint finCtknBal = tokenBal(ctoken);
            _cAmt = sub(iniCtknBal, finCtknBal);
            require(_cAmt <= _userLiq, "not-enough-to-withdraw");
            liquidityBalance[token][msg.sender] -= _cAmt;
            _amt = amt;
        }
        
        _transfer(token, _amt);
       
        emit LogWithdraw(msg.sender, token, _amt, _cAmt);
    }

}


contract Controllers is ProvideLiquidity {
    event LogEnterMarket(address[] token, address[] ctoken);
    event LogExitMarket(address indexed token, address indexed ctoken);

    event LogWithdrawMaster(address indexed user, address indexed token, uint amount);

    modifier isMaster {
        require(msg.sender == indexContract.master(), "not-master");
        _;
    }

    function switchOldPoolCheck() external isMaster {
        checkOldPool = !checkOldPool;
    }

    function _enterMarket(address[] memory cTknAddrs) internal {
        ComptrollerInterface(comptrollerAddr).enterMarkets(cTknAddrs);
        address[] memory tknAddrs = new address[](cTknAddrs.length);
        for (uint i = 0; i < cTknAddrs.length; i++) {
            if (cTknAddrs[i] != cEth) {
                tknAddrs[i] = CTokenInterface(cTknAddrs[i]).underlying();
                IERC20(tknAddrs[i]).safeApprove(cTknAddrs[i], uint(-1));
            } else {
                tknAddrs[i] = ethAddr;
            }
            tknToCTkn[tknAddrs[i]] = cTknAddrs[i];
            require(!isTknAllowed[tknAddrs[i]], "tkn-already-allowed");
            isTknAllowed[tknAddrs[i]] = true;
            tokensAllowed.push(tknAddrs[i]);
        }
        emit LogEnterMarket(tknAddrs, cTknAddrs);
    }

    /**
     * @dev Enter compound market to enable borrowing.
     * @param cTknAddrs Array Ctoken addresses.
    */
    function enterMarket(address[] calldata cTknAddrs) external isMaster {
        _enterMarket(cTknAddrs);
    }

    /**
     * @dev Exit compound market to disable borrowing.
     * @param cTkn Ctoken address.
    */
    function exitMarket(address cTkn) external isMaster {
        address tkn;
        if (cTkn != cEth) {
            tkn = CTokenInterface(cTkn).underlying();
            IERC20(tkn).safeApprove(cTkn, 0);
        } else {
            tkn = ethAddr;
        }
        require(isTknAllowed[tkn], "tkn-not-allowed");

        ComptrollerInterface(comptrollerAddr).exitMarket(cTkn);

        delete isTknAllowed[tkn];

        bool isFound = false;
        uint _length = tokensAllowed.length;
        uint _id;
        for (uint i = 0; i < _length; i++) {
            if (tkn == tokensAllowed[i]) {
                isFound = true;
                _id = i;
                break;
            }
        }
        if (isFound) {
            address _last = tokensAllowed[_length - 1];
            tokensAllowed[_length - 1] = tokensAllowed[_id];
            tokensAllowed[_id] = _last;
            tokensAllowed.pop();
        }
        emit LogExitMarket(tkn, cTkn);
    }

    /**
     * @dev Withdraw Liquidity.
     * @param token token address.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount.
    */
    function withdrawMaster(address token, uint amt) external isMaster {
        _transfer(token, amt);
        emit LogWithdrawMaster(msg.sender, token, amt);
    }

    function spell(address _target, bytes calldata _data) external isMaster {
        require(_target != address(0), "target-invalid");
        bytes memory _callData = _data;
        assembly {
            let succeeded := delegatecall(gas(), _target, add(_callData, 0x20), mload(_callData), 0, 0)

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    let size := returndatasize()
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
    }

}


contract InstaPool is Controllers {
    constructor (address[] memory ctkns) public {
        _enterMarket(ctkns);
    }

    receive() external payable {}
}