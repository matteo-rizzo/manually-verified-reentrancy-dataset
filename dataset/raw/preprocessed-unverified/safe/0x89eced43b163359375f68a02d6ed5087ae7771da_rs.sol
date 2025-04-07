/**
 *Submitted for verification at Etherscan.io on 2021-06-21
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.10;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract Series is Ownable {
  string name;
  mapping(address=>address[]) plugins;

  constructor(string memory _name) public {
    name = _name;
  }

  function getName() public view returns (string memory) {
    return name;
  }
}

contract OtoCorp is Ownable {
    
    uint256 private tknSeriesFee;
    IERC20 private tkn;
    mapping(address=>address[]) seriesOfMembers;
    
    event TokenAddrChanged(address _oldTknAddr, address _newTknAddr);
    event ReceiveTokenFrom(address src, uint256 val);
    event NewSeriesCreated(address _contract, address _owner, string _name);
    event SeriesFeeChanged(uint256 _oldFee, uint256 _newFee);
    event TokenWithdrawn(address _owner, uint256 _total);
    
    constructor(IERC20 _tkn) public {
        tkn = _tkn;
        tknSeriesFee = 0**18;
    }
    
    function withdrawTkn() external onlyOwner {
        require(tkn.transfer(owner(), balanceTkn()));
        emit TokenWithdrawn(owner(), balanceTkn());
    }
    
    function createSeries(string memory seriesName) public payable {
        require(tkn.transferFrom(msg.sender, address(this), tknSeriesFee));
        emit ReceiveTokenFrom(msg.sender, tknSeriesFee);
        Series newContract = new Series(seriesName);
        seriesOfMembers[msg.sender].push(address(newContract));
        newContract.transferOwnership(msg.sender);
        emit NewSeriesCreated(address(newContract), newContract.owner(), newContract.getName());
    }
    
    function changeTknAddr(IERC20 newTkn) external onlyOwner {
        address oldTknAddr = address(tkn);
        tkn = newTkn;
        emit TokenAddrChanged(oldTknAddr, address(tkn));
    }
    
    function changeSeriesFee(uint256 _newFee) external onlyOwner {
        uint256 oldFee = tknSeriesFee;
        tknSeriesFee = _newFee;
        emit SeriesFeeChanged(oldFee, tknSeriesFee);
    }
    
    function balanceTkn() public view returns (uint256){
        return tkn.balanceOf(address(this));
    }
    
    function isUnlockTkn() public view returns (bool){
        return tkn.allowance(msg.sender, address(this)) > 0;
    }
    
    function mySeries() public view returns (address[] memory) {
        return seriesOfMembers[msg.sender];
    }
    
}