pragma solidity ^0.4.23;







contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}







contract Locking {

    using SafeERC20 for ERC20Basic;

    using SafeMath for uint256;



    event Released(uint256 amount);



    ERC20Basic public token = ERC20Basic(0x026e62dDEd1a6aD07D93D39f96b9eabd59665e0d);



    address public companyWallet = 0x5f0F5ef64B0E4892295841519707Ca26fF34ff06;

    uint256 public firstReleaseTime = 1559347200;

    uint256 public secondReleaseTime = 1590969600;

    uint256 public deployedAt = now;

    address public owner;

    bool public isFirstPartReleased = false;

    uint256 private firstBirdAmount = 14506579 ether;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    function release() onlyOwner public {

        require(now > firstReleaseTime && !isFirstPartReleased || now > secondReleaseTime);



        uint256 amount = token.balanceOf(this);

        require(amount > 0);



        if (!isFirstPartReleased) {

            amount = firstBirdAmount;

            isFirstPartReleased = true;

        }



        token.safeTransfer(companyWallet, amount);

    }

}