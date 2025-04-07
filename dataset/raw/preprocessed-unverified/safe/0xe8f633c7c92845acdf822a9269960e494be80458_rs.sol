pragma solidity 0.4.23;





contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}







contract TokenVestingTimelock is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    event Released(uint256 amount);
    event Revoked();
    // beneficiary of tokens after they are released
    address public beneficiary;

    uint256 public start;
    uint256 public duration;

    bool public revocable;
    // ERC20 basic token contract being held
    ERC20Basic public token;

    // timestamp when token release is enabled
    uint256 public releaseTime;

    uint256 public released;
    bool public revoked;

  
    constructor(
        ERC20Basic _token,
        address _beneficiary,
        uint256 _start,
        uint256 _duration,
        bool _revokable,
        uint256 _releaseTime
    )
    public
    {
        require(_beneficiary != address(0));
        if (_releaseTime > 0) {
            // solium-disable-next-line security/no-block-members
            require(_releaseTime > block.timestamp);
        }

        beneficiary = _beneficiary;
        revocable = _revokable;
        duration = _duration;
        start = _start;
        token = _token;
        releaseTime = _releaseTime;
    }

  
    function release() public returns(bool) {
        uint256 unreleased = releasableAmount();

        require(unreleased > 0);

        if (releaseTime > 0) {
        // solium-disable-next-line security/no-block-members
            require(block.timestamp >= releaseTime);
        }

        released = released.add(unreleased);

        token.safeTransfer(beneficiary, unreleased);

        emit Released(unreleased);

        return true;
    }

 
    function revoke() public onlyOwner returns(bool) {
        require(revocable);
        require(!revoked);

        uint256 balance = token.balanceOf(this);

        uint256 unreleased = releasableAmount();
        uint256 refund = balance.sub(unreleased);

        revoked = true;

        token.safeTransfer(owner, refund);

        emit Revoked();

        return true;
    }

 
    function releasableAmount() public view returns (uint256) {
        return vestedAmount().sub(released);
    }

 
    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released);
        // solium-disable-next-line security/no-block-members
        if (block.timestamp < start) {
            return 0;
          // solium-disable-next-line security/no-block-members
        } else if (block.timestamp >= start.add(duration) || revoked) {
            return totalBalance;
        } else {
            // solium-disable-next-line security/no-block-members
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}