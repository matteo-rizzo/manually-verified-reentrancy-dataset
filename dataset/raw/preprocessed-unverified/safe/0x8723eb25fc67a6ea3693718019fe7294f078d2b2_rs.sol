/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

// SPDX-License-Identifier: (c) Otsea.fi, 2021

pragma solidity ^0.6.12;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * 
 * @dev Completely default OpenZeppelin.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 * 
 * @dev Default OpenZeppelin
 */


contract Vesting {

    using SafeMath for uint256;

    IERC20 public token;

    uint256 public totalTokens;
    uint256 public releaseStart;
    uint256 public releaseEnd;

    mapping (address => uint256) public starts;
    mapping (address => uint256) public grantedToken;

    // this means, released but unclaimed amounts
    mapping (address => uint256) public released;

    event Claimed(address indexed _user, uint256 _amount, uint256 _timestamp);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount, uint256 _timestamp);

    // do not input same recipient in the _recipients, it will lead to locked token in this contract
    function initialize(
        address _token,
        uint256 _totalTokens,
        uint256 _start,
        uint256 _period,
        address[] calldata _recipients,
        uint256[] calldata _grantedToken
    )
      public
    {
        require(releaseEnd == 0, "Contract is already initialized.");
        require(_recipients.length == _grantedToken.length, "Array lengths do not match.");

        releaseEnd = _start.add(_period);
        releaseStart = _start;

        token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _totalTokens);
        totalTokens = _totalTokens;
        uint256 sum = 0;

        for(uint256 i = 0; i<_recipients.length; i++) {
            starts[_recipients[i]] = releaseStart;
            grantedToken[_recipients[i]] = _grantedToken[i];
            sum = sum.add(_grantedToken[i]);
        }

        // We're gonna just set the weight as full tokens. Ensures grantedToken were entered correctly as well.
        require(sum == totalTokens, "Weight does not match tokens being distributed.");
    }

    /**
     * @dev User may claim tokens that have vested.
    **/
    function claim()
      public
    {
        address user = msg.sender;

        require(releaseStart <= block.timestamp, "Release has not started");
        require(grantedToken[user] > 0, "This contract may only be called by users with a stake.");

        uint256 releasing = releasable(user);
        // updates the grantedToken
        grantedToken[user] = grantedToken[user].sub(releasing);

        // claim will claim both released and releasing
        uint256 claimAmount = released[user].add(releasing);

        // flush the released since released means "unclaimed" amount
        released[user] = 0;
        
        // and update the starts
        starts[user] = block.timestamp;
        token.transfer(user, claimAmount);
        emit Claimed(user, claimAmount, block.timestamp);
    }

    /**
     * @dev returns claimable token. buffered(released) token + token released from last update
     * @param _user user to check the claimable token
    **/
    function claimableAmount(address _user) external view returns(uint256) {
        return released[_user].add(releasable(_user));
    }

    /**
     * @dev returns the token that can be released from last user update
     * @param _user user to check the releasable token
    **/
    function releasable(address _user) public view returns(uint256) {
        if (block.timestamp < releaseStart) return 0;
        uint256 applicableTimeStamp = block.timestamp >= releaseEnd ? releaseEnd : block.timestamp;
        return grantedToken[_user].mul(applicableTimeStamp.sub(starts[_user])).div(releaseEnd.sub(starts[_user]));
    }

    /**
     * @dev Transfers a sender's weight to another address starting from now.
     * @param _to The address to transfer weight to.
     * @param _amountInFullTokens The amount of tokens (in 0 decimal format). We will not have fractions of tokens.
    **/
    function transfer(address _to, uint256 _amountInFullTokens)
      external
    {
        // first, update the released
        released[msg.sender] = released[msg.sender].add(releasable(msg.sender));
        released[_to] = released[_to].add(releasable(_to));

        // then update the grantedToken;
        grantedToken[msg.sender] = grantedToken[msg.sender].sub(releasable(msg.sender));
        grantedToken[_to] = grantedToken[_to].sub(releasable(_to));

        // then update the starts of user
        starts[msg.sender] = block.timestamp;
        starts[_to] = block.timestamp;

        // If trying to transfer too much, transfer full amount.
        uint256 amount = _amountInFullTokens.mul(1e18) > grantedToken[msg.sender] ? grantedToken[msg.sender] : _amountInFullTokens.mul(1e18);

        // then move _amount
        grantedToken[msg.sender] = grantedToken[msg.sender].sub(amount);
        grantedToken[_to] = grantedToken[_to].add(amount);

        emit Transfer(msg.sender, _to, amount, block.timestamp);
    }

}