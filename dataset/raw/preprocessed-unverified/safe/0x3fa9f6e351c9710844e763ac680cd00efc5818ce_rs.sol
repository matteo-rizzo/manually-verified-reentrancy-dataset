/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.7;

// TG Airdrop Fund
//   Keep your ETH balance > (...)
//      See https://TG.io/en/latest/token/airdrop_via_contract.html
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
 * @title TG Airdrop
 */
contract TGAirdrop is Ownable {
    using SafeMath for uint256;

    IERC20 public TG;
    address TG_Addr = address(0);

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
        TG = IERC20(TG_Addr);
    }

    /**
     * @dev receive ETH and send TGs
     */
    function () external payable {
        require(_airdopped[msg.sender] != true);
        require(msg.sender.balance >= _wei_min);

        uint256 balance = TG.balanceOf(address(this));
        require(balance > 0);

        uint256 TGAmount = 100;
        TGAmount = TGAmount.add(uint256(keccak256(abi.encode(now, msg.sender, now))) % 100).mul(10 ** 6);

        if (TGAmount <= balance) {
            assert(TG.transfer(msg.sender, TGAmount));
        } else {
            assert(TG.transfer(msg.sender, balance));
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
     * @dev set TG Address
     */
    function setTGAddress(address _TGAddr) public onlyOwner {
        TG_Addr = _TGAddr;
        TG = IERC20(_TGAddr);
    }
}