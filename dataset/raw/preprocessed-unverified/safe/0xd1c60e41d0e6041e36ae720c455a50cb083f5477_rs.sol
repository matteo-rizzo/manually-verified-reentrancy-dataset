/**
 *Submitted for verification at Etherscan.io on 2021-08-23
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;





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
}









contract MultiplierMath {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }


    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }


    function getInterval(uint256 a, uint256 b) internal pure returns(uint256) {
        return a > b ? a - b : 0;
    }

}

contract ShadowDropV1 is Ownable,  MultiplierMath {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    struct UserInfo {
        uint256 rewardDebt;
        uint256 lastBlock;
    }

    IToken public token;

    mapping (address => UserInfo) private userInfo;
    mapping (address => bool) public trustedSigner;

    address[] internal users;

    mapping (address => uint256) private newUsersId;

    event Harvest(address sender, uint256 amount, uint256 blockNumber);
    event EmergencyRefund(address sender, uint256 amount);

    constructor(IToken _token, address _signer) public {
        token = _token;
        trustedSigner[_signer]=true;
    }


    function getRewards(address _user) public view returns(uint256) {
        return  userInfo[_user].rewardDebt;
    }


    function getLastBlock(address _user) public view returns(uint256) {
        return userInfo[_user].lastBlock;
    }


    /**
    * @dev Check signature and transfer tokens
    * @param  _amount - subj
    * @param  _lastBlockNumber - subj
    * @param  _currentBlockNumber - subj
    * @param  _msgForSign - hash for sign with Ethereum style prefix!!!
    * @param  _signature  - signature
    */
    function harvest(uint256 _amount, uint256 _lastBlockNumber, uint256 _currentBlockNumber, bytes32 _msgForSign, bytes memory _signature) public {
        require(_amount > 0, "Amount must positive number");
        require(token.balanceOf(address(this)) >= _amount, "Insufficient funds");

        if (newUsersId[msg.sender] == 0) {
            _registration(msg.sender, getRewards(msg.sender), getLastBlock(msg.sender));
        }

        //Double spend check
        require(getLastBlock(msg.sender) == _lastBlockNumber, "lastBlockNumber must be equal to the value in the storage");

        //1. Lets check signer
        address signedBy = _msgForSign.recover(_signature);
        require(trustedSigner[signedBy] == true, "Signature check failed!");

        //2. Check signed msg integrety
        bytes32 actualMsg = _getMsgForSign(
            _amount,
            _lastBlockNumber,
            _currentBlockNumber,
            msg.sender
        );
        require(actualMsg.toEthSignedMessageHash() == _msgForSign,"Integrety check failed!");

        //Actions

        userInfo[msg.sender].rewardDebt = userInfo[msg.sender].rewardDebt.add(_amount);
        userInfo[msg.sender].lastBlock = _currentBlockNumber;
        token.transfer(msg.sender, _amount);
        emit Harvest(msg.sender, _amount, _currentBlockNumber);
    }

    function _registration(address _user, uint256 _rewardDebt, uint256 _lastBlock) internal {
        UserInfo storage _userInfo = userInfo[_user];
        _userInfo.rewardDebt = _rewardDebt;
        _userInfo.lastBlock = _lastBlock;
        users.push(_user);
        newUsersId[_user] = users.length;
    }

    function _getMsgForSign(uint256 _amount, uint256 _lastBlockNumber, uint256 _currentBlockNumber, address _sender) internal pure returns(bytes32) {
        return keccak256(abi.encode(_amount, _lastBlockNumber, _currentBlockNumber, _sender));
    }

    function emergencyRefund() public onlyOwner {
        emit EmergencyRefund(msg.sender, token.balanceOf(address(this)));
        token.transfer(owner(), token.balanceOf(address(this)));
    }


    function setTrustedSigner(address _signer, bool _isValid) public onlyOwner {
        trustedSigner[_signer] = _isValid;
    }
}