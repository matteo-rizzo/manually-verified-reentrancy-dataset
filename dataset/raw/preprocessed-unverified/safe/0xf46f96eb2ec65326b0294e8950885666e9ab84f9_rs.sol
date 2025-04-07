/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





contract MultiSend is Ownable {
    mapping(address => bool) private _isWhiteList;

    modifier onlyWhiteList() {
        require(_isWhiteList[msg.sender], "You do not have execute permission");
        _;
    }

    constructor () {
        _isWhiteList[msg.sender] = true;
    }

    receive() external payable {}

    function addWhiteList(address[] calldata _account) external onlyOwner() {
        for (uint256 i = 0; i < _account.length; i++) {
            _isWhiteList[_account[i]] = true;
        }
    }

    function isWhiteList(address _account) public view returns (bool) {
        return _isWhiteList[_account];
    }

    function RecoverERC20(address tokenAddress) public onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(tokenAddress, msg.sender, balance);
    }

    function RecoverETH() public onlyWhiteList() {
        address owner = owner();
        payable(owner).transfer(address(this).balance);
    }

    function MultiSendETH(address[] calldata _users, uint256 _amount) external payable onlyWhiteList {
        require(_amount != 0, 'amount is 0');
        require(_users.length != 0, 'users is 0');

        uint256 userCount = _users.length;
        uint256 balance = address(this).balance;

        require(balance >= _amount * userCount, 'Insufficient balance');
        // send eth
        for (uint256 i = 0; i < userCount; i++) {
            payable(_users[i]).transfer(_amount);
        }
        if (address(this).balance != 0) {
            RecoverETH();
        }
    }

    function BulkSendETH(address[] calldata _users, uint256[] calldata _amount) external payable onlyWhiteList {
        require(address(this).balance != 0, 'balance is 0');
        require(_amount.length != 0, 'amount is 0');
        require(_users.length != 0, 'users is 0');

        uint256 amountCount = _amount.length;
        uint256 userCount = _users.length;

        require(amountCount == userCount, 'counter do not match');
        // send eth
        for (uint256 i = 0; i < userCount; i++) {
            payable(_users[i]).transfer(_amount[i]);
        }
        if (address(this).balance != 0) {
            RecoverETH();
        }
    }
    
    function MultiSendToken(address[] calldata _users, uint256 _amount, address _tokenAddress) external onlyWhiteList {
        require(_amount != 0, 'amount is 0');
        require(_users.length != 0, 'users is 0');

        uint256 userCount = _users.length;

        TransferHelper.safeTransferFrom(_tokenAddress, msg.sender, address(this), _amount * userCount);
        // send token
        for (uint256 i = 0; i < userCount; i++) {
            TransferHelper.safeTransfer(_tokenAddress, _users[i], _amount);
        }
        if (IERC20(_tokenAddress).balanceOf(address(this)) != 0) {
            RecoverERC20(_tokenAddress);
        }
    }

    function BulkSendToken(address[] calldata _users, uint256[] calldata _amount, address _tokenAddress) external onlyWhiteList {
        require(_amount.length != 0, 'amount is 0');
        require(_users.length != 0, 'users is 0');

        uint256 amountCount = _amount.length;
        uint256 userCount = _users.length;

        require(amountCount == userCount, 'counter do not match');
        // check amount
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amountCount; i++) {
            totalAmount += _amount[i];
        }

        TransferHelper.safeTransferFrom(_tokenAddress, msg.sender, address(this), totalAmount);
        // send token
        for (uint256 i = 0; i < userCount; i++) {
            TransferHelper.safeTransfer(_tokenAddress, _users[i], _amount[i]);
        }
        if (IERC20(_tokenAddress).balanceOf(address(this)) != 0) {
            RecoverERC20(_tokenAddress);
        }
    }
    

}