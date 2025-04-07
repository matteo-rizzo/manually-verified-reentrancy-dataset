/**
 *Submitted for verification at Etherscan.io on 2019-09-17
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-21
*/

pragma solidity ^0.5.7;


// Send more than WEI_MIN (init = 1 ETH) for 1002 Skts, and get unused ETH refund automatically.
//   Use the current Skt price of Skt Public-Sale.
//
// Conditions:
//   1. You have no Skt yet.
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
 * @title Skt interface
 */



/**
 * @title Skt Public-Sale interface
 */



/**
 * @title Get 1002 Skt
 */
contract Get10Skt is Ownable, Pausable {
    using SafeMath256 for uint256;

    ISkt public Skt = ISkt(0x2fB74C37Fb2C8DC76beA1910737aa9E3e2b53535);
    ISktPublicSale public Skt_PUBLIC_SALE;

    uint256 public WEI_MIN = 1 ether;
    uint256 private Skt_PER_TXN = 10000000; // 10.000000 Skt

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
     * @dev Get 10 Skt and ETH refund.
     */
    function () external payable whenNotPaused {
        require(msg.value >= WEI_MIN);
        require(Skt.balanceOf(address(this)) >= Skt_PER_TXN);
        require(Skt.balanceOf(msg.sender) == 0);
        require(!Skt.inWhitelist(msg.sender));
        require(!_alreadyGot[msg.sender]);

        uint256 __etherPrice;
        uint256 __SktUsdPrice;
        (__etherPrice, , __SktUsdPrice, , , , , , , ,) = Skt_PUBLIC_SALE.status();

        require(__etherPrice > 0);

        uint256 __usd = Skt_PER_TXN.mul(__SktUsdPrice).div(1000000);
        uint256 __wei = __usd.mul(1 ether).div(__etherPrice);
        
        require(msg.value >= __wei);

        if (msg.value > __wei) {
            msg.sender.transfer(msg.value.sub(__wei));
            _receiver.transfer(__wei);
        }

        _txs = _txs.add(1);
        _alreadyGot[msg.sender] = true;
        emit Tx(__etherPrice, __SktUsdPrice, __wei);

        assert(Skt.transfer(msg.sender, Skt_PER_TXN));
    }

    /**
     * @dev set Public Sale Address
     */
    function setPublicSaleAddress(address _pubSaleAddr) public onlyOwner {
        Skt_PUBLIC_SALE = ISktPublicSale(_pubSaleAddr);
    }

  

}