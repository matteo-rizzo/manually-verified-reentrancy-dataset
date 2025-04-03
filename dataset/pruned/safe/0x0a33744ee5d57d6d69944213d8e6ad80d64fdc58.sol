/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

// File: localhost/staking/interfaces/IGrgVault.sol

// SPDX-License-Identifier: Apache 2.0

/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

pragma solidity >=0.5.9 <0.8.0;




// File: localhost/staking/interfaces/IStructs.sol


/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

pragma solidity >=0.5.9 <0.8.0;




// File: localhost/staking/libs/LibStakingRichErrors.sol


/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

pragma solidity >=0.5.9 <0.8.0;






// File: localhost/utils/0xUtils/IERC20Token.sol


/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

pragma solidity >=0.5.9 <0.8.0;


abstract contract IERC20Token {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /// @dev send `value` token to `to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transfer(address _to, uint256 _value)
        external
        virtual
        returns (bool);

    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        virtual
        returns (bool);

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Always true if the call has enough gas to complete execution
    function approve(address _spender, uint256 _value)
        external
        virtual
        returns (bool);

    /// @dev Query total supply of token
    /// @return Total supply of token
    function totalSupply()
        external
        view
        virtual
        returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address _owner)
        external
        view
        virtual
        returns (uint256);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender)
        external
        view
        virtual
        returns (uint256);
}

// File: localhost/utils/0xUtils/IAssetData.sol


/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

// solhint-disable
pragma solidity >=0.5.4 <0.8.0;
pragma experimental ABIEncoderV2;


// @dev Interface of the asset proxy's assetData.
// The asset proxies take an ABI encoded `bytes assetData` as argument.
// This argument is ABI encoded as one of the methods of this interface.


// File: localhost/utils/0xUtils/IAssetProxy.sol


/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

pragma solidity >=0.5.4 <0.8.0;


abstract contract IAssetProxy {

    /// @dev Transfers assets. Either succeeds or throws.
    /// @param assetData Byte array encoded for the respective asset proxy.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    )
        external
        virtual;

    /// @dev Gets the proxy id associated with the proxy address.
    /// @return Proxy id.
    function getProxyId()
        external
        pure
        virtual
        returns (bytes4);
}

// File: localhost/utils/0xUtils/LibSafeMathRichErrors.sol


pragma solidity >=0.5.4 <0.8.0;




// File: localhost/utils/0xUtils/LibSafeMath.sol


pragma solidity >=0.5.9 <0.8.0;






// File: localhost/utils/0xUtils/LibOwnableRichErrors.sol


pragma solidity >=0.5.9 <0.8.0;




// File: localhost/utils/0xUtils/interfaces/IOwnable.sol


