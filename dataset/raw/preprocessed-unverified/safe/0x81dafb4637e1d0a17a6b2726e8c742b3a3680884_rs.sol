/**
 *Submitted for verification at Etherscan.io on 2019-06-21
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

    IERC20 Wesion = IERC20(0x2c1564A74F07757765642ACef62a583B38d5A213);

    /**
     * @dev Batch transfer both.
     */
    function batchTransfer(address payable[] memory accounts, uint256 etherValue, uint256 vokenValue) public payable {
        uint256 __etherBalance = address(this).balance;
        uint256 __vokenAllowance = Wesion.allowance(msg.sender, address(this));

        require(__etherBalance >= etherValue.mul(accounts.length));
        require(__vokenAllowance >= vokenValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
            assert(Wesion.transferFrom(msg.sender, accounts[i], vokenValue));
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
    function batchTransferWesion(address[] memory accounts, uint256 wesionValue) public {
        uint256 _wesionAllowance = Wesion.allowance(msg.sender, address(this));

        require(_wesionAllowance >= wesionValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            assert(Wesion.transferFrom(msg.sender, accounts[i], wesionValue));
        }
    }

    /**
     * @dev set Wesion Address
     */
    function setWesionAddress(address _WesionAddr) public onlyOwner {
        Wesion = IERC20(_WesionAddr);
    }
}