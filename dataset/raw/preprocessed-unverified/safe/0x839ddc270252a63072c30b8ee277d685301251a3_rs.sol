/**
 *Submitted for verification at Etherscan.io on 2021-02-05
*/

pragma solidity ^0.6.2;




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */







/**
 * @title MoonDayPlus DAO
 * @dev Made by SoliditySam and Grass, fuck bad mouths saying I didnt made OG tendies
 *
 * 
          ,
       _/ \_     *
      <     >
*      /.'.\                    *
             *    ,-----.,_           ,
               .'`         '.       _/ \_
    ,         /              `\    <     >
  _/ \_      |  ,.---.         \    /.'.\
 <     >     \.'    _,'.---.    ;   `   `
  /.'.\           .'  (-(0)-)   ;
  `   `          /     '---'    |  *
                /    )          |             *
     *         |  .-;           ;        ,
               \_/ |___,'      ;       _/ \_ 
          ,  |`---.MOON|_       /     <     >
 *      _/ \_ \         `     /        /.'.\
       <     > '.          _,'         `   `
 MD+    /.'.\    `'------'`     *   
        `   `
 
 
 */

// The DAO contract itself
contract MoondayPlusDAO {
    
        using SafeMath for uint256;

    // The minimum debate period that a generic proposal can have
       uint256 public minProposalDebatePeriod = 2 weeks;
      
       
       // Period after which a proposal is closed
       // (used in the case `executeProposal` fails because it throws)
       uint256 public executeProposalPeriod = 10 days;
       
       
       
     


       IERC20 public MoondayToken;

       Uniswapv2Pair public MoondayTokenPair;


       // Proposals to spend the DAO's ether
       Proposal[] public proposals;
      
       // The unix time of the last time quorum was reached on a proposal
       uint public lastTimeMinQuorumMet;

      
       // Map of addresses and proposal voted on by this address
       mapping (address => uint[]) public votingRegister;



        uint256 public V = 2 ether;
        //median fixed
        
        uint256 public W = 40;
        //40% of holders approx
        
        uint256 public B = 5;
        //0.005% vote
        
        uint256 public C = 10;
        //10* 0.005% vote
     

  
       struct Proposal {
           // The address where the `amount` will go to if the proposal is accepted
           address recipient;
           // A plain text description of the proposal
           string description;
           // A unix timestamp, denoting the end of the voting period
           uint votingDeadline;
           // True if the proposal's votes have yet to be counted, otherwise False
           bool open;
           // True if quorum has been reached, the votes have been counted, and
           // the majority said yes
           bool proposalPassed;
           // A hash to check validity of a proposal
           bytes32 proposalHash;
           // Number of Tokens in favor of the proposal
           uint yea;
           // Number of Tokens opposed to the proposal
           uint nay;
           // Simple mapping to check if a shareholder has voted for it
           mapping (address => bool) votedYes;
           // Simple mapping to check if a shareholder has voted against it
           mapping (address => bool) votedNo;
           // Address of the shareholder who created the proposal
           address creator;
       }



       event ProposalAdded(
            uint indexed proposalID,
            address recipient,
            string description
           );
        event Voted(uint indexed proposalID, bool position, address indexed voter);
        event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
       

    // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyTokenholders {
        if (MoondayToken.balanceOf(msg.sender) == 0) revert();
            _;
    }

    constructor  (
        
        IERC20 _moontoken,
        Uniswapv2Pair _MoondayTokenPair
    ) public  {

        MoondayToken = _moontoken;

        MoondayTokenPair = _MoondayTokenPair;

       
        lastTimeMinQuorumMet = block.timestamp;
        
        proposals.push(); // avoids a proposal with ID 0 because it is used

        
    }


    receive() payable external {
       //we should get ether there but I doubt
       revert();
    }

    function newProposal(
        address _recipient,
        string calldata _description,
        bytes calldata _transactionData,
        uint64 _debatingPeriod
    ) onlyTokenholders payable external returns (uint _proposalID) {

        if (_debatingPeriod < minProposalDebatePeriod
            || _debatingPeriod > 8 weeks
            || msg.sender == address(this) //to prevent a 51% attacker to convert the ether into deposit
            )
                revert("error in debating periods");

        uint256 received = determineAm().mul(C);

		
	    
	    MoondayToken.burn(msg.sender, received);
	    
      
       
        
       
        Proposal memory p;
        p.recipient = _recipient;
        p.description = _description;
        p.proposalHash = keccak256(abi.encodePacked(_recipient, _transactionData));
        p.votingDeadline = block.timestamp.add( _debatingPeriod );
        p.open = true;
        //p.proposalPassed = False; // that's default
        p.creator = msg.sender;
        proposals.push(p);
        _proposalID = proposals.length;
       

        emit ProposalAdded(
            _proposalID,
            _recipient,
            _description
        );
    }

    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        bytes calldata _transactionData
    ) view external returns (bool _codeChecksOut) {
        Proposal memory p = proposals[_proposalID];
        return p.proposalHash == keccak256(abi.encodePacked(_recipient, _transactionData));
    }

    function vote(uint _proposalID, bool _supportsProposal) external {
        
        
        //burn md+
        
        uint256 received = determineAm();

		
	    
	    MoondayToken.burn(msg.sender, received);
	    
	    

        Proposal storage p = proposals[_proposalID];

        if (block.timestamp >= p.votingDeadline) {
            revert();
        }

        if (p.votedYes[msg.sender]) {
            revert();
        }

        if (p.votedNo[msg.sender]) {
            revert();
        }
        

        if (_supportsProposal) {
            p.yea += 1;
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += 1;
            p.votedNo[msg.sender] = true;
        }

        votingRegister[msg.sender].push(_proposalID);
        emit Voted(_proposalID, _supportsProposal, msg.sender);
    }




    function executeProposal(
        uint _proposalID,
        bytes calldata _transactionData
    )  external payable  returns (bool _success) {

        Proposal storage p = proposals[_proposalID];

        // If we are over deadline and waiting period, assert proposal is closed
        if (p.open && block.timestamp > p.votingDeadline.add(executeProposalPeriod)) {
            p.open = false;
            return false;
        }

        // Check if the proposal can be executed
        if (block.timestamp < p.votingDeadline  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p.open
            || p.proposalPassed // anyone trying to call us recursively?
            // Does the transaction code match the proposal?
            || p.proposalHash != keccak256(abi.encodePacked(p.recipient, _transactionData))
            )
                revert();

        
        
         // If we are over deadline and waiting period, assert proposal is closed
        if (p.open && now > p.votingDeadline.add(executeProposalPeriod)) {
            p.open = false;
            return false;
        }
        
        
       
        uint quorum = p.yea;




        // Execute result
        if (quorum >= minQuorum() && p.yea > p.nay) {
            // we are setting this here before the CALL() value transfer to
            // assure that in the case of a malicious recipient contract trying
            // to call executeProposal() recursively money can't be transferred
            // multiple times out of the DAO
            
            
            lastTimeMinQuorumMet = block.timestamp;
            
            
            p.proposalPassed = true;

            // this call is as generic as any transaction. It sends all gas and
            // can do everything a transaction can do. It can be used to reenter
            // the DAO. The `p.proposalPassed` variable prevents the call from 
            // reaching this line again
            (bool success, ) = p.recipient.call.value(msg.value)(_transactionData);
            require(success,"big fuckup");

            
        }

        p.open = false;

        // Initiate event
        emit ProposalTallied(_proposalID, _success, quorum);
        return true;
    }


 
   
    //admin like dao functions change median ETH :(
     function changeMedianV(uint256 _V) external {
        
        require(msg.sender == address(this));
         
        V = _V;
     }
     
    //admin like dao functions change % of holders
     function changeHoldersW(uint256 _W) external {
        
        require(msg.sender == address(this));
         
        W = _W;
     }


    //admin like dao functions change % burn vote
     function changeVoteB(uint256 _B) external {
        
        require(msg.sender == address(this));
         
        B = _B;
     }
     
     //admin like dao functions change % burn vote multiplier for proposal
     function changeVoteC(uint256 _C) external {
        
        require(msg.sender == address(this));
         
        C = _C;
     }



     //admin like dao functions change minProposalDebatePeriod
     function changeMinProposalDebatePeriod(uint256 _minProposalDebatePeriod) external {
        
        require(msg.sender == address(this));
         
        minProposalDebatePeriod = _minProposalDebatePeriod;
     }


    //admin like dao functions change executeProposalPeriod
     function changeexecuteProposalPeriod(uint256 _executeProposalPeriod) external {
        
        require(msg.sender == address(this));
         
        executeProposalPeriod = _executeProposalPeriod;
     }
     
     



 

    function minQuorum() public view returns (uint _minQuorum) {
        (uint256 reserve0,uint256 reserve1,) = MoondayTokenPair.getReserves();
   
        uint256 R = ((MoondayToken.totalSupply().div( (V.mul((reserve1.div(reserve0)))))).mul(W)).div(100);
        
        return R;
    }
    
    
     function determineAm() public view returns (uint _amount) {
        uint256 burn = (MoondayToken.totalSupply().mul(B)).div(100000);
        
        return burn;
    }


 

    function numberOfProposals() view external returns (uint _numberOfProposals) {
        // Don't count index 0. It's used by getOrModifyBlocked() and exists from start
        return proposals.length - 1;
    }

  
}