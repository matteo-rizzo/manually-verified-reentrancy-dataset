pragma solidity 0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */









/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract SKYFTokenInterface {

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

}





contract SKYFNetworkDevelopmentFund is Ownable{

    using SafeMath for uint256;



    uint256 public constant startTime = 1534334400;

    uint256 public constant firstYearEnd = startTime + 365 days;

    uint256 public constant secondYearEnd = firstYearEnd + 365 days;

    

    uint256 public initialSupply;

    SKYFTokenInterface public token;



    function setToken(address _token) public onlyOwner returns (bool) {

        require(_token != address(0));

        if (token == address(0)) {

            token = SKYFTokenInterface(_token);

            return true;

        }

        return false;

    }



    function transfer(address _to, uint256 _value) public onlyOwner returns (bool) {

        uint256 balance = token.balanceOf(this);

        if (initialSupply == 0) {

            initialSupply = balance;

        }

        

        if (now < firstYearEnd) {

            require(balance.sub(_value).mul(2) >= initialSupply); //no less than 50%(1/2) should be left on account after first year

        } else if (now < secondYearEnd) {

            require(balance.sub(_value).mul(20) >= initialSupply.mul(3)); //no less than 15%(3/20) should be left on account after second year

        }



        token.transfer(_to, _value);



    }

}