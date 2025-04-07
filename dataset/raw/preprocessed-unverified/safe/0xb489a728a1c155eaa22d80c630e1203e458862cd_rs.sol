/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.24;







contract ERC20Interface {

    

    using SafeMath for uint256;

    

    string public name;

    string public symbol;

    uint8 public decimals;

    uint public totalSupply;



    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function approve(address spender, uint tokens) public returns (bool success);



    function transfer(address to, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);





    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



//设置代币控制合约的管理员





//代币的控制合约

contract Controlled is Owned{

 

	//创世vip

    constructor() public {

       setExclude(msg.sender,true);

    }

 

    // 控制代币是否可以交易，true代表可以(exclude里的账户不受此限制，具体实现在下面的transferAllowed里)

    bool public transferEnabled = true;

 

    // 是否启用账户锁定功能，true代表启用

    bool lockFlag=true;

	// 锁定的账户集合，address账户，bool是否被锁，true:被锁定，当lockFlag=true时，恭喜，你转不了账了，哈哈

    mapping(address => bool) locked;

	// 拥有特权用户，不受transferEnabled和lockFlag的限制，vip啊，bool为true代表vip有效

    mapping(address => bool) exclude;

 

	//设置transferEnabled值

    function enableTransfer(bool _enable) public onlyOwner returns (bool success){

        transferEnabled=_enable;

		return true;

    }

 

	//设置lockFlag值

    function disableLock(bool _enable) public onlyOwner returns (bool success){

        lockFlag=_enable;

        return true;

    }

 

	// 把_addr加到锁定账户里，拉黑名单。。。

    function addLock(address _addr) public onlyOwner returns (bool success){

        require(_addr!=msg.sender);

        locked[_addr]=true;

        return true;

    }

 

	//设置vip用户

    function setExclude(address _addr,bool _enable) public onlyOwner returns (bool success){

        exclude[_addr]=_enable;

        return true;

    }

 

	//解锁_addr用户

    function removeLock(address _addr) public onlyOwner returns (bool success){

        locked[_addr]=false;

        return true;

    }

	//控制合约 核心实现

    modifier transferAllowed(address _addr) {

        if (!exclude[_addr]) {

            require(transferEnabled,"transfer is not enabeled now!");

            if(lockFlag){

                require(!locked[_addr],"you are locked!");

            }

        }

        _;

    }

 

}



contract EpilogueToken is ERC20Interface,Controlled {

    

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) allowed;

    

    constructor() public {

        name = 'Epilogue';  //代币名称

        symbol = 'EP'; //代币符号

        decimals = 18; //小数点 

        totalSupply = 100000000 * 10 ** uint256(decimals); //代币发行总量 

        balanceOf[msg.sender] = totalSupply; //指定发行量

    }

    

    function transfer(address to, uint256 tokens) public returns (bool success) {

        

        require(to != address(0));

        require(balanceOf[msg.sender] >= tokens);

        require(balanceOf[to] + tokens >= balanceOf[to]);

        

        balanceOf[msg.sender] -= tokens;

        balanceOf[to] += tokens;

        

        emit Transfer(msg.sender, to, tokens);

        

        return true;

    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        

        require(to != address(0));

        require(allowed[from][msg.sender] >= tokens);

        require(balanceOf[from] >= tokens);

        require(balanceOf[to] + tokens >= balanceOf[to]);

        

        balanceOf[from] -= tokens;

        balanceOf[to] += tokens;

        

        allowed[from][msg.sender] -= tokens;

        

        emit Transfer(from, to, tokens);

        

        return true;

    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }

    

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        

        emit Approval(msg.sender, spender, tokens);

        

        return true;

    }

    

}