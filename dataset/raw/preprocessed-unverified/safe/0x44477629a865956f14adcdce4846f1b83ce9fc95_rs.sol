/**
 *Submitted for verification at Etherscan.io on 2021-02-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */


/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */


contract XReferral {
    mapping(address => address) public referrers; // account_address -> referrer_address
    mapping(address => uint256) public referredCount; // referrer_address -> num_of_referred

    event Referral(address indexed referrer, address indexed farmer);

    // Standard contract ownership transfer.
    address public owner;
    address private nextOwner;

    mapping(address => bool) public isAdmin;
    
    // Add the library methods
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    // Declare a set state variable
    EnumerableMap.UintToAddressMap private rnds;
    uint256 public rndSeedMax;

    constructor () public {
        owner = msg.sender;
        isAdmin[owner] = true;
        referrers[owner] = owner;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    modifier onlyAdmin {
        require(isAdmin[msg.sender], "OnlyAdmin methods called by non-admin.");
        _;
    }

    // Standard contract ownership transfer implementation,
    function approveNextOwner(address _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "Can only accept a preapproved new owner.");
        owner = nextOwner;
    }

    function setReferrer(address farmer, address referrer) public onlyAdmin {
        require(farmer != address(0), "!farmer");
        require(isValidReferrer(referrer), "!referrer");
        if (referrers[farmer] == address(0) && referrer != address(0)) {
            referrers[farmer] = referrer;
            referredCount[referrer] += 1;
            emit Referral(referrer, farmer);
        }
    }

    function getReferrer(address farmer) public view returns (address) {
        return referrers[farmer];
    }

    function isValidReferrer(address referrer) public view returns (bool) {
        return getReferrer(referrer) != address(0);
    }

    // Set admin status.
    function setAdminStatus(address _admin, bool _status) external onlyOwner {
        isAdmin[_admin] = _status;
    }
    
    // Seeds setup.
    function rndSeeds(address[] calldata seeds, uint16[] calldata weis) public onlyOwner {
        require(rnds.length() == 0, "!rnds");
        require(seeds.length == weis.length, "!same length");

        uint256 sum = 0;
        uint256 len = seeds.length;
        for(uint256 i = 0; i < len; ++i) {
            if(weis[i] != 0 && seeds[i] != address(0)) {
                rnds.set(sum, seeds[i]);
                sum += weis[i];
                
                // setup referrer
                setReferrer(seeds[i], owner);
            }
        }
        
        // put an additional element as sentinel
        rnds.set(sum, owner);
        rndSeedMax = sum;
    }
    
    function rndSeed(uint256 rnd) public view returns (address, bool) {
        uint256 len = rnds.length();
        
        if(len < 2) {
            return (owner, false);
        }
        
        uint256 weis;
        for(uint256 i=0; i < len; ++i) {
            (weis, ) = rnds.at(i);
            if(weis > rnd && i > 0) {
                (, address addr) = rnds.at(i - 1);
                return (addr, true);
            }
        }
        
        return (owner, false);
    }

    event EmergencyERC20Drain(address token, address owner, uint256 amount);

    // owner can drain tokens that are sent here by mistake
    function emergencyERC20Drain(IERC20 token, uint amount) external onlyOwner {
        emit EmergencyERC20Drain(address(token), owner, amount);
        token.transfer(owner, amount);
    }
}