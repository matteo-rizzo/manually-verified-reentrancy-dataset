/**
 *Submitted for verification at Etherscan.io on 2020-07-07
*/

pragma solidity ^0.5.16;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------


// ProfitLineInc contract
contract DecentribeIntegration  {
    using SafeMath for uint;
    // params 
    uint256 public previousPrice;
    uint256 public daibalance;// original dai balance
    address payable tribe; //decentrice distribution pot;
    // interfaces
    UniswapExchangeInterface constant _swapDAI = UniswapExchangeInterface(0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667);// uniswap
    PlincInterface constant hub_ = PlincInterface(0xd5D10172e8D8B84AC83031c16fE093cba4c84FC6);  // hubplinc
    IIdleToken constant _idle = IIdleToken(0x78751B12Da02728F467A44eAc40F5cbc16Bd7934);         // idle
    ERC20Interface constant _dai = ERC20Interface(0x6B175474E89094C44Da98b954EedeAC495271d0F);  //dai
    
    // Decentribe integration
    function () external payable{} // needs for divs
    function setApproval() public {
        //using idle needs to have aproval before able to get idle tokens
        // aprove idle address, amount to aprove
        _dai.approve(0x78751B12Da02728F467A44eAc40F5cbc16Bd7934,1000000000000000000000000000000000000000000);
        // approve uniswap
        _dai.approve(0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667,1000000000000000000000000000000000000000000);
    }
    function mintIdles() public payable {
        uint256 ethBalance = address(this).balance;
        uint256 deadline = block.timestamp.add(100);
        _swapDAI.ethToTokenSwapInput.value(ethBalance)(1,deadline);
        uint256 myBalance = _dai.balanceOf(address(this));
        uint256[] memory empty;
        _idle.mintIdleToken(myBalance,empty);
        daibalance = daibalance.add(myBalance);
        previousPrice = _idle.tokenPrice();
    }
    function divsToHubp1() public {
        //buy hub bonds
        
        // calculate divsToHub
        uint256[] memory empty;
        uint256 myBalance = daibalance;
        uint256 idlebalance = _idle.balanceOf(address(this));
        // fetch divs to contract (exitidle)
        
        _idle.redeemIdleToken(idlebalance, false,empty);// get all dai
        _idle.mintIdleToken(myBalance,empty);// put back investment
        // swap remaining dai to ether
        uint256 daiBalance = _dai.balanceOf(address(this));
        uint256 deadline = block.timestamp.add(100);
        _swapDAI.tokenToEthSwapInput(daiBalance,1, deadline) ;
        //
        uint256 ethBalance = address(this).balance;
        // buy bonds
        hub_.buyBonds.value(ethBalance)(0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220);
    }
    function currentPrice() public view returns(uint256 price){
        uint256 _currentPrice = _idle.tokenPrice();
        return (_currentPrice);
    }
    function currentIdleBalance() public view returns(uint256 price){
        uint256 _currentPrice = _idle.balanceOf(address(this));
        return (_currentPrice);
    }
   
    function transferERCs(address ofToken, uint256 _amount) public {
        require(msg.sender == 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220);
        ERC20Interface(ofToken).transfer(0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220, _amount);
    }
    function fetchHubVault() public{
        
        uint256 _value = hub_.playerVault(address(this));
        require(_value >0);
        //require(msg.sender == hubFundAdmin);
        hub_.vaultToWallet();
        // SEND ETH TO DECENTRIBE POT
        IDistributableInterface(tribe).distribute.value(_value)();
        
    }
    function fetchHubPiggy() public{
        
        uint256 _value = hub_.piggyBank(address(this));
        require(_value >0);
        hub_.piggyToWallet();
         // SEND ETH TO DECENTRIBE POT
        IDistributableInterface(tribe).distribute.value(_value)();
    }
    
    function upgradeTribe(address payable _tribe) public{
        require(msg.sender == 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220);
        tribe = _tribe;
    }
    constructor()
        public
        
    {
        hub_.setAuto(10);
    }
}
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}



