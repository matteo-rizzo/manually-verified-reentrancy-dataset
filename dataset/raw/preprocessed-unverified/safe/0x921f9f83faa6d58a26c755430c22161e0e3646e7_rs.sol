/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity ^0.4.24;



// File: contracts/deps/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: contracts/deps/IERC20.sol







// File: contracts/deps/SafeERC20.sol







// File: contracts/deps/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/IPCToken.sol



contract IPCToken is IERC20, Ownable {



    string public name = "Iranian Phoenix Coin";

    uint8 public decimals = 18;





    string public symbol = "IPC";



    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;





    constructor() public {}



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }





    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }





    function allowance(

        address owner,

        address spender

    )

    public

    view

    returns (uint256)

    {

        return _allowed[owner][spender];

    }





    function transfer(address to, uint256 value) public returns (bool) {

        require(value <= _balances[msg.sender]);

        require(to != address(0));



        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;

    }





    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }





    function transferFrom(

        address from,

        address to,

        uint256 value

    )

    public onlyOwner

    returns (bool)

    {

        require(value <= _balances[from]);

        require(value <= _allowed[from][msg.sender]);

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;

    }





    function increaseAllowance(

        address spender,

        uint256 addedValue

    )

    public

    returns (bool)

    {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }







    function decreaseAllowance(

        address spender,

        uint256 subtractedValue

    )

    public

    returns (bool)

    {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }





    function _mint(address account, uint256 amount) external onlyOwner {

        require(account != 0);

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }



    function _burn(address account, uint256 amount) internal {

        require(account != 0);

        require(amount <= _balances[account]);



        _totalSupply = _totalSupply.sub(amount);

        _balances[account] = _balances[account].sub(amount);



        emit Transfer(account, address(0), amount);

    }



    function burnFrom(address account, uint256 amount) public onlyOwner {

        require(amount <= _allowed[account][msg.sender]);



        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

            amount);

        _burn(account, amount);

    }

}



// File: contracts/IPCCrowdsale.sol



contract IPCCrowdsale is Ownable {



    using SafeMath for uint;

    using SafeERC20 for IPCToken;





    IPCToken private _token = new IPCToken();



    uint currentPhase = 0;



    uint256  _weiRaised;



    uint8[] phase_bonuses =  [50, 0];



    uint256[] phase_supply_limits = [ 150000 ether, 400000 ether];



    address private _wallet = 0x67E6Efc62635353aE31d16AD844Cc4BDBCaCe53D;



    uint private usd_per_barrel_rate = 55;

    uint private eth_per_usd_rate = 21800 ;





    event TokensPurchased(

        address indexed purchaser,

        address indexed beneficiary,

        uint256 value,

        uint256 amount

    );





    constructor() public {

        transferOwnership(_wallet);

        _token._mint(_wallet, 50000 ether);

    

    }





    function startMainSale() public onlyOwner {

        require(currentPhase == 0);

        currentPhase = 1;

    }





    function() external payable {

        buyTokens(msg.sender);

    }





    function token() public view returns (IERC20) {

        return _token;

    }





    function wallet() public view returns (address) {

        return _wallet;

    }





    function rate() public view returns (uint256) {

        return eth_per_usd_rate.div(usd_per_barrel_rate);

    }



    function setBarrelPrice(uint _price){

        usd_per_barrel_rate =_price;

    }





    function setEtherPrice(uint _price){

        eth_per_usd_rate = _price;

    }





    /**

     * @return the mount of wei raised.

     */

    function weiRaised() public view returns (uint256) {

        return _weiRaised;

    }





    function get_max_supply() public view returns (uint256) {

        return phase_supply_limits[currentPhase];

    }





    function buyTokens(address beneficiary) public payable {



        uint256 weiAmount = msg.value;



        uint256 tokens = _getTokenAmount(weiAmount);

        uint256 bonus = tokens.mul(phase_bonuses[currentPhase]).div(100);

        _weiRaised = _weiRaised.add(weiAmount);

        



        _processPurchase(beneficiary, tokens + bonus);



        require(token().totalSupply() < get_max_supply());



        // emit TokensPurchased(

        //     msg.sender,

        //     beneficiary,

        //     weiAmount,

        //     tokens

        // );





        _forwardFunds();

    }









    function _deliverTokens(

        address beneficiary,

        uint256 tokenAmount

    )

    internal

    {

        _token._mint(beneficiary, tokenAmount);

    }





    function _processPurchase(

        address beneficiary,

        uint256 tokenAmount

    )

    internal

    {

        _deliverTokens(beneficiary, tokenAmount);

    }



    function _getTokenAmount(uint256 weiAmount)

    internal view returns (uint256)

    {

        return weiAmount.mul(rate()).div(100);

    }



    function _forwardFunds() internal {

        _wallet.transfer(msg.value);

    }

}