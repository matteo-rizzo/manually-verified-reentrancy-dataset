/**

 *Submitted for verification at Etherscan.io on 2018-12-14

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title HtczExchange

 * @dev Eth <-> HTCZ Exchange supporting contract

 */

contract HtczExchange is Ownable {



    using SafeMath for uint256;



    // ** Events **



    // Deposit received -> sent to exchange to HTCZ token

    event Deposit(address indexed sender, uint eth_amount, uint htcz_amount);



    // HTCZ token was sent in exchange for Ether

    event Exchanged(address indexed receiver, uint indexed htcz_tx, uint htcz_amount, uint eth_amount);



    // HTCZ Reserve amount changed

    event ReserveChanged(uint indexed htcz_tx, uint old_htcz_amount, uint new_htcz_amount);



    // Operator changed

    event OperatorChanged(address indexed new_operator);





    // ** Contract state **



    // HTCZ token (address is in ETZ network)

    address public htcz_token;



    // Source of wallet for reserve (address is in ETZ network)

    address public htcz_cold_wallet;



    // HTCZ wallet used to exchange (address is in ETZ network)

    address public htcz_exchange_wallet;



    // Operator account of the exchange

    address public operator;



    // HTCZ amount used for exchange, should not exceed htcz_reserve

    uint public htcz_exchanged_amount;



    // HTCZ reserve for exchange

    uint public htcz_reserve;



    // ETH -> HTCZ exchange rate

    uint public exchange_rate;



    // gas spending on transfer function

    uint constant GAS_FOR_TRANSFER = 49483;



    // ** Modifiers **



    // Throws if called by any account other than the operator.

    modifier onlyOperator() {

        require(msg.sender == operator);

        _;

    }



    constructor(    address _htcz_token,

                    address _htcz_cold_wallet,

                    address _htcz_exchange_wallet,

                    address _operator,

                    uint _exchange_rate ) public {



	    require(_htcz_token != address(0));

	    require(_htcz_cold_wallet != address(0));

	    require(_htcz_exchange_wallet != address(0));

	    require(_operator != address(0));

	    require(_exchange_rate>0);



	    htcz_token = _htcz_token;

	    htcz_cold_wallet = _htcz_cold_wallet;

	    htcz_exchange_wallet = _htcz_exchange_wallet;

	    exchange_rate = _exchange_rate;

	    operator = _operator;



    }



    /**

    * @dev Accepts Ether.

    * Throws is token balance is not available to issue HTCZ tokens

    */

    function() external payable {



        require( msg.value > 0 );



        uint eth_amount = msg.value;

        uint htcz_amount = eth_amount.mul(exchange_rate);



        htcz_exchanged_amount = htcz_exchanged_amount.add(htcz_amount);



        require( htcz_reserve >= htcz_exchanged_amount );



        emit Deposit(msg.sender, eth_amount, htcz_amount);

    }



    /**

    * @dev Transfers ether by operator command in exchange to HTCZ tokens

    * Calculates gas amount, gasprice and substracts that from the transfered amount.

    * Note, that smart contracts are not allowed as the receiver.

    */

    function change(address _receiver, uint _htcz_tx, uint _htcz_amount) external onlyOperator {



        require(_receiver != address(0));



        uint gas_value = GAS_FOR_TRANSFER.mul(tx.gasprice);

        uint eth_amount = _htcz_amount / exchange_rate;



        require(eth_amount > gas_value);



        eth_amount = eth_amount.sub(gas_value);



        require(htcz_exchanged_amount >= _htcz_amount );



        htcz_exchanged_amount = htcz_exchanged_amount.sub(_htcz_amount);



        msg.sender.transfer(gas_value);

        _receiver.transfer(eth_amount);



        emit Exchanged(_receiver, _htcz_tx, _htcz_amount, eth_amount);



    }



    /**

    * @dev Increase HTCZ reserve

    */

    function increaseReserve(uint _htcz_tx, uint _amount) external onlyOperator {



        uint old_htcz_reserve = htcz_reserve;

        uint new_htcz_reserve = old_htcz_reserve.add(_amount);



        require( new_htcz_reserve > old_htcz_reserve);



        htcz_reserve = new_htcz_reserve;



        emit ReserveChanged(_htcz_tx, old_htcz_reserve, new_htcz_reserve);



    }



    /**

    * @dev Decrease HTCZ reserve

    */

    function decreaseReserve(uint _htcz_tx, uint _amount) external onlyOperator {



        uint old_htcz_reserve = htcz_reserve;

        uint new_htcz_reserve = old_htcz_reserve.sub(_amount);



        require( new_htcz_reserve < old_htcz_reserve);

        require( new_htcz_reserve >= htcz_exchanged_amount );



        htcz_reserve = new_htcz_reserve;



        emit ReserveChanged(_htcz_tx, old_htcz_reserve, new_htcz_reserve);



    }





    /**

    * @dev Set other operator ( 0 allowed )

    */

    function changeOperator(address _operator) external onlyOwner {

        require(_operator != operator);

        operator = _operator;

        emit OperatorChanged(_operator);

    }





}