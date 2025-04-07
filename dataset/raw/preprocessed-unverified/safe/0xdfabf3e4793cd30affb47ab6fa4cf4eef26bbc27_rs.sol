/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Utility contract to allow owner to retreive any ERC20 sent to the contract

 */

contract ReclaimTokens is Ownable {



    /**

    * @notice Reclaim all ERC20Basic compatible tokens

    * @param _tokenContract The address of the token contract

    */

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");

        IERC20 token = IERC20(_tokenContract);

        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(owner, balance), "Transfer failed");

    }

}



/**

 * @title Core functionality for registry upgradability

 */

contract PolymathRegistry is ReclaimTokens {



    mapping (bytes32 => address) public storedAddresses;



    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);



    /**

     * @notice Gets the contract address

     * @param _nameKey is the key for the contract address mapping

     * @return address

     */

    function getAddress(string _nameKey) external view returns(address) {

        bytes32 key = keccak256(bytes(_nameKey));

        require(storedAddresses[key] != address(0), "Invalid address key");

        return storedAddresses[key];

    }



    /**

     * @notice Changes the contract address

     * @param _nameKey is the key for the contract address mapping

     * @param _newAddress is the new contract address

     */

    function changeAddress(string _nameKey, address _newAddress) external onlyOwner {

        bytes32 key = keccak256(bytes(_nameKey));

        emit ChangeAddress(_nameKey, storedAddresses[key], _newAddress);

        storedAddresses[key] = _newAddress;

    }





}