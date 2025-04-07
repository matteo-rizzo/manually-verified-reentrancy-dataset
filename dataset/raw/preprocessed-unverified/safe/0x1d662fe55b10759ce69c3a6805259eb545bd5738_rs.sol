/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

pragma solidity ^0.6.0;







contract Stores {

  /**
   * @dev Return ethereum address
   */
  function getEthAddr() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
  }

  /**
   * @dev Return memory variable address
   */
  function getMemoryAddr() internal pure returns (address) {
    return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
  }

  /**
   * @dev Return InstaEvent Address.
   */
  function getEventAddr() internal pure returns (address) {
    return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; // InstaEvent Address
  }

  /**
   * @dev Get Uint value from InstaMemory Contract.
   */
  function getUint(uint getId, uint val) internal returns (uint returnVal) {
    returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
  }

  /**
  * @dev Set Uint value in InstaMemory Contract.
  */
  function setUint(uint setId, uint val) virtual internal {
    if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
  }

  /**
  * @dev emit event on event contract
  */
  function emitEvent(bytes32 eventCode, bytes memory eventData) virtual internal {
    (uint model, uint id) = connectorID();
    EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
  }

  /**
  * @dev Connector Details.
  */
  function connectorID() public pure returns(uint model, uint id) {
    (model, id) = (1, 65);
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


contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

}









contract AaveHelpers is DSMath, Stores {

    /**
     * @dev get Aave Provider
    */
    function getAaveProvider() internal pure returns (AaveProviderInterface) {
        return AaveProviderInterface(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8); //mainnet
        // return AaveProviderInterface(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5); //kovan
    }

    /**
     * @dev get Referral Code
    */
    function getReferralCode() internal pure returns (uint16) {
        return 3228;
    }

    function getIsColl(AaveInterface aave, address token) internal view returns (bool isCol) {
        (, , , , , , , , , isCol) = aave.getUserReserveData(token, address(this));
    }

    function getWithdrawBalance(address token) internal view returns (uint bal) {
        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());
        (bal, , , , , , , , , ) = aave.getUserReserveData(token, address(this));
    }

    function getPaybackBalance(AaveInterface aave, address token) internal view returns (uint bal, uint fee) {
        (, bal, , , , , fee, , , ) = aave.getUserReserveData(token, address(this));
    }
}


contract BasicResolver is AaveHelpers {
    event LogDeposit(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogWithdraw(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogBorrow(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogPayback(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogEnableCollateral(address[] tokens);

    /**
     * @dev Deposit ETH/ERC20_Token.
     * @param token token address to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount to deposit.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function deposit(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);
        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());

        uint ethAmt;
        if (token == getEthAddr()) {
            _amt = _amt == uint(-1) ? address(this).balance : _amt;
            ethAmt = _amt;
        } else {
            TokenInterface tokenContract = TokenInterface(token);
            _amt = _amt == uint(-1) ? tokenContract.balanceOf(address(this)) : _amt;
            tokenContract.approve(getAaveProvider().getLendingPoolCore(), _amt);
        }

        aave.deposit.value(ethAmt)(token, _amt, getReferralCode());

        if (!getIsColl(aave, token)) aave.setUserUseReserveAsCollateral(token, true);

        setUint(setId, _amt);

        emit LogDeposit(token, _amt, getId, setId);
    }

    /**
     * @dev Withdraw ETH/ERC20_Token.
     * @param token token address to withdraw.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount to withdraw.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function withdraw(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);
        AaveCoreInterface aaveCore = AaveCoreInterface(getAaveProvider().getLendingPoolCore());
        ATokenInterface atoken = ATokenInterface(aaveCore.getReserveATokenAddress(token));
        TokenInterface tokenContract = TokenInterface(token);

        uint initialBal = token == getEthAddr() ? address(this).balance : tokenContract.balanceOf(address(this));
        atoken.redeem(_amt);
        uint finalBal = token == getEthAddr() ? address(this).balance : tokenContract.balanceOf(address(this));

        _amt = sub(finalBal, initialBal);
        setUint(setId, _amt);

        emit LogWithdraw(token, _amt, getId, setId);
    }

    /**
     * @dev Borrow ETH/ERC20_Token.
     * @param token token address to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount to borrow.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function borrow(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);
        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());
        aave.borrow(token, _amt, 2, getReferralCode());
        setUint(setId, _amt);

        emit LogBorrow(token, _amt, getId, setId);
    }

    /**
     * @dev Payback borrowed ETH/ERC20_Token.
     * @param token token address to payback.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amount to payback.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function payback(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);
        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());

        if (_amt == uint(-1)) {
            uint fee;
            (_amt, fee) = getPaybackBalance(aave, token);
            _amt = add(_amt, fee);
        }
        uint ethAmt;
        if (token == getEthAddr()) {
            ethAmt = _amt;
        } else {
            TokenInterface(token).approve(getAaveProvider().getLendingPoolCore(), _amt);
        }

        aave.repay.value(ethAmt)(token, _amt, payable(address(this)));

        setUint(setId, _amt);

        emit LogPayback(token, _amt, getId, setId);
    }

    /**
     * @dev Enable collateral
     * @param tokens Array of tokens to enable collateral
    */
    function enableCollateral(address[] calldata tokens) external payable {
        uint _length = tokens.length;
        require(_length > 0, "0-tokens-not-allowed");

        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());

        for (uint i = 0; i < _length; i++) {
            address token = tokens[i];
            if (getWithdrawBalance(token) > 0 && !getIsColl(aave, token)) {
                aave.setUserUseReserveAsCollateral(token, true);
            }
        }

        emit LogEnableCollateral(tokens);
    }
}

contract ConnectAave is BasicResolver {
    string public name = "Aave-v1.1";
}