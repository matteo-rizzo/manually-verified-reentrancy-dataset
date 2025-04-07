/**
 *Submitted for verification at Etherscan.io on 2021-04-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract MinterReceiver is ERC165 {
    function onSharesMinted(
        uint40 stakeId,
        address supplier,
        uint72 stakedHearts,
        uint72 stakeShares
    ) external virtual;

    function onEarningsMinted(uint40 stakeId, uint72 heartsEarned)
        external
        virtual;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(MinterReceiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}



contract ShareMinter {
    IHEX public hexContract;

    struct Stake {
        uint24 unlockDay;
        MinterReceiver receiver;
    }
    mapping(uint40 => Stake) public stakes;

    event MintShares(uint40 stakeId, MinterReceiver receiver, uint72 shares);
    event MintEarnings(uint40 stakeId, MinterReceiver receiver, uint72 hearts);

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(IHEX _hex) {
        hexContract = _hex;
    }

    function mintShares(
        MinterReceiver receiver,
        address supplier,
        uint256 newStakedHearts,
        uint256 newStakedDays
    ) external lock {
        require(
            ERC165Checker.supportsInterface(
                address(receiver),
                type(MinterReceiver).interfaceId
            ),
            "UNSUPPORTED_RECEIVER"
        );

        hexContract.transferFrom(msg.sender, address(this), newStakedHearts);
        hexContract.stakeStart(newStakedHearts, newStakedDays);

        uint256 stakeCount = hexContract.stakeCount(address(this));
        (
            uint40 stakeId,
            uint72 stakedHearts,
            uint72 stakeShares,
            uint16 lockedDay,
            uint16 stakedDays,
            ,

        ) = hexContract.stakeLists(address(this), stakeCount - 1);
        uint24 unlockDay = lockedDay + stakedDays;

        Stake storage stake = stakes[stakeId];
        stake.receiver = receiver;
        stake.unlockDay = unlockDay;

        receiver.onSharesMinted(stakeId, supplier, stakedHearts, stakeShares);

        emit MintShares(stakeId, receiver, stakeShares);
    }

    function mintEarnings(uint256 stakeIndex, uint40 stakeId) external lock {
        Stake memory stake = stakes[stakeId];
        uint256 currentDay = hexContract.currentDay();
        require(currentDay >= stake.unlockDay, "STAKE_NOT_MATURE");

        uint256 prevHearts = hexContract.balanceOf(address(this));
        hexContract.stakeEnd(stakeIndex, stakeId);
        uint256 newHearts = hexContract.balanceOf(address(this));
        uint72 heartsEarned = uint72(newHearts - prevHearts);

        hexContract.transfer(address(stake.receiver), heartsEarned);
        stake.receiver.onEarningsMinted(stakeId, heartsEarned);

        emit MintEarnings(stakeId, stake.receiver, heartsEarned);
    }
}