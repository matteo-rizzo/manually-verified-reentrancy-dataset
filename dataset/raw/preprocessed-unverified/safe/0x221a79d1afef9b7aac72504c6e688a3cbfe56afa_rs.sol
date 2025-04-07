/**

 *Submitted for verification at Etherscan.io on 2019-05-21

*/



pragma solidity 0.5.8;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */







/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract sellTokens is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 public token;





    uint256 public rate;





    constructor(uint256 _rate, address _token) public {

        require(_token != address(0) );



        token = IERC20(_token);

        rate = _rate;

    }





    function() payable external {

        buyTokens();

    }





    function buyTokens() payable public {

        uint256 weiAmount = msg.value;

        _preValidatePurchase(msg.sender, weiAmount);



        uint256 tokens = _getTokenAmount(weiAmount);



        if (tokens > token.balanceOf(address(this))) {

            tokens = token.balanceOf(address(this));



            uint price = tokens.div(rate);



            uint _diff =  weiAmount.sub(price);



            if (_diff > 0) {

                msg.sender.transfer(_diff);

            }

        }



        _processPurchase(msg.sender, tokens);

    }





    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {

        require(token.balanceOf(address(this)) > 0);

        require(_beneficiary != address(0));

        require(_weiAmount != 0);

    }





    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {

        return _weiAmount.mul(rate);

    }





    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

        token.safeTransfer(_beneficiary, _tokenAmount);

    }





    function setRate(uint256 _rate) onlyOwner external {

        rate = _rate;

    }





    function withdrawETH() onlyOwner external{

        owner.transfer(address(this).balance);

    }



    

    function withdrawTokens(address _t) onlyOwner external {

        IERC20 _token = IERC20(_t);

        uint balance = _token.balanceOf(address(this));

        _token.safeTransfer(owner, balance);

    }



}





contract ReentrancyGuard {



    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor() internal {

        // The counter starts at one to prevent changing it from zero to a non-zero

        // value, which is a more expensive operation.

        _guardCounter = 1;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter);

    }



}





contract buyTokens is Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 public token;



    uint256 public rate;



    constructor(uint256 _rate, address _token) public {

        require(_token != address(0) );



        token = IERC20(_token);

        rate = _rate;

    }





    function() external payable{

    }





    function sellToken(uint _amount) public {

        _sellTokens(msg.sender, _amount);

    }





    function _sellTokens(address payable _from, uint256 _amount) nonReentrant  internal {

        require(_amount > 0);

        token.safeTransferFrom(_from, address(this), _amount);



        uint256 tokensAmount = _amount;



        uint weiAmount = tokensAmount.div(rate);



        if (weiAmount > address(this).balance) {

            tokensAmount = address(this).balance.mul(rate);

            weiAmount = address(this).balance;



            uint _diff =  _amount.sub(tokensAmount);



            if (_diff > 0) {

                token.safeTransfer(_from, _diff);

            }

        }



        _from.transfer(weiAmount);

    }





    function receiveApproval(address payable _from, uint256 _value, address _token, bytes memory _extraData) public {

        require(_token == address(token));

        require(msg.sender == address(token));



        _extraData;

        _sellTokens(_from, _value);

    }





    function setRate(uint256 _rate) onlyOwner external {

        rate = _rate;

    }





    function withdrawETH() onlyOwner external{

        owner.transfer(address(this).balance);

    }





    function withdrawTokens(address _t) onlyOwner external {

        IERC20 _token = IERC20(_t);

        uint balance = _token.balanceOf(address(this));

        _token.safeTransfer(owner, balance);

    }



}