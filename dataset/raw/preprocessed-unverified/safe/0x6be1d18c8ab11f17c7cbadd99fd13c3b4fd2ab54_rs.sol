/**

 *Submitted for verification at Etherscan.io on 2019-05-28

*/



pragma solidity ^0.5.0;

















/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */







/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */







/**

 * Utility library of inline functions on addresses

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */











/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */









contract TokenSpender is Ownable {



    using SafeERC20 for IERC20;



    function claimTokens(IERC20 token, address who, address dest, uint256 amount) external onlyOwner {

        token.safeTransferFrom(who, dest, amount);

    }



}











contract AggregatedTokenSwap {



    using SafeERC20 for IERC20;

    using SafeMath for uint;

    using ExternalCall for address;



    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;



    TokenSpender public spender;

    IGST2 gasToken;

    address payable owner;

    uint fee; // 10000 => 100%, 1 => 0.01%



    event OneInchFeePaid(

        IERC20 indexed toToken,

        address indexed referrer,

        uint256 fee

    );



    modifier onlyOwner {

        require(

            msg.sender == owner,

            "Only owner can call this function."

        );

        _;

    }



    constructor(

        address payable _owner,

        IGST2 _gasToken,

        uint _fee

    )

    public

    {

        spender = new TokenSpender();

        owner = _owner;

        gasToken = _gasToken;

        fee = _fee;

    }



    function setFee(uint _fee) public onlyOwner {



        fee = _fee;

    }



    function aggregate(

        IERC20 fromToken,

        IERC20 toToken,

        uint tokensAmount,

        address[] memory callAddresses,

        bytes memory callDataConcat,

        uint[] memory starts,

        uint[] memory values,

        uint mintGasPrice,

        uint minTokensAmount,

        address payable referrer

    )

    public

    payable

    returns (uint returnAmount)

    {

        returnAmount = gasleft();

        uint gasTokenBalance = gasToken.balanceOf(address(this));



        require(callAddresses.length + 1 == starts.length);



        if (address(fromToken) != ETH_ADDRESS) {



            spender.claimTokens(fromToken, msg.sender, address(this), tokensAmount);

        }



        for (uint i = 0; i < starts.length - 1; i++) {



            if (starts[i + 1] - starts[i] > 0) {



                if (

                    address(fromToken) != ETH_ADDRESS &&

                    fromToken.allowance(address(this), callAddresses[i]) == 0

                ) {



                    fromToken.safeApprove(callAddresses[i], uint256(- 1));

                }



                require(

                    callDataConcat[starts[i] + 0] != spender.claimTokens.selector[0] ||

                    callDataConcat[starts[i] + 1] != spender.claimTokens.selector[1] ||

                    callDataConcat[starts[i] + 2] != spender.claimTokens.selector[2] ||

                    callDataConcat[starts[i] + 3] != spender.claimTokens.selector[3]

                );

                require(callAddresses[i].externalCall(values[i], callDataConcat, starts[i], starts[i + 1] - starts[i]));

            }

        }



        if (address(toToken) == ETH_ADDRESS) {

            require(address(this).balance >= minTokensAmount);

        } else {

            require(toToken.balanceOf(address(this)) >= minTokensAmount);

        }



        //



        require(gasTokenBalance == gasToken.balanceOf(address(this)));

        if (mintGasPrice > 0) {

            audoRefundGas(returnAmount, mintGasPrice);

        }



        //



        returnAmount = _balanceOf(toToken, address(this)) * fee / 10000;

        if (referrer != address(0)) {

            returnAmount /= 2;

            if (!_transfer(toToken, referrer, returnAmount, true)) {

                returnAmount *= 2;

                emit OneInchFeePaid(toToken, address(0), returnAmount);

            } else {

                emit OneInchFeePaid(toToken, referrer, returnAmount / 2);

            }

        }



        _transfer(toToken, owner, returnAmount, false);



        returnAmount = _balanceOf(toToken, address(this));

        _transfer(toToken, msg.sender, returnAmount, false);

    }



    function _balanceOf(IERC20 token, address who) internal view returns(uint256) {

        if (address(token) == ETH_ADDRESS || token == IERC20(0)) {

            return who.balance;

        } else {

            return token.balanceOf(who);

        }

    }



    function _transfer(IERC20 token, address payable to, uint256 amount, bool allowFail) internal returns(bool) {

        if (address(token) == ETH_ADDRESS || token == IERC20(0)) {

            if (allowFail) {

                return to.send(amount);

            } else {

                to.transfer(amount);

                return true;

            }

        } else {

            token.safeTransfer(to, amount);

            return true;

        }

    }



    function audoRefundGas(

        uint startGas,

        uint mintGasPrice

    )

    private

    returns (uint freed)

    {

        uint MINT_BASE = 32254;

        uint MINT_TOKEN = 36543;

        uint FREE_BASE = 14154;

        uint FREE_TOKEN = 6870;

        uint REIMBURSE = 24000;



        uint tokensAmount = ((startGas - gasleft()) + FREE_BASE) / (2 * REIMBURSE - FREE_TOKEN);

        uint maxReimburse = tokensAmount * REIMBURSE;



        uint mintCost = MINT_BASE + (tokensAmount * MINT_TOKEN);

        uint freeCost = FREE_BASE + (tokensAmount * FREE_TOKEN);



        uint efficiency = (maxReimburse * 100 * tx.gasprice) / (mintCost * mintGasPrice + freeCost * tx.gasprice);



        if (efficiency > 100) {



            return refundGas(

                tokensAmount

            );

        } else {



            return 0;

        }

    }



    function refundGas(

        uint tokensAmount

    )

    private

    returns (uint freed)

    {



        if (tokensAmount > 0) {



            uint safeNumTokens = 0;

            uint gas = gasleft();



            if (gas >= 27710) {

                safeNumTokens = (gas - 27710) / (1148 + 5722 + 150);

            }



            if (tokensAmount > safeNumTokens) {

                tokensAmount = safeNumTokens;

            }



            uint gasTokenBalance = IERC20(address(gasToken)).balanceOf(address(this));



            if (tokensAmount > 0 && gasTokenBalance >= tokensAmount) {



                return gasToken.freeUpTo(tokensAmount);

            } else {



                return 0;

            }

        } else {



            return 0;

        }

    }



    function() external payable {



        if (msg.value == 0 && msg.sender == owner) {



            IERC20 _gasToken = IERC20(address(gasToken));



            owner.transfer(address(this).balance);

            _gasToken.safeTransfer(owner, _gasToken.balanceOf(address(this)));

        }

    }

}