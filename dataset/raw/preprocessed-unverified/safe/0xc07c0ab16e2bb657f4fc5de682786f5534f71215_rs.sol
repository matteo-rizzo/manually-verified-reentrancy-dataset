/**
 *Submitted for verification at Etherscan.io on 2021-10-05
*/

/**
 *Submitted for verification at Etherscan.io on 2021-10-01
*/

pragma solidity 0.8.0;
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



contract BikdataETH is Ownable {
    
    struct userDetails {
        uint amount;
        address token;
    }

    using SafeMath for uint256;
    
      // ECDSA Address
    using ECDSA for address;
    address public signer;
    address[] public tokenList;
    bool public lockStatus;
    
    event SetSigner(address indexed user,address indexed signer);
    event Deposit(address indexed user,uint amount,address token,uint time);
    event Claim(address indexed user,address token,uint amount,uint time);
    event Failsafe(address indexed user,uint amount,address token,uint time);
    
    mapping(bytes32 => bool)public msgHash;
    mapping(address => bool)public isClaim;
    mapping(address => userDetails)public users;
    mapping(uint => address)public tokenViewById;
    
    constructor (address _signer)  {
       
        signer = _signer;
    }
    
     /**
     * @dev Throws if lockStatus is true
     */
    modifier isLock() {
        require(lockStatus == false, "Bikdata: Contract Locked");
        _;
    }

    function addToken(address[] memory _token) public onlyOwner{
        for (uint i = 0; i < _token.length; i++) {
            tokenList.push(_token[i]);
            tokenViewById[i+1] = _token[i]; 
        }
    }
    
    function deposit(uint _tokeId,uint _amount)public isLock {
        require (tokenViewById[_tokeId] != address(0) && _amount > 0,"Incorrect params");
        IERC20(tokenViewById[_tokeId]).transferFrom(msg.sender,address(this),_amount);
        users[msg.sender].token = tokenViewById[_tokeId];
        users[msg.sender].amount = _amount;
        emit Deposit(msg.sender,_amount,tokenViewById[_tokeId],block.timestamp);
    }
    
    
    function claim(address payable _user,uint _tokeId,uint amount,bytes calldata signature,uint _time) public isLock {
         require (tokenViewById[_tokeId] != address(0) && amount > 0,"Incorrect params");
          //messageHash can be used only once
        bytes32 messageHash = message(_user,amount,_time);
        require(!msgHash[messageHash], "claim: signature duplicate");
        
           //Verifes signature    
        address src = verifySignature(messageHash, signature);
        require(signer == src, " claim: unauthorized");
        IERC20(tokenViewById[_tokeId]).transfer(_user,amount);
        msgHash[messageHash] = true;
        emit Claim(_user,tokenViewById[_tokeId],amount,block.timestamp);
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
    function message(address  _receiver ,uint amount,uint _time)
        public pure returns(bytes32 messageHash)
    {
        messageHash = keccak256(abi.encodePacked(_receiver,amount,_time));
    }
    
    // updaate signer address
    function setSigner(address _signer)public onlyOwner{
        signer = _signer;
        emit SetSigner(msg.sender, _signer);
    }
    
    function failsafe(uint _tokeId,address user,uint amount)public onlyOwner returns(bool){
           require(user != address(0) && tokenViewById[_tokeId] != address(0), "Invalid Address");
           require(IERC20(tokenViewById[_tokeId]).balanceOf(address(this)) >= amount, "Bikdata: insufficient amount");
           IERC20(tokenViewById[_tokeId]).transfer(user, amount);
            emit Failsafe(user,amount,tokenViewById[_tokeId],block.timestamp);
            return true;
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

  
    
   
    
}