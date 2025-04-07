/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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
pragma solidity ^0.5.11;


/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - <daniel@loopring.org>
contract ERC20
{
    function totalSupply()
        public
        view
        returns (uint);

    function balanceOf(
        address who
        )
        public
        view
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        view
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        returns (bool);
}
/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title Utility Functions for addresses
/// @author Daniel Wang - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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





/// @title Burnable ERC20 Token Interface
/// @author Brecht Devos - <brecht@loopring.org>
contract BurnableERC20 is ERC20
{
    function burn(
        uint value
        )
        public
        returns (bool);

    function burnFrom(
        address from,
        uint value
        )
        public
        returns (bool);
}

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".




/// @title Claimable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Extension for the Ownable contract, where the ownership needs
///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable
{
    address public pendingOwner;

    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        onlyOwner
    {
        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    /// @dev Allows the pendingOwner address to finalize the transfer.
    function claimOwnership()
        public
        onlyPendingOwner
    {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title ERC20 safe transfer
/// @dev see https://github.com/sec-bit/badERC20Fix
/// @author Brecht Devos - <brecht@loopring.org>

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title ReentrancyGuard
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Exposes a modifier that guards a function against reentrancy
///      Changing the value of the same storage value multiple times in a transaction
///      is cheap (starting from Istanbul) so there is no need to minimize
///      the number of times the value is changed
contract ReentrancyGuard
{
    //The default value must be 0 in order to work behind a proxy.
    uint private _guardValue;

    // Use this modifier on a function to prevent reentrancy
    modifier nonReentrant()
    {
        // Check if the guard value has its original value
        require(_guardValue == 0, "REENTRANCY");

        // Set the value to something else
        _guardValue = 1;

        // Function body
        _;

        // Set the value back
        _guardValue = 0;
    }
}


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title IProtocolFeeVault
/// @dev This smart contract manages the distribution of protocol fees.
///     Tokens other than LRC will be sold by TokenSeller,
///     If no TokenSeller is set, the tokens or Ether will be sent to the owner
///     to sell them for LRC by other means such as using a centralized exchange.
///     For LRC token, 70% of them can be withdrawn to the UserStakingPool contract
///     to reward LRC stakers; 20% of them can be withdrawn to the Loopring DAO,
///     and the remaining 10% can be burned to reduce LRC's total supply.
contract IProtocolFeeVault
{
    uint public constant REWARD_PERCENTAGE      = 70;
    uint public constant DAO_PERDENTAGE         = 20;

    address public userStakingPoolAddress;
    address public lrcAddress;
    address public tokenSellerAddress;
    address public daoAddress;

    uint claimedReward;
    uint claimedDAOFund;
    uint claimedBurn;

    event LRCClaimed(uint amount);
    event DAOFunded(uint amountDAO, uint amountBurn);
    event TokenSold(address token, uint amount);
    event SettingsUpdated(uint time);

    /// @dev Sets depdending contract address. All these addresses can be zero.
    /// @param _userStakingPoolAddress The address of the user staking pool.
    /// @param _tokenSellerAddress The address of the token seller.
    /// @param _daoAddress The address of the DAO contract.
    function updateSettings(
        address _userStakingPoolAddress,
        address _tokenSellerAddress,
        address _daoAddress
        )
        external;

    /// @dev Claims LRC as staking reward to the IUserStakingPool contract.
    ///      Note that this function can only be called by
    ///      the IUserStakingPool contract.
    ///
    /// @param amount The amount of LRC to be claimed.
    function claimStakingReward(uint amount) external;

    /// @dev Withdraws LRC to DAO and in the meanwhile burn some LRC according to
    ///      the predefined percentages.
    function fundDAO() external;

    /// @dev Sells a non-LRC token or Ether to LRC. If no TokenSeller is set,
    ///      the tokens or Ether will be sent to the owner.
    /// @param token The token or ether (0x0) to sell.
    /// @param amount THe amout of token/ether to sell.
    function sellTokenForLRC(
        address token,
        uint    amount
        )
        external;

    /// @dev Returns some global stats regarding fees.
    /// @return accumulatedFees The accumulated amount of LRC protocol fees.
    /// @return accumulatedBurn The accumulated amount of LRC to burn.
    /// @return accumulatedDAOFund The accumulated amount of LRC as developer pool.
    /// @return accumulatedReward The accumulated amount of LRC as staking reward.
    /// @return remainingFees The remaining amount of LRC protocol fees.
    /// @return remainingBurn The remaining amount of LRC to burn.
    /// @return remainingDAOFund The remaining amount of LRC as developer pool.
    /// @return remainingReward The remaining amount of LRC as staking reward.
    function getProtocolFeeStats()
        public
        view
        returns (
            uint accumulatedFees,
            uint accumulatedBurn,
            uint accumulatedDAOFund,
            uint accumulatedReward,
            uint remainingFees,
            uint remainingBurn,
            uint remainingDAOFund,
            uint remainingReward
        );
}

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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


/// @title ITokenSeller
/// @dev Use this contract to sell tokenS for as many tokenB.
/// @author Daniel Wang  - <daniel@loopring.org>
contract ITokenSeller
{
    /// @dev Sells all tokenS for tokenB
    /// @param tokenS The token or Ether (0x0) to sell.
    /// @param tokenB The token to buy.
    /// @return success True if success, false otherwise.
    function sellToken(
        address tokenS,
        address tokenB
        )
        external
        payable
        returns (bool success);
}

/// @title An Implementation of IProtocolFeeVault.
/// @author Daniel Wang - <daniel@loopring.org>
contract ProtocolFeeVault is Claimable, ReentrancyGuard, IProtocolFeeVault
{
    using AddressUtil       for address;
    using AddressUtil       for address payable;
    using ERC20SafeTransfer for address;
    using MathUint          for uint;

    constructor(address _lrcAddress)
        Claimable()
        public
    {
        require(_lrcAddress != address(0), "ZERO_ADDRESS");
        lrcAddress = _lrcAddress;
    }

    function() external payable { }

    function updateSettings(
        address _userStakingPoolAddress,
        address _tokenSellerAddress,
        address _daoAddress
        )
        external
        nonReentrant
        onlyOwner
    {
        require(
            userStakingPoolAddress != _userStakingPoolAddress ||
            tokenSellerAddress != _tokenSellerAddress ||
            daoAddress != _daoAddress,
            "SAME_ADDRESSES"
        );
        userStakingPoolAddress = _userStakingPoolAddress;
        tokenSellerAddress = _tokenSellerAddress;
        daoAddress = _daoAddress;

        emit SettingsUpdated(now);
    }

    function claimStakingReward(
        uint amount
        )
        external
        nonReentrant
    {
        require(amount > 0, "ZERO_VALUE");
        require(msg.sender == userStakingPoolAddress, "UNAUTHORIZED");
        lrcAddress.safeTransferAndVerify(userStakingPoolAddress, amount);
        claimedReward = claimedReward.add(amount);
        emit LRCClaimed(amount);
    }

    function fundDAO()
        external
        nonReentrant
    {
        uint amountDAO;
        uint amountBurn;
        (, , , , , amountBurn, amountDAO, ) = getProtocolFeeStats();

        address recipient = daoAddress == address(0) ? owner : daoAddress;

        if (amountDAO > 0) {
            lrcAddress.safeTransferAndVerify(recipient, amountDAO);
        }

        if (amountBurn > 0) {
            require(BurnableERC20(lrcAddress).burn(amountBurn), "BURN_FAILURE");
        }

        claimedBurn = claimedBurn.add(amountBurn);
        claimedDAOFund = claimedDAOFund.add(amountDAO);

        emit DAOFunded(amountDAO, amountBurn);
    }

    function sellTokenForLRC(
        address token,
        uint    amount
        )
        external
        nonReentrant
    {
        require(amount > 0, "ZERO_AMOUNT");
        require(token != lrcAddress, "PROHIBITED");

        address recipient = tokenSellerAddress == address(0) ? owner : tokenSellerAddress;

        if (token == address(0)) {
            recipient.sendETHAndVerify(amount, gasleft());
        } else {
            token.safeTransferAndVerify(recipient, amount);
        }

        require(
            tokenSellerAddress == address(0) ||
            ITokenSeller(tokenSellerAddress).sellToken(token, lrcAddress),
            "SELL_FAILURE"
        );

        emit TokenSold(token, amount);
    }

    function getProtocolFeeStats()
        public
        view
        returns (
            uint accumulatedFees,
            uint accumulatedBurn,
            uint accumulatedDAOFund,
            uint accumulatedReward,
            uint remainingFees,
            uint remainingBurn,
            uint remainingDAOFund,
            uint remainingReward
        )
    {
        remainingFees = ERC20(lrcAddress).balanceOf(address(this));
        accumulatedFees = remainingFees.add(claimedReward).add(claimedDAOFund).add(claimedBurn);

        accumulatedReward = accumulatedFees.mul(REWARD_PERCENTAGE) / 100;
        accumulatedDAOFund = accumulatedFees.mul(DAO_PERDENTAGE) / 100;
        accumulatedBurn = accumulatedFees.sub(accumulatedReward).sub(accumulatedDAOFund);

        remainingReward = accumulatedReward.sub(claimedReward);
        remainingDAOFund = accumulatedDAOFund.sub(claimedDAOFund);
        remainingBurn = accumulatedBurn.sub(claimedBurn);
    }
}