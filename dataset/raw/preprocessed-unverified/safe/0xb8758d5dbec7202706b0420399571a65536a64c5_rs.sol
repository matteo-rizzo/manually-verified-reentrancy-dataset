/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



pragma solidity 0.4.24;





/**

 * @title SafeMath

 * @notice Math operations with safety checks that throw on error

 */







/**



COPYRIGHT 2018 Token, Inc.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,

INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A

PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR

COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER

IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION

WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





@title Ownable

@dev The Ownable contract has an owner address, and provides basic authorization control

functions, this simplifies the implementation of "user permissions".





 */





/**



COPYRIGHT 2018 Token, Inc.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,

INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A

PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR

COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER

IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION

WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





@title TokenIOStorage - Serves as derived contract for TokenIO contract and

is used to upgrade interfaces in the event of deprecating the main contract.



@author Ryan Tate <[email protected]>, Sean Pollock <[email protected]>



@notice Storage contract



@dev In the event that the main contract becomes deprecated, the upgraded contract

will be set as the owner of this contract, and use this contract's storage to

maintain data consistency between contract.



@notice NOTE: This contract is based on the RocketPool Storage Contract,

found here: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol

And this medium article: https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d



Changes:

 - setting primitive mapping view to internal;

 - setting method views to public;



 @dev NOTE: When deprecating the main TokenIO contract, the upgraded contract

 must take ownership of the TokenIO contract, it will require using the public methods

 to update changes to the underlying data. The updated contract must use a

 standard call to original TokenIO contract such that the  request is made from

 the upgraded contract and not the transaction origin (tx.origin) of the signing

 account.





 @dev NOTE: The reasoning for using the storage contract is to abstract the interface

 from the data of the contract on chain, limiting the need to migrate data to

 new contracts.



*/

contract TokenIOStorage is Ownable {





    /// @dev mapping for Primitive Data Types;

		/// @notice primitive data mappings have `internal` view;

		/// @dev only the derived contract can use the internal methods;

		/// @dev key == `keccak256(param1, param2...)`

		/// @dev Nested mapping can be achieved using multiple params in keccak256 hash;

    mapping(bytes32 => uint256)    internal uIntStorage;

    mapping(bytes32 => string)     internal stringStorage;

    mapping(bytes32 => address)    internal addressStorage;

    mapping(bytes32 => bytes)      internal bytesStorage;

    mapping(bytes32 => bool)       internal boolStorage;

    mapping(bytes32 => int256)     internal intStorage;



    constructor() public {

				/// @notice owner is set to msg.sender by default

				/// @dev consider removing in favor of setting ownership in inherited

				/// contract

        owner[msg.sender] = true;

    }



    /// @dev Set Key Methods



    /**

     * @notice Set value for Address associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @param _value The Address value to be set

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function setAddress(bytes32 _key, address _value) public onlyOwner returns (bool success) {

        addressStorage[_key] = _value;

        return true;

    }



    /**

     * @notice Set value for Uint associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @param _value The Uint value to be set

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function setUint(bytes32 _key, uint _value) public onlyOwner returns (bool success) {

        uIntStorage[_key] = _value;

        return true;

    }



    /**

     * @notice Set value for String associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @param _value The String value to be set

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function setString(bytes32 _key, string _value) public onlyOwner returns (bool success) {

        stringStorage[_key] = _value;

        return true;

    }



    /**

     * @notice Set value for Bytes associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @param _value The Bytes value to be set

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function setBytes(bytes32 _key, bytes _value) public onlyOwner returns (bool success) {

        bytesStorage[_key] = _value;

        return true;

    }



    /**

     * @notice Set value for Bool associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @param _value The Bool value to be set

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function setBool(bytes32 _key, bool _value) public onlyOwner returns (bool success) {

        boolStorage[_key] = _value;

        return true;

    }



    /**

     * @notice Set value for Int associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @param _value The Int value to be set

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function setInt(bytes32 _key, int _value) public onlyOwner returns (bool success) {

        intStorage[_key] = _value;

        return true;

    }



    /// @dev Delete Key Methods

		/// @dev delete methods may be unnecessary; Use set methods to set values

		/// to default?



    /**

     * @notice Delete value for Address associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function deleteAddress(bytes32 _key) public onlyOwner returns (bool success) {

        delete addressStorage[_key];

        return true;

    }



    /**

     * @notice Delete value for Uint associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function deleteUint(bytes32 _key) public onlyOwner returns (bool success) {

        delete uIntStorage[_key];

        return true;

    }



    /**

     * @notice Delete value for String associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function deleteString(bytes32 _key) public onlyOwner returns (bool success) {

        delete stringStorage[_key];

        return true;

    }



    /**

     * @notice Delete value for Bytes associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function deleteBytes(bytes32 _key) public onlyOwner returns (bool success) {

        delete bytesStorage[_key];

        return true;

    }



    /**

     * @notice Delete value for Bool associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function deleteBool(bytes32 _key) public onlyOwner returns (bool success) {

        delete boolStorage[_key];

        return true;

    }



    /**

     * @notice Delete value for Int associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "success" : "Returns true when successfully called from another contract" }

     */

    function deleteInt(bytes32 _key) public onlyOwner returns (bool success) {

        delete intStorage[_key];

        return true;

    }



    /// @dev Get Key Methods



    /**

     * @notice Get value for Address associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "_value" : "Returns the Address value associated with the id key" }

     */

    function getAddress(bytes32 _key) public view returns (address _value) {

        return addressStorage[_key];

    }



    /**

     * @notice Get value for Uint associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "_value" : "Returns the Uint value associated with the id key" }

     */

    function getUint(bytes32 _key) public view returns (uint _value) {

        return uIntStorage[_key];

    }



    /**

     * @notice Get value for String associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "_value" : "Returns the String value associated with the id key" }

     */

    function getString(bytes32 _key) public view returns (string _value) {

        return stringStorage[_key];

    }



    /**

     * @notice Get value for Bytes associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "_value" : "Returns the Bytes value associated with the id key" }

     */

    function getBytes(bytes32 _key) public view returns (bytes _value) {

        return bytesStorage[_key];

    }



    /**

     * @notice Get value for Bool associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "_value" : "Returns the Bool value associated with the id key" }

     */

    function getBool(bytes32 _key) public view returns (bool _value) {

        return boolStorage[_key];

    }



    /**

     * @notice Get value for Int associated with bytes32 id key

     * @param _key Pointer identifier for value in storage

     * @return { "_value" : "Returns the Int value associated with the id key" }

     */

    function getInt(bytes32 _key) public view returns (int _value) {

        return intStorage[_key];

    }



}



