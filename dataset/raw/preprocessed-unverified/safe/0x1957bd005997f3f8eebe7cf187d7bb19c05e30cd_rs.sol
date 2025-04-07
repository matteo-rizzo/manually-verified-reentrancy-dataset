/**

 *Submitted for verification at Etherscan.io on 2019-01-18

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

 * @title Math

 * @dev Assorted math operations

 */







/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





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



/// @title OasisInterface

/// @notice Exchange contract interface









/// @title OasisHandler

/// @notice Handles the all Oasis trades for the primary contract

contract OasisHandler is ExchangeHandler, AllowanceSetter {



    /*

    *   State Variables

    */



    OasisInterface public oasis;

    WethInterface public weth;



    /*

    *   Types

    */



    struct OrderData {

        uint256 offerId;

        uint256 maxAmountToSpend;

    }



    /// @notice Constructor

    /// @dev Calls the constructor of the inherited ExchangeHandler

    /// @param oasisAddress the address of the oasis exchange contract

    /// @param wethAddress the address of the weth contract

    /// @param totlePrimary the address of the totlePrimary contract

    constructor(

        address oasisAddress,

        address wethAddress,

        address totlePrimary,

        address errorReporter

        /* , address logger */

    )

        ExchangeHandler(totlePrimary, errorReporter/*,logger*/)

        public

    {

        require(oasisAddress != address(0x0));

        require(wethAddress != address(0x0));

        oasis = OasisInterface(oasisAddress);

        weth = WethInterface(wethAddress);

    }



    /*

    *   Public functions

    */



    /// @notice Gets the amount that Totle needs to give for this order

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract.

    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".

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

        uint256 availableGetAmount;

        (availableGetAmount,,,) = oasis.getOffer(data.offerId);

        /* logger.log("Oasis order available amount arg2: availableGetAmount", availableGetAmount); */

        return availableGetAmount > data.maxAmountToSpend ? data.maxAmountToSpend : availableGetAmount;

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev This function should be called to check for payload errors.

    /// Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract.

    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".

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



        /* logger.log("Oasis static exchange checks"); */

        // Check if the offer is active

        if (!oasis.isActive(data.offerId)){

            /* logger.log("Oasis offer is not active arg2: offerId", data.offerId); */

            return false;

        }



        // Check if the pay_gem or buy_gem is weth

        address pay_gem;

        address buy_gem;

        (,pay_gem,,buy_gem) = oasis.getOffer(data.offerId);



        bool isBuyOrPayWeth = pay_gem == address(weth) || buy_gem == address(weth);

        if (!isBuyOrPayWeth){

            /* logger.log("Oasis offer's base pair is not WETH arg6: pay_gem, arg7: buy_gem", 0,0,0,0, pay_gem, buy_gem); */

            return false;

        }



        return true;

    }



    /// @notice Perform a buy order at the exchange

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract.

    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".

    /// @param data OrderData struct containing order values

    /// @param amountToSpend amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performBuyOrder(

        OrderData data,

        uint256 amountToSpend

    )

        public

        payable

        whenNotPaused

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        /* logger.log("Performing Oasis buy order arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder", amountSpentOnOrder, amountReceivedFromOrder); */

        if (msg.value != amountToSpend){



            /* logger.log("Ether sent is not equal to amount to spend arg2: amountToSpend, arg3: msg.value", amountToSpend, msg.value); */

            msg.sender.transfer(msg.value);

            return (0,0);

        }



        //Convert ETH to Weth

        weth.deposit.value(amountToSpend)();



        /* logger.log("Converted to WETH"); */



        //Approve oasis to move weth

        approveAddress(address(oasis), address(weth));



        /* logger.log("Address approved"); */



        //Fetch offer data and validate buy gem is weth

        uint256 maxPayGem;

        address payGem;

        uint256 maxBuyGem;

        address buyGem;

        (maxPayGem,payGem,maxBuyGem,buyGem) = oasis.getOffer(data.offerId);



        if (buyGem != address(weth)){

            errorReporter.revertTx("buyGem != address(weth)");

        }



        //Calculate quantity to buy

        uint256 amountToBuy = SafeMath.div( SafeMath.mul(amountToSpend, maxPayGem), maxBuyGem);



        if (!oasis.buy(data.offerId, amountToBuy)){

            errorReporter.revertTx("Oasis buy failed");

        }



        //Calculate actual amounts spent and got

        uint256 newMaxPayGem;

        uint256 newMaxBuyGem;

        (newMaxPayGem,,newMaxBuyGem,) = oasis.getOffer(data.offerId);



        amountReceivedFromOrder = maxPayGem - newMaxPayGem;

        amountSpentOnOrder = maxBuyGem - newMaxBuyGem;



        //If we didn't spend all the eth, withdraw it from weth and send back to totlePrimary

        if (amountSpentOnOrder < amountToSpend){

          /* logger.log("Got some ether left, withdrawing arg2: amountSpentOnOrder, arg3: amountToSpend", amountSpentOnOrder, amountToSpend); */

          weth.withdraw(amountToSpend - amountSpentOnOrder);

          msg.sender.transfer(amountToSpend - amountSpentOnOrder);

        }



        //Send the purchased tokens back to totlePrimary

        if (!ERC20(payGem).transfer(msg.sender, amountReceivedFromOrder)){

            errorReporter.revertTx("Unable to transfer bought tokens to totlePrimary");

        }

    }



    /// @notice Perform a sell order at the exchange

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".

    /// @param data OrderData struct containing order values

    /// @param amountToSpend amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        OrderData data,

        uint256 amountToSpend

    )

        public

        whenNotPaused

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

      //Fetch offer data and validate buy gem is weth

      uint256 maxPayGem;

      address payGem;

      uint256 maxBuyGem;

      address buyGem;

      (maxPayGem,payGem,maxBuyGem,buyGem) = oasis.getOffer(data.offerId);



      /* logger.log("Performing Oasis sell order arg2: amountToSpend", amountToSpend); */



      if (payGem != address(weth)){

          errorReporter.revertTx("payGem != address(weth)");

      }



      //Approve oasis to move buy gem

      approveAddress(address(oasis), address(buyGem));



      /* logger.log("Address approved"); */



      //Calculate quantity to buy

      uint256 amountToBuy = SafeMath.div( SafeMath.mul(amountToSpend, maxPayGem), maxBuyGem);

      if(amountToBuy == 0){

          /* logger.log("Amount to buy is zero, amountToSpend was likely too small to get any. Did the previous order fill all but a small amount? arg2: amountToSpend", amountToSpend); */

          ERC20(buyGem).transfer(msg.sender, amountToSpend);

          return (0, 0);

      }

      if (!oasis.buy(data.offerId, amountToBuy)){

          errorReporter.revertTx("Oasis buy failed");

      }



      //Calculate actual amounts spent and got

      uint256 newMaxPayGem;

      uint256 newMaxBuyGem;

      (newMaxPayGem,,newMaxBuyGem,) = oasis.getOffer(data.offerId);



      amountReceivedFromOrder = maxPayGem - newMaxPayGem;

      amountSpentOnOrder = maxBuyGem - newMaxBuyGem;



      //If we didn't spend all the tokens, withdraw it from weth and send back to totlePrimary

      if (amountSpentOnOrder < amountToSpend){

        /* logger.log("Got some tokens left, withdrawing arg2: amountSpentOnOrder, arg3: amountToSpend", amountSpentOnOrder, amountToSpend); */

        ERC20(buyGem).transfer(msg.sender, amountToSpend - amountSpentOnOrder);

      }



      //Send the purchased tokens back to totlePrimary

      weth.withdraw(amountReceivedFromOrder);

      msg.sender.transfer(amountReceivedFromOrder);

    }



    /// @notice Changes the current contract address set as WETH

    /// @param wethAddress the address of the new WETH contract

    function setWeth(

        address wethAddress

    )

        public

        onlyOwner

    {

        require(wethAddress != address(0x0));

        weth = WethInterface(wethAddress);

    }



    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {

        if (genericSelector == getAmountToGiveSelector) {

            return bytes4(keccak256("getAmountToGive((uint256,uint256))"));

        } else if (genericSelector == staticExchangeChecksSelector) {

            return bytes4(keccak256("staticExchangeChecks((uint256,uint256))"));

        } else if (genericSelector == performBuyOrderSelector) {

            return bytes4(keccak256("performBuyOrder((uint256,uint256),uint256)"));

        } else if (genericSelector == performSellOrderSelector) {

            return bytes4(keccak256("performSellOrder((uint256,uint256),uint256)"));

        } else {

            return bytes4(0x0);

        }

    }



    /*

    *   Payable fallback function

    */



    /// @notice payable fallback to allow handler or exchange contracts to return ether

    /// @dev only accounts containing code (ie. contracts) can send ether to this contract

    function() public payable whenNotPaused {

        // Check in here that the sender is a contract! (to stop accidents)

        uint256 size;

        address sender = msg.sender;

        assembly {

            size := extcodesize(sender)

        }

        if (size == 0) {

            errorReporter.revertTx("EOA cannot send ether to primary fallback");

        }

    }

}