/**

 *Submitted for verification at Etherscan.io on 2019-01-21

*/



pragma solidity 0.4.25;

pragma experimental ABIEncoderV2;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

  function totalSupply() public view returns (uint256);



  function balanceOf(address _who) public view returns (uint256);



  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transfer(address _to, uint256 _value) public returns (bool);



  function approve(address _spender, uint256 _value)

    public returns (bool);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function decimals() public view returns (uint256);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/*

    Modified Util contract as used by Kyber Network

*/











/// @title A contract which is used to check and set allowances of tokens

/// @dev In order to use this contract is must be inherited in the contract which is using

/// its functionality

contract AllowanceSetter {

    uint256 constant MAX_UINT = 2**256 - 1;



    /// @notice A function which allows the caller to approve the max amount of any given token

    /// @dev In order to function correctly, token allowances should not be set anywhere else in

    /// the inheriting contract

    /// @param addressToApprove the address which we want to approve to transfer the token

    /// @param token the token address which we want to call approve on

    function approveAddress(address addressToApprove, address token) internal {

        if(ERC20(token).allowance(address(this), addressToApprove) == 0) {

            require(ERC20SafeTransfer.safeApprove(token, addressToApprove, MAX_UINT));

        }

    }



}



contract ErrorReporter {

    function revertTx(string reason) public pure {

        revert(reason);

    }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/// @title A contract which can be used to ensure only the TotlePrimary contract can call

/// some functions

/// @dev Defines a modifier which should be used when only the totle contract should

/// able able to call a function

contract TotleControl is Ownable {

    mapping(address => bool) public authorizedPrimaries;



    /// @dev A modifier which only allows code execution if msg.sender equals totlePrimary address

    modifier onlyTotle() {

        require(authorizedPrimaries[msg.sender]);

        _;

    }



    /// @notice Contract constructor

    /// @dev As this contract inherits ownable, msg.sender will become the contract owner

    /// @param _totlePrimary the address of the contract to be set as totlePrimary

    constructor(address _totlePrimary) public {

        authorizedPrimaries[_totlePrimary] = true;

    }



    /// @notice A function which allows only the owner to change the address of totlePrimary

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _totlePrimary the address of the contract to be set as totlePrimary

    function addTotle(

        address _totlePrimary

    ) external onlyOwner {

        authorizedPrimaries[_totlePrimary] = true;

    }



    function removeTotle(

        address _totlePrimary

    ) external onlyOwner {

        authorizedPrimaries[_totlePrimary] = false;

    }

}



/// @title A contract which allows its owner to withdraw any ether which is contained inside

contract Withdrawable is Ownable {



    /// @notice Withdraw ether contained in this contract and send it back to owner

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _token The address of the token that the user wants to withdraw

    /// @param _amount The amount of tokens that the caller wants to withdraw

    /// @return bool value indicating whether the transfer was successful

    function withdrawToken(address _token, uint256 _amount) external onlyOwner returns (bool) {

        return ERC20SafeTransfer.safeTransfer(_token, owner, _amount);

    }



    /// @notice Withdraw ether contained in this contract and send it back to owner

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _amount The amount of ether that the caller wants to withdraw

    function withdrawETH(uint256 _amount) external onlyOwner {

        owner.transfer(_amount);

    }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Paused();

  event Unpaused();



  bool private _paused = false;



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns (bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused, "Contract is paused.");

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused, "Contract not paused.");

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyOwner whenNotPaused {

    _paused = true;

    emit Paused();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    _paused = false;

    emit Unpaused();

  }

}



contract SelectorProvider {

    bytes4 constant getAmountToGiveSelector = bytes4(keccak256("getAmountToGive(bytes)"));

    bytes4 constant staticExchangeChecksSelector = bytes4(keccak256("staticExchangeChecks(bytes)"));

    bytes4 constant performBuyOrderSelector = bytes4(keccak256("performBuyOrder(bytes,uint256)"));

    bytes4 constant performSellOrderSelector = bytes4(keccak256("performSellOrder(bytes,uint256)"));



    function getSelector(bytes4 genericSelector) public pure returns (bytes4);

}



/// @title Interface for all exchange handler contracts

