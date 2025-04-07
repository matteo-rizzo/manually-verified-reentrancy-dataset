/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

/**
 *Submitted for verification at Etherscan.io on 2020-04-22
*/

pragma solidity ^0.5.0;



contract IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
    function mint(address account, uint256 amount) public returns (bool);
    function burn(uint256 amount) public returns (bool);
}


contract MultiCoinVault is Ownable {
    address private daricDXAUAddress;
    address public messenger;
    uint public fees;
    address payable public feesAddress;
    struct Pair{
        uint price;
        string tokenName;
        string tokenSymbol;
        string market;
        address tokenContract;
        uint decimal;
        uint liquidity;
    }
    mapping(bytes => Pair) pairs;
    using SafeMath for uint256;

    constructor(
        address _daricDXAUAddress,
        uint _fees,
        address payable  _feesAddress
    ) public {
        daricDXAUAddress = _daricDXAUAddress;
        fees = _fees;
        feesAddress = _feesAddress;
    }

    event generated(
        address _generator,
        uint256 _amount,
        uint256 _amountGenerated,
        uint256 _fees,
        uint256 _price,
        string ticker,
        string _market
    );
 
    event pairAdded(string market, string tokenName, string tokenSymbol, address tokenContract,  uint price, uint decimal, uint liquidity);
    event pairDeleted(string _market);
    event priceChanged(address initiator, uint256 _from, uint256 _to , string market); 
    event liquidityChanged(address initiator, uint256 _from, uint256 _to, string market);
    event contractChanged(address initiator, address _from, address _to, string _market);
    event messengerChanged(address _from, address _to);
    modifier onlyMessenger() {
        require(msg.sender == messenger, "caller is not a messenger");
        _;
    }

    function addPair(string memory _market, string memory _tokenName, 
    string memory _tokenSymbol, address  _tokenContract, uint _price, uint _decimal, uint _liquidity) onlyOwner public returns (bool) {
        bytes memory key = bytes(_market);
         if (pairs[key].tokenContract != address(0)) {
             // Don't overwrite previous mappings and return false
             return false;
         }
        Pair storage pair = pairs[key];
        pair.market = _market;
        pair.tokenName = _tokenName;
        pair.tokenSymbol = _tokenSymbol;
        pair.tokenContract = _tokenContract;
        pair.price = _price;
        pair.decimal = _decimal;
        pair.liquidity = _liquidity;
        emit pairAdded(_market, _tokenName, _tokenSymbol, _tokenContract, _price, _decimal, _liquidity);
        return true;
    }
    
    function deletePair(string memory _market) onlyOwner public returns(bool){
       bytes memory key = bytes(_market);
        require(pairs[key].tokenContract != address(0), "No token found");
        
        delete pairs[key];
        emit pairDeleted(_market);
        return true;
    }

    function getPairInfo(string memory _market) public view returns (address _tokenContract, string memory _tokenName, string memory _tokenSymbol, uint _price, string memory market, uint _decimal, uint _liquidity) {
        bytes memory convertedMarket = bytes(_market);
        Pair memory pair = pairs[convertedMarket];
        return (pair.tokenContract, pair.tokenName, pair.tokenSymbol, pair.price, pair.market, pair.decimal, pair.liquidity);
    }
    
    function generate(string memory _market, uint _tokenvalueInWei) public returns(bool){
        require(_tokenvalueInWei > 0, "Amount should be greater than zero");
        bytes memory convertedMarket = bytes(_market);
        Pair storage pair = pairs[convertedMarket];
        require(pair.tokenContract != address(0), "Invalid market");
        IERC20 daricDXAU = IERC20(daricDXAUAddress);
        IERC20 genericCoin = IERC20(pair.tokenContract);
        uint _generate = pair.price.mul(_tokenvalueInWei);
        uint fee = uint(int256(_generate) / int256(10000) * int256(fees));
        uint finalGen = _generate.sub(fee).div(10 ** pair.decimal);
        uint finalFees = fee.div(10 ** pair.decimal);
        require(finalGen.add(finalFees) <= pair.liquidity, "Non-sufficient liquidity");
        pair.liquidity = pair.liquidity.sub(finalGen.add(finalFees));
        require(genericCoin.allowance(msg.sender, address(this)) >= _tokenvalueInWei, "Non-sufficient funds");
        require(genericCoin.transferFrom(msg.sender, address(this), _tokenvalueInWei), "Fail to tranfer fund");
        require(daricDXAU.mint(msg.sender, finalGen), "Fail to generate fund");
        require(daricDXAU.mint(feesAddress, finalFees), "Fail to send fees");
        emit generated(msg.sender, _tokenvalueInWei, finalGen, finalFees, pair.price, pair.tokenSymbol, pair.market);
        return true;
    }
    
    function generateETH(string memory _market) payable public returns(bool){
        uint _tokenvalueInWei = msg.value;
        require(_tokenvalueInWei > 0, "Amount should be greater than zero");
        bytes memory convertedMarket = bytes(_market);
        Pair storage pair = pairs[convertedMarket];
        require(pair.tokenContract != address(0), "Invalid market");
        IERC20 daricDXAU = IERC20(daricDXAUAddress);
        uint _generate = pair.price.mul(_tokenvalueInWei);
        uint fee = uint(int256(_generate) / int256(10000) * int256(fees));
        uint finalGen = _generate.sub(fee).div(10 ** pair.decimal);
        uint finalFees = fee.div(10 ** pair.decimal);
        require(finalGen.add(finalFees) <= pair.liquidity, "Non-sufficient liquidity");
        pair.liquidity = pair.liquidity.sub(finalGen.add(finalFees));
        require(daricDXAU.mint(msg.sender, finalGen), "Fail to generate fund");
        require(daricDXAU.mint(feesAddress, finalFees), "Fail to send fees");
        emit generated(msg.sender, _tokenvalueInWei, finalGen, finalFees, pair.price, pair.tokenSymbol, pair.market);
        return true;
    }
    
    function redeem(string memory _market, uint _tokenvalueInWei) public returns(bool){
        require(_tokenvalueInWei > 0, "Amount should be greater than zero");
        bytes memory convertedMarket = bytes(_market);
        Pair memory pair = pairs[convertedMarket];
        require(pair.tokenContract != address(0), "Invalid market");
        IERC20 daricDXAU = IERC20(daricDXAUAddress);
        IERC20 genericCoin = IERC20(pair.tokenContract);
        uint _redeem = (_tokenvalueInWei * 10**18).div(pair.price);
        uint fee = uint(int256(_redeem) / int256(10000) * int256(fees));
        uint finalRed = _redeem.sub(fee);
        require(daricDXAU.allowance(msg.sender, address(this)) >= _tokenvalueInWei, "Please create allowance");
        require(genericCoin.balanceOf(address(this)) >= _redeem, "Insufficient vault balance");
        require(genericCoin.transfer(msg.sender, finalRed), "Fail to generate fund");
        require(genericCoin.transfer(feesAddress, fee), "Fail to generate fund");
        require(daricDXAU.transferFrom(msg.sender, address(this), _tokenvalueInWei), "Fail to send fund");
        emit generated(msg.sender, _tokenvalueInWei, finalRed, fee, pair.price, "DXAU", _market);
        return true;
        
    }
    
    function redeemETH(string memory _market, uint _tokenvalueInWei) public returns(bool){
        require(_tokenvalueInWei > 0, "Amount should be greater than zero");
        bytes memory convertedMarket = bytes(_market);
        Pair memory pair = pairs[convertedMarket];
        require(pair.tokenContract != address(0), "Invalid market");
        IERC20 daricDXAU = IERC20(daricDXAUAddress);
        uint _redeem = (_tokenvalueInWei * 10**18).div(pair.price);
        uint fee = uint(int256(_redeem) / int256(10000) * int256(fees));
        uint finalRed = _redeem.sub(fee);
        require(daricDXAU.allowance(msg.sender, address(this)) >= _tokenvalueInWei, "Please create allowance");
        require(address(this).balance >= _redeem, "Insufficient vault balance");
        msg.sender.transfer(finalRed);
        feesAddress.transfer(fee);
        require(daricDXAU.transferFrom(msg.sender, address(this), _tokenvalueInWei), "Fail to send fund");
        emit generated(msg.sender, _tokenvalueInWei, finalRed, fee, pair.price, "DXAU", _market);
        return true;
        
    }
    
      function setMessenger(address _messenger) public onlyOwner {
        address currentMessenger = messenger;
        messenger = _messenger;
        emit messengerChanged(currentMessenger, _messenger);
    }
    
    function getPrice(string memory _market) public view returns (uint256 _price) {
     bytes memory convertedMarket = bytes(_market);
     Pair memory pair = pairs[convertedMarket];
     return pair.price;
    }

    function getLiquity(string memory _market) public view returns (uint256 _liquidity) {
     bytes memory convertedMarket = bytes(_market);
     Pair memory pair = pairs[convertedMarket];
     return pair.liquidity;
    }
    
    
    function setdaricDXAU(address _daricDXAUAddress) public onlyOwner{
     daricDXAUAddress = _daricDXAUAddress;
    }
    
     function setfess(uint _fee) public onlyOwner{
     fees = _fee;
    }
    
    function setFeesAddress(address payable  _feesAddress) public onlyOwner{
     feesAddress = _feesAddress;
    }
    
    
     function getCoinAddresses() public view returns (address _daricDXAUAddress) {
        return(daricDXAUAddress);
    }


function updatePrice(string memory _market, uint256 _price) public onlyMessenger{
    bytes memory convertedMarket = bytes(_market);
    Pair storage pair = pairs[convertedMarket];
    require(pair.tokenContract != address(0), "Invalid market");
    uint256 currentprice = pair.price;
    pair.price = _price;
    emit priceChanged(msg.sender, currentprice, _price, _market);
}

function updateLiquidity(string memory _market, uint256 _amount) public onlyOwner{
    bytes memory convertedMarket = bytes(_market);
    Pair storage pair = pairs[convertedMarket];
    require(pair.tokenContract != address(0), "Invalid market");
    uint256 currentLiquidity = pair.liquidity;
    pair.liquidity = _amount;
    emit liquidityChanged(msg.sender, currentLiquidity, _amount, _market);
}

function updateContract(string memory _market, address _contract) public onlyMessenger{
    bytes memory convertedMarket = bytes(_market);
    Pair storage pair = pairs[convertedMarket];
    require(pair.tokenContract != address(0), "Invalid market");
    address currentContract = pair.tokenContract;
    pair.tokenContract = _contract;
    emit contractChanged(msg.sender, currentContract, _contract, _market);
}

function burn() public onlyOwner{
    IERC20 daricDXAU = IERC20(daricDXAUAddress);
    require(daricDXAU.burn(daricDXAU.balanceOf(address(this))), "Fail to empty vault");
}

}