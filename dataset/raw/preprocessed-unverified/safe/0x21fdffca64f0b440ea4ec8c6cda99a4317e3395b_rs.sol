/**
 *Submitted for verification at Etherscan.io on 2021-02-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


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

contract ShadowStakingV2 is Ownable,  MultiplierMath {
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

    mapping (address => UserInfo) private userInfo;
    mapping (address => bool) public trustedSigner;

    address[] internal users;


    PoolInfo[] private poolInfo;


    uint256 private totalPoints;

    uint256[5] internal epochs;

    uint256[5] internal multipliers;


    event Harvest(address sender, uint256 amount, uint256 blockNumber);
    event AddNewPool(address token, uint256 pid);
    event PoolUpdate(uint256 poolPid, uint256 previusPoints, uint256 newPoints);
    event AddNewKey(bytes keyHash, uint256 id);

        // 5 epochs // 5 - 23
    constructor(IMilk2Token _milk, uint256[5] memory _epochs, uint256[5] memory _multipliers) public {
        milk = _milk;
        epochs = _epochs; // 11770000
        multipliers = _multipliers;
        
        //For debug
        trustedSigner[msg.sender]=true;
    }


    /**
      * @dev Add a new lp to the pool.
      *
      * @param _lpToken - address of ERC-20 LP token
       * @param _newPoints - share in the total amount of rewards
      * DO NOT add the same LP token more than once. Rewards will be messed up if you do.
      * Can only be called by the current owner.
      */
    function addNewPool(IERC20 _lpToken, uint256 _newPoints) public onlyOwner {
        totalPoints = totalPoints.add(_newPoints);
        poolInfo.push(PoolInfo({lpToken: _lpToken, allocPointAmount: _newPoints, blockCreation:block.number}));
        emit AddNewPool(address(_lpToken), _newPoints);
    }


    /**
     * @dev Update lp address to the pool.
     *
     * @param _poolPid - number of pool
     * @param _newPoints - new amount of allocation points
     * DO NOT add the same LP token more than once. Rewards will be messed up if you do.
     * Can only be called by the current owner.
     */
    function setPoll(uint256 _poolPid, uint256 _newPoints) public onlyOwner {
        PoolInfo memory _poolInfo = poolInfo[_poolPid];
        uint256 _previousPoints = poolInfo[_poolPid].allocPointAmount;
        _poolInfo.allocPointAmount = _newPoints;

        totalPoints = totalPoints.sub(poolInfo[_poolPid].allocPointAmount).add(_newPoints);
        emit PoolUpdate(_poolPid, _previousPoints, _newPoints);
    }

    /**
    *@dev set address that can sign
    */
    function setTrustedSigner(address _signer, bool _isValid) public onlyOwner {
        trustedSigner[_signer] = _isValid;
    }


    function getPool(uint256 _poolPid) public view returns(address _lpToken, uint256 _block, uint256 _weight) {
        PoolInfo memory _poolInfo = poolInfo[_poolPid];
        _lpToken = address(_poolInfo.lpToken);
        _block = _poolInfo.blockCreation;
        _weight = _poolInfo.allocPointAmount;
    }


    /**
      * @dev - return Number of keys
      */
    function getPoolsCount() public view returns(uint256) {
        return poolInfo.length;
    }


    /**
      * @dev - return info about current user's reward
      * @param _user - user's address
      */
    function getRewards(address _user) public view returns(uint256) {
        return  userInfo[_user].rewardDebt;
    }


    /**
      * @dev - return info about user's last block with update
      *
      * @param _user - user's address
      */
    function getLastBlock(address _user) public view returns(uint256) {
        return userInfo[_user].lastBlock;
    }


    /**
    * @dev - return total allocation points
    */
    function getTotalPoints() public view returns(uint256) {
        return totalPoints;
    }


    function registration() public {
        require(userInfo[msg.sender].lastBlock == 0, "User already exist");
        UserInfo storage _userInfo = userInfo[msg.sender];
        _userInfo.rewardDebt = 0;
        _userInfo.lastBlock = block.number;
        users.push(msg.sender);
    }


    function getData(uint256 _amount,
                    uint256 _lastBlockNumber,
                    uint256 _currentBlockNumber,
                    address _sender) public pure returns(bytes32) {
        return sha256(abi.encode(_amount, _lastBlockNumber, _currentBlockNumber, _sender));
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    ///// Refactored items
    /////////////////////////////////////////////////////////////////////////////////////
    /**
    *@dev Prepare abi encoded message
    */
    function getMsgForSign(
        uint256 _amount,
        uint256 _lastBlockNumber,
        uint256 _currentBlockNumber,
        address _sender) public pure returns(bytes32) 
    {
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
    * @dev Check signature and mint tokens
    * @param  _amount - subj
    * @param  _lastBlockNumber - subj
    * @param  _currentBlockNumber - subj
    * @param  _msgForSign - hash for sign with Ethereum style prefix!!!
    * @param  _signature  - signature
    */
    function harvest(   
        uint256 _amount,
        uint256 _lastBlockNumber,
        uint256 _currentBlockNumber,
        bytes32 _msgForSign,
        bytes memory _signature) 
    public 
    {
        require(_currentBlockNumber <= block.number, "currentBlockNumber cannot be larger than the last block");
        
        //Double spend check
        require(userInfo[msg.sender].lastBlock == _lastBlockNumber, "lastBlockNumber must be equal to the value in the storage");
        
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
            milk.mint(msg.sender, _amount);
        }
        emit Harvest(msg.sender, _amount, _currentBlockNumber);
    }


    /**
    * @dev Check signature and mint tokens
    * @param  _amount - subj
    * @param  _lastBlockNumber - subj
    * @param  _currentBlockNumber - subj
    * @param  _msgForSign - hash for sign with Ethereum style prefix!!!
    * @param  _signature  - signature
    */
    function debug_harvest(   
        uint256 _amount,
        uint256 _lastBlockNumber,
        uint256 _currentBlockNumber,
        bytes32 _msgForSign,
        bytes memory _signature) 
    public view returns(address _signer, bytes32 _msg, bytes32 _prefixedMsg)
    {
        require(_currentBlockNumber <= block.number, "currentBlockNumber cannot be larger than the last block");
        
        //Double spend check
        require(userInfo[msg.sender].lastBlock == _lastBlockNumber, "lastBlockNumber must be equal to the value in the storage");
        
        //1. Lets check signer
        address signedBy = _msgForSign.recover(_signature);
        //require(trustedSigner[signedBy] == true, "Signature check failed!");

        //2. Check signed msg integrety
        bytes32 actualMsg = getMsgForSign(
            _amount, 
            _lastBlockNumber, 
            _currentBlockNumber, 
            msg.sender
        );
        //require(actualMsg.toEthSignedMessageHash() == _msgForSign,"Integrety check failed!");

        // //Actions
        // userInfo[msg.sender].rewardDebt = userInfo[msg.sender].rewardDebt.add(_amount);
        // userInfo[msg.sender].lastBlock = _currentBlockNumber;
        // if (_amount > 0) {
        //     milk.mint(msg.sender, _amount);
        // }
        // emit Harvest(msg.sender, _amount, _currentBlockNumber);
        return (signedBy, actualMsg, actualMsg.toEthSignedMessageHash());
    }
    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////


    /**
     * @dev - return Number of users
     */
    function getUsersCount() public view returns(uint256) {
        return users.length;
    }


    /**
     * @dev - return address of user
     * @param - _userId - unique number of user in array
     */
    function getUser(uint256 _userId) public view returns(address) {
        return users[_userId];
    }


    /**
     * @dev - return total rewards
     */
    function getTotalRewards(address _user) public view returns(uint256) {
        return userInfo[_user].rewardDebt;
    }


    /**
    * @param - _id - multiplier's id (0-4)
    * @dev - return value of multiplier
    */
    function getValueMultiplier(uint256 _id) public view returns(uint256) {
        return multipliers[_id];
    }


    /**
    * @param - _id - epoch's id(0-4)
    * @dev - return value of epoch
    */
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

}