pragma solidity ^0.4.24;

/**

 * @title SafeMath v0.1.9

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr 

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */

 





/*

 * ERC20 interface

 * see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf( address who ) public view returns (uint value);

    function allowance( address owner, address spender ) public view returns (uint _allowance);



    function transfer( address to, uint value) public returns (bool ok);

    function transferFrom( address from, address to, uint value) public returns (bool ok);

    function approve( address spender, uint value ) public returns (bool ok);



    event Transfer( address indexed from, address indexed to, uint value);

    event Approval( address indexed owner, address indexed spender, uint value);

}

/*

 * contract : Ownable

 */

 

/*

 * Pausable contract

 */



contract Pausable is Ownable {

    event Pause();

    event Unpause();



    bool public paused = false;



    modifier whenNotPaused() {

        require(!paused);

        _;

    }



    modifier whenPaused {

        require(paused);

        _;

    }



    function pause() onlyOwner whenNotPaused public returns (bool) {

        paused = true;

        emit Pause();

        return true;

    }



    function unpause() onlyOwner whenPaused public returns (bool) {

        paused = false;

        emit Unpause();

        return true;

    }

}

/**

 contract : NTechToken

 */

contract NTechToken is ERC20, Ownable, Pausable{

    /**

     代币基本信息

     */

    string public                   name = "NTech";

    string public                   symbol = "NT";

    uint8 constant public           decimals = 18;

    uint256                         supply;



    mapping (address => uint256)                        balances;

    mapping (address => mapping (address => uint256))   approvals;

    uint256 public constant initSupply = 10000000000;       // 10,000,000,000



    constructor() public {

        supply = SafeMath.mul(uint256(initSupply),uint256(10)**uint256(decimals));

        balances[msg.sender] = supply; 

    }

    // ERC 20

    function totalSupply() public view returns (uint256){

        return supply ;

    }



    function balanceOf(address src) public view returns (uint256) {

        return balances[src];

    }



    function allowance(address src, address guy) public view returns (uint256) {

        return approvals[src][guy];

    }

    

    function transfer(address dst, uint wad) whenNotPaused public returns (bool) {

        require(balances[msg.sender] >= wad);                   // 要有足够余额

        require(dst != 0x0);                                    // 不能送到无效地址



        balances[msg.sender] = SafeMath.sub(balances[msg.sender], wad);  // -    

        balances[dst] = SafeMath.add(balances[dst], wad);                // +

        

        emit Transfer(msg.sender, dst, wad);                    // 记录事件

        

        return true;

    }



    function transferFrom(address src, address dst, uint wad) whenNotPaused public returns (bool) {

        require(balances[src] >= wad);                          // 要有足够余额

        require(approvals[src][msg.sender] >= wad);

        

        approvals[src][msg.sender] = SafeMath.sub(approvals[src][msg.sender], wad);

        balances[src] = SafeMath.sub(balances[src], wad);

        balances[dst] = SafeMath.add(balances[dst], wad);

        

        emit Transfer(src, dst, wad);

        

        return true;

    }

    

    function approve(address guy, uint256 wad) whenNotPaused public returns (bool) {

        require(wad != 0);

        approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;

    }



    

}