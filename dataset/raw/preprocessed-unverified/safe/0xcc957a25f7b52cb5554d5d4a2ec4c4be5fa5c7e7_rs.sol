/**
 *Submitted for verification at Etherscan.io on 2019-10-19
*/

pragma solidity ^0.5.2;






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
contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;

}


contract OneBlockToken is ERC20Interface, Owned {

    using SafeMath for uint;
    using ExtendedMath for uint;


    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;

 uint public project_funding;



     uint public latestDifficultyPeriodStarted;



    uint public epochCount;


    uint public _BLOCKS_PER_READJUSTMENT = 1024;


    uint public  _MINIMUM_TARGET = 2**10*234;


    uint public  _MAXIMUM_TARGET = 2**160;


    uint public miningTarget;

    bytes32 public challengeNumber;   



    uint public rewardEra;
    uint public maxSupplyForEra;


    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;

    bool locked = false;

    mapping(bytes32 => bytes32) solutionForChallenge;

    uint public tokensMinted;

    mapping(address => uint) balances;


    mapping(address => mapping(address => uint)) allowed;


    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

   
    constructor () public onlyOwner{



        symbol = "OneB";

        name = "One Block Token";

        decimals = 8;

        _totalSupply = 5000000 * 10**uint(decimals);
project_funding = 1000000 * 10**uint(decimals);
        if(locked) revert();
        locked = true;

        tokensMinted = 0;

        rewardEra = 0;
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, project_funding);
_totalSupply =  _totalSupply.sub(balances[owner]);
        maxSupplyForEra = _totalSupply.div(2);

        miningTarget = _MAXIMUM_TARGET;

        latestDifficultyPeriodStarted = block.number;
        
        _startNewMiningEpoch();


    }




        function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {


            bytes32 digest =  keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce ));

            if (digest != challenge_digest) revert();

            if(uint256(digest) > miningTarget) revert();


             bytes32 solution = solutionForChallenge[challengeNumber];
             solutionForChallenge[challengeNumber] = digest;
             if(solution != 0x0) revert();  

            uint reward_amount = getMiningReward();

            balances[msg.sender] = balances[msg.sender].add(reward_amount);

            tokensMinted = tokensMinted.add(reward_amount);


            assert(tokensMinted <= maxSupplyForEra);

            lastRewardTo = msg.sender;
            lastRewardAmount = reward_amount;
            lastRewardEthBlockNumber = block.number;


             _startNewMiningEpoch();

              emit Mint(msg.sender, reward_amount, epochCount, challengeNumber );

           return true;

        }


    function _startNewMiningEpoch() internal {

      if( tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < 1)
      {
        rewardEra = rewardEra + 1;
      }

      maxSupplyForEra = _totalSupply - _totalSupply.div( 2**(rewardEra + 1));

      epochCount = epochCount.add(1);

     
      if(epochCount % _BLOCKS_PER_READJUSTMENT == 0)
      {
        _reAdjustDifficulty();
      }

    challengeNumber = blockhash(block.number - 1);






    }

    function _reAdjustDifficulty() internal {


        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
       
        uint epochsMined = _BLOCKS_PER_READJUSTMENT; 

        uint targetEthBlocksPerDiffPeriod = epochsMined * 600 * 24; 

        if( ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod )
        {
          uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div( ethBlocksSinceLastDifficultyPeriod );

          uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
        
          miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra));   
        }else{
          uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(100)).div( targetEthBlocksPerDiffPeriod );

          uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000);           miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra));
        }



        latestDifficultyPeriodStarted = block.number;

        if(miningTarget < _MINIMUM_TARGET)
        {
          miningTarget = _MINIMUM_TARGET;
        }

        if(miningTarget > _MAXIMUM_TARGET)       {
          miningTarget = _MAXIMUM_TARGET;
        }
    }


    function getChallengeNumber() public view returns (bytes32) {
        return challengeNumber;
    }

     function getMiningDifficulty() public view returns (uint) {
        return _MAXIMUM_TARGET.div(miningTarget);
    }

    function getMiningTarget() public view returns (uint) {
       return miningTarget;
   }


    function getMiningReward() public view returns (uint) {
         return (5 * 10**uint(decimals) ).div( 2**rewardEra ) ;

    }
    function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest) {
bytes32 diges=challenge_digest;
diges = challenge_number;
        bytes32 digest = keccak256(abi.encodePacked(challenge_number,msg.sender,nonce));

        return digest;

      }
      function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {

          bytes32 digest = keccak256(abi.encodePacked(challenge_number,msg.sender,nonce));

          if(uint256(digest) > testTarget) revert();

          return (digest == challenge_digest);

        }



    function totalSupply() public view returns (uint) {

        return _totalSupply  - balances[address(0)];

    }



    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }



  
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }



 
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

      ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);

        return true;

    }
   function () external payable {

        revert();

    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}