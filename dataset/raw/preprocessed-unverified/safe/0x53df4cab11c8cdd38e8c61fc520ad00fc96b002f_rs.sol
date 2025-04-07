/**

 *Submitted for verification at Etherscan.io on 2019-05-07

*/



pragma solidity ^0.4.23;











contract ERC20 {





    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);



    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}











contract BasicToken is ERC20 {

    



    using Math for uint256;

    

    event Burn(address indexed burner, uint256 value);



    uint256 totalSupply_;

    mapping(address => uint256) balances_;

    mapping (address => mapping (address => uint256)) internal allowed_;    



    function totalSupply() public view returns (uint256) {

        

        return totalSupply_;

    }



    function transfer(address to, uint256 value) public returns (bool) {



        require(to != address(0));

        require(value <= balances_[msg.sender]);



        balances_[msg.sender] = balances_[msg.sender].sub(value);

        balances_[to] = balances_[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;

    }



    function balanceOf(address owner) public view returns (uint256 balance) {



        return balances_[owner];

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {



        require(to != address(0));

        require(value <= balances_[from]);

        require(value <= allowed_[from][msg.sender]);



        balances_[from] = balances_[from].sub(value);

        balances_[to] = balances_[to].add(value);

        allowed_[from][msg.sender] = allowed_[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;

    }



    function approve(address spender, uint256 value) public returns (bool) {

        

        allowed_[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    function allowance(address owner, address spender) public view returns (uint256) {

        

        return allowed_[owner][spender];

    }



    function burn(uint256 value) public {



        require(value <= balances_[msg.sender]);

        address burner = msg.sender;

        balances_[burner] = balances_[burner].sub(value);

        totalSupply_ = totalSupply_.sub(value);

        emit Burn(burner, value);

    }    

}







contract TUNEToken is BasicToken, Ownable {



    

    using Math for uint;



    string constant public name     = "TUNEToken";

    string constant public symbol   = "TUNE";

    uint8 constant public decimals  = 18;

    uint256 constant TOTAL_SUPPLY   = 1000000000e18;



    address constant comany = 0x70745487A80e21ec7ba9aad971d13aBb8a3d8104;

    

    constructor() public {



        totalSupply_ = TOTAL_SUPPLY;

        allowTo(comany, totalSupply_);

    }



    function allowTo(address addr, uint amount) internal returns (bool) {

        

        balances_[addr] = amount;

        emit Transfer(address(0x0), addr, amount);

        return true;

    }



    function transfer(address to, uint256 value) public returns (bool) {



        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {



        return super.transferFrom(from, to, value);

    }



    function withdrawTokens(address tokenContract) external onlyOwner {

        

        TUNEToken tc = TUNEToken(tokenContract);

        tc.transfer(owner_, tc.balanceOf(this));

    }



    function withdrawEther() external onlyOwner {



        owner_.transfer(address(this).balance);

    }

}