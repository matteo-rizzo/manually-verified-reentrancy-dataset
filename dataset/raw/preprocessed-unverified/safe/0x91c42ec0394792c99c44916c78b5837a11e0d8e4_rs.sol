/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.7;


// Send more than WEI_MIN (init = 1 ETH) for 1002 TGs, and get unused ETH refund automatically.
//   Use the current TG price of TG Public-Sale.
//
// Conditions:
//   1. You have no TG yet.
//   2. You are not in the whitelist yet.
//   3. Send more than 1 ETH (for balance verification).
//

/**
 * @title SafeMath for uint256
 * @dev Unsigned math operations with safety checks that revert on error.
 */



/**
 * @title Ownable
 */



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor () internal {
        _paused = false;
    }

    /**
     * @return Returns true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Paused.");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function setPaused(bool state) external onlyOwner {
        if (_paused && !state) {
            _paused = false;
            emit Unpaused(msg.sender);
        } else if (!_paused && state) {
            _paused = true;
            emit Paused(msg.sender);
        }
    }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */



/**
 * @title TG interface
 */



/**
 * @title TG Public-Sale interface
 */



/**
 * @title Get 1002 TG
 */
contract Get1002TG is Ownable, Pausable {
    using SafeMath256 for uint256;

    address TG_Addr = address(0);
    ITG public TG = ITG(TG_Addr);

    ITGPublicSale public TG_PUBLIC_SALE;

    uint256 public WEI_MIN = 1 ether;
    uint256 private TG_PER_TXN = 1002000000; // 1002.000000 TG

    uint256 private _txs;

    mapping (address => bool) _alreadyGot;

    event Tx(uint256 etherPrice, uint256 vokdnUsdPrice, uint256 weiUsed);

    /**
     * @dev Transaction counter
     */
    function txs() public view returns (uint256) {
        return _txs;
    }

    function setWeiMin(uint256 weiMin) public onlyOwner {
        WEI_MIN = weiMin;
    }

    /**
     * @dev Get 1002 TG and ETH refund.
     */
    function () external payable whenNotPaused {
        require(msg.value >= WEI_MIN);
        require(TG.balanceOf(address(this)) >= TG_PER_TXN);
        require(TG.balanceOf(msg.sender) == 0);
        require(!TG.inWhitelist(msg.sender));
        require(!_alreadyGot[msg.sender]);

        uint256 __etherPrice;
        uint256 __TGUsdPrice;
        (__etherPrice, , , __TGUsdPrice, , , , , , , ,) = TG_PUBLIC_SALE.status();

        require(__etherPrice > 0);

        uint256 __usd = TG_PER_TXN.mul(__TGUsdPrice).div(1000000);
        uint256 __wei = __usd.mul(1 ether).div(__etherPrice);

        require(msg.value >= __wei);

        if (msg.value > __wei) {
            msg.sender.transfer(msg.value.sub(__wei));
            _receiver.transfer(__wei);
        }

        _txs = _txs.add(1);
        _alreadyGot[msg.sender] = true;
        emit Tx(__etherPrice, __TGUsdPrice, __wei);

        assert(TG.transfer(msg.sender, TG_PER_TXN));
    }

    /**
     * @dev set Public Sale Address
     */
    function setPublicSaleAddress(address _pubSaleAddr) public onlyOwner {
        TG_PUBLIC_SALE = ITGPublicSale(_pubSaleAddr);
    }

    /**
     * @dev set TG Address
     */
    function setTGAddress(address _TgAddr) public onlyOwner {
        TG_Addr = _TgAddr;
        TG = ITG(_TgAddr);
    }

}