pragma solidity ^0.4.21;






contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock is Ownable {
    using SafeERC20 for ERC20;

    // ERC20 basic token contract being held
    ERC20 public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint256 public releaseTime;

    function TokenTimelock(ERC20 _token, address _beneficiary) public {
        // solium-disable-next-line security/no-block-members
        
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = now + 365 days;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solium-disable-next-line security/no-block-members
        require(now >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.safeTransfer(beneficiary, amount);
    }


    function setReleaseTime(uint256 _releaseTime) onlyOwner external {
        require(_releaseTime > releaseTime);
        releaseTime = _releaseTime;
    }
}