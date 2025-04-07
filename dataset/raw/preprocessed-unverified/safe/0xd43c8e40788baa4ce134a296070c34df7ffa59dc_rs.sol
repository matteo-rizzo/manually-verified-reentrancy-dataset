/**

 *Submitted for verification at Etherscan.io on 2019-06-25

*/



pragma solidity ^0.5.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see `ERC20Detailed`.

 */



/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be applied to your functions to restrict their use to

 * the owner.

 */







contract GlobalVar{

    address public KyberAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;// Proxy, same for ropsten and mainnet

    address public ETHToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public DAItoken = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

}







contract Dex is Ownable, GlobalVar {

    uint256 public serviceFee;

    address payable feeAccount;

    uint256 public maxAllowance;

    KyberNetworkI private kyberExchange;



    constructor() public {

        serviceFee = 0;

        feeAccount = 0x398d297BAB517770feC4d8Bb7a4127b486c244bB;

        maxAllowance = 2**256 - 1;

        

        // Instances

        kyberExchange = KyberNetworkI(KyberAddress);



        //Preapprove Tokens

        IERC20 DAI = IERC20(DAItoken);

        DAI.approve(KyberAddress, maxAllowance);

    }

    

    //=============

    //== Setters

    //=============

    

    function setFee(uint256 fee) public onlyOwner returns (bool success) {

        serviceFee = fee;

        return true;

    }

    

    function setFeeAccount(address payable account) public onlyOwner returns (bool success) {

        feeAccount = account;

        return true;

    }

    

    

    //=============

    //== Helper Functions

    //=============

    

    function checkAllowance(address erc20, uint256 amount) public view returns (bool success) {

        IERC20 tokenFunctions = IERC20(erc20);

        return tokenFunctions.allowance(address(this), KyberAddress) > amount;

    }



    function approve(address erc20, address spender, uint tokens) public onlyOwner returns (bool success) {

        IERC20 tokenFunctions = IERC20(erc20);

        require(tokenFunctions.approve(spender, tokens), "Token Approve aborted");

        return true;

    }

    

    

    //=============

    //== Admin Functions

    //=============



    function withdrawEth() public onlyOwner returns (bool success) {

        require(address(this).balance > 0, "Balance is zero");

        feeAccount.transfer(address(this).balance);

        return true;

    }



    function withdrawTokens(IERC20 token) public onlyOwner returns (bool success) {

        uint256 balance = token.balanceOf(address(this));



        // Double checking

        require(balance > 0, "Balance is zero");

        require(token.transfer(feeAccount, balance), "Token transfer aborted");

        return true;

    }

    

    

    

    //=============

    //== Functions

    //=============

    

    function getAmount(address inputToken, uint srcAmt) internal returns (uint ethQty) {

        if (inputToken == ETHToken) {

            require(msg.value == srcAmt, "Amount is inconsistent");

        } else {

            IERC20 tokenFunctions = IERC20(inputToken);

            require(tokenFunctions.transferFrom(msg.sender, address(this), srcAmt), "transferFrom failed");

        }

        return srcAmt;

    }

    

    function calculateWithdrawWithFee(uint256 swappedAmount) public view returns (uint256 amount){

        uint256 transferAmount;

        if (serviceFee > 0) {

            uint256 feeToSub = (swappedAmount * serviceFee) / (1 ether);

            transferAmount = swappedAmount - feeToSub;

        } else {

            transferAmount = swappedAmount;

        }

        

        return transferAmount;

    }

    

    

    //=============

    //== Swap Functions

    //=============

    

    function sell(

        address source, //0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee, // eth token in kyber

        uint srcAmount,

        address dest,

        address recepient

    )

        public

        payable

        returns (uint256 swappedAmount)

    {

        uint amount = getAmount(source, srcAmount);

        

        uint256 actualDestAmount = kyberExchange.trade(

            source, 

            amount, //amount of tokens to convert. If sending ETH must be equal to msg.value. Otherwise, must not be higher than user token allowance to kyber network contract address.

            dest, 

            address(this),

            maxAllowance, //maxDestAmount: maximum destination amount. The actual converted amount will be the minimum of srcAmount and required amount to get maxDestAmount of dest tokens. For an exchange application, we recommend to set it to MAX_UINT (i.e., 2**256 - 1).

            1, //minConversionRate: the minimal conversion rate. If the current rate is too high, then the transaction is reverted. For an exchange application this value can be set according to the priceSlippage return value of getExpectedRate. However, in this case, the execution of the transaction is not guaranteed in case big changes in market price happens before the confirmation of the transaction. A value of 1 will execute the trade according to market price in the time of the transaction confirmation.

            feeAccount

        );

        

        uint256 finalAmount = calculateWithdrawWithFee(actualDestAmount);

    

        require(IERC20(dest).transfer(recepient, finalAmount));

        return finalAmount;

    }



    function buy(

        address source,

        uint srcAmount,

        address dest,

        address recepient

    )

        public

        payable

        returns (uint256 swappedAmount)

    {

        uint amount = getAmount(source, srcAmount);

        

        uint256 actualDestAmount = kyberExchange.trade.value(amount)(

            source, // eth token in kyber

            amount, //amount of tokens to convert. If sending ETH must be equal to msg.value. Otherwise, must not be higher than user token allowance to kyber network contract address.

            dest, 

            address(this),

            maxAllowance, //maxDestAmount: maximum destination amount. The actual converted amount will be the minimum of srcAmount and required amount to get maxDestAmount of dest tokens. For an exchange application, we recommend to set it to MAX_UINT (i.e., 2**256 - 1).

            1, //minConversionRate: the minimal conversion rate. If the current rate is too high, then the transaction is reverted. For an exchange application this value can be set according to the priceSlippage return value of getExpectedRate. However, in this case, the execution of the transaction is not guaranteed in case big changes in market price happens before the confirmation of the transaction. A value of 1 will execute the trade according to market price in the time of the transaction confirmation.

            feeAccount

        );

        

        

        uint256 finalAmount = calculateWithdrawWithFee(actualDestAmount);



        /**

        * Tokens are send back to the users

        */

        require(IERC20(dest).transfer(recepient, finalAmount));

        return finalAmount;

    }

    

    function () external payable {

        revert();

    }



}