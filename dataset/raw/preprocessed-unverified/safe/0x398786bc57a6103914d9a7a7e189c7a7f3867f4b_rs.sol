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





contract SKYFReserveFund is Ownable{

    uint256 public constant startTime = 1534334400;

    uint256 public constant firstYearEnd = startTime + 365 days;

    

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

        require(now > firstYearEnd);



        token.transfer(_to, _value);



    }

}