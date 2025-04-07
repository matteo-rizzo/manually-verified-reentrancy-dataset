/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity 0.4.25;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */



contract owned {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner , "Unauthorized Access");

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}









contract TansalICOTokenVault is owned{

    

     using SafeERC20 for ERC20Interface;

     ERC20Interface TansalCoin;

      struct Investor {

        string fName;

        string lName;

        uint256 totalTokenWithdrawn;

        bool exists;

    }

    

    mapping (address => Investor) public investors;

    address[] public investorAccts;

    uint256 public numberOFApprovedInvestorAccounts;



     constructor() public

     {

         

         TansalCoin = ERC20Interface(0x0EF0183E9Db9069a7207543db99a4Ec4d06f11cB);

     }

    

     function() public {

         //not payable fallback function

          revert();

    }

    

     function sendApprovedTokensToInvestor(address _benificiary,uint256 _approvedamount,string _fName, string _lName) public onlyOwner

    {

        uint256 totalwithdrawnamount;

        require(TansalCoin.balanceOf(address(this)) > _approvedamount);

        if(investors[_benificiary].exists)

        {

            uint256 alreadywithdrawn = investors[_benificiary].totalTokenWithdrawn;

            totalwithdrawnamount = alreadywithdrawn + _approvedamount;

            

        }

        else

        {

          totalwithdrawnamount = _approvedamount;

          investorAccts.push(_benificiary) -1;

        }

         investors[_benificiary] = Investor({

                                            fName: _fName,

                                            lName: _lName,

                                            totalTokenWithdrawn: totalwithdrawnamount,

                                            exists: true

            

        });

        numberOFApprovedInvestorAccounts = investorAccts.length;

        TansalCoin.safeTransfer(_benificiary , _approvedamount);

    }

    

     function onlyPayForFuel() public payable onlyOwner{

        // Owner will pay in contract to bear the gas price if transactions made from contract

        

    }

    function withdrawEtherFromcontract(uint _amountInwei) public onlyOwner{

        require(address(this).balance > _amountInwei);

      require(msg.sender == owner);

      owner.transfer(_amountInwei);

     

    }

    function withdrawTokenFromcontract(ERC20Interface _token, uint256 _tamount) public onlyOwner{

        require(_token.balanceOf(address(this)) > _tamount);

         _token.safeTransfer(owner, _tamount);

     

    }

}