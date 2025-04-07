/**
 *Submitted for verification at Etherscan.io on 2021-03-04
*/

/*
  Copyright 2019,2020 StarkWare Industries Ltd.
  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  https://www.starkware.co/open-source-license/
  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.6.2;




/*
  Extends the IFactRegistry interface with a query method that indicates
  whether the fact registry has successfully registered any fact or is still empty of such facts.
*/
interface IQueryableFactRegistry is IFactRegistry {

    /*
      Returns true if at least one fact has been registered.
    */
    function hasRegisteredFact()
        external view
        returns(bool);

}


contract FactRegistry is IQueryableFactRegistry {
    // Mapping: fact hash -> true.
    mapping (bytes32 => bool) private verifiedFact;

    // Indicates whether the Fact Registry has at least one fact registered.
    bool anyFactRegistered;

    /*
      Checks if a fact has been verified.
    */
    function isValid(bytes32 fact)
        external view override
        returns(bool)
    {
        return _factCheck(fact);
    }


    /*
      This is an internal method to check if the fact is already registered.
      In current implementation of FactRegistry it's identical to isValid().
      But the check is against the local fact registrey,
      So for a derived referral fact registry, it's not the same.
    */
    function _factCheck(bytes32 fact)
        internal view
        returns(bool)
    {
        return verifiedFact[fact];
    }

    function registerFact(
        bytes32 factHash
        )
        internal
    {
        // This function stores the fact hash in the mapping.
        verifiedFact[factHash] = true;

        // Mark first time off.
        if (!anyFactRegistered) {
            anyFactRegistered = true;
        }
    }

    /*
      Indicates whether at least one fact was registered.
    */
    function hasRegisteredFact()
        external view override
        returns(bool)
    {
        return anyFactRegistered;
    }

}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract TransferRegistry is FactRegistry, Identity {
    using SafeERC20 for IERC20;

    event LogRegisteredTransfer(
        address recipient,
        address token,
        uint256 amount,
        uint256 salt
    );

    function identify()
        external view override
        returns(string memory)
    {
        return "StarkWare_TransferRegistry_2020_1";
    }

    /*
      Passes on the transaction ETH value onto the recipient address,
      and register the associated fact.
      Reverts if the fact has already been registered.
    */
    function transfer(address payable recipient, uint256 salt) // NOLINT: erc20-interface.
        payable
        external {
        bytes32 transferFact = keccak256(
            abi.encodePacked(recipient, msg.value, address(0x0), salt));
        require(!_factCheck(transferFact), "TRANSFER_ALREADY_REGISTERED");
        registerFact(transferFact);
        emit LogRegisteredTransfer(recipient, address(0x0), msg.value, salt);
        recipient.transfer(msg.value);
    }

    /*
      Transfer the specified amount of erc20 tokens from msg.sender balance to the recipient's
      balance.
      Pre-conditions to successful transfer are that the msg.sender has sufficient balance,
      and the the approval (for the transfer) was granted to this contract.
      A fact with the transfer details is registered upon success.
      Reverts if the fact has already been registered.
    */
    function transferERC20(address recipient, address erc20, uint256 amount, uint256 salt)
        external {
        bytes32 transferFact = keccak256(
            abi.encodePacked(recipient, amount, erc20, salt));
        require(!_factCheck(transferFact), "TRANSFER_ALREADY_REGISTERED");
        registerFact(transferFact);
        emit LogRegisteredTransfer(recipient, erc20, amount, salt);
        IERC20(erc20).safeTransferFrom(msg.sender, recipient, amount);
    }

}