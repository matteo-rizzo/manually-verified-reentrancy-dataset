/**
 *Submitted for verification at Etherscan.io on 2020-12-20
*/

// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗
// ╚════██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗░░░██╔════╝██║
// ░░███╔═╝███████║██████╔╝██████╔╝█████╗░░██████╔╝░░░█████╗░░██║
// ██╔══╝░░██╔══██║██╔═══╝░██╔═══╝░██╔══╝░░██╔══██╗░░░██╔══╝░░██║
// ███████╗██║░░██║██║░░░░░██║░░░░░███████╗██║░░██║██╗██║░░░░░██║
// ╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝
// Copyright (C) 2020 zapper

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//

///@author Zapper
///@notice This contract mints cover/no-cover tokens and deposits them in their respective balancer pools

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol

pragma solidity ^0.5.5;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address payable public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}











contract Cover_ZapIn_General_V1 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    bool public stopped = false;
    uint16 public goodwill;

    address payable
        private constant zgoodwillAddress = 0x3CE37278de6388532C3949ce4e886F365B14fB56;

    address
        public constant collateralAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    ICoverFactory public constant coverFactory = ICoverFactory(
        0xedfC81Bf63527337cD2193925f9C0cF2D537AccA
    );

    IBFactory public constant BalancerFactory = IBFactory(
        0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd
    );

    event Zapin(
        address toWhomToIssue,
        address protocolCovered,
        uint256 claimRec,
        uint256 noClaimRec,
        uint256 claimBPTRec,
        uint256 noClaimBPTRec
    );

    constructor(uint16 _goodwill) public {
        goodwill = _goodwill;
    }

    // circuit breaker modifiers
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    /**
    @notice This function is used to mint cover for a supported protocol and add the cover/no-cover to balancer pools
    @param _fromTokenAddress The token used for investment (address(0x00) if ether)
    @param _protocolAddress The address of protocol to acquire cover for
    @param _claimBalancerAddress The balancer pool address for cover
    @param _noClaimBalancerAddress The balancer pool address for no-cover 
    @param _amount The amount of ERC to invest, use any arbitrary value if ether
    @param _allowanceTarget Spender for the swap
    @param _swapTarget Excecution target for the swap
    @param swapData DEX quote data
    @return Claim/No-Claim BPT Received
     */
    function ZapIn(
        address _fromTokenAddress,
        address _protocolAddress,
        address _claimBalancerAddress,
        address _noClaimBalancerAddress,
        uint256 _amount,
        address _allowanceTarget,
        address _swapTarget,
        bytes calldata swapData
    )
        external
        payable
        nonReentrant
        stopInEmergency
        returns (
            uint256 claimRec,
            uint256 noClaimRec,
            uint256 claimBpt,
            uint256 noClaimBpt
        )
    {
        uint256 valueToSend;
        address tokenToSend;
        if (_fromTokenAddress == address(0)) {
            require(msg.value > 0, "ERR: No ETH sent");
            valueToSend = _transferGoodwill(_fromTokenAddress, msg.value);
        } else {
            require(_amount > 0, "Err: No Tokens Sent");
            require(msg.value == 0, "ERR: ETH sent with Token");
            tokenToSend = _fromTokenAddress;
            IERC20(tokenToSend).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
            valueToSend = _transferGoodwill(_fromTokenAddress, _amount);
        }

        if (_fromTokenAddress != collateralAddress) {
            valueToSend = _fillQuote(
                tokenToSend,
                valueToSend,
                _allowanceTarget,
                _swapTarget,
                swapData
            );
        }
        (claimRec, noClaimRec, claimBpt, noClaimBpt) = _enterPosition(
            _protocolAddress,
            valueToSend,
            _claimBalancerAddress,
            _noClaimBalancerAddress
        );

        IERC20(_claimBalancerAddress).safeTransfer(msg.sender, claimBpt);

        IERC20(_noClaimBalancerAddress).safeTransfer(msg.sender, noClaimBpt);

        emit Zapin(
            msg.sender,
            _protocolAddress,
            claimRec,
            noClaimRec,
            claimBpt,
            noClaimBpt
        );
    }

    function _enterPosition(
        address _protocolAddress,
        uint256 amount,
        address _claimBalancerAddress,
        address _noClaimBalancerAddress
    )
        internal
        returns (
            uint256 claimRec,
            uint256 noClaimRec,
            uint256 claimBpt,
            uint256 noClaimBpt
        )
    {
        (claimRec, noClaimRec) = _enterCover(_protocolAddress, amount);

        (claimBpt, noClaimBpt) = _enterBalancer(
            _protocolAddress,
            claimRec,
            noClaimRec,
            _claimBalancerAddress,
            _noClaimBalancerAddress
        );
    }

    function _enterBalancer(
        address _protocolAddress,
        uint256 claimAmt,
        uint256 noClaimAmt,
        address _claimBalancerAddress,
        address _noClaimBalancerAddress
    ) internal returns (uint256 claimBptRec, uint256 noClaimBptRec) {
        (, address _claim, address _noClaim) = _getCoverDetails(
            _protocolAddress
        );
        IBPool balancerClaim = IBPool(_claimBalancerAddress);
        IBPool balancerNoClaim = IBPool(_noClaimBalancerAddress);

        require(
            balancerClaim.isBound(_claim) && balancerNoClaim.isBound(_noClaim),
            "Token not bound"
        );

        IERC20(_claim).safeApprove(address(_claimBalancerAddress), claimAmt);

        IERC20(_noClaim).safeApprove(
            address(_noClaimBalancerAddress),
            noClaimAmt
        );

        claimBptRec = balancerClaim.joinswapExternAmountIn(_claim, claimAmt, 1);
        noClaimBptRec = balancerNoClaim.joinswapExternAmountIn(
            _noClaim,
            noClaimAmt,
            1
        );
    }

    function _enterCover(address _protocolAddress, uint256 amount)
        internal
        returns (uint256, uint256)
    {
        (uint48 timestamp, address _claim, address _noclaim) = _getCoverDetails(
            _protocolAddress
        );
        IERC20 claim = IERC20(_claim);
        IERC20 noClaim = IERC20(_noclaim);

        uint256 initialBalanceClaim = claim.balanceOf(address(this));
        uint256 initialBalancenoClaim = noClaim.balanceOf(address(this));

        ICoverProtocol protocol = ICoverProtocol(_protocolAddress);

        IERC20(collateralAddress).safeApprove(address(_protocolAddress), 0);
        IERC20(collateralAddress).safeApprove(
            address(_protocolAddress),
            amount
        );

        bool success = protocol.addCover(collateralAddress, timestamp, amount);

        require(success, "Error minting CLAIM/NO-CLAIM Tokens");

        uint256 claimRec = claim.balanceOf(address(this)).sub(
            initialBalanceClaim
        );
        uint256 noClaimRec = claim.balanceOf(address(this)).sub(
            initialBalancenoClaim
        );

        return (claimRec, noClaimRec);
    }

    function _fillQuote(
        address _fromTokenAddress,
        uint256 _amount,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapData
    ) internal returns (uint256 collateralBought) {
        uint256 valueToSend;
        if (_fromTokenAddress == address(0)) {
            valueToSend = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);
            fromToken.safeApprove(address(_allowanceTarget), 0);
            fromToken.safeApprove(address(_allowanceTarget), _amount);
        }

        IERC20 collateral = IERC20(collateralAddress);

        uint256 initialBalance = collateral.balanceOf(address(this));

        (bool success, ) = _swapTarget.call.value(valueToSend)(swapData);
        require(success, "Error Swapping Tokens");

        collateralBought = collateral.balanceOf(address(this)).sub(
            initialBalance
        );

        require(collateralBought > 0, "Swapped to Invalid Intermediate");
    }

    function _getCoverDetails(address _protocolAddress)
        internal
        view
        returns (
            uint48 timestamp,
            address _claim,
            address _noClaim
        )
    {
        ICoverProtocol protocol = ICoverProtocol(_protocolAddress);

        ICover cover = ICover(
            protocol.activeCovers((protocol.activeCoversLength()).sub(1))
        );

        (, timestamp, , , _claim, _noClaim) = cover.getCoverDetails();
    }

    /**
    @dev This function is used to calculate and transfer goodwill
    @param _tokenContractAddress Token from which goodwill is deducted
    @param valueToSend The total value being zapped in
    @return The quantity of remaining tokens
     */
    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 valueToSend
    ) internal returns (uint256) {
        if (goodwill == 0) return valueToSend;

        uint256 goodwillPortion = SafeMath.div(
            SafeMath.mul(valueToSend, goodwill),
            10000
        );
        if (_tokenContractAddress == address(0)) {
            zgoodwillAddress.transfer(goodwillPortion);
        } else {
            IERC20(_tokenContractAddress).safeTransfer(
                zgoodwillAddress,
                goodwillPortion
            );
        }
        return valueToSend.sub(goodwillPortion);
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function inCaseTokengetsStuck(address _tokenAddress) public onlyOwner {
        IERC20 tokenAddress = IERC20(_tokenAddress);
        uint256 qty = tokenAddress.balanceOf(address(this));
        tokenAddress.safeTransfer(owner(), qty);
    }

    // - to Pause the contract
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    // - to withdraw any ETH balance sitting in the contract
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }
}