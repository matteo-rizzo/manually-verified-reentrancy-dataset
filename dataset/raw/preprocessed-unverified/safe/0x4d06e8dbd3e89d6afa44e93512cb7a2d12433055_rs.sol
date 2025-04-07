/**

 *Submitted for verification at Etherscan.io on 2019-07-09

*/



pragma solidity ^0.4.24;

//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";















contract ERC20Basic {

  uint public totalSupply;

  function balanceOf(address who) public returns (uint);

  function transfer(address to, uint value) public;

  event Transfer(address indexed from, address indexed to, uint value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public returns (uint);

  function transferFrom(address from, address to, uint value) public;

  function approve(address spender, uint value) public;

  event Approval(address indexed owner, address indexed spender, uint value);

}



contract Airdropper2 is Ownable {

    using SafeMath for uint256;

    function multisend(address[] wallets, uint256[] values) external onlyTeam returns (uint256) {

        

        uint256 limit = globalLimit;

        uint256 tokensToIssue = 0;

        address wallet = address(0);

        

        for (uint i = 0; i < wallets.length; i++) {



            tokensToIssue = values[i];

            wallet = wallets[i];



           if(tokensToIssue > 0 && wallet != address(0)) { 

               

                if(personalLimit[wallet] > globalLimit) {

                    limit = personalLimit[wallet];

                }



                if(distributedBalances[wallet].add(tokensToIssue) > limit) {

                    tokensToIssue = limit.sub(distributedBalances[wallet]);

                }



                if(limit > distributedBalances[wallet]) {

                    distributedBalances[wallet] = distributedBalances[wallet].add(tokensToIssue);

                    ERC20(token).transfer(wallet, tokensToIssue);

                }

           }

        }

    }

    

    function simplesend(address[] wallets) external onlyTeam returns (uint256) {

        

        uint256 tokensToIssue = globalLimit;

        address wallet = address(0);

        

        for (uint i = 0; i < wallets.length; i++) {

            

            wallet = wallets[i];

           if(wallet != address(0)) {

               

                if(distributedBalances[wallet] == 0) {

                    distributedBalances[wallet] = distributedBalances[wallet].add(tokensToIssue);

                    ERC20(token).transfer(wallet, tokensToIssue);

                }

           }

        }

    }





    function evacuateTokens(ERC20 _tokenInstance, uint256 _tokens) external onlyOwner returns (bool success) {

        _tokenInstance.transfer(owner, _tokens);

        return true;

    }



    function _evacuateEther() onlyOwner external {

        owner.transfer(address(this).balance);

    }

}