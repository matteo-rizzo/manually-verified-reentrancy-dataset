/**

 *Submitted for verification at Etherscan.io on 2019-05-07

*/



pragma solidity ^0.5.8;



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */









/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract ZmineVoteBurn is Ownable {

  

    // Use itmap for all functions on the struct

    using IterableMap for IterableMap.IMap;

    using SafeMath for uint256;

    

    // ERC20 basic token contract being held

    IERC20 public token;

  

    // map address => vote

    IterableMap.IMap voteRecordMap;

    // map address => token available for reclaim

    IterableMap.IMap reclaimTokenMap;

    

    // time to start vote period

    uint256 public timestampStartVote;

    // time to end vote period

    uint256 public timestampEndVote;

    // time to enable reclaim token process

    uint256 public timestampReleaseToken;

    

    // cumulative count for total vote

    uint256 _totalVote;

    

    constructor(IERC20 _token) public {



        token = _token;

        

        // (Mainnet) May 22, 2019 GMT (epoch time 1558483200)

        // (Kovan) from now

        timestampStartVote = 1558483200; 

        

        // (Mainnet) May 28, 2019 GMT (epoch time 1559001600)

        // (Kovan) period for 10 years

        timestampEndVote = 1559001600; 

        

        // (Mainnet) May 30, 2019 GMT (epoch time 1559174400)

        // (Kovan) from now

        timestampReleaseToken = 1559174400; 

    }

    

    /**

     * modifier

     */

     

    // during the votable period?

    modifier onlyVotable() {

        require(isVotable());

        _;

    }

    

    // during the reclaimable period?

    modifier onlyReclaimable() {

        require(isReclaimable());

        _;

    }

  

    /**

     * public methods

     */

     

    function isVotable() public view returns (bool){

        return (timestampStartVote <= block.timestamp && block.timestamp <= timestampEndVote);

    }

    

    function isReclaimable() public view returns (bool){

        return (block.timestamp >= timestampReleaseToken);

    }

    

    function countVoteUser() public view returns (uint256){

        return voteRecordMap.size();

    }

    

    function countVoteScore() public view returns (uint256){

        return _totalVote;

    }

    

    function getVoteByAddress(address _address) public view returns (uint256){

        return voteRecordMap.get(_address);

    }

    

    // vote by transfer token into this contract as collateral

    // This process require approval from sender, to allow contract transfer token on the sender behalf.

    function voteBurn(uint256 amount) public onlyVotable {



        require(token.balanceOf(msg.sender) >= amount);

        

        // transfer token on the sender behalf.

        token.transferFrom(msg.sender, address(this), amount);

        

        // calculate cumulative vote

        uint256 newAmount = voteRecordMap.get(msg.sender).add(amount);

        

        // save to map

        reclaimTokenMap.insert(msg.sender, newAmount);

        voteRecordMap.insert(msg.sender, newAmount);

        

        // cumulative count total vote

        _totalVote = _totalVote.add(amount);

    }

    

    // Take the token back to the sender after reclaimable period has come.

    function reclaimToken() public onlyReclaimable {

      

        uint256 amount = reclaimTokenMap.get(msg.sender);

        require(amount > 0);

        require(token.balanceOf(address(this)) >= amount);

          

        // transfer token back to sender

        token.transfer(msg.sender, amount);

        

        // remove from map

        reclaimTokenMap.remove(msg.sender);

    }

    

    /**

     * admin methods

     */

     

    function adminCountReclaimableUser() public view onlyOwner returns (uint256){

        return reclaimTokenMap.size();

    }

    

    function adminCheckReclaimableAddress(uint256 index) public view onlyOwner returns (address){

        

        require(index >= 0); 

        

        if(reclaimTokenMap.size() > index){

            return reclaimTokenMap.getKey(index);

        }else{

            return address(0);

        }

    }

    

    function adminCheckReclaimableToken(uint256 index) public view onlyOwner returns (uint256){

    

        require(index >= 0); 

    

        if(reclaimTokenMap.size() > index){

            return reclaimTokenMap.get(reclaimTokenMap.getKey(index));

        }else{

            return 0;

        }

    }

    

    function adminCheckVoteAddress(uint256 index) public view onlyOwner returns (address){

        

        require(index >= 0); 

        

        if(voteRecordMap.size() > index){

            return voteRecordMap.getKey(index);

        }else{

            return address(0);

        }

    }

    

    function adminCheckVoteToken(uint256 index) public view onlyOwner returns (uint256){

    

        require(index >= 0); 

    

        if(voteRecordMap.size() > index){

            return voteRecordMap.get(voteRecordMap.getKey(index));

        }else{

            return 0;

        }

    }

    

    // perform reclaim token by admin 

    function adminReclaimToken(address _address) public onlyOwner {

      

        uint256 amount = reclaimTokenMap.get(_address);

        require(amount > 0);

        require(token.balanceOf(address(this)) >= amount);

          

        token.transfer(_address, amount);

        

        // remove from map

        reclaimTokenMap.remove(_address);

    }

    

    // Prevent deposit tokens by accident to a contract with the transfer function? 

    // The transaction will succeed but this will not be recognized by the contract.

    // After reclaim process was ended, admin will able to transfer the remain tokens to himself. 

    // And return the remain tokens to senders by manual process.

    function adminSweepMistakeTransferToken() public onlyOwner {

        

        require(reclaimTokenMap.size() == 0);

        require(token.balanceOf(address(this)) > 0);

        token.transfer(owner, token.balanceOf(address(this)));

    }

}