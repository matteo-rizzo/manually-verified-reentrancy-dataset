pragma solidity ^0.4.24;



/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









/*

* There are 4 entities in this contract - 

#1 `company` - This is the company which is going to place a bounty of tokens

#2 `referrer` - This is the referrer who refers a candidate that gets a job finally

#3 `candidate` - This is the candidate who gets a job finally

#4 `owner` - Indorse as a company will be the owner of this contract

*

*/



contract JobsBounty is Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    string public companyName; //Name of the company who is putting the bounty

    string public jobPost; //Link to the job post for this Smart Contract

    uint public endDate; //Unix timestamp of the end date of this contract when the bounty can be released

    

    // On Rinkeby

    // address public INDToken = 0x656c7da9501bB3e4A5a544546230D74c154A42eb;

    // On Mainnet

    address public INDToken = 0xf8e386eda857484f5a12e4b5daa9984e06e73705;

    

    constructor(string _companyName,

                string _jobPost,

                uint _endDate

                ) public{

        companyName = _companyName;

        jobPost = _jobPost ;

        endDate = _endDate;

    }

    

    //Helper function, not really needed, but good to have for the sake of posterity

    function ownBalance() public view returns(uint256) {

        return ERC20(INDToken).balanceOf(this);

    }

    

    function payOutBounty(address _referrerAddress, address _candidateAddress) public onlyOwner nonReentrant returns(bool){

        uint256 individualAmounts = (ERC20(INDToken).balanceOf(this) / 100) * 50;

        

        assert(block.timestamp >= endDate);

        // Tranferring to the candidate first

        assert(ERC20(INDToken).transfer(_candidateAddress, individualAmounts));

        assert(ERC20(INDToken).transfer(_referrerAddress, individualAmounts));

        return true;    

    }

    

    //This function can be used in 2 instances - 

    // 1st one if to withdraw tokens that are accidentally send to this Contract

    // 2nd is to actually withdraw the tokens and return it to the company in case they don't find a candidate

    function withdrawERC20Token(address anyToken) public onlyOwner nonReentrant returns(bool){

        assert(block.timestamp >= endDate);

        assert(ERC20(anyToken).transfer(owner, ERC20(anyToken).balanceOf(this)));        

        return true;

    }

    

    //ETH cannot get locked in this contract. If it does, this can be used to withdraw

    //the locked ether.

    function withdrawEther() public nonReentrant returns(bool){

        if(address(this).balance > 0){

            owner.transfer(address(this).balance);

        }        

        return true;

    }

}