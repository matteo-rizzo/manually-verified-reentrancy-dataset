/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.11;



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




contract FundsMgr is Ownable {
    using UniversalERC20 for IToken;

    function withdraw(address token, uint256 amount) public onlyOwnerWithLockPeriod {
        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            IToken(token).universalTransfer(owner, amount);
        }
    }

    function withdrawAll(address[] memory tokens) public onlyOwnerWithLockPeriod {
        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], IToken(tokens[i]).universalBalanceOf(address(this)));
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {
        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    /*function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }*/
}

contract TokenRefund is FundsMgr, DSMath {
    address public immutable token;
    bytes32 public immutable merkleRoot;

    uint256 public tokenPrice;  // in WAD (1e18)

    // This is a packed array of booleans.
    mapping(uint256 => uint256) internal claimedBitMap;


    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount, uint256 ethAmount);

    event TokenPriceSet(uint256 price);


    // 0xf028ADEe51533b1B47BEaa890fEb54a457f51E89
    // 0xf60b1cf822f64d69be551b4b59ccf21fec3ee988f951d14c3317090dcf342447
    // 17285209236593
    constructor(address token_, uint256 tokenPrice_, bytes32 merkleRoot_) public {
        token = token_;
        tokenPrice = tokenPrice_;
        merkleRoot = merkleRoot_;
    }


    // ** PUBLIC VIEW functions **

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }


    // ** PUBLIC functions **

    function claim(uint256 index, uint256 amount, bytes32[] memory merkleProof) public returns (uint256) {
        return _claim(index, msg.sender, amount, merkleProof);
    }


    // ** PUBLIC ONLY_OWNER functions **

    function claimByOwner(uint256 index, address account, uint256 amount, bytes32[] memory merkleProof) public onlyOwner returns (uint256) {
        return _claim(index, account, amount, merkleProof);
    }

    function setTokenPrice(uint256 price) public onlyOwnerWithLockPeriod {
        tokenPrice = price;
        emit TokenPriceSet(price);
    }


    // ** INTERNAL functions **

    function _claim(uint256 index, address account, uint256 amount, bytes32[] memory merkleProof) internal returns (uint256) {
        require(!isClaimed(index), 'MerkleDistributor: Already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed.
        _setClaimed(index);

        // Return tokens and send eth
        uint currentUserBalance = IToken(token).balanceOf(account);
        if (currentUserBalance < amount) amount = currentUserBalance;

        IToken(token).universalTransferFrom(account, address(this), amount);
        uint ethAmount = wmul(amount, tokenPrice);
        IToken(address(0x0)).universalTransfer(account, ethAmount);

        emit Claimed(index, account, amount, ethAmount);

        return ethAmount;
    }

    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }


    receive() external payable {}
}