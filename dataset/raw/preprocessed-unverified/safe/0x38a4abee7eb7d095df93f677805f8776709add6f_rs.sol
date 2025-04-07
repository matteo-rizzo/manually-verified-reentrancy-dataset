/**
 *Submitted for verification at Etherscan.io on 2021-09-20
*/

/**
 *Submitted for verification at BscScan.com on 2021-09-20
*/

pragma solidity 0.8.4;
// SPDX-License-Identifier: Unlicensed
pragma abicoder v2;





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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



contract FutureCoinBridge is Ownable {
    
    struct userDetails {
        uint amount;
        address token;
    }
    
      // ECDSA Address
    using ECDSA for address;
    address public signer;
    IBEP20 public token;
    address[] public tokenList;
    bool public lockStatus;
    
    event SetSigner(address indexed user,address indexed signer);
    event Deposit(address indexed user,uint amount,address token,uint time);
    event Claim(address indexed user,address token,uint amount,uint time);
    event Fallback(address indexed user,uint amount,uint time);
    event Failsafe(address indexed user,uint amount,uint time);
    
    mapping(bytes32 => bool)public msgHash;
    mapping(address => bool)public isClaim;
    mapping(address => userDetails)public users;
    mapping(uint => address)public tokenViewById;
    
    constructor (address _signer,address _token)  {
        signer = _signer;
        token = IBEP20(_token);
    }
    
     /**
     * @dev Throws if lockStatus is true
     */
    modifier isLock() {
        require(lockStatus == false, "FutureCoin: Contract Locked");
        _;
    }

    /**
     * @dev Throws if called by other contract
     */
    modifier isContractCheck(address _user) {
        require(!isContract(_user), "FutureCoin: Invalid address");
        _;
    }
    
    function addToken(uint _amount) public onlyOwner {
        require(_amount > 0,"Invalid amount");
        token.transferFrom(msg.sender,address(this),_amount);
    }
    
    function addToken(address[] memory _token) public {
        for (uint i = 0; i < _token.length; i++) {
            tokenList.push(_token[i]);
            tokenViewById[i+1] = _token[i]; 
        }
    }
    
    receive()external payable {
        emit Fallback(msg.sender,msg.value,block.timestamp);
    }
    
    function deposit(uint _amount)public isLock {
        require (_amount > 0,"Incorrect params");
        token.transferFrom(msg.sender,address(this),_amount);
        users[msg.sender].token = address(token);
        users[msg.sender].amount = _amount;
        emit Deposit(msg.sender,_amount,address(token),block.timestamp);
    }
    
    function claim(address _user,uint amount,bytes calldata signature,uint _time) public isLock {
        
          //messageHash can be used only once
        bytes32 messageHash = message(_user,amount,_time);
        require(!msgHash[messageHash], "claim: signature duplicate");
        
           //Verifes signature    
        address src = verifySignature(messageHash, signature);
        require(signer == src, " claim: unauthorized");
        token.transfer(_user,amount);
        msgHash[messageHash] = true;
        emit Claim(_user,address(token),amount,block.timestamp);
    }
    
    /**
    * @dev Ethereum Signed Message, created from `hash`
    * @dev Returns the address that signed a hashed message (`hash`) with `signature`.
    */
    function verifySignature(bytes32 _messageHash, bytes memory _signature) public pure returns (address signatureAddress)
    {
        bytes32 hash = ECDSA.toEthSignedMessageHash(_messageHash);
        signatureAddress = ECDSA.recover(hash, _signature);
    }
    
    /**
    * @dev Returns hash for given data
    */
    function message(address  _receiver ,uint amount,uint time)
        public pure returns(bytes32 messageHash)
    {
        messageHash = keccak256(abi.encodePacked(_receiver,amount,time));
    }
    
    // updaate signer address
    function setSigner(address _signer)public onlyOwner{
        signer = _signer;
        emit SetSigner(msg.sender, _signer);
    }
    
    function failsafe(address user,uint amount)public onlyOwner{
        token.transfer(user,amount);
        emit Failsafe(user,amount,block.timestamp);
    }
    
    function checkBalance()public view returns(uint){
        return address(this).balance;
    }
    
     /**
     * @dev contractLock: For contract status
     */
    function contractLock(bool _lockStatus) public onlyOwner returns(bool) {
        lockStatus = _lockStatus;
        return true;
    }

    /**
     * @dev isContract: Returns true if account is a contract
     */
    function isContract(address _account) public view returns(bool) {
        uint32 size;
        assembly {
            size:= extcodesize(_account)
        }
        if (size != 0)
            return true;
        return false;
    }
    
   
    
}