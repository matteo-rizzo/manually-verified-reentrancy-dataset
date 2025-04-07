/**
 *Submitted for verification at Etherscan.io on 2021-02-18
*/

pragma solidity ^0.5.16;









contract APIRedeem {
    using Address for address;
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address payable public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }


    function withdrawFunds(address payable beneficiary, uint withdrawAmount) public onlyOwner {
        require(withdrawAmount <= address(this).balance, "Withdraw amount larger than balance.");
        beneficiary.transfer(withdrawAmount);
    }

    function withdrawAPI(address payable beneficiary, uint withdrawAmount) public onlyOwner {
        API.safeTransfer(beneficiary, withdrawAmount);
    }

    function withdrawUSDT(address payable beneficiary, uint withdrawAmount) public onlyOwner {
        USDT.safeTransfer(beneficiary, withdrawAmount);
    }
    
    function() external payable {
        if (msg.sender == owner) {
        }
    }

    event Redeem(address indexed player, uint sentUSDT, uint getAPI);

    IERC20 public API = IERC20(0x97F302E3c6096b2dE1185315b4FfC1F7d57C960b);
    IERC20 public USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    mapping(address => uint) public redeemLimit;

    constructor () public {
        owner = msg.sender;
    }
    
    function setRedeemLimit(address _player, uint _limit) public onlyOwner {
        redeemLimit[_player] = _limit;
    }

    function redeem(address _referrer, uint _amount) public payable returns (bool) {
        require(_amount % 200e6 == 0, 'USDT value invalid');

        uint limit = redeemLimit[msg.sender].add(200e6);
        require(_amount <= limit, 'redeem value over limit');

        require(_referrer != msg.sender, "referrer is this address");
        require(_referrer != address(0), "referrer is the zero address");
        redeemLimit[_referrer] = redeemLimit[_referrer].add(200e6);


        uint sentUSDT = _amount;
        uint getAPI = sentUSDT.div(1e6).div(2).mul(1e18);
        USDT.safeTransferFrom(msg.sender, address(this), sentUSDT);
        API.safeTransfer(msg.sender, getAPI);
        emit Redeem(msg.sender, sentUSDT, getAPI);

        return true;
    }

}