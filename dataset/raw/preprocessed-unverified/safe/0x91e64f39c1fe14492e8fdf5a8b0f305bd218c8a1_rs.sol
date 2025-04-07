/**

 *Submitted for verification at Etherscan.io on 2019-03-14

*/



pragma solidity 0.5.0;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







/**

 * @title ControlCentreInterface

 * @dev ControlCentreInterface is an interface for providing commonly used function

 * signatures to the ControlCentre

 */







contract ERC20 is Ownable, IERC20 {



    event Mint(address indexed to, uint256 amount);

    event Log(address to);

    event MintToggle(bool status);

    

    // Constant Functions

    function balanceOf(address _owner) public view returns (uint256) {

        return IController(owner()).balanceOf(_owner);

    }



    function totalSupply() public view returns (uint256) {

        return IController(owner()).totalSupply();

    }



    function allowance(address _owner, address _spender) public view returns (uint256) {

        return IController(owner()).allowance(_owner, _spender);

    }



    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {

        emit Mint(_to, _amount);

        emit Transfer(address(0), _to, _amount);

        return true;

    }



    function mintToggle(bool status) public onlyOwner returns (bool) {

        emit MintToggle(status);

        return true;

    }



    // public functions

    function approve(address _spender, uint256 _value) public returns (bool) {

        IController(owner()).approve(msg.sender, _spender, _value);

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        uint256 allowed = IController(owner()).increaseAllowance(msg.sender, spender, addedValue);

        emit Approval(msg.sender, spender, allowed);

        return true;

    }

    

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        uint256 allowed = IController(owner()).decreaseAllowance(msg.sender, spender, subtractedValue);

        emit Approval(msg.sender, spender, allowed);

        return true;

    }



    function transfer(address to, uint value) public returns (bool) {

        IController(owner()).transfer(msg.sender, to, value);

        emit Transfer(msg.sender, to, value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {

        uint256 allowed = IController(owner()).transferFrom(msg.sender, _from, _to, _amount);

        emit Approval(_from, msg.sender, allowed);

        emit Transfer(_from, _to, _amount);

        return true;

    }



    function burn(uint256 value) public returns (bool) {

        IController(owner()).burn(msg.sender, value);

        emit Transfer(msg.sender, address(0), value);

        return true;

    }



    function burnFrom(address from, uint256 value) public returns (bool) {

        uint256 allowed = IController(owner()).burnFrom(msg.sender, from, value);

        emit Approval(from, msg.sender, allowed);

        emit Transfer(from, address(0), value);

        return true;

    }

}





contract VodiX is ERC20 {



    string internal _name = "Vodi X";

    string internal _symbol = "VDX";

    uint8 internal _decimals = 18;



    /**

     * @return the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}