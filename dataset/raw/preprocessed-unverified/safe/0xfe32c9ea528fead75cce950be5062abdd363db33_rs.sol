/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

pragma solidity =0.6.6;

/**
 * Math operations with safety checks
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */






contract Gswap_stake is Ownable{
    using SafeMath for uint;

    INFT public nft;
    ERC20 public usdg;
    uint public cost;

    mapping (uint => address) private tokenHolders;

    event GovWithdrawToken(address indexed token, address indexed to, uint256 value);

    constructor(address _usdg,address _nft, uint _cost)public {
        setParams(_usdg,_nft,_cost);
    }

    function ipo(string memory _symbol, string memory _name, string memory _icon,uint _goal) public {
        uint allowed = usdg.allowance(msg.sender,address(this));
        uint balanced = usdg.balanceOf(msg.sender);
        require(allowed >= cost, "!allowed");
        require(balanced >= cost, "!balanced");
        usdg.transferFrom( msg.sender,address(this), cost);

        uint tokenId = nft.mintNft(msg.sender,_symbol,_name,_icon,_goal);
        tokenHolders[tokenId] = msg.sender;
    }

    function addFile(uint _tokenId, string memory _file)public{
        require(tokenHolders[_tokenId] == msg.sender, "not authorized");
        nft.addFile(_tokenId,_file);
    }

    function govWithdraUsdg(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        usdg.transfer( msg.sender, _amount);
        emit GovWithdrawToken(address(usdg), msg.sender, _amount);
    }

    function setParams(address _usdg,address _nft, uint _cost)onlyOwner public {
        usdg = ERC20(_usdg);
        nft = INFT(_nft);
        cost = _cost;
    }
}