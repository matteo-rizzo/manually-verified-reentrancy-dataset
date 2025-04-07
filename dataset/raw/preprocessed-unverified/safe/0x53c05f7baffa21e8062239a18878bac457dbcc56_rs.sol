/**
 *Submitted for verification at Etherscan.io on 2019-11-13
*/

pragma solidity 0.5.10;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


/**
 * @title BlackListedRole.
 */
contract BlackListedRole is Ownable {
    using Roles for Roles.Role;

    event BlackListedAdded(address indexed account);
    event BlackListedRemoved(address indexed account);

    Roles.Role private _blackListeds;

    modifier onlyBlackListed() {
        require(isBlackListed(msg.sender), "Caller has no permission");
        _;
    }

    function isBlackListed(address account) public view returns (bool) {
        return(_blackListeds.has(account) || isOwner(account));
    }

    function addBlackListed(address account) public onlyOwner {
        _blackListeds.add(account);
        emit BlackListedAdded(account);
    }

    function removeBlackListed(address account) public onlyOwner {
        _blackListeds.remove(account);
        emit BlackListedRemoved(account);
    }
}

/**
 * @title GRSHAToken Interface
 */


/**
 * @title Distribution contract.
 */
contract Distribution is BlackListedRole {
    using SafeMath for uint256;

    IGRSHAToken token;

    uint256 index;
    uint256 sendingAmount;

    event Payed(address recipient, uint256 amount);
    event Error(address recipient);
    event Success();
    event Suspended();

    constructor(address tokenAddr) public {
        token = IGRSHAToken(tokenAddr);
    }

    function() external payable {
        if (msg.value == 0) {
            if (sendingAmount == 0) {
                sendingAmount = address(this).balance;
            }
            massSending(sendingAmount);
        }
    }

    function massSending(uint256 weiAmount) public onlyOwner {
        require(weiAmount != 0);
        address payable[] memory addresses = token.holders();

        for (uint i = index; i < addresses.length; i++) {
            uint256 amount = getShare(addresses[i], weiAmount);
            if (!isBlackListed(addresses[i]) && amount > 0 && addresses[i].send(amount)) {
                emit Payed(addresses[i], amount);
            } else {
                emit Error(addresses[i]);
            }

            if (i == addresses.length - 1) {
                token.unpause();
                index = 0;
                sendingAmount = 0;
                emit Success();
                break;
            }

            if (gasleft() <= 50000) {
                token.pause();
                index = i + 1;
                emit Suspended();
                break;
            }
        }
    }

    function setIndex(uint256 newIndex) public onlyOwner {
        index = newIndex;
    }

    function withdrawBalance() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {
        uint256 amount = IGRSHAToken(ERC20Token).balanceOf(address(this));
        IGRSHAToken(ERC20Token).transfer(recipient, amount);
    }

    function getShare(address account, uint256 weiAmount) public view returns(uint256) {
        return (token.balanceOf(account)).div(1e15).mul(weiAmount).div(token.totalSupply().div(1e15));
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

}