/**

COPYRIGHT 2018 Token, Inc.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,

INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A

PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR

COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER

IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION

WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





@title TokenIOLib



@author Ryan Tate <[email protected]>, Sean Pollock <[email protected]>



@notice This library proxies the TokenIOStorage contract for the interface contract,

allowing the library and the interfaces to remain stateless, and share a universally

available storage contract between interfaces.





*/









/*

COPYRIGHT 2018 Token, Inc.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,

INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A

PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR

COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER

IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION

WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



@title ERC20 Compliant Smart Contract for Token, Inc.



@author Ryan Tate <[email protected]>, Sean Pollock <[email protected]>



@notice Contract uses generalized storage contract, `TokenIOStorage`, for

upgradeability of interface contract.



@dev In the event that the main contract becomes deprecated, the upgraded contract

will be set as the owner of this contract, and use this contract's storage to

maintain data consistency between contract.

*/







contract TokenIOERC20 is Ownable {

  //// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage

  using TokenIOLib for TokenIOLib.Data;

  TokenIOLib.Data lib;



  /**

  * @notice Constructor method for ERC20 contract

  * @param _storageContract     address of TokenIOStorage contract

  */

  constructor(address _storageContract) public {

    //// @dev Set the storage contract for the interface

    //// @dev This contract will be unable to use the storage constract until

    //// @dev contract address is authorized with the storage contract

    //// @dev Once authorized, Use the `setParams` method to set storage values

    lib.Storage = TokenIOStorage(_storageContract);



    //// @dev set owner to contract initiator

    owner[msg.sender] = true;

  }





  /**

  @notice Sets erc20 globals and fee paramters

  @param _name Full token name  'USD by token.io'

  @param _symbol Symbol name 'USDx'

  @param _tla Three letter abbreviation 'USD'

  @param _version Release version 'v0.0.1'

  @param _decimals Decimal precision

  @param _feeContract Address of fee contract

  @return { "success" : "Returns true if successfully called from another contract"}

  */

  function setParams(

    string _name,

    string _symbol,

    string _tla,

    string _version,

    uint _decimals,

    address _feeContract,

    uint _fxUSDBPSRate

    ) onlyOwner public returns (bool success) {

      require(lib.setTokenName(_name),

        "Error: Unable to set token name. Please check arguments.");

      require(lib.setTokenSymbol(_symbol),

        "Error: Unable to set token symbol. Please check arguments.");

      require(lib.setTokenTLA(_tla),

        "Error: Unable to set token TLA. Please check arguments.");

      require(lib.setTokenVersion(_version),

        "Error: Unable to set token version. Please check arguments.");

      require(lib.setTokenDecimals(_symbol, _decimals),

        "Error: Unable to set token decimals. Please check arguments.");

      require(lib.setFeeContract(_feeContract),

        "Error: Unable to set fee contract. Please check arguments.");

      require(lib.setFxUSDBPSRate(_symbol, _fxUSDBPSRate),

        "Error: Unable to set fx USD basis points rate. Please check arguments.");

      return true;

    }



    /**

    * @notice Gets name of token

    * @return {"_name" : "Returns name of token"}

    */

    function name() public view returns (string _name) {

      return lib.getTokenName(address(this));

    }



    /**

    * @notice Gets symbol of token

    * @return {"_symbol" : "Returns symbol of token"}

    */

    function symbol() public view returns (string _symbol) {

      return lib.getTokenSymbol(address(this));

    }



    /**

    * @notice Gets three-letter-abbreviation of token

    * @return {"_tla" : "Returns three-letter-abbreviation of token"}

    */

    function tla() public view returns (string _tla) {

      return lib.getTokenTLA(address(this));

    }



    /**

    * @notice Gets version of token

    * @return {"_version" : "Returns version of token"}

    */

    function version() public view returns (string _version) {

      return lib.getTokenVersion(address(this));

    }



    /**

    * @notice Gets decimals of token

    * @return {"_decimals" : "Returns number of decimals"}

    */

    function decimals() public view returns (uint _decimals) {

      return lib.getTokenDecimals(lib.getTokenSymbol(address(this)));

    }



    /**

    * @notice Gets total supply of token

    * @return {"supply" : "Returns current total supply of token"}

    */

    function totalSupply() public view returns (uint supply) {

      return lib.getTokenSupply(lib.getTokenSymbol(address(this)));

    }



    /**

    * @notice Gets allowance that spender has with approver

    * @param account Address of approver

    * @param spender Address of spender

    * @return {"amount" : "Returns allowance of given account and spender"}

    */

    function allowance(address account, address spender) public view returns (uint amount) {

      return lib.getTokenAllowance(lib.getTokenSymbol(address(this)), account, spender);

    }



    /**

    * @notice Gets balance of account

    * @param account Address for balance lookup

    * @return {"balance" : "Returns balance amount"}

    */

    function balanceOf(address account) public view returns (uint balance) {

      return lib.getTokenBalance(lib.getTokenSymbol(address(this)), account);

    }



    /**

    * @notice Gets fee parameters

    * @return {

      "bps":"Fee amount as a mesuare of basis points",

      "min":"Minimum fee amount",

      "max":"Maximum fee amount",

      "flat":"Flat fee amount",

      "contract":"Address of fee contract"

      }

    */

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes feeMsg, address feeAccount) {

      address feeContract = lib.getFeeContract(address(this));

      return (

        lib.getFeeBPS(feeContract),

        lib.getFeeMin(feeContract),

        lib.getFeeMax(feeContract),

        lib.getFeeFlat(feeContract),

        lib.getFeeMsg(feeContract),

        feeContract

      );

    }



    /**

    * @notice Calculates fee of a given transfer amount

    * @param amount Amount to calculcate fee value

    * @return {"fees": "Returns the calculated transaction fees based on the fee contract parameters"}

    */

    function calculateFees(uint amount) public view returns (uint fees) {

      return lib.calculateFees(lib.getFeeContract(address(this)), amount);

    }



    /**

    * @notice transfers 'amount' from msg.sender to a receiving account 'to'

    * @param to Receiving address

    * @param amount Transfer amount

    * @return {"success" : "Returns true if transfer succeeds"}

    */

    function transfer(address to, uint amount) public notDeprecated returns (bool success) {

      /// @notice send transfer through library

      /// @dev !!! mutates storage state

      require(

        lib.transfer(lib.getTokenSymbol(address(this)), to, amount, "0x0"),

        "Error: Unable to transfer funds. Please check your parameters."

      );

      return true;

    }



    /**

    * @notice spender transfers from approvers account to the reciving account

    * @param from Approver's address

    * @param to Receiving address

    * @param amount Transfer amount

    * @return {"success" : "Returns true if transferFrom succeeds"}

    */

    function transferFrom(address from, address to, uint amount) public notDeprecated returns (bool success) {

      /// @notice sends transferFrom through library

      /// @dev !!! mutates storage state

      require(

        lib.transferFrom(lib.getTokenSymbol(address(this)), from, to, amount, "0x0"),

        "Error: Unable to transfer funds. Please check your parameters and ensure the spender has the approved amount of funds to transfer."

      );

      return true;

    }



    /**

    * @notice approves spender a given amount

    * @param spender Spender's address

    * @param amount Allowance amount

    * @return {"success" : "Returns true if approve succeeds"}

    */

    function approve(address spender, uint amount) public notDeprecated returns (bool success) {

      /// @notice sends approve through library

      /// @dev !!! mtuates storage states

      require(

        lib.approveAllowance(spender, amount),

        "Error: Unable to approve allowance for spender. Please ensure spender is not null and does not have a frozen balance."

      );

      return true;

    }



    /**

    * @notice gets currency status of contract

    * @return {"deprecated" : "Returns true if deprecated, false otherwise"}

    */

    function deprecateInterface() public onlyOwner returns (bool deprecated) {

      require(lib.setDeprecatedContract(address(this)),

        "Error: Unable to deprecate contract!");

      return true;

    }



    modifier notDeprecated() {

      /// @notice throws if contract is deprecated

      require(!lib.isContractDeprecated(address(this)),

        "Error: Contract has been deprecated, cannot perform operation!");

      _;

    }



  }