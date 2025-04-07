/**
 *Submitted for verification at Etherscan.io on 2021-04-25
*/

// Sources flattened with hardhat v2.1.1 https://hardhat.org
pragma solidity ^0.7.0;

// File @openzeppelin/contracts/math/[emailÂ protected]

// SPDX-License-Identifier: MIT

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



// File contracts/mainnet/common/math.sol

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

  function toInt(uint x) internal pure returns (int y) {
    y = int(x);
    require(y >= 0, "int-overflow");
  }

  function toRad(uint wad) internal pure returns (uint rad) {
    rad = mul(wad, 10 ** 27);
  }

}


// File contracts/mainnet/common/interfaces.sol










// File contracts/mainnet/common/stores.sol

abstract contract Stores {

  /**
   * @dev Return ethereum address
   */
  address constant internal ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /**
   * @dev Return Wrapped ETH address
   */
  address constant internal wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  /**
   * @dev Return memory variable address
   */
  MemoryInterface constant internal instaMemory = MemoryInterface(0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F);

  /**
   * @dev Return InstaDApp Mapping Addresses
   */
  InstaMapping constant internal instaMapping = InstaMapping(0xe81F70Cc7C0D46e12d70efc60607F16bbD617E88);

  /**
   * @dev Get Uint value from InstaMemory Contract.
   */
  function getUint(uint getId, uint val) internal returns (uint returnVal) {
    returnVal = getId == 0 ? val : instaMemory.getUint(getId);
  }

  /**
  * @dev Set Uint value in InstaMemory Contract.
  */
  function setUint(uint setId, uint val) virtual internal {
    if (setId != 0) instaMemory.setUint(setId, val);
  }

}


// File contracts/mainnet/common/basic.sol