contract ExchangeHandler is SelectorProvider, TotleControl, Withdrawable, Pausable {



    /*

    *   State Variables

    */



    ErrorReporter public errorReporter;

    /* Logger public logger; */

    /*

    *   Modifiers

    */



    /// @notice Constructor

    /// @dev Calls the constructor of the inherited TotleControl

    /// @param totlePrimary the address of the totlePrimary contract

    constructor(

        address totlePrimary,

        address _errorReporter

        /* ,address _logger */

    )

        TotleControl(totlePrimary)

        public

    {

        require(_errorReporter != address(0x0));

        /* require(_logger != address(0x0)); */

        errorReporter = ErrorReporter(_errorReporter);

        /* logger = Logger(_logger); */

    }



    /// @notice Gets the amount that Totle needs to give for this order

    /// @param genericPayload the data for this order in a generic format

    /// @return amountToGive amount taker needs to give in order to fill the order

    function getAmountToGive(

        bytes genericPayload

    )

        public

        view

        returns (uint256 amountToGive)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.getAmountToGive.selector);



        assembly {

            let functionSelectorLength := 0x04

            let functionSelectorOffset := 0x1C

            let scratchSpace := 0x0

            let wordLength := 0x20

            let bytesLength := mload(genericPayload)

            let totalLength := add(functionSelectorLength, bytesLength)

            let startOfNewData := add(genericPayload, functionSelectorOffset)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(genericPayload, functionSelectorCorrect)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            wordLength // Length of return variable is one word

                           )

            amountToGive := mload(scratchSpace)

            if eq(success, 0) { revert(0, 0) }

        }

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev this should be called to check for payload errors

    /// @param genericPayload the data for this order in a generic format

    /// @return checksPassed value representing pass or fail

    function staticExchangeChecks(

        bytes genericPayload

    )

        public

        view

        returns (bool checksPassed)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.staticExchangeChecks.selector);

        assembly {

            let functionSelectorLength := 0x04

            let functionSelectorOffset := 0x1C

            let scratchSpace := 0x0

            let wordLength := 0x20

            let bytesLength := mload(genericPayload)

            let totalLength := add(functionSelectorLength, bytesLength)

            let startOfNewData := add(genericPayload, functionSelectorOffset)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(genericPayload, functionSelectorCorrect)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            wordLength // Length of return variable is one word

                           )

            checksPassed := mload(scratchSpace)

            if eq(success, 0) { revert(0, 0) }

        }

    }



    /// @notice Perform a buy order at the exchange

    /// @param genericPayload the data for this order in a generic format

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performBuyOrder(

        bytes genericPayload,

        uint256 amountToGiveForOrder

    )

        public

        payable

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.performBuyOrder.selector);

        assembly {

            let callDataOffset := 0x44

            let functionSelectorOffset := 0x1C

            let functionSelectorLength := 0x04

            let scratchSpace := 0x0

            let wordLength := 0x20

            let startOfFreeMemory := mload(0x40)



            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)



            let bytesLength := mload(startOfFreeMemory)

            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)



            let functionSelectorCorrect := mload(scratchSpace)



            mstore(startOfFreeMemory, functionSelectorCorrect)



            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)



            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            mul(wordLength, 0x02) // Length of return variables is two words

                          )

            amountSpentOnOrder := mload(scratchSpace)

            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))

            if eq(success, 0) { revert(0, 0) }

        }

    }



    /// @notice Perform a sell order at the exchange

    /// @param genericPayload the data for this order in a generic format

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        bytes genericPayload,

        uint256 amountToGiveForOrder

    )

        public

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.performSellOrder.selector);

        assembly {

            let callDataOffset := 0x44

            let functionSelectorOffset := 0x1C

            let functionSelectorLength := 0x04

            let scratchSpace := 0x0

            let wordLength := 0x20

            let startOfFreeMemory := mload(0x40)



            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)



            let bytesLength := mload(startOfFreeMemory)

            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)



            let functionSelectorCorrect := mload(scratchSpace)



            mstore(startOfFreeMemory, functionSelectorCorrect)



            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)



            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            mul(wordLength, 0x02) // Length of return variables is two words

                          )

            amountSpentOnOrder := mload(scratchSpace)

            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))

            if eq(success, 0) { revert(0, 0) }

        }

    }

}







/// @title Handler for TokenStore exchange

