/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

pragma solidity ^0.5.4;
// File: openzeppelin-solidity/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: contracts/FeeManager.sol
/**
 * @title FeeManager
 * @notice Manage the fees
 */
contract FeeManager is Ownable {

    uint256[] public fees;
    address public awgContractAddress;

    /**
     * @dev Callers must have the role.
     */
    modifier onlyAWG() {
        require(msg.sender == awgContractAddress, "Only AWG contract can call this function");
        _;
    }

    constructor(address _awgContractAddress) public {
        awgContractAddress = _awgContractAddress;
    }

    /**
     * @dev Called by AWG Contract to notify that a fee was processed and transferred
     */
    function processFee(uint256 _amount) external onlyAWG {
        fees.push(_amount);
    }

    /**
     * @dev Temporary call by the owner to retrieve the collected fees.
     * TBD: Will move to staking AWX to receive fees.
     */
    function withdrawTokens() external onlyOwner {
        IERC20(awgContractAddress).transfer(msg.sender,IERC20(awgContractAddress).balanceOf(address(this)));
    }
}