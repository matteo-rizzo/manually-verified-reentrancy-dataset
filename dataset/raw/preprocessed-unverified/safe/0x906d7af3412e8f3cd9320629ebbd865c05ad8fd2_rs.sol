/**
 *Submitted for verification at Etherscan.io on 2021-03-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.5;



contract Ownable is IOwnable {
    
  address internal _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    _owner = msg.sender;
    emit OwnershipTransferred( address(0), _owner );
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require( _owner == msg.sender, "Ownable: caller is not the owner" );
    _;
  }

  function renounceOwnership() public virtual override onlyOwner() {
    emit OwnershipTransferred( _owner, address(0) );
    _owner = address(0);
  }

  function transferOwnership( address newOwner_ ) public virtual override onlyOwner() {
    require( newOwner_ != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred( _owner, newOwner_ );
    _owner = newOwner_;
  }
}





contract aOHMMigration is Ownable {
    using SafeMath for uint256;

    uint256 swapEndBlock;

    IERC20 public OHM;
    IERC20 public aOHM;
    
    bool public isInitialized;

    mapping(address => uint256) public senderInfo;
    
    modifier onlyInitialized() {
        require(isInitialized, "not initialized");
        _;
    }

    function initialize(
        address _OHM,
        address _aOHM,
        uint256 _swapDuration
    ) public {
        OHM = IERC20(_OHM);
        aOHM = IERC20(_aOHM);
        swapEndBlock = block.number.add(_swapDuration);
        isInitialized = true;
    }

    function migrate(uint256 amount) external onlyInitialized() {
        require(
            aOHM.balanceOf(msg.sender) >= amount,
            "amount above user balance"
        );
        require(block.number < swapEndBlock, "swapping of aOHM has ended");

        aOHM.transferFrom(msg.sender, address(this), amount);
        senderInfo[msg.sender] = senderInfo[msg.sender].add(amount);
        OHM.transfer(msg.sender, amount);
    }

    function reclaim() external {
        require( senderInfo[msg.sender] > 0, "user has no aOHM to withdraw" );
        require( block.number > swapEndBlock, "aOHM swap is still ongoing" );

        uint256 amount = senderInfo[msg.sender];
        senderInfo[msg.sender] = 0;
        aOHM.transfer(msg.sender, amount);
    }

    function withdraw() external onlyOwner() {
        require(block.number > swapEndBlock, "swapping of aOHM has not ended");
        uint256 amount = OHM.balanceOf(address(this));

        OHM.transfer(msg.sender, amount);
    }
}