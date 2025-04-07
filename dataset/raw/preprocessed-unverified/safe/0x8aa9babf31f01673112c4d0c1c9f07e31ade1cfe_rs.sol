/**

 *Submitted for verification at Etherscan.io on 2019-01-21

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



contract Ethex {

    function takeSellOrder(address token, uint256 tokenAmount, uint256 weiAmount, address seller) external payable;

    function takeBuyOrder(address token, uint256 tokenAmount, uint256 weiAmount, uint256 totalTokens, address buyer) external;

    function sellOrderBalances(bytes32 orderHash) external constant returns (uint256); //Returns number of tokens - e.g. available maker tokens

    function buyOrderBalances(bytes32 orderHash) external constant returns (uint256); //Returns number of eth - e.g. available maker's eth

    function makeFee() external constant returns (uint256);

    function takeFee() external constant returns (uint256);

    function feeFromTotalCostForAccount(uint256 totalCost, uint256 feeAmount, address account) external constant returns (uint256);

    function calculateFeeForAccount(uint256 cost, uint256 feeAmount, address account) public constant returns (uint256);

}



/// @title EthexHandler

/// @notice Handles the all EtherDelta trades for the primary contract

contract EthexHandler is ExchangeHandler, AllowanceSetter {



    /*

    *   State Variables

    */



    Ethex public exchange;



    /*

    *   Types

    */



    struct OrderData {

        address token;       //Token address

        uint256 tokenAmount; //Order's token amount

        uint256 weiAmount;   //Order's wei amount

        address maker;       //Person that created the order

        bool isSell;         //True if sell order, false if buy order - This is from the Ethex order perspective. E.g. An Ethex sell order is a Totle buy order, so this is True.

    }



    /// @notice Constructor

    /// @param _exchange Address of the EtherDelta exchange

    /// @param totlePrimary the address of the totlePrimary contract

    /// @param errorReporter the address of the error reporter contract

    constructor(

        address _exchange,

        address totlePrimary,

        address errorReporter

        /* ,address logger */

    )

        ExchangeHandler(totlePrimary, errorReporter/*, logger*/)

        public

    {

        require(_exchange != address(0x0));

        exchange = Ethex(_exchange);

    }



    /*

    *   Public functions

    */



    /// @notice Gets the amount that Totle needs to give for this order

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param order OrderData struct containing order values

    /// @return amountToGive amount taker needs to give in order to fill the order

    function getAmountToGive(

        OrderData order

    )

        public

        view

        onlyTotle

        returns (uint256 amountToGive)

    {

        bytes32 orderHash = hashOrder(order);

        uint256 makeFee = exchange.makeFee();

        uint256 takeFee = exchange.takeFee();

        uint256 ethVolumeAvailable;

        if(order.isSell){

            uint256 tokenVolumeAvailable = Math.min(exchange.sellOrderBalances(orderHash), order.tokenAmount);

            ethVolumeAvailable = SafeMath.div(SafeMath.mul(tokenVolumeAvailable, order.weiAmount), order.tokenAmount);

            amountToGive = SafeMath.add(ethVolumeAvailable, feeFromTotalCost(ethVolumeAvailable, takeFee));

        } else {

            ethVolumeAvailable = Math.min(removeFee(exchange.buyOrderBalances(orderHash), makeFee), order.weiAmount);

            amountToGive = SafeMath.div(SafeMath.mul(ethVolumeAvailable, order.tokenAmount), order.weiAmount);

        }

        /* logger.log("Remaining volume from Ethex", amountToGive); */

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract.

    /// This should be called to check for payload errors.

    /// @param order OrderData struct containing order values

    /// @return checksPassed value representing pass or fail

    function staticExchangeChecks(

        OrderData order

    )

        public

        view

        onlyTotle

        returns (bool checksPassed)

    {

        //Nothing to check

        return true;

    }



    /// @notice Perform a buy order at the exchange

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param order OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performBuyOrder(

        OrderData order,

        uint256 amountToGiveForOrder

    )

        public

        payable

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        uint256 takeFee = exchange.takeFee();

        amountSpentOnOrder = amountToGiveForOrder;

        uint256 amountSpentMinusFee = SafeMath.sub(amountSpentOnOrder, exchange.feeFromTotalCostForAccount(amountSpentOnOrder, takeFee, address(this)));

        amountReceivedFromOrder = SafeMath.div(SafeMath.mul(amountSpentMinusFee, order.tokenAmount), order.weiAmount);

        exchange.takeSellOrder.value(amountToGiveForOrder)(order.token, order.tokenAmount, order.weiAmount, order.maker);

        if (!ERC20SafeTransfer.safeTransfer(order.token, msg.sender, amountReceivedFromOrder)) {

            errorReporter.revertTx("Unable to transfer bought tokens to primary");

        }

    }



    /// @notice Perform a sell order at the exchange

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param order OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        OrderData order,

        uint256 amountToGiveForOrder

    )

        public

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        approveAddress(address(exchange), order.token);

        uint256 takeFee = exchange.takeFee();

        amountSpentOnOrder = amountToGiveForOrder;

        uint256 ethAmount = SafeMath.div(SafeMath.mul(amountSpentOnOrder, order.weiAmount), order.tokenAmount);

        amountReceivedFromOrder = SafeMath.sub(ethAmount, exchange.calculateFeeForAccount(ethAmount, takeFee, address(this)));

        exchange.takeBuyOrder(order.token, order.tokenAmount, order.weiAmount, amountSpentOnOrder, order.maker);

        msg.sender.transfer(amountReceivedFromOrder);

    }



    function hashOrder(OrderData order) internal pure returns (bytes32){

        return sha256(order.token, order.tokenAmount, order.weiAmount, order.maker);

    }



    function removeFee(uint256 cost, uint256 feeAmount) internal pure returns (uint256) {

        return SafeMath.div(SafeMath.mul(cost, 1e18), SafeMath.add(1e18, feeAmount));

    }



    function addFee(uint256 cost, uint256 feeAmount) internal pure returns (uint256) {

        return SafeMath.div(SafeMath.mul(cost, 1e18), SafeMath.sub(1e18, feeAmount));

    }



    function feeFromTotalCost(uint256 totalCost, uint256 feeAmount) public constant returns (uint256) {



        uint256 cost = SafeMath.mul(totalCost, (1 ether)) / SafeMath.add((1 ether), feeAmount);



        // Calculate ceil(cost).

        uint256 remainder = SafeMath.mul(totalCost, (1 ether)) % SafeMath.add((1 ether), feeAmount);

        if (remainder != 0) {

            cost = SafeMath.add(cost, 1);

        }



        uint256 fee = SafeMath.sub(totalCost, cost);

        return fee;

    }



    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {

        if (genericSelector == getAmountToGiveSelector) {

            return bytes4(keccak256("getAmountToGive((address,uint256,uint256,address,bool))"));

        } else if (genericSelector == staticExchangeChecksSelector) {

            return bytes4(keccak256("staticExchangeChecks((address,uint256,uint256,address,bool))"));

        } else if (genericSelector == performBuyOrderSelector) {

            return bytes4(keccak256("performBuyOrder((address,uint256,uint256,address,bool),uint256)"));

        } else if (genericSelector == performSellOrderSelector) {

            return bytes4(keccak256("performSellOrder((address,uint256,uint256,address,bool),uint256)"));

        } else {

            return bytes4(0x0);

        }

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