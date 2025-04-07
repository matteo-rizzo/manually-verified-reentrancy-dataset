/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.15;




















contract StrategyWBTCVSP {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public bt = address(0x76c5449F4950f6338A393F53CdA8b53B0cd3Ca3a);

    address constant public want = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);  //WBTC

    address constant public vWBTC = address(0x4B2e76EbBc9f2923d83F5FBDe695D8733db1a17B);     //vWBTC

    address constant public poolRewards = address(0x479A8666Ad530af3054209Db74F3C74eCd295f8D);      //poolRewards
    address constant public VSP = address(0x1b40183EFB4Dd766f11bDa7A7c3AD8982e998421);        //VSP

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
        controller = 0x5C6d3Cb5612b551452B3E9b48c920559634510D4;
        doApprove();
		swap2BTRouting = [VSP,weth,bt];
        swap2TokenRouting = [VSP,weth,want];
    }

	function doApprove () internal{
        IERC20(VSP).approve(unirouter, uint(-1));
    }

    function deposit() public isAuthorized{
		uint256 _wantAmount = IERC20(want).balanceOf(address(this));
		if (_wantAmount > 0) {
            IERC20(want).safeApprove(vWBTC, 0);
            IERC20(want).safeApprove(vWBTC, _wantAmount);

            VWBTC(vWBTC).deposit(_wantAmount);
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
            uint256 shares = amount.mul(1e18).div(VWBTC(vWBTC).getPricePerShare());
            uint256 allShares = IERC20(vWBTC).balanceOf(address(this));
            if(shares > allShares){
                shares = allShares;
            }
            VWBTC(vWBTC).withdraw(shares);
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

    // Governance only function for creating additional rewards from dust
    function withdrawAsset(address _asset,address _to) external returns(uint256 balance){
        require(msg.sender == governance, "!governance");
        require(_to != address(0x0) && _asset != address(0x0) ,"Invalid address");
        require(want != _asset && vWBTC != _asset, "want");
        balance = IERC20(_asset).balanceOf(address(this));
        IERC20(_asset).safeTransfer(_to, balance);
    }

    function balanceOfwant() public view returns (uint256) {
		return IERC20(want).balanceOf(address(this));
	}

	function balanceOfVWBTC() public view returns (uint256) {
		return IERC20(vWBTC).balanceOf(address(this));
	}

    function balanceOf() public view returns (uint256) {
        return balanceOfwant().add(balanceOfVWBTC().mul(VWBTC(vWBTC).getPricePerShare()).div(1e18));
    }

    function getVSPToken()public view returns(uint256) {
        return IERC20(VSP).balanceOf(address(this));
    }

    function getPending()public view returns(uint256){
        return PoolRewards(poolRewards).claimable(address(this));
    }

    function harvest() public
    {
        PoolRewards(poolRewards).claimReward(address(this));
        redelivery();
    }

    function redelivery() internal {
        uint256 reward = IERC20(VSP).balanceOf(address(this));
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