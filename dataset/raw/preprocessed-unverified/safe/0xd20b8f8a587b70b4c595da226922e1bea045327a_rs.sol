/**
 *Submitted for verification at Etherscan.io on 2019-07-07
*/

pragma solidity ^0.5.10;

/* MintHelper for BitcoinSoV
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
    address public payoutsWallet;
    address public minterWallet;
    uint public minterFeePercent;

    constructor(address mToken, address pWallet, address mWallet, string memory mName, uint256 mMintFeePct)
    public
    {
      mintableToken = mToken;
      payoutsWallet = pWallet;
      minterWallet = mWallet;
      name = mName;
      
      minterFeePercent = mMintFeePct;
    }

    function setMintableToken(address mToken)
    public onlyOwner
    returns (bool)
    {
      mintableToken = mToken;
      return true;
    }

    function setPayoutsWallet(address pWallet)
    public onlyOwner
    returns (bool)
    {
      payoutsWallet = pWallet;
      return true;
    }

    function setMinterWallet(address mWallet)
    public onlyOwner
    returns (bool)
    {
      minterWallet = mWallet;
      return true;
    }

    function setMinterFeePercent(uint fee)
    public onlyOwner
    returns (bool)
    {
      require(fee >= 0 && fee <= 100, "Fee not within range");
      minterFeePercent = fee;
      return true;
    }

    function proxyMint(uint256 nonce, bytes32 challenge_digest )
    public
    returns (bool)
    {
      //identify the rewards that will be won and how to split them up
      uint totalReward = ERC918Interface(mintableToken).getMiningReward();

      // Pool fee covers the 0.5 BSOV (1%) burned. Payout fund gets the 90% it expects.
      uint burnAmount = totalReward.div(100);
      uint minterReward = totalReward.mul(minterFeePercent).div(100).sub(burnAmount);
      uint payoutReward = totalReward.sub(minterReward);
      
      // get paid in new tokens
      require(ERC918Interface(mintableToken).mint(nonce, challenge_digest), "Could not mint token");

      //transfer the tokens to the correct wallets
      require(ERC20Interface(mintableToken).transfer(minterWallet, minterReward), "Could not transfer minter fee of token");
      require(ERC20Interface(mintableToken).transfer(payoutsWallet, payoutReward), "Could not transfer minter fee of token");

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
}