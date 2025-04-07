// Dependency file: contracts/libraries/TransferHelper.sol

//SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0;







// Dependency file: contracts/interface/IWasabi.sol

//SPDX-License-Identifier: MIT
// pragma solidity >=0.5.0;




// Dependency file: contracts/interface/IERC20.sol

//SPDX-License-Identifier: MIT
// pragma solidity >=0.5.0;




// Root file: contracts/WasabiGovernance.sol

pragma solidity >=0.6.6;

// import 'contracts/libraries/TransferHelper.sol';
// import 'contracts/interface/IWasabi.sol';
// import 'contracts/interface/IERC20.sol';

// todo
contract WasabiGovernance  {
    uint public version = 1;
    address public wasabi;
    address public owner;

    event OwnerChanged(address indexed _oldOwner, address indexed _newOwner);
    event Upgraded(address indexed _from, address indexed _to, uint _value);
    event RewardManagerChanged(address indexed _from, address indexed _to, uint _rewardTokenBalance, uint _wsbTokenBalance);

    modifier onlyOwner() {
        require(msg.sender == owner, 'WasabiGovernance: FORBIDDEN');
        _;
    }

    constructor () public {
        owner = msg.sender;
    }

    function initialize(address _wasabi) external onlyOwner {
        require(_wasabi != address(0), 'WasabiGovernance: INPUT_ADDRESS_IS_ZERO');
        wasabi = _wasabi;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), 'WasabiGovernance: INVALID_ADDRESS');
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    function upgrade(address _newGovernor) external onlyOwner returns (bool) {
        IWasabi(wasabi).upgradeGovernance(_newGovernor);
        return true; 
    }

    function changeRewardManager(address _manager) external onlyOwner returns (bool) {
        address rewardToken = IWasabi(wasabi).acceptToken();
        address wsbToken = IWasabi(wasabi).tokenAddress();
        uint rewardTokenBalance = IERC20(rewardToken).balanceOf(address(this));
        uint wsbTokenBalance = IERC20(wsbToken).balanceOf(address(this));
        require(rewardTokenBalance > 0 || wsbTokenBalance > 0, 'WasabiGovernance: NO_REWARD');
        require(_manager != address(this), 'WasabiGovernance: NO_CHANGE');
        if (rewardTokenBalance > 0) TransferHelper.safeTransfer(rewardToken, _manager, rewardTokenBalance);
        if (wsbTokenBalance > 0) TransferHelper.safeTransfer(wsbToken, _manager, wsbTokenBalance);
        emit RewardManagerChanged(address(this), _manager, rewardTokenBalance, wsbTokenBalance);
        return true;
    }

}