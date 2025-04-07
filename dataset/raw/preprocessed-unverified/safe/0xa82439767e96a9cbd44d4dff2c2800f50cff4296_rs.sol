/**
 *Submitted for verification at Etherscan.io on 2019-07-10
*/

/**

██╗    ██╗██████╗ ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗ ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  █████╗  ██████╗████████╗███████╗    ██████╗ ██████╗ ███╗   ███╗
██║    ██║██╔══██╗██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝   ██╔════╝██╔═══██╗████╗ ████║
██║ █╗ ██║██████╔╝███████╗██╔████╔██║███████║██████╔╝   ██║   ██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝███████║██║        ██║   ███████╗   ██║     ██║   ██║██╔████╔██║
██║███╗██║██╔═══╝ ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██║██║        ██║   ╚════██║   ██║     ██║   ██║██║╚██╔╝██║
╚███╔███╔╝██║     ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║  ██║╚██████╗   ██║   ███████║██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║
 ╚══╝╚══╝ ╚═╝     ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚══════╝╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝

Blockhain Made Easy

https://wpsmartcontracts.com/

*/

pragma solidity ^0.5.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


/**
 *
 * WPSmartContracts / Campaign Contract
 *
 * Contribution campaigns including the ability to approve the transfer of funds per request
 *
 */

contract CampaignMango {

    using SafeMath for uint256;
    
    // this is a struct definition, that needs to be instantiated to be used... like classes.
    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }
    
    Request[] public requests; // this is the instance of the struct, like an array of Request
    address public manager; // the owner
    uint256 minimumContribution; // the... minimum contribution

    /*
        a factor to calculate minimum number of approvers by 100/factor
        the factor values are 2 and 10, factors that makes sense:
            2: meaning that the number or approvers required will be 50%
            3: 33.3%
            4: 25%
            5: 20%
            10: 10%
    */
    uint8 approversFactor; 
    
    mapping(address => bool) public approvers;
    uint256 public approversCount;

    // a modifier of functions to add validation of the manager to run any function
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // Constructor function to create a Campaign
    constructor(address creator, uint256 minimum, uint8 factor) public {
        // validate factor number betweeb 2 and 10
        require(factor >= 2);
        require(factor <= 10);
        manager = creator;
        approversFactor = factor;
        minimumContribution = minimum;
    }
    
    // allows a contributor to contribute
    function contribute() public payable {
        // validate minimun contribution
        require(msg.value >= minimumContribution);
        
        // approvers.push(msg.sender); // array was changed to mappings
        approvers[msg.sender] = true; // this maps this address with true
        
        // increment the number of approvers
        approversCount++; 
    }

    // create a request... 
    function createRequest(string memory description, uint256 value, address payable recipient) public restricted {
    
        // create the struct, specifying memory as a holder
        Request memory newRequest = Request({ 
           description: description, 
           value: value, 
           recipient: recipient,
           complete: false,
           approvalCount: 0
        });
        
        requests.push(newRequest);
        
    }
    
    // contributors has the right to approve request
    function approveRequest(uint256 index) public {
        
        // this is to store in a local variable "request" the request[index] and avoid using it all the time
        // storage means that we want the same copy inside of storage?, WTF?
        // Request means to a Request struct defined at the beginning
        Request storage request = requests[index];
        
        // if will require that the sender address is in the mapping of approvers
        // if not will exit the function inmediatly
        require(approvers[msg.sender]);
        
        // it will require the contributor not to vote twice for the same request
        require(!request.approvals[msg.sender]);
        
        // add the voter to the approvals map
        request.approvals[msg.sender] = true;
        
        // increment the number of YES votes for the request
        request.approvalCount++;
        
    }
    
    // send the money to the vendor y there are enough votes
    // restricted means that only the creator is allowed to run this function
    function finalizeRequest(uint256 index) public restricted {
        
        // this is to store in a local variable "request" the request[index] and avoid using it all the time
        // storage means that we want the same copy inside of storage?, WTF?
        // Request means to a Request struct defined at the beginning
        Request storage request = requests[index];

        // transfer the money if it has more than X% of approvals
        require(request.approvalCount >= approversCount.div(approversFactor)); 
        
        // we will require that the request in process is not completed yet
        require(!request.complete);
        
        // mark the request as completed
        request.complete = true;
        
        // transfer the money requested (value) from the contract to the vendor that created the request
        request.recipient.transfer(request.value);
        
    }

    // helper function to show basic info of a contract in the interface
    function getSummary() public view returns (
      uint256, uint256, uint256, uint256, address
      ) {
        return (
          minimumContribution,
          address(this).balance,
          requests.length,
          approversCount,
          manager
        );
    }

    // for looping?
    function getRequestsCount() public view returns (uint256) {
        return requests.length;
    }   

}