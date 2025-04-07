pragma solidity ^0.4.18;






contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Distributor is Owned {

    using SafeMath for uint256;

    ERC20 public token;
    uint256 public eligibleTokens;
    mapping(address => uint256) public distributed;
    uint256 public totalDistributionAmountInWei;

    event Dividend(address holder, uint256 amountDistributed);

    function Distributor(address _targetToken, uint256 _eligibleTokens) public payable {
        require(msg.value > 0);

        token = ERC20(_targetToken);
        assert(_eligibleTokens <= token.totalSupply());
        eligibleTokens = _eligibleTokens;
        totalDistributionAmountInWei = msg.value;
    }

    function percent(uint numerator, uint denominator, uint precision) internal pure returns (uint quotient) {
        uint _numerator = numerator * 10 ** (precision + 1);
        quotient = ((_numerator / denominator) + 5) / 10;
    }

    function distribute(address holder) public onlyOwner returns (uint256 amountDistributed) {
        require(distributed[holder] == 0);

        uint256 holderBalance = token.balanceOf(holder);
        uint256 portion = percent(holderBalance, eligibleTokens, uint256(4));
        amountDistributed = totalDistributionAmountInWei.mul(portion).div(10000);

        distributed[holder] = amountDistributed;
        Dividend(holder, amountDistributed);
        holder.transfer(amountDistributed);
    }


}