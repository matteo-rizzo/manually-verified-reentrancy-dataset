/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.25;

pragma experimental ABIEncoderV2;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title Math

 * @dev Assorted math operations

 */







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

    address public totlePrimary;



    /// @dev A modifier which only allows code execution if msg.sender equals totlePrimary address

    modifier onlyTotle() {

        require(msg.sender == totlePrimary);

        _;

    }



    /// @notice Contract constructor

    /// @dev As this contract inherits ownable, msg.sender will become the contract owner

    /// @param _totlePrimary the address of the contract to be set as totlePrimary

    constructor(address _totlePrimary) public {

        require(_totlePrimary != address(0x0));

        totlePrimary = _totlePrimary;

    }



    /// @notice A function which allows only the owner to change the address of totlePrimary

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _totlePrimary the address of the contract to be set as totlePrimary

    function setTotle(

        address _totlePrimary

    ) external onlyOwner {

        require(_totlePrimary != address(0x0));

        totlePrimary = _totlePrimary;

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

    bytes4 constant getAmountToGive = bytes4(keccak256("getAmountToGive(bytes)"));

    bytes4 constant staticExchangeChecks = bytes4(keccak256("staticExchangeChecks(bytes)"));

    bytes4 constant performBuyOrder = bytes4(keccak256("performBuyOrder(bytes,uint256)"));

    bytes4 constant performSellOrder = bytes4(keccak256("performSellOrder(bytes,uint256)"));



    function getSelector(bytes4 genericSelector) public pure returns (bytes4);

}



/// @title Interface for all exchange handler contracts

