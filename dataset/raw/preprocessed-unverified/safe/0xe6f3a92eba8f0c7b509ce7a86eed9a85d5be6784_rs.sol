/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity  0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract ERC20 {

    uint public totalSupply;



    function balanceOf(address who) public view returns(uint);



    function allowance(address owner, address spender) public view returns(uint);



    function transfer(address to, uint value) public returns(bool ok);



    function transferFrom(address from, address to, uint value) public returns(bool ok);



    function approve(address spender, uint value) public returns(bool ok);



    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}









contract Bounties is Ownable {



    using SafeMath for uint;



    uint public totalTokensToClaim;

    uint public totalBountyUsers;

    uint public claimCount;

    uint public totalClaimed;





    mapping(address => bool) public claimed; // Tokens claimed by bounty members

    Token public token;



    mapping(address => bool) public bountyUsers;

    mapping(address => uint) public bountyUsersAmounts;



    constructor(Token _token) public {

        require(_token != address(0));

        token = Token(_token);

    }



    event TokensClaimed(address backer, uint count);

    event LogBountyUser(address user, uint num);

    event LogBountyUserMultiple(uint num);





    // @notice Specify address of token contract

    // @param _tokenAddress {address} address of the token contract

    // @return res {bool}

    function updateTokenAddress(Token _tokenAddress) external onlyOwner() returns(bool res) {

        token = _tokenAddress;

        return true;

    }



    // @notice contract owner can add one user at a time to claim bounties

    function addBountyUser(address _user, uint _amount) public onlyOwner() returns (bool) {



        require(_amount > 0);



        if (bountyUsers[_user] != true) {

            bountyUsers[_user] = true;

            bountyUsersAmounts[_user] = _amount;

            totalBountyUsers++;

            totalTokensToClaim += _amount;

            emit LogBountyUser(_user, totalBountyUsers);

        }

        return true;

    }



    // @notice contract owner can add multipl bounty users

    function addBountyUserMultiple(address[] _users, uint[] _amount) external onlyOwner()  returns (bool) {



        for (uint i = 0; i < _users.length; ++i) {



            addBountyUser(_users[i], _amount[i]);

        }

        emit LogBountyUserMultiple(totalBountyUsers);

        return true;

    }



    // {fallback function}

    // @notice It will call internal function which handels allocation of tokens to bounty users.

    // bounty members can send 0 ether transaction to this contract to claim their tokens.

    function () external payable {

        claimTokens();

    }



    // @notice

    // This function will allow to transfer unclaimed tokens to another address.

    function transferRemainingTokens(address _newAddress) external onlyOwner() returns (bool) {

        require(_newAddress != address(0));

        if (!token.transfer(_newAddress, token.balanceOf(this)))

            revert(); // transfer tokens to admin account or multisig wallet

        return true;

    }





    // @notice called to send tokens to bounty members by contract owner

    // @param _backer {address} address of beneficiary

    function claimTokensForUser(address _backer) external onlyOwner()  returns(bool) {

        require(token != address(0));

        require(bountyUsers[_backer]);

        require(!claimed[_backer]);

        claimCount++;

        claimed[_backer] = true;

        totalClaimed = totalClaimed.add(bountyUsersAmounts[_backer]);



        if (!token.transfer(_backer, bountyUsersAmounts[_backer]))

            revert(); // send claimed tokens to contributor account



        emit TokensClaimed(_backer, bountyUsersAmounts[_backer]);

        return true;

    }



    // @notice bounty users can claim tokens

    // Tokens also can be claimed by sending 0 eth transaction to this contract.

    function claimTokens() public {



        require(token != address(0));

        require(bountyUsers[msg.sender]);

        require(!claimed[msg.sender]);

        claimCount++;

        claimed[msg.sender] = true;

        totalClaimed = totalClaimed.add(bountyUsersAmounts[msg.sender]);



        if (!token.transfer(msg.sender, bountyUsersAmounts[msg.sender]))

            revert(); // send claimed tokens to contributor account



        emit TokensClaimed(msg.sender, bountyUsersAmounts[msg.sender]);

    }



}



// The token

contract Token is ERC20, Ownable {

        function transfer(address _to, uint _value) public  returns(bool);

}