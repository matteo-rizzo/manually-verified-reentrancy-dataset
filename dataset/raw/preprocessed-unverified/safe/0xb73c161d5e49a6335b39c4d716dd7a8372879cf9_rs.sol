/**

 *Submitted for verification at Etherscan.io on 2018-11-02

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









/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 * @notice interface contract from Zeppelin token erc20;

 */





/*

COPYRIGHT 2018 Token, Inc.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,

INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A

PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR

COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER

IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION

WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



@title ERC20 Compliant StableCoin Swap Smart Contract for Token, Inc.



@author Ryan Tate <[email protected]>, Sean Pollock <[email protected]>



@notice Contract uses generalized storage contract, `TokenIOStorage`, for

upgradeability of interface contract.



@dev In the event that the main contract becomes deprecated, the upgraded contract

will be set as the owner of this contract, and use this contract's storage to

maintain data consistency between contract.

*/







contract TokenIOStableSwap is Ownable {

  /// @dev use safe math operations

  using SafeMath for uint;



  //// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage

  using TokenIOLib for TokenIOLib.Data;

  TokenIOLib.Data lib;



  event StableSwap(address fromAsset, address toAsset, address requestedBy, uint amount, string currency);

  event TransferredHoldings(address asset, address to, uint amount);

  event AllowedERC20Asset(address asset, string currency);

  event RemovedERC20Asset(address asset, string currency);



  /**

  * @notice Constructor method for TokenIOStableSwap contract

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

	 * @notice Allows the address of the asset to be accepted by this contract by the currency type. This method is only called by admins.

	 * @notice This method may be deprecated or refactored to allow for multiple interfaces

	 * @param  asset Ethereum address of the ERC20 compliant smart contract to allow the swap

	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)

   * @param feeBps Basis points Swap Fee

	 * @param feeMin Minimum Swap Fees

	 * @param feeMax Maximum Swap Fee

	 * @param feeFlat Flat Swap Fee

	 * @return { "success" : "Returns true if successfully called from another contract"}

	 */

	function allowAsset(address asset, string currency, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner notDeprecated returns (bool success) {

		bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));

    require(

      lib.Storage.setBool(id, true),

      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."

    );



    /// @notice set Currency for the asset;

    require(setAssetCurrency(asset, currency), 'Error: Unable to set Currency for asset');



    /// @notice set the Fee Params for the asset

    require(setAssetFeeParams(asset, feeBps, feeMin, feeMax, feeFlat), 'Error: Unable to set fee params for asset');



    /// @dev Log Allow ERC20 Asset

    emit AllowedERC20Asset(asset, currency);

		return true;

	}



  function removeAsset(address asset) public onlyOwner notDeprecated returns (bool success) {

    string memory currency = getAssetCurrency(asset);

    bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));

    require(

      lib.Storage.setBool(id, false),

      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."

    );

    emit RemovedERC20Asset(asset, currency);

    return true;

  }



	/**

	 * @notice Return boolean if the asset is an allowed stable asset for the corresponding currency

	 * @param  asset Ethereum address of the ERC20 compliant smart contract to check allowed status of

	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)

	 * @return {"allowed": "Returns true if the asset is allowed"}

	 */

	function isAllowedAsset(address asset, string currency) public view returns (bool allowed) {

		if (isTokenXContract(asset, currency)) {

			return true;

		} else {

			bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));

			return lib.Storage.getBool(id);

		}

	}



  /**

   * Set the Three Letter Abbrevation for the currency associated to the asset

   * @param asset Ethereum address of the asset to set the currency for

   * @param currency string Currency of the asset (NOTE: This is the currency for the asset)

   * @return { "success" : "Returns true if successfully called from another contract"}

   */

  function setAssetCurrency(address asset, string currency) public onlyOwner returns (bool success) {

    bytes32 id = keccak256(abi.encodePacked('asset.currency', asset));

    require(

      lib.Storage.setString(id, currency),

      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."

    );

    return true;

  }



  /**

   * Get the Currency for an associated asset;

   * @param asset Ethereum address of the asset to get the currency for

   * @return {"currency": "Returns the Currency of the asset if the asset has been allowed."}

   */

  function getAssetCurrency(address asset) public view returns (string currency) {

    bytes32 id = keccak256(abi.encodePacked('asset.currency', asset));

    return lib.Storage.getString(id);

  }



  /**

	 * @notice Register the address of the asset as a Token X asset for a specific currency

	 * @notice This method may be deprecated or refactored to allow for multiple interfaces

	 * @param  asset Ethereum address of the ERC20 compliant Token X asset

	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)

	 * @return { "success" : "Returns true if successfully called from another contract"}

	 */

	function setTokenXCurrency(address asset, string currency) public onlyOwner notDeprecated returns (bool success) {

    bytes32 id = keccak256(abi.encodePacked('tokenx', asset, currency));

    require(

      lib.Storage.setBool(id, true),

      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."

    );



    /// @notice set Currency for the asset;

    require(setAssetCurrency(asset, currency));



    return true;

	}



  /**

    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency

    * @param  asset Ethereum address of the asset to check if is a registered Token X stable coin asset

    * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)

    * @return {"allowed": "Returns true if the asset is allowed"}

   */

	function isTokenXContract(address asset, string currency) public view returns (bool isX) {

		bytes32 id = keccak256(abi.encodePacked('tokenx', asset, currency));

		return lib.Storage.getBool(id);

	}



  /**

   * @notice Set BPS, Min, Max, and Flat fee params for asset

   * @param asset Ethereum address of the asset to set fees for.

   * @param feeBps Basis points Swap Fee

	 * @param feeMin Minimum Swap Fees

	 * @param feeMax Maximum Swap Fee

	 * @param feeFlat Flat Swap Fee

	 * @return { "success" : "Returns true if successfully called from another contract"}

   */

  function setAssetFeeParams(address asset, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner notDeprecated returns (bool success) {

    /// @dev This method bypasses the setFee library methods and directly sets the fee params for a requested asset.

    /// @notice Fees can be different per asset. Some assets may have different liquidity requirements.

    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.max', asset)), feeMax),

      'Error: Failed to set fee parameters with storage contract. Please check permissions.');



    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.min', asset)), feeMin),

      'Error: Failed to set fee parameters with storage contract. Please check permissions.');



    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.bps', asset)), feeBps),

      'Error: Failed to set fee parameters with storage contract. Please check permissions.');



    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.flat', asset)), feeFlat),

      'Error: Failed to set fee parameters with storage contract. Please check permissions.');



    return true;

  }



  /**

   * [calcAssetFees description]

   * @param  asset Ethereum address of the asset to calculate fees based on

   * @param  amount Amount to calculate fees on

   * @return { "fees" : "Returns the fees for the amount associated with the asset contract"}

   */

  function calcAssetFees(address asset, uint amount) public view returns (uint fees) {

    return lib.calculateFees(asset, amount);

  }



  /**

    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency

    * @notice Amounts will always be passed in according to the decimal representation of the `fromAsset` token;

    * @param  fromAsset Ethereum address of the asset with allowance for this contract to transfer and

    * @param  toAsset Ethereum address of the asset to check if is a registered Token X stable coin asset

    * @param  amount Amount of fromAsset to be transferred.

    * @return { "success" : "Returns true if successfully called from another contract"}

   */

	function convert(address fromAsset, address toAsset, uint amount) public notDeprecated returns (bool success) {

    /// @notice lookup currency from one of the assets, check if allowed by both assets.

    string memory currency = getAssetCurrency(fromAsset);

    uint fromDecimals = ERC20Interface(fromAsset).decimals();

    uint toDecimals = ERC20Interface(toAsset).decimals();



    /// @dev Ensure assets are allowed to be swapped;

		require(isAllowedAsset(fromAsset, currency), 'Error: Unsupported asset requested. Asset must be supported by this contract and have a currency of `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK` .');

		require(isAllowedAsset(toAsset, currency), 'Error: Unsupported asset requested. Asset must be supported by this contract and have a currency of `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK` .');





		/// @dev require one of the assets be equal to Token X asset;

		if (isTokenXContract(toAsset, currency)) {

      /// @notice This requires the erc20 transfer function to return a boolean result of true;

      /// @dev the amount being transferred must be in the same decimal representation of the asset

      /// e.g. If decimals = 6 and want to transfer $100.00 the amount passed to this contract should be 100e6 (100 * 10 ** 6)

      require(

        ERC20Interface(fromAsset).transferFrom(msg.sender, address(this), amount),

        'Error: Unable to transferFrom your asset holdings. Please ensure this contract has an approved allowance equal to or greater than the amount called in transferFrom method.'

      );



      /// @dev Deposit TokenX asset to the user;

      /// @notice Amount received from deposit is net of fees.

      uint netAmountFrom = amount.sub(calcAssetFees(fromAsset, amount));

      /// @dev Ensure amount is converted for the correct decimal representation;

      uint convertedAmountFrom = (netAmountFrom.mul(10**toDecimals)).div(10**fromDecimals);

      require(

        lib.deposit(lib.getTokenSymbol(toAsset), msg.sender, convertedAmountFrom, 'Token, Inc.'),

        "Error: Unable to deposit funds. Please check issuerFirm and firm authority are registered"

      );

		} else if(isTokenXContract(fromAsset, currency)) {

      ///@dev Transfer the asset to the user;

      /// @notice Amount received from withdraw is net of fees.

      uint convertedAmount = (amount.mul(10**toDecimals)).div(10**fromDecimals);

      uint fees = calcAssetFees(toAsset, convertedAmount);

      uint netAmountTo = convertedAmount.sub(fees);

      /// @dev Ensure amount is converted for the correct decimal representation;

      require(

      	ERC20Interface(toAsset).transfer(msg.sender, netAmountTo),

      	'Unable to call the requested erc20 contract.'

      );



      /// @dev Withdraw TokenX asset from the user

      require(

      	lib.withdraw(lib.getTokenSymbol(fromAsset), msg.sender, amount, 'Token, Inc.'),

      	"Error: Unable to withdraw funds. Please check issuerFirm and firm authority are registered and have issued funds that can be withdrawn"

      );

		} else {

        revert('Error: At least one asset must be issued by Token, Inc. (Token X).');

		}



    /// @dev Log the swap event for event listeners

    emit StableSwap(fromAsset, toAsset, msg.sender, amount, currency);

    return true;

	}



  /**

   * Allow this contract to transfer collected fees to another contract;

   * @param  asset Ethereum address of asset to transfer

   * @param  to Transfer collected fees to the following account;

   * @param  amount Amount of fromAsset to be transferred.

   * @return { "success" : "Returns true if successfully called from another contract"}

   */

  function transferCollectedFees(address asset, address to, uint amount) public onlyOwner notDeprecated returns (bool success) {

		require(

			ERC20Interface(asset).transfer(to, amount),

			"Error: Unable to transfer fees to account."

		);

    emit TransferredHoldings(asset, to, amount);

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