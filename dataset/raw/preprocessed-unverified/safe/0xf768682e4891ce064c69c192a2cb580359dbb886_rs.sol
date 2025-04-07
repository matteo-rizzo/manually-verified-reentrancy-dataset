pragma solidity ^0.4.21;

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
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




contract TOSInstitutionsIncentiveContract {
    using SafeERC20 for ERC20;
    using SafeMath for uint;
    string public constant name = "TOSInstitutionsIncentiveContract";


    uint256 public constant RELEASE_START               = 1541347200; //2018/11/5 0:0:0
    uint256 public constant RELEASE_INTERVAL            = 30 days; // 30 days
    address public constant beneficiary = 0x34F7747e0A4375FC6A0F22c3799335E9bE3A18fF;
    ERC20 public constant tosToken = ERC20(0xFb5a551374B656C6e39787B1D3A03fEAb7f3a98E);
    

    uint[6] public releasePercentages = [
        15,  //15%
        35,   //20%
        50,   //15%
        65,   //15%
        80,   //15%
        100   //20%
    ];


    uint256 public released = 0;
    uint256 public totalLockAmount = 0; 
    function TOSInstitutionsIncentiveContract() public {}

    function release() public {

        uint256 num = now.sub(RELEASE_START).div(RELEASE_INTERVAL);
        if (totalLockAmount == 0) {
            totalLockAmount = tosToken.balanceOf(this);
        }

        if (num >= releasePercentages.length.sub(1)) {
            tosToken.safeTransfer(beneficiary, tosToken.balanceOf(this));
            released = 100;
        }
        else {
            uint256 releaseAmount = totalLockAmount.mul(releasePercentages[num].sub(released)).div(100);
            tosToken.safeTransfer(beneficiary, releaseAmount);
            released = releasePercentages[num];
        }
    }
}