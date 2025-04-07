/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.7;

// TG Business Fund

/**
 * @title Ownable
 */



/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */



/**
 * @title TG Business Fund
 */
contract TGBusinessFund is Ownable{
    IERC20 public TG;
    address TG_Addr = address(0);

    event Donate(address indexed account, uint256 amount);

    /**
     * @dev constructor
     */
    constructor() public {
        TG = IERC20(TG_Addr);
    }

    /**
     * @dev donate
     */
    function () external payable {
        emit Donate(msg.sender, msg.value);
    }

    /**
     * @dev transfer TG
     */
    function transferTG(address to, uint256 amount) external onlyOwner {
        assert(TG.transfer(to, amount));
    }

    /**
     * @dev batch transfer
     */
    function batchTransfer(address[] memory accounts, uint256[] memory values) public onlyOwner {
        require(accounts.length == values.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            assert(TG.transfer(accounts[i], values[i]));
        }
    }

    /**
     * @dev set TG Address
     */
    function setTGAddress(address _TGAddr) public onlyOwner {
        TG_Addr = _TGAddr;
        TG = IERC20(_TGAddr);
    }
}