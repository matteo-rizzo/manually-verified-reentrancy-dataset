/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.24;



// File: contracts\CloneFactory.sol



/**

*This contracts helps clone factories and swaps through the Deployer.sol and MasterDeployer.sol.

*The address of the targeted contract to clone has to be provided.

*/

contract CloneFactory {



    /*Variables*/

    address internal owner;

    

    /*Events*/

    event CloneCreated(address indexed target, address clone);



    /*Modifiers*/

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    /*Functions*/

    constructor() public{

        owner = msg.sender;

    }    

    

    /**

    *@dev Allows the owner to set a new owner address

    *@param _owner the new owner address

    */

    function setOwner(address _owner) public onlyOwner(){

        owner = _owner;

    }



    /**

    *@dev Creates factory clone

    *@param _target is the address being cloned

    *@return address for clone

    */

    function createClone(address target) internal returns (address result) {

        bytes memory clone = hex"600034603b57603080600f833981f36000368180378080368173bebebebebebebebebebebebebebebebebebebebe5af43d82803e15602c573d90f35b3d90fd";

        bytes20 targetBytes = bytes20(target);

        for (uint i = 0; i < 20; i++) {

            clone[26 + i] = targetBytes[i];

        }

        assembly {

            let len := mload(clone)

            let data := add(clone, 0x20)

            result := create(0, data, len)

        }

    }

}



// File: contracts\interfaces\DRCT_Token_Interface.sol



//DRCT_Token functions - descriptions can be found in DRCT_Token.sol





// File: contracts\interfaces\ERC20_Interface.sol



//ERC20 function interface





// File: contracts\interfaces\Factory_Interface.sol



//Swap factory functions - descriptions can be found in Factory.sol





// File: contracts\interfaces\Oracle_Interface.sol



//Swap Oracle functions - descriptions can be found in Oracle.sol





// File: contracts\libraries\SafeMath.sol



//Slightly modified SafeMath library - includes a min function





// File: contracts\libraries\TokenLibrary.sol



/**

*The TokenLibrary contains the reference code used to create the specific DRCT base contract 

*that holds the funds of the contract and redistributes them based upon the change in the

*underlying values

*/







// File: contracts\TokenToTokenSwap.sol



/**

*This contract is the specific DRCT base contract that holds the funds of the contract and

*redistributes them based upon the change in the underlying values

*/



contract TokenToTokenSwap {



    using TokenLibrary for TokenLibrary.SwapStorage;



    /*Variables*/

    TokenLibrary.SwapStorage public swap;





    /*Functions*/

    /**

    *@dev Constructor - Run by the factory at contract creation

    *@param _factory_address address of the factory that created this contract

    *@param _creator address of the person who created the contract

    *@param _userContract address of the _userContract that is authorized to interact with this contract

    *@param _start_date start date of the contract

    */

    constructor (address _factory_address, address _creator, address _userContract, uint _start_date) public {

        swap.startSwap(_factory_address,_creator,_userContract,_start_date);

    }

    

    /**

    *@dev Acts as a constructor when cloning the swap

    *@param _factory_address address of the factory that created this contract

    *@param _creator address of the person who created the contract

    *@param _userContract address of the _userContract that is authorized to interact with this contract

    *@param _start_date start date of the contract

    */

    function init (address _factory_address, address _creator, address _userContract, uint _start_date) public {

        swap.startSwap(_factory_address,_creator,_userContract,_start_date);

    }



    /**

    *@dev A getter function for retriving standardized variables from the factory contract

    *@return 

    *[userContract, Long Token addresss, short token address, oracle address, base token address], number DRCT tokens, , multiplier, duration, Start date, end_date

    */

    function showPrivateVars() public view returns (address[5],uint, uint, uint, uint, uint){

        return swap.showPrivateVars();

    }



    /**

    *@dev A getter function for retriving current swap state from the factory contract

    *@return current state (References swapState Enum: 1=created, 2=started, 3=ended)

    */

    function currentState() public view returns(uint){

        return swap.showCurrentState();

    }



    /**

    *@dev Allows the sender to create the terms for the swap

    *@param _amount Amount of Token that should be deposited for the notional

    *@param _senderAdd States the owner of this side of the contract (does not have to be msg.sender)

    */

    function createSwap(uint _amount, address _senderAdd) public {

        swap.createSwap(_amount,_senderAdd);

    }



    /**

    *@dev This function can be called after the swap is tokenized or after the Calculate function is called.

    *If the Calculate function has not yet been called, this function will call it.

    *The function then pays every token holder of both the long and short DRCT tokens

    *@param _topay number of contracts to try and pay (run it again if its not enough)

    *@return true if the oracle was called and all contracts were paid out or false once ?

    */

    function forcePay(uint _topay) public returns (bool) {

       swap.forcePay(_topay);

    }





}



// File: contracts\Deployer.sol



/**

*Swap Deployer Contract - purpose is to save gas for deployment of Factory contract.

*It ensures only the factory can create new contracts and uses CloneFactory to clone 

*the swap specified.

*/



contract Deployer is CloneFactory {

    /*Variables*/

    address internal factory;

    address public swap;

    

    /*Events*/

    event Deployed(address indexed master, address indexed clone);



    /*Functions*/

    /**

    *@dev Deploys the factory contract and swap address

    *@param _factory is the address of the factory contract

    */    

    constructor(address _factory) public {

        factory = _factory;

        swap = new TokenToTokenSwap(address(this),msg.sender,address(this),now);

    }



    /**

    *@dev Set swap address to clone

    *@param _addr swap address to clone

    */

    function updateSwap(address _addr) public onlyOwner() {

        swap = _addr;

    }

        

    /**

    *@notice The function creates a new contract

    *@dev It ensures the new contract can only be created by the factory

    *@param _party address of user creating the contract

    *@param user_contract address of userContract.sol 

    *@param _start_date contract start date

    *@return returns the address for the new contract

    */

    function newContract(address _party, address _user, uint _start) public returns (address) {

        address new_swap = createClone(swap);

        TokenToTokenSwap(new_swap).init(factory, _party, _user, _start);

        emit Deployed(swap, new_swap);

        return new_swap;

    }



    /**

    *@dev Set variables if the owner is the factory contract

    *@param _factory address

    *@param _owner address

    */

    function setVars(address _factory, address _owner) public {

        require (msg.sender == owner);

        factory = _factory;

        owner = _owner;

    }

}