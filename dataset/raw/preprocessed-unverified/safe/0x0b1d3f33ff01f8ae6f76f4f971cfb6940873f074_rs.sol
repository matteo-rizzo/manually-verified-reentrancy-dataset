/**
 *Submitted for verification at Etherscan.io on 2021-04-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits




contract ShareMarket is IMinterReceiver {
    IERC20 public hexContract;
    address public minterContract;

    struct ShareOrder {
        uint40 stakeId;
        uint72 sharesPurchased;
        address shareReceiver;
    }
    struct ShareListing {
        uint72 heartsStaked;
        uint72 sharesTotal;
        uint72 sharesAvailable;
        uint72 heartsEarned;
        uint72 supplierHeartsOwed;
        address supplier;
        mapping(address => uint72) shareOwners;
    }
    mapping(uint40 => ShareListing) public shareListings;

    event AddListing(
        uint40 indexed stakeId,
        address indexed supplier,
        uint72 shares
    );
    event SharesUpdate(
        uint40 indexed stakeId,
        address indexed updater,
        uint72 sharesAvailable
    );
    event AddEarnings(uint40 indexed stakeId, uint72 heartsEarned);
    event BuyShares(
        uint40 indexed stakeId,
        address indexed owner,
        uint72 sharesPurchased
    );
    event ClaimEarnings(
        uint40 indexed stakeId,
        address indexed claimer,
        uint256 heartsClaimed
    );
    event SupplierWithdraw(
        uint40 indexed stakeId,
        address indexed supplier,
        uint72 heartsWithdrawn
    );

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(IERC20 _hex, address _minter) {
        hexContract = _hex;
        minterContract = _minter;
    }

    function sharesOwned(uint40 stakeId, address owner)
        public
        view
        returns (uint72 shares)
    {
        return shareListings[stakeId].shareOwners[owner];
    }

    function sharesMinted(
        uint40 stakeId,
        address supplier,
        uint72 stakedHearts,
        uint72 stakeShares
    ) external override {
        require(msg.sender == minterContract, "CALLER_NOT_MINTER");

        ShareListing storage listing = shareListings[stakeId];
        listing.heartsStaked = stakedHearts;
        listing.sharesTotal = stakeShares;
        listing.sharesAvailable = stakeShares;
        listing.supplier = supplier;

        emit AddListing(stakeId, supplier, stakeShares);
    }

    function earningsMinted(uint40 stakeId, uint72 heartsEarned)
        external
        override
    {
        require(msg.sender == minterContract, "CALLER_NOT_MINTER");

        shareListings[stakeId].heartsEarned = heartsEarned;

        emit AddEarnings(stakeId, heartsEarned);
    }

    function _buyShares(
        uint40 stakeId,
        address shareReceiver,
        uint72 sharesPurchased
    ) private returns (uint72 heartsOwed) {
        require(sharesPurchased != 0, "INSUFFICIENT_SHARES_PURCHASED");

        ShareListing storage listing = shareListings[stakeId];

        require(
            sharesPurchased <= listing.sharesAvailable,
            "INSUFFICIENT_SHARES_AVAILABLE"
        );

        heartsOwed = uint72(
            FullMath.mulDivRoundingUp(
                sharesPurchased,
                listing.heartsStaked,
                listing.sharesTotal
            )
        );
        require(heartsOwed > 0, "INSUFFICIENT_HEARTS_INPUT");

        listing.sharesAvailable -= sharesPurchased;
        emit SharesUpdate(stakeId, msg.sender, listing.sharesAvailable);

        listing.shareOwners[shareReceiver] += sharesPurchased;
        listing.supplierHeartsOwed += heartsOwed;
        emit BuyShares(stakeId, shareReceiver, sharesPurchased);

        return heartsOwed;
    }

    function multiBuyShares(ShareOrder[] memory orders) external lock {
        uint256 orderCount = orders.length;
        require(orderCount <= 30, "EXCEEDED_ORDER_LIMIT");

        uint256 totalHeartsOwed;
        for (uint256 i = 0; i < orderCount; i++) {
            ShareOrder memory order = orders[i];
            totalHeartsOwed += _buyShares(
                order.stakeId,
                order.shareReceiver,
                order.sharesPurchased
            );
        }

        hexContract.transferFrom(msg.sender, address(this), totalHeartsOwed);
    }

    function buyShares(
        uint40 stakeId,
        address shareReceiver,
        uint72 sharesPurchased
    ) external lock {
        uint72 heartsOwed = _buyShares(stakeId, shareReceiver, sharesPurchased);
        hexContract.transferFrom(msg.sender, address(this), heartsOwed);
    }

    function claimEarnings(uint40 stakeId) external lock {
        ShareListing storage listing = shareListings[stakeId];
        require(listing.heartsEarned != 0, "SHARES_NOT_MATURE");

        uint72 ownedShares = listing.shareOwners[msg.sender];

        if (msg.sender == listing.supplier) {
            ownedShares += listing.sharesAvailable;
            listing.sharesAvailable = 0;
            emit SharesUpdate(stakeId, msg.sender, 0);
        }

        uint256 heartsOwed =
            FullMath.mulDiv(
                listing.heartsEarned,
                ownedShares,
                listing.sharesTotal
            );
        require(heartsOwed != 0, "NO_HEARTS_CLAIMABLE");

        listing.shareOwners[msg.sender] = 0;
        hexContract.transfer(msg.sender, heartsOwed);

        emit ClaimEarnings(stakeId, msg.sender, heartsOwed);
    }

    function supplierWithdraw(uint40 stakeId) external lock {
        ShareListing storage listing = shareListings[stakeId];
        require(msg.sender == listing.supplier, "SENDER_NOT_SUPPLIER");

        uint72 heartsOwed = listing.supplierHeartsOwed;
        require(heartsOwed != 0, "NO_HEARTS_OWED");

        listing.supplierHeartsOwed = 0;
        hexContract.transfer(msg.sender, heartsOwed);

        emit SupplierWithdraw(stakeId, msg.sender, heartsOwed);
    }
}