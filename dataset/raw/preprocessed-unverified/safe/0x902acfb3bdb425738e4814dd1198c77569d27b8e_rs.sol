/**
 *Submitted for verification at Etherscan.io on 2019-11-05
*/

pragma solidity 0.5.11;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */

contract ERC20BasicInterface {
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals;
}
contract GachaDrop is Ownable {
    uint public periodToPlay = 86400; // 86400; // seconds
    uint256 public requireHB = 0;
    bool public isEnded;
    address HBWallet = address(0xEc7ba74789694d0d03D458965370Dc7cF2FE75Ba);
    ERC20BasicInterface public hbwalletToken = ERC20BasicInterface(HBWallet);
    mapping(address => uint) public timeTrackUser;
    event _random(address _from, uint _ticket);
    constructor() public {}
    function getAward() public {
        require(isValidToPlay());
        timeTrackUser[msg.sender] = block.timestamp;
        emit _random(msg.sender, block.timestamp);
    }

    function isValidToPlay() public view returns (bool){
        return (!isEnded
        && periodToPlay <= now - timeTrackUser[msg.sender]
        && hbwalletToken.balanceOf(msg.sender) >= requireHB);
    }
    function changePeriodToPlay(uint _period) onlyOwner public{
        periodToPlay = _period;
    }
    function updateGetAward() onlyOwner public{
        isEnded = true;
    }
    function updateRequireHB(uint256 _requireHB) onlyOwner public{
        requireHB = _requireHB;
    }

}