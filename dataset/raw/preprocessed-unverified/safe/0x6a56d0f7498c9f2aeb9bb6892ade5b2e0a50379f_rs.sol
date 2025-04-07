/**
 *Submitted for verification at Etherscan.io on 2021-08-24
*/

// SPDX-License-Identifier: No License (None)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


contract MultisigWallet {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct Ballot {
        uint128 votes;      // bitmap of unique votes (max 127 votes)
        uint64 expire;      // time when ballot expire
        uint8 yea;          // number of votes `Yea`
    }

    EnumerableSet.AddressSet owners; // founders may transfer contract's ownership
    uint256 public ownersSetCounter;   // each time when change owners increase the counter
    uint256 public expirePeriod = 3 days;
    mapping(bytes32 => Ballot) public ballots;
 
    event SetOwner(address owner, bool isEnable);
    event CreateBallot(bytes32 ballotHash, uint256 expired);
    event Execute(bytes32 ballotHash, address to, uint256 value, bytes data);


    modifier onlyThis() {
        require(address(this) == msg.sender, "Only multisig allowed");
        _;
    }
    
    constructor (address[] memory _owners) {
        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Zero address");
            owners.add(_owners[i]);
        }
    }

    // get number of owners
    function getOwnersNumber() external view returns(uint256) {
        return owners.length();
    }

    // returns list of owners addresses
    function getOwners() external view returns(address[] memory) {
        return owners._values;
    }

    // add owner
    function addOwner(address owner) external onlyThis{
        require(owner != address(0), "Zero address");
        require(owners.length() < 127, "Too many owners");
        require(owners.add(owner), "Owner already added");
        ownersSetCounter++; // change owners set
        emit SetOwner(owner, true);
    }

    // remove owner
    function removeOwner(address owner) external onlyThis{
        require(owners.length() > 1, "Remove all owners is not allowed");
        require(owners.remove(owner), "Owner does not exist");
        ownersSetCounter++; // change owners set
        emit SetOwner(owner, false);
    }
    
    function setExpirePeriod(uint256 period) external onlyThis {
        require(period >= 1 days, "Too short period");  // avoid deadlock in case of set too short period
        expirePeriod = period;
    }

    function vote(address to, uint256 value, bytes calldata data) external {
        uint256 index = owners.indexOf(msg.sender);
        require(index != 0, "Only owner");
        bytes32 ballotHash = keccak256(abi.encodePacked(to, value, data, ownersSetCounter));
        Ballot memory b = ballots[ballotHash];
        if (b.expire == 0 || b.expire < uint64(block.timestamp)) { // if no ballot or ballot expired - create new ballot
            b.expire = uint64(block.timestamp + expirePeriod);
            b.votes = 0;
            b.yea = 0;
            emit CreateBallot(ballotHash, b.expire);
        }
        uint256 mask = 1 << index;
        if (b.votes & mask == 0) {  // this owner don't vote yet.
            b.votes = uint128(b.votes | mask); // record owner's vote
            b.yea += 1; // increase total votes "Yea"
        }

        if (b.yea >= owners.length() / 2 + 1) {   // vote "Yea" > 50% of owners
            delete ballots[ballotHash];
            execute(to, value, data);
            emit Execute(ballotHash, to, value, data);
        } else {
            // update ballot
            ballots[ballotHash] = b;
        }
    }

    function execute(address to, uint256 value, bytes memory data) internal {
        (bool success,) = to.call{value: value}(data);
        require(success, "Execute error");
    }
}