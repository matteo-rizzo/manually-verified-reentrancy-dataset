/**

 *Submitted for verification at Etherscan.io on 2019-03-25

*/



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 * @author nabirkin @cryptoalpha

 */





contract CryptoAlphaToken {

    string public name = "CryptoAlphaToken";

    string public symbol = "CAT";

    uint8 public decimals = 0;

    uint256 private _cap = 10000;



    using SafeMath for uint256;



    mapping (address => uint256) private _balances;

    mapping (address => uint) private _mintTimestamps;

    uint256 private _totalSupply;

    address private _minter;



    event MinterTransferred(address indexed previousMinter, address indexed newMinter);

    event Transfer(address indexed from, address indexed to, uint256 value);



    constructor() public {

        _minter = msg.sender;

        emit MinterTransferred(address(0), _minter);

    }



    /**

     * @dev Total number of tokens in existence

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

    * @dev Gets timestamp of the mint operation by the specified address.

    * @param owner The address to query the mint timestamp of.

    * @return An uint representing the seconds since unix epoch.

    */

    function mintTimestampOf(address owner) public view returns (uint) {

        return _mintTimestamps[owner];

    }



    /**

    * @return the cap for the token minting.

    */

    function cap() public view returns (uint256) {

        return _cap;

    }



    /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);

        return true;

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap);

        require(account != address(0));

        require(_balances[account] == 0);



        _totalSupply = _totalSupply.add(value);

        _balances[account] = value;

        _mintTimestamps[account] = now;

        emit Transfer(address(0), account, value);

    }





    /**

    * @return the address of the minter.

    */

    function minter() public view returns (address) {

        return _minter;

    }



    /**

     * @dev Throws if called by any account other than the minter.

     */

    modifier onlyMinter() {

        require(isMinter());

        _;

    }



    /**

    * @return true if `msg.sender` is the minter of the contract.

    */

    function isMinter() public view returns (bool) {

        return msg.sender == _minter;

    }



    /**

    * @dev Allows the current minter to transfer control of the contract to a newMinter.

    * @param newMinter The address to transfer mintership to.

    */

    function transferMintership(address newMinter) public onlyMinter {

        require(newMinter != address(0));

        emit MinterTransferred(_minter, newMinter);

        _minter = newMinter;

    }

}