/**
 *Submitted for verification at Etherscan.io on 2021-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.15;





















contract StrategyUNITogether  {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public bt = address(0x76c5449F4950f6338A393F53CdA8b53B0cd3Ca3a);

    address constant public want = address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);  //UNI

    address constant public prizePool = address(0x0650d780292142835F6ac58dd8E2a336e87b4393);     //CompoundPrizePool
    address constant public PcUNI = address(0xA92a861FC11b99b24296aF880011B47F9cAFb5ab);

    address constant public claimPool = address(0xa5dddefD30e234Be2Ac6FC1a0364cFD337aa0f61);      //TokenFaucet
    address constant public claimToken = address(0x0cEC1A9154Ff802e7934Fc916Ed7Ca50bDE6844e);        //POOL

    address public governance;
    address public controller;

    uint256 public redeliverynum = 100 * 1e18;

	address[] public swap2BTRouting;
    address[] public swap2TokenRouting;

    modifier onlyController {
        require(msg.sender == controller, "!controller");
        _;
    }

	modifier isAuthorized() {
        require(msg.sender == governance || msg.sender == controller || msg.sender == address(this), "!authorized");
        _;
    }

    constructor() public {
        governance = tx.origin;
        controller = 0x03D2079c54967f463Fd6e89E76012F74EBC62615;
        doApprove();
		swap2BTRouting = [claimToken,weth,bt];
        swap2TokenRouting = [claimToken,weth,want];
    }

	function doApprove () internal{
        IERC20(claimToken).approve(unirouter, uint(-1));
        IERC20(weth).approve(unirouter, uint(-1));
    }

    function deposit() public {
		uint256 _wantAmount = IERC20(want).balanceOf(address(this));
		if (_wantAmount > 0) {
            IERC20(want).safeApprove(prizePool, 0);
            IERC20(want).safeApprove(prizePool, _wantAmount);

            PoolTogether(prizePool).depositTo(address(this),_wantAmount,PcUNI,address(0));
        }
    }


    // Withdraw partial funds, normally used with a vault withdrawal
	function withdraw(uint _amount) external onlyController
	{
		uint amount = _withdraw(_amount);
		address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, amount);
	}


    function _withdraw(uint _amount) internal returns(uint) {
		uint amount = IERC20(want).balanceOf(address(this));
		if (amount < _amount) {
            amount = _amount.sub(amount);
            (uint256 exitFee, uint256 burnedCredit) = PoolTogether(prizePool).calculateEarlyExitFee(address(this),PcUNI,amount);
			PoolTogether(prizePool).withdrawInstantlyFrom(address(this),amount,PcUNI,exitFee.mul(1003).div(1000));
			amount = IERC20(want).balanceOf(address(this));
            if (amount < _amount){
                return amount;
            }
        }
		return _amount;
    }

	function withdrawAll() external onlyController returns (uint balance){
		balance = _withdraw(balanceOf());

		address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, balance);
	}

    function balanceOfwant() public view returns (uint256) {
		return IERC20(want).balanceOf(address(this));
	}

	function balanceOfPcUNI() public view returns (uint256) {
		return IERC20(PcUNI).balanceOf(address(this));
	}

    function balanceOf() public view returns (uint256) {
        return balanceOfwant().add(balanceOfPcUNI());
    }

    function getPOOLToken()public view returns(uint256) {
        return IERC20(claimToken).balanceOf(address(this));
    }

    function harvest() public
    {
        RewardTogether(claimPool).claim(address(this));
        redelivery();
    }

    function redelivery() internal {
        uint256 reward = IERC20(claimToken).balanceOf(address(this));
        if(reward > redeliverynum){
            uint256 _2token = reward.mul(80).div(100); //80%
		    uint256 _2bt = reward.sub(_2token);  //20%
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2token, 0, swap2TokenRouting, address(this), now.add(1800));
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2bt, 0, swap2BTRouting, Controller(controller).rewards(), now.add(1800));
        }
        deposit();
    }

    function setredeliverynum(uint256 value) public {
        require(msg.sender == governance, "!governance");
        redeliverynum = value;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}