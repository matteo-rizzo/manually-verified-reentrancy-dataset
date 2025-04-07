/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-03
 */

/**
 *Submitted for verification at Etherscan.io on 2021-04-14
 */

// SPDX-License-Identifier: AGPL-3.0-or-later\
pragma solidity 0.7.5;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */










contract ExercisepASG {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public owner;
    address public newOwner;

    address public immutable pASG;
    address public immutable ASG;
    address public immutable DAI;
    address public immutable treasury;
    address public immutable circulatingASGContract;

    struct Term {
        uint256 percent; // 4 decimals ( 5000 = 0.5% )
        uint256 claimed;
        uint256 max;
    }
    mapping(address => Term) public terms;

    mapping(address => address) public walletChange;

    bool hasMigrated;

    constructor(
        address _pASG,
        address _ASG,
        address _dai,
        address _treasury,
        address _circulatingASGContract
    ) {
        owner = msg.sender;
        require(_pASG != address(0));
        pASG = _pASG;
        require(_ASG != address(0));
        ASG = _ASG;
        require(_dai != address(0));
        DAI = _dai;
        require(_treasury != address(0));
        treasury = _treasury;
        require(_circulatingASGContract != address(0));
        circulatingASGContract = _circulatingASGContract;
    }

    // Sets terms for a new wallet
    function setTerms(
        address _vester,
        uint256 _amountCanClaim,
        uint256 _rate
    ) external returns (bool) {
        require(msg.sender == owner, "Sender is not owner");
        require(
            _amountCanClaim >= terms[_vester].max,
            "cannot lower amount claimable"
        );
        require(_rate >= terms[_vester].percent, "cannot lower vesting rate");

        // if (terms[_vester].max == 0) {
        //     terms[_vester].claimed = IOldClaimContract(previousContract)
        //         .amountClaimed(_vester);
        // }

        terms[_vester].max = _amountCanClaim;
        terms[_vester].percent = _rate;

        return true;
    }

    // Allows wallet to redeem pASG for ASG
    function exercise(uint256 _amount) external returns (bool) {
        Term memory info = terms[msg.sender];
        require(redeemable(info) >= _amount, "Not enough vested");
        require(info.max.sub(info.claimed) >= _amount, "Claimed over max");

        IERC20(DAI).safeTransferFrom(msg.sender, address(this), _amount);
        IPASG(pASG).burnFrom(msg.sender, _amount);

        IERC20(DAI).approve(treasury, _amount);
        uint256 ASGToSend = ITreasury(treasury).deposit(_amount, DAI, 0);

        terms[msg.sender].claimed = info.claimed.add(_amount);

        IERC20(ASG).safeTransfer(msg.sender, ASGToSend);

        return true;
    }

    // Allows wallet owner to transfer rights to a new address
    function pushWalletChange(address _newWallet) external returns (bool) {
        require(terms[msg.sender].percent != 0);
        walletChange[msg.sender] = _newWallet;
        return true;
    }

    // Allows wallet to pull rights from an old address
    function pullWalletChange(address _oldWallet) external returns (bool) {
        require(walletChange[_oldWallet] == msg.sender, "wallet did not push");

        walletChange[_oldWallet] = address(0);
        terms[msg.sender] = terms[_oldWallet];
        delete terms[_oldWallet];

        return true;
    }

    // Amount a wallet can redeem based on current supply
    function redeemableFor(address _vester) public view returns (uint256) {
        return redeemable(terms[_vester]);
    }

    function redeemable(Term memory _info) internal view returns (uint256) {
        return
            (
                ICirculatingASG(circulatingASGContract)
                    .ASGCirculatingSupply()
                    .mul(_info.percent)
                    .mul(1000)
            ).sub(_info.claimed);
    }

    // // Migrates terms from old redemption contract
    // function migrate(address[] calldata _addresses) external returns (bool) {
    //     require(msg.sender == owner, "Sender is not owner");
    //     require(!hasMigrated, "Already migrated");

    //     for (uint256 i = 0; i < _addresses.length; i++) {
    //         terms[_addresses[i]] = Term({
    //             percent: IOldClaimContract(previousContract)
    //                 .percentCanVest(_addresses[i])
    //                 .mul(100),
    //             claimed: IOldClaimContract(previousContract).amountClaimed(
    //                 _addresses[i]
    //             ),
    //             max: IOldClaimContract(previousContract).maxAllowedToClaim(
    //                 _addresses[i]
    //             )
    //         });
    //     }

    //     hasMigrated = true;
    //     return true;
    // }

    function pushOwnership(address _newOwner) external returns (bool) {
        require(msg.sender == owner, "Sender is not owner");
        require(_newOwner != address(0));
        newOwner = _newOwner;
        return true;
    }

    function pullOwnership() external returns (bool) {
        require(msg.sender == newOwner);
        owner = newOwner;
        newOwner = address(0);
        return true;
    }
}