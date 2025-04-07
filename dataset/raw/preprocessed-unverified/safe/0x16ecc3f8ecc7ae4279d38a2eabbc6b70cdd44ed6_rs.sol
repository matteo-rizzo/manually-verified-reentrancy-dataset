/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;



abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



abstract contract IQLF is IERC165 {
    /**
     * @dev Returns if the given address is qualified, implemented on demand.
     */
    function ifQualified (address account) virtual external view returns (bool);

    /**
     * @dev Logs if the given address is qualified, implemented on demand.
     */
    function logQualified (address account, uint256 ito_start_time) virtual external returns (bool);

    /**
     * @dev Ensure that custom contract implements `ifQualified` amd `logQualified` correctly.
     */
    function supportsInterface(bytes4 interfaceId) virtual external override pure returns (bool) {
        return interfaceId == this.supportsInterface.selector || 
            interfaceId == (this.ifQualified.selector ^ this.logQualified.selector);
    }

    /**
     * @dev Emit when `ifQualified` is called to decide if the given `address`
     * is `qualified` according to the preset rule by the contract creator and 
     * the current block `number` and the current block `timestamp`.
     */
    event Qualification(address account, bool qualified, uint256 blockNumber, uint256 timestamp);
}

abstract contract IMTS {
  /**
    * @dev Returns a historical position of MASK of an address.
    */  
  function get_balance(address addr) virtual view public returns (uint256);
}

contract QLF_HISTORY_POSITION_500_MASK_MAIN is IQLF {
    using SafeERC20 for IERC20;

    string private name;
    uint256 private creation_time;
    uint256 start_time;
    address creator;
    mapping(address => bool) black_list;

    modifier creatorOnly {
        require(msg.sender == creator, "Not Authorized");
        _;
    }

    constructor (string memory _name, uint256 _start_time) {
        name = _name;
        creation_time = block.timestamp;
        start_time = _start_time;
        creator = msg.sender;
    }

    function get_name() public view returns (string memory) {
        return name;
    }

    function get_creation_time() public view returns (uint256) {
        return creation_time;
    }

    function get_start_time() public view returns (uint256) {
        return start_time;
    }

    function set_start_time(uint256 _start_time) public creatorOnly {
        start_time = _start_time;
    }

    function ifQualified(address account) public view override returns (bool qualified) {
        if (IMTS(address(0x42aca25Fd7Be774225abfbE4275beb9BF59c832f)).get_balance(account) < 500) {
            return false;
        }
        qualified = true;
    } 

    function logQualified(address account, uint256 ito_start_time) public override returns (bool qualified) {
        if (IMTS(address(0x42aca25Fd7Be774225abfbE4275beb9BF59c832f)).get_balance(account) < 500) {
            return false;
        }              
        if (start_time > block.timestamp || ito_start_time > block.timestamp) {
            black_list[account] = true;
            return false;
        }
        if (black_list[account]) {
            return false;
        }
        emit Qualification(account, true, block.number, block.timestamp);
        return true;
    } 

    function supportsInterface(bytes4 interfaceId) external override pure returns (bool) {
        return interfaceId == this.supportsInterface.selector || 
            interfaceId == (this.ifQualified.selector ^ this.logQualified.selector) ||
            interfaceId == this.get_start_time.selector;
    }    
}