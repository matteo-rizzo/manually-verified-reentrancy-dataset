/**
 *Submitted for verification at Etherscan.io on 2019-06-15
*/

pragma solidity ^0.5.7;


// Batch transfer Ether and Wesion

/**
 * @title SafeMath for uint256
 * @dev Unsigned math operations with safety checks that revert on error.
 */



/**
 * @title Ownable
 */



/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */



/**
 * @title Batch Transfer Ether And Wesion
 */
contract BatchTransferEtherAndWesion is Ownable{
    using SafeMath256 for uint256;

    IERC20 VOKEN = IERC20(0xF0921CF26f6BA21739530ccA9ba2548bB34308f1);

    /**
     * @dev Batch transfer both.
     */
    function batchTransfer(address payable[] memory accounts, uint256 etherValue, uint256 vokenValue) public payable {
        uint256 __etherBalance = address(this).balance;
        uint256 __vokenAllowance = VOKEN.allowance(msg.sender, address(this));

        require(__etherBalance >= etherValue.mul(accounts.length));
        require(__vokenAllowance >= vokenValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
            assert(VOKEN.transferFrom(msg.sender, accounts[i], vokenValue));
        }
    }

    /**
     * @dev Batch transfer Ether.
     */
    function batchTtransferEther(address payable[] memory accounts, uint256 etherValue) public payable {
        uint256 __etherBalance = address(this).balance;

        require(__etherBalance >= etherValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
        }
    }

    /**
     * @dev Batch transfer Wesion.
     */
    function batchTransferWesion(address[] memory accounts, uint256 vokenValue) public {
        uint256 __vokenAllowance = VOKEN.allowance(msg.sender, address(this));

        require(__vokenAllowance >= vokenValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            assert(VOKEN.transferFrom(msg.sender, accounts[i], vokenValue));
        }
    }
}