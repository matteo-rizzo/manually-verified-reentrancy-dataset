/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;





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



contract ShadowStakingV4 is Ownable,  MultiplierMath {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    struct UserInfo {
        uint256 rewardDebt;
        uint256 lastBlock;
    }


    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPointAmount;
        uint256 blockCreation;
    }

    IMilk2Token public milk;

    LastShadowContract public lastShadowContract;

    mapping (address => UserInfo) private userInfo;
    mapping (address => bool) public trustedSigner;

    address[] internal users;

    uint256 internal previousUsersCount;

    mapping (address => uint256) public newUsersId;

    PoolInfo[] private poolInfo;

    uint256 private totalPoints;

    uint256[5] internal epochs;

    uint256[5] internal multipliers;

    event Harvest(address sender, uint256 amount, uint256 blockNumber);
    event AddNewPool(address token, uint256 pid);
    event PoolUpdate(uint256 poolPid, uint256 previusPoints, uint256 newPoints);
    event AddNewKey(bytes keyHash, uint256 id);
    event EmergencyRefund(address sender, uint256 amount);

    constructor(IMilk2Token _milk, uint256[5] memory _epochs, uint256[5] memory _multipliers, LastShadowContract _lastShadowContract) public {
        milk = _milk;
        epochs = _epochs;
        multipliers = _multipliers;
        lastShadowContract = _lastShadowContract;
        previousUsersCount = lastShadowContract.getUsersCount();
    }


    function addNewPool(IERC20 _lpToken, uint256 _newPoints) public onlyOwner {
        totalPoints = totalPoints.add(_newPoints);
        poolInfo.push(PoolInfo({lpToken: _lpToken, allocPointAmount: _newPoints, blockCreation:block.number}));
        emit AddNewPool(address(_lpToken), _newPoints);
    }


    function setPoll(uint256 _poolPid, uint256 _newPoints) public onlyOwner {
        totalPoints = totalPoints.sub(poolInfo[_poolPid].allocPointAmount).add(_newPoints);
        poolInfo[_poolPid].allocPointAmount = _newPoints;
    }


    function setTrustedSigner(address _signer, bool _isValid) public onlyOwner {
        trustedSigner[_signer] = _isValid;
    }


    function getPool(uint256 _poolPid) public view returns(address _lpToken, uint256 _block, uint256 _weight) {
        _lpToken = address(poolInfo[_poolPid].lpToken);
        _block = poolInfo[_poolPid].blockCreation;
        _weight = poolInfo[_poolPid].allocPointAmount;
    }


    function getPoolsCount() public view returns(uint256) {
        return poolInfo.length;
    }


    function getRewards(address _user) public view returns(uint256) {
        if (newUsersId[_user] == 0) {
            return  lastShadowContract.getRewards(_user);
        } else {
            return  userInfo[_user].rewardDebt;
        }
    }


    function getLastBlock(address _user) public view returns(uint256) {
        if (newUsersId[_user] == 0) {
            return lastShadowContract.getLastBlock(_user);
        } else {
            return userInfo[_user].lastBlock;
        }
    }


    function getTotalPoints() public view returns(uint256) {
        return totalPoints;
    }


    function registration() public {
        require(getLastBlock(msg.sender) == 0, "User already exist");

        _registration(msg.sender, 0, block.number);
    }


    function getData(uint256 _amount, uint256 _lastBlockNumber, uint256 _currentBlockNumber, address _sender) public pure returns(bytes32) {
        return sha256(abi.encode(_amount, _lastBlockNumber, _currentBlockNumber, _sender));
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    ///// Refactored items
    /////////////////////////////////////////////////////////////////////////////////////
    /**
    *@dev Prepare abi encoded message
    */
    function getMsgForSign(uint256 _amount, uint256 _lastBlockNumber, uint256 _currentBlockNumber, address _sender) public pure returns(bytes32) {
        return keccak256(abi.encode(_amount, _lastBlockNumber, _currentBlockNumber, _sender));
    }

    /**
    * @dev prepare hash for sign with Ethereum comunity convention
    *see links below
    *https://ethereum.stackexchange.com/questions/24547/sign-without-x19ethereum-signed-message-prefix?rq=1
    *https://github.com/ethereum/EIPs/pull/712
    *https://programtheblockchain.com/posts/2018/02/17/signing-and-verifying-messages-in-ethereum/
    */
    function preSignMsg(bytes32 _msg) public pure returns(bytes32) {
        return _msg.toEthSignedMessageHash();
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
        require(_currentBlockNumber <= block.number, "currentBlockNumber cannot be larger than the last block");

        if (newUsersId[msg.sender] == 0) {
            _registration(msg.sender, getRewards(msg.sender), getLastBlock(msg.sender));
        }

        //Double spend check
        require(getLastBlock(msg.sender) == _lastBlockNumber, "lastBlockNumber must be equal to the value in the storage");

        //1. Lets check signer
        address signedBy = _msgForSign.recover(_signature);
        require(trustedSigner[signedBy] == true, "Signature check failed!");

        //2. Check signed msg integrety
        bytes32 actualMsg = getMsgForSign(
            _amount,
            _lastBlockNumber,
            _currentBlockNumber,
            msg.sender
        );
        require(actualMsg.toEthSignedMessageHash() == _msgForSign,"Integrety check failed!");

        //Actions

        userInfo[msg.sender].rewardDebt = userInfo[msg.sender].rewardDebt.add(_amount);
        userInfo[msg.sender].lastBlock = _currentBlockNumber;
        if (_amount > 0) {
            milk.transfer(msg.sender, _amount);
        }
        emit Harvest(msg.sender, _amount, _currentBlockNumber);
    }



    function getUsersCount() public view returns(uint256) {
        return users.length.add(previousUsersCount);
    }


    function getUser(uint256 _userId) public view returns(address) {
        if (_userId < previousUsersCount) {
            return lastShadowContract.getUser(_userId);
        }
        else {
            return users[_userId.sub(previousUsersCount)];
        }
    }


    function getTotalRewards(address _user) public view returns(uint256) {
        if (newUsersId[_user] == 0) {
            return lastShadowContract.getTotalRewards(_user);
        }
        else {
            return userInfo[_user].rewardDebt;
        }
    }


    function _registration(address _user, uint256 _rewardDebt, uint256 _lastBlock) internal {
        UserInfo storage _userInfo = userInfo[_user];
        _userInfo.rewardDebt = _rewardDebt;
        _userInfo.lastBlock = _lastBlock;
        users.push(_user);
        newUsersId[_user] = users.length;
    }


    function getValueMultiplier(uint256 _id) public view returns(uint256) {
        return multipliers[_id];
    }


    function getValueEpoch(uint256 _id) public view returns(uint256) {
        return epochs[_id];
    }


    function getMultiplier(uint256 f, uint256 t) public view returns(uint256) {
        return getInterval(min(t, epochs[1]), max(f, epochs[0])) * multipliers[0] +
        getInterval(min(t, epochs[2]), max(f, epochs[1])) * multipliers[1] +
        getInterval(min(t, epochs[3]), max(f, epochs[2])) * multipliers[2] +
        getInterval(min(t, epochs[4]), max(f, epochs[3])) * multipliers[3] +
        getInterval(max(t, epochs[4]), max(f, epochs[4])) * multipliers[4];
    }


    function getCurrentMultiplier() public view returns(uint256) {
        if (block.number < epochs[0]) {
            return 0;
        }
        if (block.number < epochs[1]) {
            return multipliers[0];
        }
        if (block.number < epochs[2]) {
            return multipliers[1];
        }
        if (block.number < epochs[3]) {
            return multipliers[2];
        }
        if (block.number < epochs[4]) {
            return multipliers[3];
        }
        if (block.number > epochs[4]) {
            return multipliers[4];
        }
    }


    function setEpoch(uint256 _id, uint256 _amount) public onlyOwner {
        epochs[_id] = _amount;
    }


    function setMultiplier(uint256 _id, uint256 _amount) public onlyOwner {
        multipliers[_id] = _amount;
    }


    function emergencyRefund() public onlyOwner {
        emit EmergencyRefund(msg.sender, milk.balanceOf(address(this)));
        milk.transfer(owner(), milk.balanceOf(address(this)));
    }

}