/*
  Copyright 2019 ZeroEx Intl.
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

pragma solidity >=0.5.9 <0.8.0;


abstract contract IOwnable {

    /// @dev Emitted by Ownable when ownership is transferred.
    /// @param previousOwner The previous owner of the contract.
    /// @param newOwner The new owner of the contract.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Transfers ownership of the contract to a new address.
    /// @param newOwner The address that will become the owner.
    function transferOwnership(address newOwner)
        public
        virtual;
}

// File: localhost/utils/0xUtils/Ownable.sol


/*
  Copyright 2019 ZeroEx Intl.
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

pragma solidity >=0.5.9 <0.8.0;





contract Ownable is
    IOwnable
{
    /// @dev The owner of this contract.
    /// @return 0 The owner address.
    address public owner;

    constructor ()
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    /// @dev Change the owner of this contract.
    /// @param newOwner New owner address.
    function transferOwnership(address newOwner)
        public
        override
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibRichErrors.rrevert(LibOwnableRichErrors.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {
        if (msg.sender != owner) {
            LibRichErrors.rrevert(LibOwnableRichErrors.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}

// File: localhost/utils/0xUtils/LibRichErrors.sol


/*

  Copyright 2019 ZeroEx Intl.

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

pragma solidity >=0.5.9 <0.8.0;




// File: localhost/utils/0xUtils/LibAuthorizableRichErrors.sol


/*
  Copyright 2019 ZeroEx Intl.
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

pragma solidity >=0.5.9 <0.8.0;




// File: localhost/utils/0xUtils/interfaces/IAuthorizable.sol


/*
  Copyright 2019 ZeroEx Intl.
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

pragma solidity >=0.5.9 <0.8.0;



abstract contract IAuthorizable is
    IOwnable
{
    // Event logged when a new address is authorized.
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    // Event logged when a currently authorized address is unauthorized.
    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target)
        external
        virtual;

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target)
        external
        virtual;

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        virtual;

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses()
        external
        view
        virtual
        returns (address[] memory);
}

// File: localhost/utils/0xUtils/Authorizable.sol


/*

  Copyright 2019 ZeroEx Intl.

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

pragma solidity >=0.5.9 <0.8.0;






// solhint-disable no-empty-blocks
contract Authorizable is
    Ownable,
    IAuthorizable
{
    /// @dev Only authorized addresses can invoke functions with this modifier.
    modifier onlyAuthorized {
        _assertSenderIsAuthorized();
        _;
    }

    /// @dev Whether an address is authorized to call privileged functions.
    /// @dev 0 Address to query.
    /// @return 0 Whether the address is authorized.
    mapping (address => bool) public authorized;
    /// @dev Whether an adderss is authorized to call privileged functions.
    /// @dev 0 Index of authorized address.
    /// @return 0 Authorized address.
    address[] public authorities;

    /// @dev Initializes the `owner` address.
    constructor()
        Ownable()
    {}

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {
        _addAuthorizedAddress(target);
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {
        if (!authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetNotAuthorizedError(target));
        }
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        override
        onlyOwner
    {
        _removeAuthorizedAddressAtIndex(target, index);
    }

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses()
        external
        view
        override
        returns (address[] memory)
    {
        return authorities;
    }

    /// @dev Reverts if msg.sender is not authorized.
    function _assertSenderIsAuthorized()
        internal
        view
    {
        if (!authorized[msg.sender]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.SenderNotAuthorizedError(msg.sender));
        }
    }

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function _addAuthorizedAddress(address target)
        internal
    {
        // Ensure that the target is not the zero address.
        if (target == address(0)) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.ZeroCantBeAuthorizedError());
        }

        // Ensure that the target is not already authorized.
        if (authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetAlreadyAuthorizedError(target));
        }

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    /// @dev Removes authorization of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function _removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        internal
    {
        if (!authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetNotAuthorizedError(target));
        }
        if (index >= authorities.length) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.IndexOutOfBoundsError(
                index,
                authorities.length
            ));
        }
        if (authorities[index] != target) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.AuthorizedAddressMismatchError(
                authorities[index],
                target
            ));
        }

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.pop();
        emit AuthorizedAddressRemoved(target, msg.sender);
    }
}

// File: localhost/staking/GrgVault.sol


/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

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

pragma solidity 0.7.4;










contract GrgVault is
    Authorizable,
    IGrgVault
{
    using LibSafeMath for uint256;

    // Address of staking proxy contract
    address public stakingProxyAddress;

    // True iff vault has been set to Catastrophic Failure Mode
    bool public isInCatastrophicFailure;

    // Mapping from staker to GRG balance
    mapping (address => uint256) internal _balances;

    // Grg Asset Proxy
    IAssetProxy public grgAssetProxy;

    // Grg Token
    IERC20Token internal _grgToken;

    // Asset data for the ERC20 Proxy
    bytes internal _grgAssetData;

    /// @dev Only stakingProxy can call this function.
    modifier onlyStakingProxy() {
        _assertSenderIsStakingProxy();
        _;
    }

    /// @dev Function can only be called in catastrophic failure mode.
    modifier onlyInCatastrophicFailure() {
        _assertInCatastrophicFailure();
        _;
    }

    /// @dev Function can only be called not in catastropic failure mode
    modifier onlyNotInCatastrophicFailure() {
        _assertNotInCatastrophicFailure();
        _;
    }

    /// @dev Constructor.
    /// @param _grgProxyAddress Address of the RigoBlock Grg Proxy.
    /// @param _grgTokenAddress Address of the Grg Token.
    constructor(
        address _grgProxyAddress,
        address _grgTokenAddress
    )
        Authorizable()
    {
        grgAssetProxy = IAssetProxy(_grgProxyAddress);
        _grgToken = IERC20Token(_grgTokenAddress);
        _grgAssetData = abi.encodeWithSelector(
            IAssetData(address(0)).ERC20Token.selector,
            _grgTokenAddress
        );
    }

    /// @dev Sets the address of the StakingProxy contract.
    /// Note that only the contract owner can call this function.
    /// @param _stakingProxyAddress Address of Staking proxy contract.
    function setStakingProxy(address _stakingProxyAddress)
        external
        override
        onlyAuthorized
    {
        stakingProxyAddress = _stakingProxyAddress;
        emit StakingProxySet(_stakingProxyAddress);
    }

    /// @dev Vault enters into Catastrophic Failure Mode.
    /// *** WARNING - ONCE IN CATOSTROPHIC FAILURE MODE, YOU CAN NEVER GO BACK! ***
    /// Note that only the contract owner can call this function.
    function enterCatastrophicFailure()
        external
        override
        onlyAuthorized
        onlyNotInCatastrophicFailure
    {
        isInCatastrophicFailure = true;
        emit InCatastrophicFailureMode(msg.sender);
    }

    /// @dev Sets the Grg proxy.
    /// Note that only an authorized address can call this function.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param _grgProxyAddress Address of the RigoBlock Grg Proxy.
    function setGrgProxy(address _grgProxyAddress)
        external
        override
        onlyAuthorized
        onlyNotInCatastrophicFailure
    {
        grgAssetProxy = IAssetProxy(_grgProxyAddress);
        emit GrgProxySet(_grgProxyAddress);
    }

    /// @dev Deposit an `amount` of Grg Tokens from `staker` into the vault.
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker of Grg Tokens.
    /// @param amount of Grg Tokens to deposit.
    function depositFrom(address staker, uint256 amount)
        external
        override
        onlyStakingProxy
        onlyNotInCatastrophicFailure
    {
        // update balance
        _balances[staker] = _balances[staker].safeAdd(amount);

        // notify
        emit Deposit(staker, amount);

        // deposit GRG from staker
        grgAssetProxy.transferFrom(
            _grgAssetData,
            staker,
            address(this),
            amount
        );
    }

    /// @dev Withdraw an `amount` of Grg Tokens to `staker` from the vault.
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker of Grg Tokens.
    /// @param amount of Grg Tokens to withdraw.
    function withdrawFrom(address staker, uint256 amount)
        external
        override
        onlyStakingProxy
        onlyNotInCatastrophicFailure
    {
        _withdrawFrom(staker, amount);
    }

    /// @dev Withdraw ALL Grg Tokens to `staker` from the vault.
    /// Note that this can only be called when *in* Catastrophic Failure mode.
    /// @param staker of Grg Tokens.
    function withdrawAllFrom(address staker)
        external
        override
        onlyInCatastrophicFailure
        returns (uint256)
    {
        // get total balance
        uint256 totalBalance = _balances[staker];

        // withdraw GRG to staker
        _withdrawFrom(staker, totalBalance);
        return totalBalance;
    }

    /// @dev Returns the balance in Grg Tokens of the `staker`
    /// @return Balance in Grg.
    function balanceOf(address staker)
        external
        view
        override
        returns (uint256)
    {
        return _balances[staker];
    }

    /// @dev Returns the entire balance of Grg tokens in the vault.
    function balanceOfGrgVault()
        external
        view
        override
        returns (uint256)
    {
        return _grgToken.balanceOf(address(this));
    }

    /// @dev Withdraw an `amount` of Grg Tokens to `staker` from the vault.
    /// @param staker of Grg Tokens.
    /// @param amount of Grg Tokens to withdraw.
    function _withdrawFrom(address staker, uint256 amount)
        internal
    {
        // update balance
        // note that this call will revert if trying to withdraw more
        // than the current balance
        _balances[staker] = _balances[staker].safeSub(amount);

        // notify
        emit Withdraw(staker, amount);

        // withdraw GRG to staker
        _grgToken.transfer(
            staker,
            amount
        );
    }

    /// @dev Asserts that sender is stakingProxy contract.
    function _assertSenderIsStakingProxy()
        private
        view
    {
        if (msg.sender != stakingProxyAddress) {
            LibRichErrors.rrevert(LibStakingRichErrors.OnlyCallableByStakingContractError(
                msg.sender
            ));
        }
    }

    /// @dev Asserts that vault is in catastrophic failure mode.
    function _assertInCatastrophicFailure()
        private
        view
    {
        if (!isInCatastrophicFailure) {
            LibRichErrors.rrevert(LibStakingRichErrors.OnlyCallableIfInCatastrophicFailureError());
        }
    }

    /// @dev Asserts that vault is not in catastrophic failure mode.
    function _assertNotInCatastrophicFailure()
        private
        view
    {
        if (isInCatastrophicFailure) {
            LibRichErrors.rrevert(LibStakingRichErrors.OnlyCallableIfNotInCatastrophicFailureError());
        }
    }
}