abstract contract Basic is DSMath, Stores {

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function getTokenBal(TokenInterface token) internal view returns(uint _amt) {
        _amt = address(token) == ethAddr ? address(this).balance : token.balanceOf(address(this));
    }

    function getTokensDec(TokenInterface buyAddr, TokenInterface sellAddr) internal view returns(uint buyDec, uint sellDec) {
        buyDec = address(buyAddr) == ethAddr ?  18 : buyAddr.decimals();
        sellDec = address(sellAddr) == ethAddr ?  18 : sellAddr.decimals();
    }

    function encodeEvent(string memory eventName, bytes memory eventParam) internal pure returns (bytes memory) {
        return abi.encode(eventName, eventParam);
    }

    function changeEthAddress(address buy, address sell) internal pure returns(TokenInterface _buy, TokenInterface _sell){
        _buy = buy == ethAddr ? TokenInterface(wethAddr) : TokenInterface(buy);
        _sell = sell == ethAddr ? TokenInterface(wethAddr) : TokenInterface(sell);
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {
        if(isEth) token.deposit{value: amount}();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {
       if(isEth) {
            token.approve(address(token), amount);
            token.withdraw(amount);
        }
    }
}


// File contracts/mainnet/connectors/aave/staked-aave/interface.sol
interface AaveInterface is TokenInterface {
    function delegate(address delegatee) external;
    function delegateByType(address delegatee, uint8 delegationType) external;
    function getDelegateeByType(address delegator, uint8 delegationType) external view returns (address);
}

interface StakedAaveInterface is AaveInterface {
    function stake(address onBehalfOf, uint256 amount) external;
    function redeem(address to, uint256 amount) external;
    function cooldown() external;
    function claimRewards(address to, uint256 amount) external;
}


// File contracts/mainnet/connectors/aave/staked-aave/helpers.sol

abstract contract Helpers is DSMath, Basic {

    enum DelegationType {VOTING_POWER, PROPOSITION_POWER, BOTH}

    /**
     * @dev Staked Aave Token
    */
    StakedAaveInterface internal constant stkAave = StakedAaveInterface(0x4da27a545c0c5B758a6BA100e3a049001de870f5);

    /**
     * @dev Aave Token
    */
    AaveInterface internal constant aave = AaveInterface(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);

    function _delegateAave(address _delegatee, DelegationType _type) internal {
        if (_type == DelegationType.BOTH) {
            require(
                aave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );
            require(
                aave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            aave.delegate(_delegatee);
        } else if (_type == DelegationType.VOTING_POWER) {
            require(
                aave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );

            aave.delegateByType(_delegatee, 0);
        } else {
            require(
                aave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            aave.delegateByType(_delegatee, 1);
        }
    }

    function _delegateStakedAave(address _delegatee, DelegationType _type) internal {
        if (_type == DelegationType.BOTH) {
            require(
                stkAave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );
            require(
                stkAave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            stkAave.delegate(_delegatee);
        } else if (_type == DelegationType.VOTING_POWER) {
            require(
                stkAave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );

            stkAave.delegateByType(_delegatee, 0);
        } else {
            require(
                stkAave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            stkAave.delegateByType(_delegatee, 1);
        }
    }
}


// File contracts/mainnet/connectors/aave/staked-aave/events.sol

contract Events {
    event LogClaim(uint amt, uint getId, uint setId);
    event LogStake(uint amt, uint getId, uint setId);
    event LogCooldown();
    event LogRedeem(uint amt, uint getId, uint setId);
    event LogDelegate(
        address delegatee,
        bool delegateAave,
        bool delegateStkAave,
        uint8 aaveDelegationType,
        uint8 stkAaveDelegationType
    );
}


// File contracts/mainnet/connectors/aave/staked-aave/main.sol

abstract contract AaveResolver is Helpers, Events {

    /**
     * @dev Claim Accrued AAVE.
     * @notice Claim Accrued AAVE Token rewards.
     * @param amount The amount of rewards to claim. uint(-1) for max.
     * @param getId ID to retrieve amount.
     * @param setId ID stores the amount of tokens claimed.
    */
    function claim(
        uint256 amount,
        uint256 getId,
        uint256 setId
    ) external payable {
        uint _amt = getUint(getId, amount);

        uint intialBal = aave.balanceOf(address(this));
        stkAave.claimRewards(address(this), _amt);
        uint finalBal = aave.balanceOf(address(this));
        _amt = sub(finalBal, intialBal);

        setUint(setId, _amt);

        emit LogClaim(_amt, getId, setId);
    }

    /**
     * @dev Stake AAVE Token
     * @notice Stake AAVE Token in Aave security module
     * @param amount The amount of AAVE to stake. uint(-1) for max.
     * @param getId ID to retrieve amount.
     * @param setId ID stores the amount of tokens staked.
    */
    function stake(
        uint256 amount,
        uint256 getId,
        uint256 setId
    ) external payable {
        uint _amt = getUint(getId, amount);

        _amt = _amt == uint(-1) ? aave.balanceOf(address(this)) : _amt;
        stkAave.stake(address(this), _amt);

        setUint(setId, _amt);

        emit LogStake(_amt, getId, setId);
    }

    /**
     * @dev Initiate cooldown to unstake
     * @notice Initiate cooldown to unstake from Aave security module
    */
    function cooldown() external payable {
        require(stkAave.balanceOf(address(this)) > 0, "no-staking");

        stkAave.cooldown();

        emit LogCooldown();
    }

    /**
     * @dev Redeem tokens from Staked AAVE
     * @notice Redeem AAVE tokens from Staked AAVE after cooldown period is over
     * @param amount The amount of AAVE to redeem. uint(-1) for max.
     * @param getId ID to retrieve amount.
     * @param setId ID stores the amount of tokens redeemed.
    */
    function redeem(
        uint256 amount,
        uint256 getId,
        uint256 setId
    ) external payable {
        uint _amt = getUint(getId, amount);

        uint intialBal = aave.balanceOf(address(this));
        stkAave.redeem(address(this), _amt);
        uint finalBal = aave.balanceOf(address(this));
        _amt = sub(finalBal, intialBal);

        setUint(setId, _amt);

        emit LogRedeem(_amt, getId, setId);
    }

    /**
     * @dev Delegate AAVE or stkAAVE
     * @notice Delegate AAVE or stkAAVE
     * @param delegatee The address of the delegatee
     * @param delegateAave Whether to delegate Aave balance
     * @param delegateStkAave Whether to delegate Staked Aave balance
     * @param aaveDelegationType Aave delegation type. Voting power - 0, Proposition power - 1, Both - 2
     * @param stkAaveDelegationType Staked Aave delegation type. Values similar to aaveDelegationType
    */
    function delegate(
        address delegatee,
        bool delegateAave,
        bool delegateStkAave,
        uint8 aaveDelegationType,
        uint8 stkAaveDelegationType
    ) external payable {
        require(delegateAave || delegateStkAave, "invalid-delegate");
        require(delegatee != address(0), "invalid-delegatee");

        if (delegateAave) {
            _delegateAave(delegatee, Helpers.DelegationType(aaveDelegationType));
        }

        if (delegateStkAave) {
            _delegateStakedAave(delegatee, Helpers.DelegationType(stkAaveDelegationType));
        }

        emit LogDelegate(delegatee, delegateAave, delegateStkAave, aaveDelegationType, stkAaveDelegationType);
    }
}


contract ConnectAaveStake is AaveResolver {
    /**
    * @dev Connector ID and Type.
    */
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 93);
    }

    string public constant name = "Aave-Stake-v1";
}