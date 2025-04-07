pragma solidity ^0.4.23;



// File: contracts/common/Ownable.sol



/**

 * Ownable contract from Open zepplin

 * https://github.com/OpenZeppelin/openzeppelin-solidity/

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/common/ReentrancyGuard.sol



/**

 * Reentrancy guard from open Zepplin :

 * https://github.com/OpenZeppelin/openzeppelin-solidity/

 *

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



// File: contracts/interfaces/ERC20Interface.sol







//TODO : Flattener does not like aliased imports. Not needed in actual codebase.









// File: contracts/interfaces/IBancorNetwork.sol



contract IBancorNetwork {

    function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);

    function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);

    function convertForPrioritized2(

        IERC20Token[] _path,

        uint256 _amount,

        uint256 _minReturn,

        address _for,

        uint256 _block,

        uint8 _v,

        bytes32 _r,

        bytes32 _s)

        public payable returns (uint256);



    // deprecated, backward compatibility

    function convertForPrioritized(

        IERC20Token[] _path,

        uint256 _amount,

        uint256 _minReturn,

        address _for,

        uint256 _block,

        uint256 _nonce,

        uint8 _v,

        bytes32 _r,

        bytes32 _s)

        public payable returns (uint256);

}



/*

   Bancor Contract Registry interface

*/

contract IContractRegistry {

    function getAddress(bytes32 _contractName) public view returns (address);

}



// File: contracts/TokenPaymentBancor.sol



/*

 * @title Token Payment using Bancor API v0.1

 * @author Haresh G

 * @dev This contract is used to convert ETH to an ERC20 token on the Bancor network.

 * @notice It does not support ERC20 to ERC20 transfer.

 */















contract IndTokenPayment is Ownable, ReentrancyGuard {  

    IERC20Token[] public path;    

    address public destinationWallet;       

    uint256 public minConversionRate;

    IContractRegistry public bancorRegistry;

    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";

    

    event conversionSucceded(address from,uint256 fromTokenVal,address dest,uint256 destTokenVal);    

    

    constructor(IERC20Token[] _path,

                address destWalletAddr,

                address bancorRegistryAddr,

                uint256 minConvRate){

        path = _path;

        bancorRegistry = IContractRegistry(bancorRegistryAddr);

        destinationWallet = destWalletAddr;         

        minConversionRate = minConvRate;

    }



    function setConversionPath(IERC20Token[] _path) public onlyOwner {

        path = _path;

    }

    

    function setBancorRegistry(address bancorRegistryAddr) public onlyOwner {

        bancorRegistry = IContractRegistry(bancorRegistryAddr);

    }



    function setMinConversionRate(uint256 minConvRate) public onlyOwner {

        minConversionRate = minConvRate;

    }    



    function setDestinationWallet(address destWalletAddr) public onlyOwner {

        destinationWallet = destWalletAddr;

    }    

    

    function convertToInd() internal nonReentrant {

        assert(bancorRegistry.getAddress(BANCOR_NETWORK) != address(0));

        IBancorNetwork bancorNetwork = IBancorNetwork(bancorRegistry.getAddress(BANCOR_NETWORK));   

        //TODO : Compute minReturn

        uint256 minReturn =0;

        uint256 convTokens =  bancorNetwork.convertFor.value(msg.value)(path,msg.value,minReturn,destinationWallet);        

        assert(convTokens > 0);

        emit conversionSucceded(msg.sender,msg.value,destinationWallet,convTokens);                                                                    

    }



    //If accidentally tokens are transferred to this

    //contract. They can be withdrawn by the followin interface.

    function withdrawToken(IERC20Token anyToken) public onlyOwner nonReentrant returns(bool){

        if( anyToken != address(0x0) ) {

            assert(anyToken.transfer(destinationWallet, anyToken.balanceOf(this)));

        }

        return true;

    }



    //ETH cannot get locked in this contract. If it does, this can be used to withdraw

    //the locked ether.

    function withdrawEther() public onlyOwner nonReentrant returns(bool){

        if(address(this).balance > 0){

            destinationWallet.transfer(address(this).balance);

        }        

        return true;

    }

 

    function () public payable {

        //Bancor contract can send the transfer back in case of error, which goes back into this

        //function ,convertToInd is non-reentrant.

        convertToInd();

    }



    /*

    * Helper functions to debug contract. Not to be deployed

    *

    */



    function getBancorContractAddress() public returns(address) {

        return bancorRegistry.getAddress(BANCOR_NETWORK);

    }



}