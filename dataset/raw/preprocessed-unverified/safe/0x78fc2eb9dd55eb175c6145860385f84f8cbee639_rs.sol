pragma solidity 0.6.12;





abstract contract LamdenTau  {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);

}

contract TAUSwap is Ownable {
    using SafeMath for uint256;

    LamdenTau tau = LamdenTau(0xc27A2F05fa577a83BA0fDb4c38443c0718356501);
    mapping(address => uint256) swappedBalances;

    event Swap(address sender, string receiver, uint256 value);

    function swap(string memory mainnetAddress, uint256 amount) public {
        tau.transferFrom(msg.sender, address(this), amount);

        swappedBalances[msg.sender] = swappedBalances[msg.sender].add(amount);

        emit Swap(msg.sender, mainnetAddress, amount);
    }

    function sweep(address owner, uint256 amount) public onlyOwner {
        if (amount == 0) {
            amount = swappedBalances[owner];
        }

        swappedBalances[owner] = swappedBalances[owner].sub(amount);
        tau.transfer(address(0x0), amount);
    }

    function tauRevert(address owner, uint256 amount) public onlyOwner {
        swappedBalances[owner] = swappedBalances[owner].sub(amount);
        tau.transfer(owner, amount);
    }
}