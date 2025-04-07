/**

 *Submitted for verification at Etherscan.io on 2018-09-18

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



@title TokenIOCurrencyAuthority - Currency Authority Smart Contract for Token, Inc.



@author Ryan Tate <[email protected]>, Sean Pollock <[email protected]>



@notice Contract uses generalized storage contract, `TokenIOStorage`, for

upgradeability of interface contract.

*/



contract TokenIOCurrencyAuthority is Ownable {



    /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage */

    using TokenIOLib for TokenIOLib.Data;

    TokenIOLib.Data lib;



    /**

     * @notice Constructor method for CurrencyAuthority contract

     * @param _storageContract Address of TokenIOStorage contract

     */

    constructor(address _storageContract) public {

        /**

         * @notice Set the storage contract for the interface

         * @dev This contract will be unable to use the storage constract until

         * @dev Contract address is authorized with the storage contract

         */

        lib.Storage = TokenIOStorage(_storageContract);



        // @dev set owner to contract initiator

        owner[msg.sender] = true;

    }



    /**

     * @notice Gets balance of sepcified account for a given currency

     * @param currency Currency symbol 'USDx'

     * @param account Sepcified account address

     * @return { "balance": "Returns account balance"}

     */

    function getTokenBalance(string currency, address account) public view returns (uint balance) {

      return lib.getTokenBalance(currency, account);

    }



    /**

     * @notice Gets total supply of specified currency

     * @param currency Currency symbol 'USDx'

     * @return { "supply": "Returns total supply of currency"}

     */

    function getTokenSupply(string currency) public view returns (uint supply) {

      return lib.getTokenSupply(currency);

    }



    /**

     * @notice Updates account status. false: frozen, true: un-frozen

     * @param account Sepcified account address

     * @param isAllowed Frozen status

     * @param issuerFirm Name of the issuer firm with authority on account holder;

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function freezeAccount(address account, bool isAllowed, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

        // @notice updates account status

        // @dev !!! mutates storage state

        require(

          lib.setAccountStatus(account, isAllowed, issuerFirm),

          "Error: Unable to freeze account. Please check issuerFirm and firm authority are registered"

        );

        return true;

    }



    /**

     * @notice Sets approval status of specified account

     * @param account Sepcified account address

     * @param isApproved Frozen status

     * @param issuerFirm Name of the issuer firm with authority on account holder;

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function approveKYC(address account, bool isApproved, uint limit, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

        // @notice updates kyc approval status

        // @dev !!! mutates storage state

        require(

          lib.setKYCApproval(account, isApproved, issuerFirm),

          "Error: Unable to approve account. Please check issuerFirm and firm authority are registered"

        );

        // @notice updates account statuss

        // @dev !!! mutates storage state

        require(

          lib.setAccountStatus(account, isApproved, issuerFirm),

          "Error: Unable to set account status. Please check issuerFirm and firm authority are registered"

        );

        require(

          lib.setAccountSpendingLimit(account, limit),

          "Error: Unable to set initial spending limit for account. Please check issuerFirm and firm authority are registered"

        );

        require(

          lib.setAccountSpendingPeriod(account, (now + 86400)),

          "Error: Unable to set spending period for account. Please check issuerFirm and firm authority are registered"

        );

        return true;

    }



    /**

     * @notice Approves account and deposits specified amount of given currency

     * @param currency Currency symbol of amount to be deposited;

     * @param account Ethereum address of account holder;

     * @param amount Deposit amount for account holder;

     * @param issuerFirm Name of the issuer firm with authority on account holder;

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function approveKYCAndDeposit(string currency, address account, uint amount, uint limit, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

        /// @notice updates kyc approval status

        /// @dev !!! mutates storage state

        require(

          lib.setKYCApproval(account, true, issuerFirm),

          "Error: Unable to approve account. Please check issuerFirm and firm authority are registered"

        );

        /// @notice updates kyc approval status

        /// @dev !!! mutates storage state

        require(

          lib.setAccountStatus(account, true, issuerFirm),

          "Error: Unable to set account status. Please check issuerFirm and firm authority are registered"

        );

        require(

          lib.deposit(currency, account, amount, issuerFirm),

          "Error: Unable to deposit funds. Please check issuerFirm and firm authority are registered"

        );

        require(

          lib.setAccountSpendingLimit(account, limit),

          "Error: Unable to set initial spending limit for account. Please check issuerFirm and firm authority are registered"

        );

        require(

          lib.setAccountSpendingPeriod(account, (now + 86400)),

          "Error: Unable to set spending period for account. Please check issuerFirm and firm authority are registered"

        );

        return true;

    }



    /**

     * @notice Sets the spending limit for a given account

     * @param account Ethereum address of account holder;

     * @param limit Spending limit amount for account;

     * @param issuerFirm Name of the issuer firm with authority on account holder;

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function setAccountSpendingLimit(address account, uint limit, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

      require(

        lib.setAccountSpendingLimit(account, limit),

        "Error: Unable to set initial spending limit for account. Please check issuerFirm and firm authority are registered"

      );

      return true;

    }



    /**

     * @notice Returns the periodic remaining spending amount for an account

     * @param  account Ethereum address of account holder;

     * @return {"spendingRemaining" : "Returns the remaining spending amount for the account"}

     */

    function getAccountSpendingRemaining(address account) public view returns (uint spendingRemaining) {

      return lib.getAccountSpendingRemaining(account);

    }



    /**

     * @notice Return the spending limit for an account

     * @param  account Ethereum address of account holder

     * @return {"spendingLimit" : "Returns the remaining daily spending limit of the account"}

     */

    function getAccountSpendingLimit(address account) public view returns (uint spendingLimit) {

      return lib.getAccountSpendingLimit(account);

    }



    /**

     * @notice Set the foreign currency exchange rate to USD in basis points

     * @dev NOTE: This value should always be relative to USD pair; e.g. JPY/USD, GBP/USD, etc.

     * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)

     * @param bpsRate Basis point rate of foreign currency exchange rate to USD

     * @param issuerFirm Firm setting the foreign currency exchange

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function setFxBpsRate(string currency, uint bpsRate, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

      require(

        lib.setFxUSDBPSRate(currency, bpsRate),

        "Error: Unable to set FX USD basis points rate. Please ensure issuerFirm is authorized"

      );

      return true;

    }



    /**

     * @notice Return the foreign currency USD exchanged amount

     * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)

     * @param fxAmount Amount of foreign currency to exchange into USD

     * @return {"usdAmount" : "Returns the foreign currency amount in USD"}

     */

    function getFxUSDAmount(string currency, uint fxAmount) public view returns (uint usdAmount) {

      return lib.getFxUSDAmount(currency, fxAmount);

    }



    /**

     * @notice Updates to new forwarded account

     * @param originalAccount [address]

     * @param updatedAccount [address]

     * @param issuerFirm Name of the issuer firm with authority on account holder;

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function approveForwardedAccount(address originalAccount, address updatedAccount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

        // @notice updatesa forwarded account

        // @dev !!! mutates storage state

        require(

          lib.setForwardedAccount(originalAccount, updatedAccount),

          "Error: Unable to set forwarded address for account. Please check issuerFirm and firm authority are registered"

        );

        return true;

    }



    /**

     * @notice Issues a specified account to recipient account of a given currency

     * @param currency [string] currency symbol

     * @param amount [uint] issuance amount

     * @param issuerFirm Name of the issuer firm with authority on account holder;

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function deposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

        require(

          lib.verifyAccount(account),

          "Error: Account is not verified!"

        );

        // @notice depositing tokens to account

        // @dev !!! mutates storage state

        require(

          lib.deposit(currency, account, amount, issuerFirm),

          "Error: Unable to deposit funds. Please check issuerFirm and firm authority are registered"

        );

        return true;

    }



    /**

     * @notice Withdraws a specified amount of tokens of a given currency

     * @param currency Currency symbol

     * @param account Ethereum address of account holder

     * @param amount Issuance amount

     * @param issuerFirm Name of the issuer firm with authority on account holder

     * @return { "success": "Returns true if successfully called from another contract"}

     */

    function withdraw(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {

        require(

          lib.verifyAccount(account),

          "Error: Account is not verified!"

        );

        // @notice withdrawing from account

        // @dev !!! mutates storage state

        require(

          lib.withdraw(currency, account, amount, issuerFirm),

          "Error: Unable to withdraw funds. Please check issuerFirm and firm authority are registered and have issued funds that can be withdrawn"

        );

        return true;

    }



    /**

     * @notice Ensure only authorized currency firms and authorities can modify protected methods

     * @dev authority must be registered to an authorized firm to use protected methods

     */

    modifier onlyAuthority(string firmName, address authority) {

        // @notice throws if authority account is not registred to the given firm

        require(

          lib.isRegisteredToFirm(firmName, authority),

          "Error: issuerFirm and/or firm authority are not registered"

        );

        _;

    }



}