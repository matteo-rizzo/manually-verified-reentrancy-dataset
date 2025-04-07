/**
 *Submitted for verification at Etherscan.io on 2021-07-13
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;






contract SimpleCrowdsale {
    using SafeMath for uint256;
      // The token being sold
  address public token;
  
  address[] public incoming_addresses;
  
    
    uint256 public count = 1;
     mapping (uint256 => address) public investor_list;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;
    uint256 total_tokens_value;
  
  bool public locked = false;
  
    address public owner_address;
    

    // function get_total_count() public returns (uint256){
    //     return count;
    // }
    // function get_address_from_list(uint256 tcount) public returns (address){
    //     return investor_list[tcount];
    // }
    // function get_balance(address address_of_investor) public returns (uint256){
    //     return IERC20(token).balanceOf(address_of_investor);
    // }
    function get_incoming_addresses(uint256 index) public returns (address){
        return incoming_addresses[index];
    }
    


  
    constructor(uint256 t_rate,address t_token) public payable {
        token = t_token;
        owner_address = msg.sender;
        rate = t_rate;
        
        
    }
        function total_tokens() public view returns (uint256)
    {
        return IERC20(token).balanceOf(address(this));
    }
            function upadte_total_tokens() internal
    {
        total_tokens_value = IERC20(token).balanceOf(address(this));
    }
    function unlock() public {
        require(msg.sender == owner_address,"Only owner");
        locked = false;
    }
    function get_back_all_tokens() public {
        require(msg.sender == owner_address,"Only owner");
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        upadte_total_tokens();
    }
    function get_back_tokens(uint256 amount) public {
        require(msg.sender == owner_address,"Only owner");
        //require(total_tokens_value >= amount);
        IERC20(token).transfer(msg.sender, amount);
        
        upadte_total_tokens();
    }
        function lock() public {
            require(msg.sender == owner_address,"Only owner");
        locked = true;
    }

    
    // function getBalanceOfToken(address _address) public view returns (uint256) {
    //     return IERC20(_address).balanceOf(address(this));
    // }
    
    receive() external payable {
      buyTokens(msg.sender);
     //IERC20(token).transfer(msg.sender, 100000000000000000);
    }
    fallback() external payable {
       // buyTokens(msg.sender);
    }
    
    function buyTokens(address payable _beneficiary) public payable{

         require(!locked, "Locked");
         uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary,msg.value);
    
        // calculate token amount to be created
         uint256 t_rate = _getTokenAmount(weiAmount);
         require(IERC20(token).balanceOf(address(this)) >= t_rate, "Contract Doesnot have enough tokens");
    
        //  // update state
         
        
        IERC20(token).transfer(_beneficiary, t_rate);
        incoming_addresses.push(_beneficiary);
        weiRaised = weiRaised.add(weiAmount);
        investor_list[count] = _beneficiary;
        count++;
       // _deliverTokens(_beneficiary, t_rate);
       upadte_total_tokens();

  }
  
    function _preValidatePurchase (
        address _beneficiary,
        uint256 _weiAmount
    ) pure
    internal
    {
        require(_beneficiary != address(0), "Beneficiary = address(0)");
        require(_weiAmount >= 100000000000000000 || _weiAmount <= 10000000000000000000 ,"send Minimum 0.1 eth or 10 Eth max");
    }
    
      function extractEther() public {
           require(msg.sender == owner_address,"Only owner");
          msg.sender.transfer(address(this).balance);
       }
        function changeOwner(address new_owner) public {
           require(msg.sender == owner_address,"Only owner");
          owner_address = new_owner;
       }
  
    function _getTokenAmount(uint256 _weiAmount)
    public view returns (uint256)
    {
        uint256 temp1 = _weiAmount.div(1000000000);
        return temp1.mul(rate) * 10**9;
       // return _weiAmount.mul(325) * 10**9;
    }
    
        function _calculate_TokenAmount(uint256 _weiAmount, uint256 t_rate, uint divide_amount)
    public pure returns (uint256)
    {
        uint256 temp2 = _weiAmount.div(divide_amount);
        return temp2.mul(t_rate);
    }
    

         function update_rate(uint256 _rate)
    public
    {
        require(msg.sender == owner_address,"Only owner");
        rate = _rate;
    }

  
    function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    IERC20(token).transfer(_beneficiary, _tokenAmount);
  }
    
}