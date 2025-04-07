/**
 *Submitted for verification at Etherscan.io on 2021-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IAddressResolver



// Part: IMintProposal



// Part: OpenZeppelin/[email protected]/Context

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: MintProposal.sol

contract MintProposal is IMintProposal, Ownable {
    using SafeMath for uint256;

    bytes32 public constant BORINGDAO = "BoringDAO";
    IAddressResolver addrReso;
    uint public diff=1;

    constructor(IAddressResolver _addrResovler) public {
        addrReso = _addrResovler;
    }

    struct Proposal {
        bytes32 tunnelKey;
        uint256 amount;
        uint256 voteCount;
        address creater;
        bool finished;
        bool isExist;
        mapping(address => bool) voteState;
        address to;
        string txid;
    }
    // mapping(address => bool) voteState;

    mapping(bytes32 => Proposal) public proposals;

    function setDiff(uint _diff) public onlyOwner {
        diff = _diff;
    }

    function approve(
        bytes32 _tunnelKey,
        string memory _txid,
        uint256 _amount,
        address to,
        address trustee,
        uint256 trusteeCount
    ) public override onlyBoringDAO returns (bool) {
        require(msg.sender == addrReso.key2address(BORINGDAO));
        bytes32 pid = keccak256(
            abi.encodePacked(_tunnelKey, _txid, _amount, to)
        );
        if (proposals[pid].isExist == false) {
            // new proposal
            Proposal memory p = Proposal({
                tunnelKey: _tunnelKey,
                to: to,
                txid: _txid,
                amount: _amount,
                creater: trustee,
                voteCount: 1,
                finished: false,
                isExist: true
            });
            proposals[pid] = p;
            proposals[pid].voteState[trustee] = true;
            emit VoteMintProposal(_tunnelKey, _txid, _amount, to, trustee, p.voteCount, trusteeCount);
        } else {
            // exist proposal
            Proposal storage p = proposals[pid];
            // had voted nothing to do more
            if(p.voteState[trustee] == true) {
                return false;
            }
            // proposal finished noting to do more
            if (p.finished) {
                return false;
            }
            p.voteCount = p.voteCount.add(1);
            p.voteState[trustee] = true;
            emit VoteMintProposal(_tunnelKey, _txid, _amount, to, trustee, p.voteCount, trusteeCount);
        }
        Proposal storage p = proposals[pid];
        uint threshold = trusteeCount.mod(3) == 0 ? trusteeCount.mul(2).div(3) : trusteeCount.mul(2).div(3).add(diff);
        if (p.voteCount >= threshold) {
            p.finished = true;
            return true;
        } else {
            return false;
        }
    }

    modifier onlyBoringDAO {
        require(msg.sender == addrReso.key2address(BORINGDAO), "MintProposal::caller is not boringDAO");
        _;
    }

    event VoteMintProposal(
        bytes32 _tunnelKey,
        string _txid,
        uint256 _amount,
        address to,
        address trustee,
        uint votedCount,
        uint256 trusteeCount
    );

}