/**
 *Submitted for verification at Etherscan.io on 2019-06-21
*/

pragma solidity ^0.5.7;

// wesion Airdrop Fund
//   Keep your ETH balance > (...)
//      See https://wesion.io/en/latest/token/airdrop_via_contract.html
//
//   And call this contract (send 0 ETH here),
//   and you will receive 100-200 VNET Tokens immediately.

/**
 * @title Ownable
 */



/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */



/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */



/**
 * @title wesion Airdrop
 */
contract WesionAirdrop is Ownable {
    using SafeMath for uint256;

    IERC20 public wesion;

    uint256 private _wei_min;

    mapping(address => bool) public _airdopped;

    event Donate(address indexed account, uint256 amount);

    /**
     * @dev Wei Min
     */
    function wei_min() public view returns (uint256) {
        return _wei_min;
    }

    /**
     * @dev constructor
     */
    constructor() public {
        wesion = IERC20(0x2c1564A74F07757765642ACef62a583B38d5A213);
    }

    /**
     * @dev receive ETH and send wesions
     */
    function () external payable {
        require(_airdopped[msg.sender] != true);
        require(msg.sender.balance >= _wei_min);

        uint256 balance = wesion.balanceOf(address(this));
        require(balance > 0);

        uint256 wesionAmount = 100;
        wesionAmount = wesionAmount.add(uint256(keccak256(abi.encode(now, msg.sender, now))) % 100).mul(10 ** 6);

        if (wesionAmount <= balance) {
            assert(wesion.transfer(msg.sender, wesionAmount));
        } else {
            assert(wesion.transfer(msg.sender, balance));
        }

        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    /**
     * @dev set wei min
     */
    function setWeiMin(uint256 value) external onlyOwner {
        _wei_min = value;
    }

    /**
     * @dev set Wesion Address
     */
    function setWesionAddress(address _WesionAddr) public onlyOwner {
        wesion = IERC20(_WesionAddr);
    }
}