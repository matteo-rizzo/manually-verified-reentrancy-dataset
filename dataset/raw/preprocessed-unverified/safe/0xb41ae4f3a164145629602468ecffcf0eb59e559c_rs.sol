pragma solidity ^0.4.15;



/**

 * title Eliptic curve signature operations

 *

 * 

 */







/**

 * title SafeMath

 * Math operations with safety checks that throw on error

 */





/**

 * title Ownable

 * The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * §¬§à§ß§ä§â§Ñ§Ü§ä §è§Ö§ß§ä§â§Ñ§Ý§î§ß§à§Û §Ý§à§Ô§Ú§Ü§Ú

 */



contract MemeCore is Ownable {

    using SafeMath for uint;

    using ECRecovery for bytes32;



    /* §®§Ñ§á§Ñ §Ñ§Õ§â§Ö§ã §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ - nonce, §ß§å§Ø§ß§à §Õ§Ý§ñ §ä§à§Ô§à, §é§ä§à§Ò§í §ß§Ö§Ý§î§Ù§ñ §Ò§í§Ý§à §á§à§Ó§ä§à§â§ß§à §Ù§Ñ§á§â§à§ã§Ú§ä§î withdraw */

    mapping (address => uint) withdrawalsNonce;



    event Withdraw(address receiver, uint weiAmount);

    event WithdrawCanceled(address receiver);



    function() payable {

        require(msg.value != 0);

    }



    /* §©§Ñ§á§â§à§ã §ß§Ñ §Ó§í§á§Ý§Ñ§ä§å §à§ä §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ, §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ü§Ý§Ú§Ö§ß§ä §Õ§Ö§Ý§Ñ§Ö§ä withdraw */

    function _withdraw(address toAddress, uint weiAmount) private {

        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð

        toAddress.transfer(weiAmount);



        Withdraw(toAddress, weiAmount);

    }





    /* §©§Ñ§á§â§à§ã §ß§Ñ §Ó§í§á§Ý§Ñ§ä§å §à§ä §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ, §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ü§Ý§Ú§Ö§ß§ä §Õ§Ö§Ý§Ñ§Ö§ä withdraw */

    function withdraw(uint weiAmount, bytes signedData) external {

        uint256 nonce = withdrawalsNonce[msg.sender] + 1;



        bytes32 validatingHash = keccak256(msg.sender, weiAmount, nonce);



        // §±§à§Õ§á§Ú§ã§í§Ó§Ñ§ä§î §Ó§ã§Ö §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Ú §Õ§à§Ý§Ø§Ö§ß owner

        address addressRecovered = validatingHash.recover(signedData);



        require(addressRecovered == owner);



        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð

        _withdraw(msg.sender, weiAmount);



        withdrawalsNonce[msg.sender] = nonce;

    }



    /* §°§ä§Þ§Ö§ß§Ñ withdraw */

    function cancelWithdraw(){

        withdrawalsNonce[msg.sender]++;



        WithdrawCanceled(msg.sender);

    }



    /* §¥§à§ã§ä§å§á§ß§Ñ §ä§à§Ý§î§Ü§à owner'§å, §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ò§ï§Ü§Ö§ß§Õ §Õ§Ö§Ý§Ñ§Ö§ä withdraw */

    function backendWithdraw(address toAddress, uint weiAmount) external onlyOwner {

        require(toAddress != 0);



        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð

        _withdraw(toAddress, weiAmount);

    }



}