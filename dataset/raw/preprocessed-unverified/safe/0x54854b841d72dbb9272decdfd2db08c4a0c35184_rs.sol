/**
 *Submitted for verification at Etherscan.io on 2020-12-23
*/

pragma solidity 0.6.2;



/**
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */




/**
 * @dev Math operations with safety checks that throw on error. This contract is based on the
 * source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol.
 */



/**
 * @dev signature of external (deployed) contract (ERC20 token)
 * only methods we will use
 */
contract ERC20Token {
 
    function totalSupply() external view returns (uint256){}
    function balanceOf(address account) external view returns (uint256){}
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function approve(address spender, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function decimals()  external view returns (uint8){}
  
}



contract TokenSale is
  Ownable
{
    using SafeMath for uint256;
   
    modifier onlyPriceManager() {
      require(
          msg.sender == price_manager,
          "only price manager can call this function"
          );
          _;
    }
  
   
   
    ERC20Token token;
    
    /**
    * @dev some non-working address from the start to ensure owner will set correct one
    */
   
    address ERC20Contract = 0x0000000000000000000000000000000000000000;
    address price_manager = 0x0000000000000000000000000000000000000000;
    
    /**
    * @dev 10**18 for tokens with 18 digits, need to be changed accordingly (setter/getter)
    */
    uint256 adj_constant = 1000000000000000000; 
    
    //initial in wei
    uint256  sell_price = 2000000000000000; 
    
    //initial in wei
    uint256  buyout_price = 1; 
    
    //events
    event Bought(uint256 amount, address wallet);
    event Sold(uint256 amount, address wallet);
    event TokensDeposited(uint256 amount, address wallet);
    event FinneyDeposited(uint256 amount, address wallet);
    event Withdrawn(uint256 amount, address wallet);
    event TokensWithdrawn(uint256 amount, address wallet);
   
    /**
    * @dev set price_manager == owner in the beginning, but could be changed by setter, below
    */
    constructor() public {
        price_manager = owner;
    }
    
    
    function setPriceManagerRight(address newPriceManager) external onlyOwner{
          price_manager = newPriceManager;
    }
      
      
    function getPriceManager() public view returns(address){
        return price_manager;
    }
    
    
    /**
    * @dev setter/getter for ERC20 linked to exchange (current) smartcontract
    */
    function setERC20(address newERC20Contract) external onlyOwner returns(bool){
        
        ERC20Contract = newERC20Contract;
        token = ERC20Token(ERC20Contract); 
    }
    
    
    function getERC20() external view returns(address){
        return ERC20Contract;
    }

    /**
    * @dev setter/getter for digits constant (current 10**18)
    */
    function setAdjConstant(uint256 new_adj_constant) external onlyOwner{
        adj_constant = new_adj_constant;
    }
    
    function getAdjConstant() external view returns(uint256){  
        return adj_constant;
    }
 
    /**
    * @dev setters/getters for prices 
    */
    function setSellPrice(uint256 new_sell_price) external onlyPriceManager{
        sell_price = new_sell_price;
    }
    
    function setBuyOutPrice(uint256 new_buyout_price) external onlyPriceManager{
        buyout_price = new_buyout_price;
    }
    
    function getSellPrice() external view returns(uint256){  
        return sell_price;
    }
    
    function getBuyOutPrice() external view returns(uint256){  
        return buyout_price;
    }
    
    
    /**
    * @dev two functions below are to assess 'value' of buy/sell
    */
    
    //number of tokens I can buy for amount (in wei), "user" view
    function calcCanBuy(uint256 forWeiAmount) external view returns(uint256){
        require(forWeiAmount > 0,"forWeiAmount should be > 0");
        uint256 amountTobuy = forWeiAmount.div(sell_price);
       
        //not adjusted [10 ** decimals]), i.e. for frontend
        return amountTobuy; 
    }
    
     
    //cash I will get for tokens ("user" view)
    function calcCanGet(uint256 tokensNum) external view returns(uint256){
        require(tokensNum > 0,"tokensNum should be > 0"); //it is "frontend" tokens
        uint256 amountToGet = tokensNum.mul(buyout_price);
        return amountToGet; //wei
    }
    
    
    /**
    * @dev user buys tokens - number of tokens calc. based on value sent
    */
    function buy() payable external notContract returns (bool) {
        uint256 amountSent = msg.value; //in wei..
        require(amountSent > 0, "You need to send some Ether");
         uint256 dexBalance = token.balanceOf(address(this));
        //calc number of tokens (real ones, not converted based on decimals..)
        uint256 amountTobuy = amountSent.div(sell_price); //tokens as user see them
       
        uint256 realAmountTobuy = amountTobuy.mul(adj_constant); //tokens adjusted to real ones
        
       
        
        require(realAmountTobuy > 0, "not enough ether to buy any feasible amount of tokens");
        require(realAmountTobuy <= dexBalance, "Not enough tokens in the reserve");
        
    
        
        try token.transfer(msg.sender, realAmountTobuy) { //ensure we revert in case of failure
            emit Bought(amountTobuy, msg.sender);
            return true;
        } catch {
            revert();
        }
        
    }
    
    
    receive() external payable {// called when ether is send

        uint256 amountSent = msg.value; //in wei..
        require(amountSent > 0, "You need to send some Ether");
        uint256 dexBalance = token.balanceOf(address(this));
        //calc number of tokens (real ones, not converted based on decimals..)
        uint256 amountTobuy = amountSent.div(sell_price); //tokens as user see them
       
        uint256 realAmountTobuy = amountTobuy.mul(adj_constant); //tokens adjusted to real ones
        
       
        
        require(realAmountTobuy > 0, "not enough ether to buy any feasible amount of tokens");
        require(realAmountTobuy <= dexBalance, "Not enough tokens in the reserve");
        
        try token.transfer(msg.sender, realAmountTobuy) { //ensure we revert in case of failure
            emit Bought(amountTobuy, msg.sender);
            return;
        } catch {
            revert();
        }
        
    }
    
    
    /**
    * @dev user sells tokens
    */
    function sell(uint256 amount_tokens) external notContract returns(bool) {
        uint256 amount_wei = 0;
        require(amount_tokens > 0, "You need to sell at least some tokens");
        uint256 realAmountTokens = amount_tokens.mul(adj_constant);
        
        uint256 token_bal = token.balanceOf(msg.sender);
        require(token_bal >= realAmountTokens, "Check the token balance on your wallet");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= realAmountTokens, "Check the token allowance");
       
        amount_wei = amount_tokens.mul(buyout_price); //convert to wei
        
        
        require(address(this).balance > amount_wei, "unsufficient funds");
        bool success = false;
       
        //ensure we revert in case of failure 
        try token.transferFrom(msg.sender, address(this), realAmountTokens) { 
            //just continue if all good..
        } catch {
            require(false,"tokens transfer failed");
            return false;
        }
        
        
        // **   msg.sender.transfer(amount_wei); .** 
       
        (success, ) = msg.sender.call.value(amount_wei)("");
        require(success, "Transfer failed.");
        // ** end **
        
      
            // all done..
        emit Sold(amount_tokens, msg.sender);
        return true; //normal completion
       
    }


    
    /**
    * @dev returns contract balance, in wei
    */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
    * @dev returns contract tokens balance
    */
    function getContractTokensBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
   
    
    /**
    * @dev - four functions below are for owner to 
    * deposit/withdraw eth/tokens to exchange contract
    */
    function withdraw(address payable sendTo, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "unsufficient funds");
        bool success = false;
        // ** sendTo.transfer(amount);** 
        (success, ) = sendTo.call.value(amount)("");
        require(success, "Transfer failed.");
        // ** end **
        emit Withdrawn(amount, sendTo); //wei
    }
  
    
    function deposit(uint256 amount) payable external onlyOwner { //amount in finney
        require(amount*(1 finney) == msg.value,"please provide value in finney");
        emit FinneyDeposited(amount, owner); //in finney
    }

    function depositTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "You need to deposit at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        
        emit TokensDeposited(amount.div(adj_constant), owner);
    }
    
  
    function withdrawTokens(address to_wallet, uint256 amount_tokens) external onlyOwner{
        require(amount_tokens > 0, "You need to withdraw at least some tokens");
        uint256 realAmountTokens = amount_tokens.mul(adj_constant);
        uint256 contractTokenBalance = token.balanceOf(address(this));
        
        require(contractTokenBalance > realAmountTokens, "unsufficient funds");
      
       
        
        //ensure we revert in case of failure 
        try token.transfer(to_wallet, realAmountTokens) { 
            //just continue if all good..
        } catch {
            require(false,"tokens transfer failed");
           
        }
        
    
        // all done..
        emit TokensWithdrawn(amount_tokens, to_wallet);
    }
    
    
    /**
    * @dev service function to check tokens on wallet and allowance of wallet
    */
    function walletTokenBalance(address wallet) external view returns(uint256){
        return token.balanceOf(wallet);
    }
    
    /**
    * @dev service function to check allowance of wallet for tokens
    */
    function walletTokenAllowance(address wallet) external view returns (uint256){
        return  token.allowance(wallet, address(this)); 
    }
    
    
    /**
    * @dev not bullet-proof check, but additional measure, not to allow buy & sell from contracts
    */
    function isContract(address _addr) internal view returns (bool){
      uint32 size;
      assembly {
          size := extcodesize(_addr)
      }
      
      return (size > 0);
    }
    
    modifier notContract(){
      require(
          (!isContract(msg.sender)),
          "external contracts are not allowed"
          );
          _;
    }
}