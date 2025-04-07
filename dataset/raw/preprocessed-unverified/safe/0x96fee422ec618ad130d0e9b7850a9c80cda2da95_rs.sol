/**

 *Submitted for verification at Etherscan.io on 2018-11-27

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



contract Ethpen is Ownable {

    mapping (address => mapping (bytes32 =>uint)) public paidAmount;

    mapping (address => uint) public balances;

    uint8 public feeRate;



    event PayForUrl(address _from, address _creator, string _url, uint amount);

    event Withdraw(address _from, uint amount);

    constructor (uint8 _feeRate) public {

        feeRate = _feeRate;

    }

    function payForUrl(address _creator,string _url) public payable {

        uint fee = (msg.value * feeRate) / 100; 

        balances[owner()] += fee;

        balances[_creator] += msg.value - fee;

        paidAmount[msg.sender][keccak256(_url)] += msg.value;

        emit PayForUrl(msg.sender,_creator,_url,msg.value);

    }

    function setFeeRate (uint8 _feeRate)public onlyOwner{

        require(_feeRate < feeRate, "Cannot raise fee rate");

        feeRate = _feeRate;

    }

    function withdraw() public{

        uint balance = balances[msg.sender];

        require(balance > 0, "Balance must be greater than zero");

        balances[msg.sender] = 0;

        msg.sender.transfer(balance);

        emit Withdraw(msg.sender, balance);

    }

}