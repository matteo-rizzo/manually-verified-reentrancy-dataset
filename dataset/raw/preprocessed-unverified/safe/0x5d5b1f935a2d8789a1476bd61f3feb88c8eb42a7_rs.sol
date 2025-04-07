pragma solidity ^0.4.23;

contract Clockmaking {
	address public clockmaker;
	address public newClockmaker;

	event ClockmakingTransferred(address indexed oldClockmaker, address indexed newClockmaker);

	constructor() public {
		clockmaker = msg.sender;
		newClockmaker = address(0);
	}

	modifier onlyClockmaker() {
		require(msg.sender == clockmaker, "msg.sender == clockmaker");
		_;
	}

	function transferClockmaker(address _newClockmaker) public onlyClockmaker {
		require(address(0) != _newClockmaker, "address(0) != _newClockmaker");
		newClockmaker = _newClockmaker;
	}

	function acceptClockmaker() public {
		require(msg.sender == newClockmaker, "msg.sender == newClockmaker");
		emit ClockmakingTransferred(clockmaker, msg.sender);
		clockmaker = msg.sender;
		newClockmaker = address(0);
	}
}



contract ERC20Basic {
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}



/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock is Ownable, Clockmaking {
  using SafeERC20 for ERC20Basic;
  ERC20Basic public token;   // ERC20 basic token contract being held
  uint64 public releaseTime; // timestamp when token claim is enabled

  constructor(ERC20Basic _token, uint64 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    owner = msg.sender;
    clockmaker = msg.sender;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to owner.
   */
  function claim() public onlyOwner {
    require(now >= releaseTime, "now >= releaseTime");

    uint256 amount = token.balanceOf(this);
    require(amount > 0, "amount > 0");

    token.safeTransfer(owner, amount);
  }
  
  function updateTime(uint64 _releaseTime) public onlyClockmaker {
      releaseTime = _releaseTime;
  }
  
}