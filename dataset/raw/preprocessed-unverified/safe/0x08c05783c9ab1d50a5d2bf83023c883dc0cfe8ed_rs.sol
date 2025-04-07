/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.7;

// TG Early Investors Fund
//   Freezed till 2020-06-30 23:59:59, (timestamp 1593532799).


/**
 * @title SafeMath
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
 * @title TG Early Investors Fund
 */
contract TGEarlyInvestorsFund is Ownable{
    using SafeMath for uint256;

    IERC20 public TG;
    address TG_Addr = address(0);

    uint32 private _till = 1592722800;
    uint256 private _holdings;

    mapping (address => uint256) private _investors;

    event InvestorRegistered(address indexed account, uint256 amount);
    event Donate(address indexed account, uint256 amount);


    /**
     * @dev constructor
     */
    constructor() public {
        TG = IERC20(TG_Addr);
    }

    /**
     * @dev Withdraw or Donate by any amount
     */
    function () external payable {
        if (now > _till && _investors[msg.sender] > 0) {
            assert(TG.transfer(msg.sender, _investors[msg.sender]));
            _investors[msg.sender] = 0;
        }

        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    /**
     * @dev holdings amount
     */
    function holdings() public view returns (uint256) {
        return _holdings;
    }

    /**
     * @dev balance of the owner
     */
    function investor(address owner) public view returns (uint256) {
        return _investors[owner];
    }

    /**
     * @dev register an investor
     */
    function registerInvestor(address to, uint256 amount) external onlyOwner {
        _holdings = _holdings.add(amount);
        require(_holdings <= TG.balanceOf(address(this)));
        _investors[to] = _investors[to].add(amount);
        emit InvestorRegistered(to, amount);
    }

    /**
     * @dev Rescue compatible ERC20 Token, except "TG"
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(TG != _token);
        require(receiver != address(0));

        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }

    /**
     * @dev set TG Address
     */
    function setTGAddress(address _TGAddr) public onlyOwner {
        TG_Addr = _TGAddr;
        TG = IERC20(_TGAddr);
    }
}