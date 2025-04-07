/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;


// 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}









contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}



contract GShibaMigrator is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IRFI public oldToken;
    IERC20 public newToken;

    uint256 public decimals1;
    uint256 public decimals2;

    mapping (address => uint256) public MAX_EXCHANGABLE;
    mapping (address => uint256) public exchangedAmount;
    event TokenExchanged(address indexed recipient, uint256 amount, uint256 timestamp);

    constructor(address _oldToken, address _newToken) public {
        oldToken = IRFI(_oldToken);
        newToken = IERC20(_newToken);

        decimals1 = oldToken.decimals();
        decimals2 = newToken.decimals();
    }

    function setMaxExchangable(address[] calldata _users , uint256[] calldata _amounts) external onlyOwner {
        require(_users.length == _amounts.length, "setmaxExchangable: Sth went wrong!");

        for(uint256 i = 0; i < _users.length; i ++) {
            MAX_EXCHANGABLE[_users[i]] = MAX_EXCHANGABLE[_users[i]].add(_amounts[i]);
        }
    }
    function updateOldToken(address _oldToken) external onlyOwner {
        oldToken = IRFI(_oldToken);
        decimals1 = oldToken.decimals();
    }

    function updateNewToken(address _newToken) external onlyOwner {
        newToken = IERC20(_newToken);
        decimals2 = newToken.decimals();
    }
    function migrateToNew(uint256 _amount) external {
        require(_amount > 0, "migrateToNew: Cannot exchange ZERO amount!");
        uint256 newAmount = exchangedAmount[_msgSender()].add(_amount);
        require(newAmount <= MAX_EXCHANGABLE[_msgSender()], "migrateToNew: Cannot exceed the max exchangable amount!");
        require(oldToken.transferFrom(_msgSender(), address(this), _amount), "migrateToNew: Not enough old token balance!");

        // Fit to newtoken's decimals
        uint256 newTokenBalance = _amount.mul(10**decimals2).div(10**decimals1);
        require(newToken.transfer(_msgSender(), newTokenBalance), "migrateToNew: Cannot transfer the new token!");
        require(newToken.migrate(_msgSender(), newTokenBalance), "migrateToNew: Migration has been failed!");
        exchangedAmount[_msgSender()] = newAmount;

        emit TokenExchanged(_msgSender(), _amount, block.timestamp);
    }

    function withdrawOldToken(address _treasury) external onlyOwner {
        require(oldToken.transfer(_treasury, oldToken.balanceOf(address(this))), "withdrawOldToken: Cannot withdraw the old token!");
    }

    function withdrawRemainedNewToken(address _treasury) external onlyOwner {
        require(newToken.transfer(_treasury, newToken.balanceOf(address(this))), "withdrawRemainedNewToken: Cannot withdraw the new token!");
    }
}