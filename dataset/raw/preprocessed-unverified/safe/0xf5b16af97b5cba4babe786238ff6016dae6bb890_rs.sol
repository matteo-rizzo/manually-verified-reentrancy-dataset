pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

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

























contract DydxFlashloanBase {
    using SafeMath for uint256;

    // -- Internal Helper functions -- //

    function _getMarketIdFromTokenAddress(address _solo, address token)
        internal
        view
        returns (uint256)
    {
        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("No marketId found for provided token");
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {
        return Account.Info({owner: address(this), number: 1});
    }

    function _getWithdrawAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }
}


/**
 * @title ICallee
 * @author dYdX
 *
 * Interface that Callees for Solo must implement in order to ingest data.
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



contract Helper {
    struct CastData {
        address dsa;
        address token;
        uint amount;
        address[] targets;
        bytes[] data;
    }

    function encodeDsaAddr(address dsa, bytes memory data) internal pure returns (bytes memory _data) {
        CastData memory cd;
        (cd.token, cd.amount, cd.targets, cd.data) = abi.decode(data, (address, uint256, address[], bytes[]));
        _data = abi.encode(dsa, cd.token, cd.amount, cd.targets, cd.data);
    }
}

contract DydxFlashloaner is ICallee, DydxFlashloanBase, DSMath, Helper {
    using SafeERC20 for IERC20;

    address public constant soloAddr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event LogDydxFlashLoan(
        address indexed sender,
        address indexed token,
        uint amount
    );

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public override {
        require(sender == address(this), "not-same-sender");
        CastData memory cd;
        (cd.dsa, cd.token, cd.amount, cd.targets, cd.data) = abi.decode(
            data,
            (address, address, uint256, address[], bytes[])
        );

        IERC20 tokenContract;
        if (cd.token == ethAddr) {
            tokenContract = IERC20(wethAddr);
            tokenContract.approve(wethAddr, cd.amount);
            tokenContract.withdraw(cd.amount);
            payable(cd.dsa).transfer(cd.amount);
        } else {
            tokenContract = IERC20(cd.token);
            tokenContract.safeTransfer(cd.dsa, cd.amount);
        }

        DSAInterface(cd.dsa).cast(cd.targets, cd.data, 0xB7fA44c2E964B6EB24893f7082Ecc08c8d0c0F87);

        if (cd.token == ethAddr) {
            tokenContract.deposit.value(cd.amount)();
        }

    }

    function initiateFlashLoan(address _token, uint256 _amount, bytes calldata data) external {
        ISoloMargin solo = ISoloMargin(soloAddr);

        uint256 marketId = _getMarketIdFromTokenAddress(soloAddr, _token);

        IERC20(_token).approve(soloAddr, _amount + 2);

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, _amount);
        operations[1] = _getCallAction(encodeDsaAddr(msg.sender, data));
        operations[2] = _getDepositAction(marketId, _amount + 2);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        IERC20 _tokenContract = IERC20(_token);
        uint iniBal = _tokenContract.balanceOf(address(this));

        solo.operate(accountInfos, operations);

        uint finBal = _tokenContract.balanceOf(address(this));
        require(sub(iniBal, finBal) < 5, "amount-paid-less");
    }

}

contract InstaDydxFlashLoan is DydxFlashloaner {

    receive() external payable {}
}