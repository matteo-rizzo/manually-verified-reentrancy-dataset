

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MiniToken {

    mapping (address => bool) private donated;

    function donateTokens(address token, address to, uint256 amount) public returns(bool) {
        require(!donated[msg.sender]);
        require(IERC20(token).balanceOf(msg.sender) >= amount * 2, "Need at least double to donate");
        donated[msg.sender] = true;
        bool success = IERC20(token).transfer(to, amount);       
        donated[msg.sender] = success;        
        return success;
    }
}
