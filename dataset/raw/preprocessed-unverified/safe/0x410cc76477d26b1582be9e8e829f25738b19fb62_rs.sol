/**

 *Submitted for verification at Etherscan.io on 2018-09-08

*/



pragma solidity ^0.4.19;























contract ProfitManager

{

    address public m_Owner;

    bool public m_Paused;

    AbstractDatabase m_Database= AbstractDatabase(0x400d188e1c21d592820df1f2f8cf33b3a13a377e);



    modifier NotWhilePaused()

    {

        require(m_Paused == false);

        _;

    }

    modifier OnlyOwner(){

    require(msg.sender == m_Owner);

    _;

}



    address constant NullAddress = 0;



    //Market

    uint256 constant ProfitFundsCategory = 14;

    uint256 constant WithdrawalFundsCategory = 15;

    uint256 constant HeroMarketCategory = 16;

    

    //ReferalCategory

    uint256 constant ReferalCategory = 237;



    function ProfitManager() public {

    m_Owner = msg.sender;

    m_Paused = true;

}

    function Unpause() public OnlyOwner()

    {

        m_Paused = false;

    }



    function Pause() public OnlyOwner()

    {

        require(m_Paused == false);



        m_Paused = true;

    }



    // 1 write

    function WithdrawProfitFunds(uint256 withdraw_amount, address beneficiary) public NotWhilePaused() OnlyOwner()

    {

        uint256 profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));

        require(withdraw_amount > 0);

        require(withdraw_amount <= profit_funds);

        require(beneficiary != address(0));

        require(beneficiary != address(this));

        require(beneficiary != address(m_Database));



        profit_funds -= withdraw_amount;



        m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(profit_funds));



        m_Database.TransferFunds(beneficiary, withdraw_amount);

    }



    // 1 write

    function WithdrawWinnings(uint256 withdraw_amount) public NotWhilePaused()

    {



        require(withdraw_amount > 0);



        uint256 withdrawal_funds = uint256(m_Database.Load(msg.sender, WithdrawalFundsCategory, 0));

        require(withdraw_amount <= withdrawal_funds);



        withdrawal_funds -= withdraw_amount;



        m_Database.Store(msg.sender, WithdrawalFundsCategory, 0, bytes32(withdrawal_funds));



        m_Database.TransferFunds(msg.sender, withdraw_amount);

    }



    function GetProfitFunds() view public OnlyOwner() returns (uint256 funds)

    {

        uint256 profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));

        return profit_funds;

    }

    function GetWithdrawalFunds(address target) view public NotWhilePaused() returns (uint256 funds)

    {

        funds = uint256(m_Database.Load(target, WithdrawalFundsCategory, 0));

    }



}



contract AbstractDatabase

{

    function() public payable;

    function ChangeOwner(address new_owner) public;

    function ChangeOwner2(address new_owner) public;

    function Store(address user, uint256 category, uint256 slot, bytes32 data) public;

    function Load(address user, uint256 category, uint256 index) public view returns (bytes32);

    function TransferFunds(address target, uint256 transfer_amount) public;

    function getRandom(uint256 upper, uint8 seed) public returns (uint256 number);

}