contract ExchangeHandler is TotleControl, Withdrawable, Pausable {



    /*

    *   State Variables

    */



    SelectorProvider public selectorProvider;

    ErrorReporter public errorReporter;

    /* Logger public logger; */

    /*

    *   Modifiers

    */



    modifier onlySelf() {

        require(msg.sender == address(this));

        _;

    }



    /// @notice Constructor

    /// @dev Calls the constructor of the inherited TotleControl

    /// @param _selectorProvider the provider for this exchanges function selectors

    /// @param totlePrimary the address of the totlePrimary contract

    constructor(

        address _selectorProvider,

        address totlePrimary,

        address _errorReporter

        /* ,address _logger */

    )

        TotleControl(totlePrimary)

        public

    {

        require(_selectorProvider != address(0x0));

        require(_errorReporter != address(0x0));

        /* require(_logger != address(0x0)); */

        selectorProvider = SelectorProvider(_selectorProvider);

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

        onlyTotle

        whenNotPaused

        returns (uint256 amountToGive)

    {

        bool success;

        bytes4 functionSelector = selectorProvider.getSelector(this.getAmountToGive.selector);



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



            success := call(

                            gas,

                            address, // This address of the current contract

                            callvalue,

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

        onlyTotle

        whenNotPaused

        returns (bool checksPassed)

    {

        bool success;

        bytes4 functionSelector = selectorProvider.getSelector(this.staticExchangeChecks.selector);

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



            success := call(

                            gas,

                            address, // This address of the current contract

                            callvalue,

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

        onlyTotle

        whenNotPaused

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        bool success;

        bytes4 functionSelector = selectorProvider.getSelector(this.performBuyOrder.selector);

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



            success := call(

                            gas,

                            address, // This address of the current contract

                            callvalue,

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

        onlyTotle

        whenNotPaused

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        bool success;

        bytes4 functionSelector = selectorProvider.getSelector(this.performSellOrder.selector);

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



            success := call(

                            gas,

                            address, // This address of the current contract

                            callvalue,

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







/// @title EtherDeltaSelectorProvider

/// @notice Provides this exchange implementation with correctly formatted function selectors

contract EtherDeltaSelectorProvider is SelectorProvider {

    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {

        if (genericSelector == getAmountToGive) {

            return bytes4(keccak256("getAmountToGive((address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32,uint256))"));

        } else if (genericSelector == staticExchangeChecks) {

            return bytes4(keccak256("staticExchangeChecks((address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32,uint256))"));

        } else if (genericSelector == performBuyOrder) {

            return bytes4(keccak256("performBuyOrder((address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32,uint256),uint256)"));

        } else if (genericSelector == performSellOrder) {

            return bytes4(keccak256("performSellOrder((address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32,uint256),uint256)"));

        } else {

            return bytes4(0x0);

        }

    }

}



/// @title EtherDeltaHandler

/// @notice Handles the all EtherDelta trades for the primary contract

contract EtherDeltaHandler is ExchangeHandler, AllowanceSetter {



    /*

    *   State Variables

    */



    EtherDelta public exchange;



    /*

    *   Types

    */



    struct OrderData {

        address user;

        address tokenGive;

        address tokenGet;

        uint256 amountGive;

        uint256 amountGet;

        uint256 expires;

        uint256 nonce;

        uint8 v;

        bytes32 r;

        bytes32 s;

        uint256 exchangeFee;

    }



    /// @notice Constructor

    /// @param _exchange Address of the EtherDelta exchange

    /// @param selectorProvider the provider for this exchanges function selectors

    /// @param totlePrimary the address of the totlePrimary contract

    /// @param errorReporter the address of the error reporter contract

    constructor(

        address _exchange,

        address selectorProvider,

        address totlePrimary,

        address errorReporter

        /* ,address logger */

    )

        ExchangeHandler(selectorProvider, totlePrimary, errorReporter/*, logger*/)

        public

    {

        require(_exchange != address(0x0));

        exchange = EtherDelta(_exchange);

    }



    /*

    *   Public functions

    */



    /// @notice Gets the amount that Totle needs to give for this order

    /// @dev Uses the `onlySelf` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param data OrderData struct containing order values

    /// @return amountToGive amount taker needs to give in order to fill the order

    function getAmountToGive(

        OrderData data

    )

        public

        view

        onlySelf

        returns (uint256 amountToGive)

    {

        uint256 availableVolume = exchange.availableVolume(

            data.tokenGet,

            data.amountGet,

            data.tokenGive,

            data.amountGive,

            data.expires,

            data.nonce,

            data.user,

            data.v,

            data.r,

            data.s

        );

        /* logger.log("Getting available volume from Etherdelta", availableVolume); */

        // Adds the exchange fee onto the available amount

        amountToGive = getPartialAmount(availableVolume, SafeMath.sub(1 ether, data.exchangeFee), 1 ether);

        /* logger.log("Removing fee from amountToGive", amountToGive); */

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev Uses the `onlySelf` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract.

    /// This should be called to check for payload errors.

    /// @param data OrderData struct containing order values

    /// @return checksPassed value representing pass or fail

    function staticExchangeChecks(

        OrderData data

    )

        public

        view

        onlySelf

        returns (bool checksPassed)

    {

        /* logger.log(block.number <= data.expires ? "Order isn't expired" : "Order is expired"); */

        // Only one thing to check here

        return block.number <= data.expires; // TODO - check if this is < or <=

    }



    /// @notice Perform a buy order at the exchange

    /// @dev Uses the `onlySelf` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

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

        onlySelf

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        if (msg.value != amountToGiveForOrder) {

            errorReporter.revertTx("msg.value != amountToGiveForOrder");

        }

        /* logger.log("Depositing eth to Etherdelta arg2: amountToGive, arg3: ethBalance", amountToGiveForOrder, address(this).balance); */

        exchange.deposit.value(amountToGiveForOrder)();



        uint256 amountToTrade;

        uint256 fee;



        (amountToTrade, fee) = substractFee(data.exchangeFee, amountToGiveForOrder);

        /* logger.log("Removing fee from amountToGiveForOrder arg2: amountToGiveForOrder, arg3: amountToTrade, arg4: fee", amountToGiveForOrder, amountToTrade, fee); */

        trade(data, amountToTrade);



        amountSpentOnOrder = amountToGiveForOrder;

        amountReceivedFromOrder = getPartialAmount(data.amountGive, data.amountGet, amountToTrade);

        /* logger.log("Withdrawing tokens from EtherDelta arg2: amountReceivedFromOrder, arg3: amountSpentOnOrder", amountReceivedFromOrder, amountSpentOnOrder); */

        exchange.withdrawToken(data.tokenGive, amountReceivedFromOrder);



        if (!ERC20SafeTransfer.safeTransfer(data.tokenGive, totlePrimary, amountReceivedFromOrder)) {

            errorReporter.revertTx("Unable to transfer bought tokens to primary");

        }

    }



    /// @notice Perform a sell order at the exchange

    /// @dev Uses the `onlySelf` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param data OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        OrderData data,

        uint256 amountToGiveForOrder

    )

        public

        onlySelf

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        approveAddress(address(exchange), data.tokenGet);

        /* logger.log("Depositing tokens to EtherDelta arg2: amountToGiveForOrder", amountToGiveForOrder); */

        exchange.depositToken(data.tokenGet, amountToGiveForOrder);



        uint256 amountToTrade;

        uint256 fee;



        (amountToTrade, fee) = substractFee(data.exchangeFee, amountToGiveForOrder);

        /* logger.log("arg2: amountToTrade, arg3: fee", amountToTrade, fee); */



        trade(data, amountToTrade);



        amountSpentOnOrder = amountToGiveForOrder;

        amountReceivedFromOrder = getPartialAmount(data.amountGive, data.amountGet, amountToTrade);



        exchange.withdraw(amountReceivedFromOrder);

        /* logger.log("Withdrawing ether arg2: amountReceived", amountReceivedFromOrder); */

        address(totlePrimary).transfer(amountReceivedFromOrder);

    }



    /*

    *   Internal functions

    */



    /// @notice Performs the trade at the exchange

    /// @dev It was necessary to separate this into a function due to limited stack space

    /// @param data OrderData struct containing order values

    /// @param amountToTrade amount that should be spent on this order

    function trade(

        OrderData data,

        uint256 amountToTrade

    )

        internal

    {

        exchange.trade(

            data.tokenGet,

            data.amountGet,

            data.tokenGive,

            data.amountGive,

            data.expires,

            data.nonce,

            data.user,

            data.v,

            data.r,

            data.s,

            amountToTrade

        );

    }



    /// @notice Subtract fee percentage from the amount give

    /// @param feePercentage the percentage fee to deduct

    /// @param  amount the amount that we should deduct from

    /// @return amountMinusFee the amount that would be spent on the order

    /// @return fee the amount that was received from this order

    function substractFee(

        uint256 feePercentage,

        uint256 amount

    )

        public

        pure

        returns (uint256 amountMinusFee, uint256 fee)

    {

        fee = SafeMath.sub(amount, getPartialAmount(amount, SafeMath.add(feePercentage, 1 ether), 1 ether ));

        amountMinusFee = SafeMath.sub(amount, fee);

    }



    /// @notice Calculate the result of ((numerator * target) / denominator)

    /// @param numerator the numerator in the equation

    /// @param denominator the denominator in the equation

    /// @param target the target for the equations

    /// @return partialAmount the resultant value

    function getPartialAmount(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

        internal

        pure

        returns (uint256)

    {

        return SafeMath.div(SafeMath.mul(numerator, target), denominator);

    }



    /*

    *   Payable fallback function

    */



    /// @notice payable fallback to allow the exchange to return ether directly to this contract

    /// @dev note that only the exchange should be able to send ether to this contract

    function() public payable {

        if (msg.sender != address(exchange)) {

            errorReporter.revertTx("An address other than the exchange cannot send ether to EDHandler fallback");

        }

    }

}