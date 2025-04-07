/**
 *Submitted for verification at Etherscan.io on 2021-05-03
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-05
*/

/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

pragma solidity 0.5.9;



















contract UnitiDex_Governance is Ownable  {
    mapping(address=>bool) public owners;

 
   

    bool public breaker = false;
    uint256 deadlineIndex = 0;
    uint256 public MinTokenForVote=0;
    address public RYIPToken=address(0);
    uint256 public tokenFreezeDuration=86400;// default 1 day or 24 hours

    //mapping(address=> mapping(uint256=> uint256)) public deadline;
    
     mapping(address => bool) public voters;

    struct stake{
        uint time;
        uint amount;
    }
    mapping(address=>stake[]) public details;


    function setBreaker(bool _breaker) external {
        require(msg.sender == governance, "!governance");
        breaker = _breaker;
    }

    mapping(address => uint) public voteLock;

    struct Proposal {
        uint id;
        address proposer;
        mapping(address => uint) forVotes;
        mapping(address => uint) againstVotes;
        uint totalForVotes;
        uint totalAgainstVotes;
        uint start; // block start;
        uint end; // start + period
        address executor;
        string hash;
        uint totalVotesAvailable;
        uint quorum;
        uint quorumRequired;
        bool open;
        uint categoryID;
    }

    mapping (uint => Proposal) public proposals;
    uint public proposalCount=0;
    uint public lock = 17280;
    uint public minimum = 1e18;
    uint public quorum = 2000;
    bool public config = true;

    address public governance;

  constructor(uint256 _MinTokenForVote,address _RYIPToken) public{
        //sending all the tokens to Owner
        MinTokenForVote=_MinTokenForVote;
        RYIPToken=_RYIPToken;
    }


    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setQuorum(uint _quorum) public {
        require(msg.sender == governance, "!governance");
        quorum = _quorum;
    }

    function setMinimum(uint _minimum) public {
        require(msg.sender == governance, "!governance");
        minimum = _minimum;
    }

    function setPeriod(uint _proposeId, uint _endtime) public returns(bool){
        require(proposals[_proposeId].executor==msg.sender || owners[msg.sender]==true);
        require(proposals[_proposeId].end!=0);

         proposals[_proposeId].end=_endtime;
         return true;
    }

    function setLock(uint _lock) public {
        require(msg.sender == governance, "!governance");
        lock = _lock;
    }

    function initialize(uint id) public {
        require(config == true, "!config");
        config = false;
        proposalCount = id;
        governance = 0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52;
    }


    event NewProposal(string _hash, uint id, address creator, uint start, uint duration, address executor, uint _categoryID);
    event Vote(uint indexed id, address indexed voter, bool vote, uint weight);

    function propose(address executor, string memory hash, uint _categoryID, uint _startTime, uint _endTime) public returns(bool){


        if(_startTime==0)
        {
           _startTime=block.timestamp;
        }

         proposalCount=proposalCount+1;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            totalForVotes: 0,
            totalAgainstVotes: 0,
            start: _startTime,
            end: _endTime,
            executor: executor,
            hash: hash,
            totalVotesAvailable: totalVotes,
            quorum: 0,
            quorumRequired: quorum,
            open: true,
            categoryID: _categoryID
        });

        emit NewProposal(hash, proposalCount, msg.sender, _startTime, _endTime, executor, _categoryID);
        return true;
    }

    event RemoveProposal(uint indexed id, address indexed remover, uint indexed time);


    function removePropose(uint _proposeId) public returns(bool){
        require(proposals[_proposeId].executor==msg.sender || owners[msg.sender]==true);
        delete proposals[_proposeId];
        emit RemoveProposal(_proposeId,msg.sender,block.timestamp);
        return true;
    }

    function execute(uint id) public {
        (uint _for, uint _against, uint _quorum) = getStats(id);
        require(proposals[id].quorumRequired < _quorum, "!quorum");
        require(proposals[id].end < block.timestamp , "!end");
        if (proposals[id].open == true) {
            tallyVotes(id);
        }
        Executor(proposals[id].executor).execute(id, _for, _against, _quorum);
    }

    function getStats(uint id) public view returns (uint _for, uint _against, uint _quorum) {
        _for = proposals[id].totalForVotes;
        _against = proposals[id].totalAgainstVotes;
        _quorum = proposals[id].quorum;
    }

    event ProposalFinished(uint indexed id, uint _for, uint _against, bool quorumReached);

    function tallyVotes(uint id) public {
        require(proposals[id].open == true, "!open");
        require(proposals[id].end < block.timestamp, "!end");

        (uint _for, uint _against,) = getStats(id);
        bool _quorum = false;
        if (proposals[id].quorum >= proposals[id].quorumRequired) {
            _quorum = true;
        }
        proposals[id].open = false;
        emit ProposalFinished(id, _for, _against, _quorum);
    }

    function votesOf(address voter) public view returns (uint) {
        return votes[voter];
    }
    function checkVoted(uint id) public view returns(bool) {
        if(proposals[id].forVotes[msg.sender]==1 || proposals[id].againstVotes[msg.sender]==1)
        {
          return true;
        }
        else
        {
          return false;
        }
    }
    uint public totalVotes;
    mapping(address => uint) public votes;
    event RevokeVoter(address voter, uint votes, uint totalVotes);


    function revoke() public {
        require(voters[msg.sender] == true, "!voter");
        voters[msg.sender] = false;
        if (totalVotes < votes[msg.sender]) {
            totalVotes = 0;
        } else {
            totalVotes = votes[msg.sender];
        }
        emit RevokeVoter(msg.sender, votes[msg.sender], totalVotes);
        votes[msg.sender] = 0;
    }


    function voteFor(uint id) public returns(bool){
        require(proposals[id].start < block.timestamp , "<start");
        require(proposals[id].end > block.timestamp , ">end");
        require(proposals[id].forVotes[msg.sender]==0 && proposals[id].againstVotes[msg.sender]==0,"Already Voted");
        //require(msg.value==500000,"Invalid Amount");
       // require(_amount==MinTokenForVote,"Invalid Amount");
        IERC20(RYIPToken).transferFrom(msg.sender,address(this),MinTokenForVote);
        // freezeToken[msg.sender] += MinTokenForVote;
        
        proposals[id].forVotes[msg.sender] = 1;
        proposals[id].totalVotesAvailable = totalVotes;
        proposals[id].totalForVotes= proposals[id].totalForVotes + 1;

        stake memory st=stake(now+tokenFreezeDuration,MinTokenForVote);

        details[msg.sender].push(st);

        emit Vote(id, msg.sender, true, 1);
        return true;
    }
    function NumberOfVotes(address _add) public view returns(uint256){
        return details[_add].length;
    }
    function voteAgainst(uint id) public returns(bool) {
        require(proposals[id].start < block.timestamp , "<start");
        require(proposals[id].end > block.timestamp , ">end");
        require(proposals[id].forVotes[msg.sender]==0 && proposals[id].againstVotes[msg.sender]==0,"Already Voted");
       // require(_amount==MinTokenForVote,"Invalid Amount");
        IERC20(RYIPToken).transferFrom(msg.sender,address(this),MinTokenForVote);
        //freezeToken[msg.sender] += MinTokenForVote;
        proposals[id].againstVotes[msg.sender] = 1;
        proposals[id].totalVotesAvailable = totalVotes;
        proposals[id].totalAgainstVotes= proposals[id].totalAgainstVotes + 1;


        stake memory st=stake(now+tokenFreezeDuration,MinTokenForVote);
        details[msg.sender].push(st);

        emit Vote(id, msg.sender, false, 1);
        return true;
    }
    function changeMinTokenForVote(uint256 _amount) public onlyOwner returns(bool){
        require(_amount>0,"invalid Amount");
        MinTokenForVote=_amount;
        return true;

    }


    function ClaimToken() public returns(bool) {
        uint256 _tokenAmount= 0;
        uint256 _tmpAmount =0;
        uint256 _tmpDeadline =0;
        
        for (uint256 i=0;i<details[msg.sender].length;){
            
            if (now>details[msg.sender][i].time && details[msg.sender][i].amount>0){ // if deadline time is over.
            
                    //vreturn= vreturn.add(details[msg.sender][i].amount);
                    _tokenAmount= _tokenAmount+details[msg.sender][i].amount;
                    if (details[msg.sender].length>1) // if element is less than 2 no need to swap 
                        
                        {

                            // storing last index element in temp variable for swaping
                            _tmpAmount = details[msg.sender][details[msg.sender].length-1].amount;
                            _tmpDeadline = details[msg.sender][details[msg.sender].length-1].time;
                    
                            // storing current element on last index 
                            details[msg.sender][details[msg.sender].length-1].amount = details[msg.sender][i].amount;
                            details[msg.sender][details[msg.sender].length-1].time = details[msg.sender][i].time;  
                    
                            //storing last index element on current index
                    
                            details[msg.sender][i].amount= _tmpAmount;
                            details[msg.sender][i].time = _tmpDeadline;
                        }
                     // removing item on array
                     details[msg.sender].pop();
                        
            }
            
            else{
                
                // it increment value only when array lenght is not decreasing
                i++;
            }
        }
        require(_tokenAmount>0,'invalid balance');
        require(IERC20(RYIPToken).transfer(msg.sender,_tokenAmount),'transfer sending fail');
        return true;

    }
    

    function showFreezeToken(address _address) public view returns(uint256){
         require(_address!=address(0),'invalid address');
        uint256 vreturn=0;
        //for (uint256 i=deadlineStarIndex[msg.sender];i<=deadlineLastIndex[msg.sender] ;i++){
        for (uint256 i=0;i<details[_address].length ;i++){

            if (now<details[_address][i].time && details[_address][i].amount>0){ // if deadline time is over.
                    //vreturn= vreturn.add(details[msg.sender][i].amount);
                    vreturn= vreturn+details[_address][i].amount;
            }
        }
        return vreturn;

    }


    function showUnFreezeToken(address _address) public view  returns(uint256){
       require(_address!=address(0),'invalid address');
      uint256 vreturn=0;

        //for (uint256 i=deadlineStarIndex[msg.sender];i<=deadlineLastIndex[msg.sender] ;i++){
        for (uint256 i=0;i<details[_address].length ;i++){

            if (now>details[_address][i].time && details[_address][i].amount>0){ // if deadline time is over.
                    //vreturn= vreturn.add(details[msg.sender][i].amount);
                    vreturn= vreturn+details[_address][i].amount;
                    
            }
        }
        return vreturn;
    }
    
    


    function changeTokenDuration (uint256 _timePeriod) public onlyOwner returns(bool){
        tokenFreezeDuration= _timePeriod;
        return true;
    }

    function changeToken(address _RYIPToken) public onlyOwner returns(bool){
        RYIPToken=_RYIPToken;
        return true;
    }

}