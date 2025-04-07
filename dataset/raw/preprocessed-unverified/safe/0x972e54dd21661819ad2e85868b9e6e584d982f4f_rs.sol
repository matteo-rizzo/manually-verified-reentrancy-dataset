/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

pragma solidity =0.8.0;













contract NBUInfluencerBonusPart is Ownable {
    using SafeMath for uint;
    
    IERC20 public NBU;
    
    uint public nbuBonusAmount;
    INimbusReferralProgram public referralProgram;
    INimbusStakingPool[] public stakingPools;
    
    INimbusRouter public swapRouter;                
    address public swapToken;                       
    uint public swapTokenAmountForBonusThreshold;  
    
    mapping (address => bool) public influencers;
    mapping (address => mapping (address => bool)) public processedUsers;

    event ProcessInfluencerBonus(address influencer, address user, uint userAmount, uint influencerBonus);
    event Rescue(address to, uint amount);
    event RescueToken(address token, address to, uint amount); 

    constructor(address nbu, address router, address referral) {
        NBU = IERC20(nbu);
        swapRouter = INimbusRouter(router);
        referralProgram = INimbusReferralProgram(referral);
        nbuBonusAmount = 5 * 10 ** 18;
    }

    function claimBonus(address[] memory users) external {
        for (uint i; i < users.length; i++) {
            claimBonus(users[i]);
        }
    }

    function claimBonus(address user) public {
        require(influencers[msg.sender], "NBUInfluencerBonusPart: Not influencer");
        require(!processedUsers[msg.sender][user], "NBUInfluencerBonusPart: Bonus for user already received");
        require(referralProgram.userSponsorByAddress(user) == referralProgram.userIdByAddress(msg.sender), "NBUInfluencerBonusPart: Not user sponsor");
        uint amount;
        for (uint i; i < stakingPools.length; i++) {
            amount = amount.add(stakingPools[i].balanceOf(user));
        }

        address[] memory path = new address[](2);
        path[0] = swapToken;
        path[1] = address(NBU);
        uint minNbuAmountForBonus = swapRouter.getAmountsOut(swapTokenAmountForBonusThreshold, path)[1];
        require (amount >= minNbuAmountForBonus, "NBUInfluencerBonusPart: Bonus threshold not met");
        NBU.transfer(msg.sender, nbuBonusAmount);
        processedUsers[msg.sender][user] = true;
        emit ProcessInfluencerBonus(msg.sender, user, amount, nbuBonusAmount);
    }

    function isBonusForUserAllowed(address influencer, address user) external view returns (bool) {
        if (!influencers[influencer]) return false;
        if (processedUsers[influencer][user]) return false;
        if (referralProgram.userSponsorByAddress(user) != referralProgram.userIdByAddress(influencer)) return false;
        uint amount;
        for (uint i; i < stakingPools.length; i++) {
            amount = amount.add(stakingPools[i].balanceOf(user));
        }

        address[] memory path = new address[](2);
        path[0] = swapToken;
        path[1] = address(NBU);
        uint minNbuAmountForBonus = swapRouter.getAmountsOut(swapTokenAmountForBonusThreshold, path)[1];
        return amount >= minNbuAmountForBonus;
    }



    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "NBUInfluencerBonusPart: Address is zero");
        require(amount > 0, "NBUInfluencerBonusPart: Should be greater than 0");
        TransferHelper.safeTransferETH(to, amount);
        emit Rescue(to, amount);
    }

    function rescue(address to, address token, uint256 amount) external onlyOwner {
        require(to != address(0), "NBUInfluencerBonusPart: Address is zero");
        require(amount > 0, "NBUInfluencerBonusPart: Should be greater than 0");
        TransferHelper.safeTransfer(token, to, amount);
        emit RescueToken(token, to, amount);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(newSwapRouter != address(0), "NBUInfluencerBonusPart: Address is zero");
        swapRouter = INimbusRouter(newSwapRouter);
    }
    
    function updateStakingPoolAdd(address newStakingPool) external onlyOwner {
        for (uint i; i < stakingPools.length; i++) {
            require (address(stakingPools[i]) != newStakingPool, "NBUInfluencerBonusPart: Pool exists");
        }
        stakingPools.push(INimbusStakingPool(newStakingPool));
    }

    function updateStakingPoolRemove(uint poolIndex) external onlyOwner {
        stakingPools[poolIndex] = stakingPools[stakingPools.length - 1];
        stakingPools.pop();
    }

    function updateInfluencer(address influencer, bool isActive) external onlyOwner {
        influencers[influencer] = isActive;
    }

    function updateNbuBonusAmount(uint newAmount) external onlyOwner {
        nbuBonusAmount = newAmount;
    }

    function updateSwapToken(address newSwapToken) external onlyOwner {
        require(newSwapToken != address(0), "NBUInfluencerBonusPart: Address is zero");
        swapToken = newSwapToken;
    }

    function updateSwapTokenAmountForBonusThreshold(uint threshold) external onlyOwner {
        swapTokenAmountForBonusThreshold = threshold;
    }
}

