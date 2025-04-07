// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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



abstract contract ContractConn{

    function burn(uint256 _value) virtual public returns(bool);
}

contract Furnace is Ownable {

    using SafeMath for uint256;
    uint256 public tokenBurned = 0;
    
    event BurnToken(uint256 amount,address indexed who,uint256 time);
    
    ContractConn public token;    
    constructor(address _token) public {
        token = ContractConn(_token);
    }
    
    function combustion(uint256 amount) public onlyOwner returns(bool){
        require(amount > 0, "combustionï¼šamount error");
        token.burn(amount);
        tokenBurned = tokenBurned.add(amount);
        emit BurnToken(amount,msg.sender,now);
        return true;
    } 

}