contract TokenStoreHandler is ExchangeHandler, AllowanceSetter {



    /*

    *   Types

    */

    struct OrderData {

        address takerToken; //For a Totle sell, takerToken is the token address

        uint256 takerAmount;

        address makerToken; //For a Totle sell, makerToken is 0x0 (ETH)

        uint256 makerAmount;

        uint256 expires;

        uint256 nonce;

        address user; //Maker

        uint8 v;

        bytes32 r;

        bytes32 s;

    }



    TokenStoreExchange exchange;



    /// @notice Constructor

    /// @param _exchange the address of the token store exchange

    /// @param _totlePrimary the address of the totlePrimary contract

    /// @param errorReporter the address of of the errorReporter contract

    constructor(

        address _exchange,

        address _totlePrimary,

        address errorReporter/*,

        address logger*/

    ) ExchangeHandler(_totlePrimary, errorReporter/*, logger*/) public {

        exchange = TokenStoreExchange(_exchange);

    }



    /*

    *   Internal functions

    */



    /// @notice Gets the amount that TotlePrimary needs to give for this order

    /// @param data OrderData struct containing order values

    /// @return amountToGive amount taker needs to give in order to fill the order

    function getAmountToGive(

        OrderData data

    )

        public

        view

        whenNotPaused

        onlyTotle

        returns (uint256 amountToGive)

    {

        uint256 feePercentage = exchange.fee();

        uint256 availableVolume = exchange.availableVolume(data.takerToken, data.takerAmount, data.makerToken, data.makerAmount, data.expires,

            data.nonce, data.user, data.v, data.r, data.s);

        uint256 fee = SafeMath.div(SafeMath.mul(availableVolume, feePercentage), 1 ether);

        return SafeMath.add(availableVolume, fee);

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev This should be called to check for payload errors

    /// @param data OrderData struct containing order values

    /// @return checksPassed value representing pass or fail

    function staticExchangeChecks(

        OrderData data

    )

        public

        view

        whenNotPaused

        onlyTotle

        returns (bool checksPassed)

    {

        bytes32 hash = sha256(abi.encodePacked(address(exchange), data.takerToken, data.takerAmount, data.makerToken, data.makerAmount, data.expires, data.nonce));

        if (ecrecover(sha3(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), data.v, data.r, data.s) != data.user || block.number > data.expires) {

            return false;

        }

        return true;

    }



    /// @dev Perform a buy order at the exchange

    /// @param data OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performBuyOrder(

        OrderData data,

        uint256 amountToGiveForOrder

    )

        public

        payable

        whenNotPaused

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        amountSpentOnOrder = amountToGiveForOrder;

        exchange.deposit.value(amountToGiveForOrder)();

        uint256 amountToSpend = removeFee(amountToGiveForOrder);

        amountReceivedFromOrder = SafeMath.div(SafeMath.mul(amountToSpend, data.makerAmount), data.takerAmount);

        exchange.trade(data.takerToken, data.takerAmount, data.makerToken, data.makerAmount, data.expires, data.nonce, data.user, data.v, data.r, data.s, amountToSpend);

        /* logger.log("Performing TokenStore buy order arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder", amountSpentOnOrder, amountReceivedFromOrder);  */

        exchange.withdrawToken(data.makerToken, amountReceivedFromOrder);

        if (!ERC20SafeTransfer.safeTransfer(data.makerToken, msg.sender, amountReceivedFromOrder)){

            errorReporter.revertTx("Failed to transfer tokens to totle primary");

        }



    }



    /// @dev Perform a sell order at the exchange

    /// @param data OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        OrderData data,

        uint256 amountToGiveForOrder

    )

        public

        whenNotPaused

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        amountSpentOnOrder = amountToGiveForOrder;

        approveAddress(address(exchange), data.takerToken);

        exchange.depositToken(data.takerToken, amountToGiveForOrder);

        uint256 amountToSpend = removeFee(amountToGiveForOrder);

        amountReceivedFromOrder = SafeMath.div(SafeMath.mul(amountToSpend, data.makerAmount), data.takerAmount);

        exchange.trade(data.takerToken, data.takerAmount, data.makerToken, data.makerAmount, data.expires, data.nonce, data.user, data.v, data.r, data.s, amountToSpend);

        /* logger.log("Performing TokenStore sell order arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder",amountSpentOnOrder,amountReceivedFromOrder); */

        exchange.withdraw(amountReceivedFromOrder);

        msg.sender.transfer(amountReceivedFromOrder);

    }



    function removeFee(uint256 totalAmount) internal constant returns (uint256){

      uint256 feePercentage = exchange.fee();

      return SafeMath.div(SafeMath.mul(totalAmount, 1 ether), SafeMath.add(feePercentage, 1 ether));



    }



    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {

        if (genericSelector == getAmountToGiveSelector) {

            return bytes4(keccak256("getAmountToGive((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32))"));

        } else if (genericSelector == staticExchangeChecksSelector) {

            return bytes4(keccak256("staticExchangeChecks((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32))"));

        } else if (genericSelector == performBuyOrderSelector) {

            return bytes4(keccak256("performBuyOrder((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32),uint256)"));

        } else if (genericSelector == performSellOrderSelector) {

            return bytes4(keccak256("performSellOrder((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32),uint256)"));

        } else {

            return bytes4(0x0);

        }

    }



    /// @notice payable fallback to block EOA sending eth

    /// @dev this should fail if an EOA (or contract with 0 bytecode size) tries to send ETH to this contract

    function() public payable {

        // Check in here that the sender is a contract! (to stop accidents)

        uint256 size;

        address sender = msg.sender;

        assembly {

            size := extcodesize(sender)

        }

        require(size > 0);

    }

}