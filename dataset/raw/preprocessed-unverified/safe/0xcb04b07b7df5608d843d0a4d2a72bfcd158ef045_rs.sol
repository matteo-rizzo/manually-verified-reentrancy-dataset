/**
 *Submitted for verification at Etherscan.io on 2021-02-05
*/

pragma solidity ^0.4.24;
// ----------------------------------------------------------------------------
// @Name SafeMath
// @Desc Math operations with safety checks that throw on error
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// @Name ERC20 interface
// @Desc https://eips.ethereum.org/EIPS/eip-20
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// @Name Ownable
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// @Name AmazonFinanceRewardPool
// @Desc Contract Of Reward For Writing
// ----------------------------------------------------------------------------
contract AmazonFinanceRewardPool is Ownable {
    event eventChangeOwnerAddress(address previousOwner, address newOwner);
    event eventChangeTokenCAEvent(address previousCA, address newCA);
    event eventChangeRewardAmountEvent(uint256 indexed previousAmount, uint256 indexed newAmount);
    event eventFundTransfer(address backer, uint256 amount);
    event eventTokenWithdrawEvent(address withdrawAddress, uint256 amount);
    
    using SafeMath for uint256;

    IERC20 private TOKEN_CONTRACT_ADDRESS;
    address public OWNER_ADDRESS;
    uint256 public REWARD_RATE;
    
    constructor() public {
        TOKEN_CONTRACT_ADDRESS = IERC20(0x0B5aC384a35d029cDa75b8675ACe96Dfe670f54c);
        REWARD_RATE = 5000000000000000000;
        OWNER_ADDRESS = 0x9D2b30FB5EE941Cb59AE71Bb7Ef1C6f06dfeB6c7;
    }
    
    function () payable public {
        uint256 amount = msg.value;
        amount = amount.mul(REWARD_RATE);
        
        require(amount <= TOKEN_CONTRACT_ADDRESS.balanceOf(this));
    
        address(OWNER_ADDRESS).transfer(msg.value);
        tokenTransfer(amount);
    }
    
    function withdrawToken(address _to, uint256 _amount) external onlyOwner {
        require(TOKEN_CONTRACT_ADDRESS.transfer(_to, _amount));        
        emit eventTokenWithdrawEvent(_to, _amount);
    }

    function changeTokenAddress(IERC20 _tokenCA) external onlyOwner {
        require(_tokenCA != address(0));
        emit eventChangeTokenCAEvent(TOKEN_CONTRACT_ADDRESS, _tokenCA);
        TOKEN_CONTRACT_ADDRESS = _tokenCA;
    }
    
    // 1 ETH : _amount Token
    function changeRewardRate(uint256 _rate) external onlyOwner {
        emit eventChangeRewardAmountEvent(REWARD_RATE, _rate);
        REWARD_RATE = _rate;
    }
    
    function changOwnerAddress(address _ownerAddress) external onlyOwner {
        emit eventChangeOwnerAddress(OWNER_ADDRESS, _ownerAddress);
        OWNER_ADDRESS = _ownerAddress;
    }

    function tokenTransfer(uint256 _amount) internal {
        require(TOKEN_CONTRACT_ADDRESS.transfer(msg.sender, _amount));
        emit eventFundTransfer(msg.sender, _amount);
    }
}