/**
 *Submitted for verification at Etherscan.io on 2019-06-24
*/

pragma solidity ^0.5.7;










contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor () internal {
        _paused = false;
    }


    function paused() public view returns (bool) {
        return _paused;
    }


    modifier whenNotPaused() {
        require(!_paused, "Paused.");
        _;
    }


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













contract Get102Token is Ownable, Pausable {
    using SafeMath256 for uint256;

    IToken           public TOKEN             = IToken(0x13bB73376c18faB89Dd5143D50BeF64d9D865200);
    ITokenPublicSale public TOKEN_PUBLIC_SALE = ITokenPublicSale(0xE94F0adA89B3CFecb7645911898b3907170Bf7CB);

    uint256 private WEI_MIN = 1 ether;
    uint256 private TOKEN_PER_TXN = 102000000; // 102.000000 TM Token

    uint256 private _txs;

    mapping (address => bool) _alreadyGot;

    event Tx(uint256 etherPrice, uint256 vokdnUsdPrice, uint256 weiUsed);


    function txs() public view returns (uint256) {
        return _txs;
    }


    function () external payable whenNotPaused {
        require(msg.value >= WEI_MIN);
        require(TOKEN.balanceOf(address(this)) >= TOKEN_PER_TXN);
        require(TOKEN.balanceOf(msg.sender) == 0);
        require(!TOKEN.inWhitelist(msg.sender));
        require(!_alreadyGot[msg.sender]);

        uint256 __etherPrice;
        uint256 __tokenUsdPrice;
        (__etherPrice, , , __tokenUsdPrice, , , , , , , ,) = TOKEN_PUBLIC_SALE.status();

        require(__etherPrice > 0);

        uint256 __usd = TOKEN_PER_TXN.mul(__tokenUsdPrice).div(1000000);
        uint256 __wei = __usd.mul(1 ether).div(__etherPrice);

        require(msg.value >= __wei);

        if (msg.value > __wei) {
            msg.sender.transfer(msg.value.sub(__wei));
            _receiver.transfer(__wei);
        }

        _txs = _txs.add(1);
        _alreadyGot[msg.sender] = true;
        emit Tx(__etherPrice, __tokenUsdPrice, __wei);

        assert(TOKEN.transfer(msg.sender, TOKEN_PER_TXN));
    }
}