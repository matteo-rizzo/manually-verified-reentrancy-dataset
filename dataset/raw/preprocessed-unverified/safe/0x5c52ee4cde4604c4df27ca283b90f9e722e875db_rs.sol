/**
 *Submitted for verification at Etherscan.io on 2019-07-07
*/

pragma solidity ^0.5.10;

/* MintHelper for BitcoinSoV (BSOV)
 * Based off https://github.com/0xbitcoin/mint-helper
 * 1% Burn fee comes from mining pool's fee, allowing miner payout contract to receive its full share.
 * https://www.btcsov.com
 */




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */



contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ERC918Interface {
  function totalSupply() public view returns (uint);
  function getMiningDifficulty() public view returns (uint);
  function getMiningTarget() public view returns (uint);
  function getMiningReward() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);

  function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);

  event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
}

/*
The owner (or anyone) will deposit tokens in here
The owner calls the multisend method to send out payments
*/
contract MintHelper is Ownable {
   using SafeMath for uint;

    string public name;
    address public mintableToken;
    mapping(bytes32 => bool) successfulPayments;

    constructor(address mToken, string memory mName)
    public
    {
      mintableToken = mToken;
      name = mName;
    }

    function setMintableToken(address mToken)
    public onlyOwner
    returns (bool)
    {
      mintableToken = mToken;
      return true;
    }

    function paymentSuccessful(bytes32 paymentId) public view returns (bool){
        return (successfulPayments[paymentId] == true);
    }
    
    function proxyMint(uint256 nonce, bytes32 challenge_digest )
    public
    returns (bool)
    {
      require(ERC918Interface(mintableToken).mint(nonce, challenge_digest), "Could not mint token");
      return true;
    }

    //withdraw any eth inside
    function withdraw()
    public onlyOwner
    {
        msg.sender.transfer(address(this).balance);
    }

    //send tokens out
    function send(address _tokenAddr, address dest, uint value)
    public onlyOwner
    returns (bool)
    {
     return ERC20Interface(_tokenAddr).transfer(dest, value);
    }

    //batch send tokens
    function multisend(address _tokenAddr, bytes32 paymentId, address[] memory dests, uint256[] memory values)
    public onlyOwner
    returns (uint256)
    {
        require(dests.length > 0, "Must have more than 1 destination address");
        require(values.length >= dests.length, "Address to Value array size mismatch");
        require(successfulPayments[paymentId] != true, "Payment ID already exists and was successful");

        uint256 i = 0;
        while (i < dests.length) {
           require(ERC20Interface(_tokenAddr).transfer(dests[i], values[i]));
           i += 1;
        }

        successfulPayments[paymentId] = true;
        return (i);
    }
}