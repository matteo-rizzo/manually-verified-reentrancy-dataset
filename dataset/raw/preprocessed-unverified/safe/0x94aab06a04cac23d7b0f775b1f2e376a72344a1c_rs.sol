pragma solidity 0.4.21;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */






contract Airdrop is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 public cap;
    uint256 public individualCap;
    uint256 public totalAlloctedToken;
    mapping (address => uint256) airdropContribution;

    function Airdrop(
        IERC20 _tokenAddr,
        uint256 _cap,
        uint256 _individualCap
    )
        public
    {
        token = _tokenAddr;
        cap = _cap;
        individualCap = _individualCap;
    }

    function drop(address[] _recipients, uint256[] _amount) 
        external 
        onlyOwner returns (bool) 
    {
        require(_recipients.length == _amount.length);
        
        for (uint i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            require(individualCap >= airdropContribution[_recipients[i]].add(_amount[i]));
            require(cap >= totalAlloctedToken.add(_amount[i]));
            airdropContribution[_recipients[i]] = airdropContribution[_recipients[i]].add(_amount[i]);
            totalAlloctedToken = totalAlloctedToken.add(_amount[i]);
            token.transfer(_recipients[i], _amount[i]);
        }
        return true;
    }
}