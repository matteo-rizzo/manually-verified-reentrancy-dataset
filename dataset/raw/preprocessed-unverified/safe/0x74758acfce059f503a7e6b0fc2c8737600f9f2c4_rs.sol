/**

 *Submitted for verification at Etherscan.io on 2018-12-08

*/



pragma solidity 0.4.25;



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





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/*



  Copyright 2018 ZeroEx Intl.



  Licensed under the Apache License, Version 2.0 (the "License");

  you may not use this file except in compliance with the License.

  You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



  Unless required by applicable law or agreed to in writing, software

  distributed under the License is distributed on an "AS IS" BASIS,

  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and

  limitations under the License.



*/



/// @title TokenTransferProxy - Transfers tokens on behalf of contracts that have been approved via decentralized governance.

/// @author Amir Bandeali - <[email protected]>, Will Warren - <[email protected]>

contract TokenTransferProxy is Ownable {



    /// @dev Only authorized addresses can invoke functions with this modifier.

    modifier onlyAuthorized {

        require(authorized[msg.sender]);

        _;

    }



    modifier targetAuthorized(address target) {

        require(authorized[target]);

        _;

    }



    modifier targetNotAuthorized(address target) {

        require(!authorized[target]);

        _;

    }



    mapping (address => bool) public authorized;

    address[] public authorities;



    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);

    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);



    /*

     * Public functions

     */



    /// @dev Authorizes an address.

    /// @param target Address to authorize.

    function addAuthorizedAddress(address target)

        public

        onlyOwner

        targetNotAuthorized(target)

    {

        authorized[target] = true;

        authorities.push(target);

        emit LogAuthorizedAddressAdded(target, msg.sender);

    }



    /// @dev Removes authorizion of an address.

    /// @param target Address to remove authorization from.

    function removeAuthorizedAddress(address target)

        public

        onlyOwner

        targetAuthorized(target)

    {

        delete authorized[target];

        for (uint i = 0; i < authorities.length; i++) {

            if (authorities[i] == target) {

                authorities[i] = authorities[authorities.length - 1];

                authorities.length -= 1;

                break;

            }

        }

        emit LogAuthorizedAddressRemoved(target, msg.sender);

    }



    /// @dev Calls into ERC20 Token contract, invoking transferFrom.

    /// @param token Address of token to transfer.

    /// @param from Address to transfer token from.

    /// @param to Address to transfer token to.

    /// @param value Amount of token to transfer.

    /// @return Success of transfer.

    function transferFrom(

        address token,

        address from,

        address to,

        uint value)

        public

        onlyAuthorized

        returns (bool)

    {

        require(ERC20SafeTransfer.safeTransferFrom(token, from, to, value));

        return true;

    }



    /*

     * Public constant functions

     */



    /// @dev Gets all authorized addresses.

    /// @return Array of authorized addresses.

    function getAuthorizedAddresses()

        public

        view

        returns (address[])

    {

        return authorities;

    }

}