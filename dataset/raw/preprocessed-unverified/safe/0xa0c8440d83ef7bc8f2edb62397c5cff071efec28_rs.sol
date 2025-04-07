/**
 *Submitted for verification at Etherscan.io on 2021-09-20
*/

// This contract will generate rewards for life and will be used to fund FEG developments. 
// Only the rewards from the burnt balance inside can be removed, the burnt balance can never be removed unless contract is broken.
// Broken contract = 180 days since last reward claim.
// This contract will burn the ROX removed for asset backing and not be sold on market.

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;



abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// ----------------------------------------------------------------------------
// SafeMath library
// ----------------------------------------------------------------------------




// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------








contract ROXPerpRewardFund is Owned, ReentrancyGuard {
    using SafeMath for uint256;
    
    roxx _roxx;
    address public ROX  = 0x378c77C5379cA07BBB5B3506c08a1C769dEC91c2; // ROX token
    uint256 public totalBurnt = 0;
    address public fund1 = 0xC35D37147CD4f918A7cc7e58a29E51559e385548; 
    address public fund2 = 0x620844ddBe24240e0BB2DbB40a322619B608FbF7; 
    address public fund3 = 0x9550aC8B333A0A0F5A9B0F0Cb61f9265d9405028; 
    address public fund4 = 0xAd0A7B1Dd61762cb4747C712D8612408bFf3EA82; 
    address public fund5 = 0x191dE23a590599Fb3a0A106dda1F62113B4e6a99; 
    address public fund6 = 0xCd4b658404fF9cA476A9362242f018b2b7b45722; 
    address public fund7 = 0xD7e4310F9Ebc41dB113CcCBc1Dc319eB66e93FBf; 
    mapping(address => uint256) private _balances1;
    uint256 public cast = 0;
    event BURNT(address staker, uint256 tokens); 
    event CLAIM(address fund, uint256 amt);
    event DISTRIBUTED(uint256 amt, uint256 cast);

    constructor(){
        _roxx = roxx(ROX);
    }
    
    receive() external payable {
    }

    function myPendingClaim() external view returns(uint256){
        uint256 pendingClaim = _balances1[msg.sender];
        return pendingClaim;
    }
    
    function supplyROX(uint256 tokens) external nonReentrant { 
        require(IERC20(ROX).transferFrom(msg.sender, address(this), tokens), "Tokens cannot be transferred from user for locking");
        totalBurnt = totalBurnt.add(tokens * 99/100); // Set for 1% tx fees
        emit BURNT(msg.sender, tokens);
    }
    
    function updateFund1(address _fund1) external nonReentrant {
        require(msg.sender == fund1, "You do not have permission");
        require(_fund1 != address(0), "Cannot set the 0 address");
        fund1 = _fund1;
    }
    
    function updateFund2(address _fund2) external nonReentrant {
        require(msg.sender == fund2, "You do not have permission");
        require(_fund2 != address(0), "Cannot set the 0 address");
        fund2 = _fund2;
    }
    
    function updateFund3(address _fund3) external nonReentrant {
        require(msg.sender == fund3, "You do not have permission");
        require(_fund3 != address(0), "Cannot set the 0 address");
        fund3 = _fund3;
    }
    
    function updateFund4(address _fund4) external nonReentrant {
        require(msg.sender == fund4, "You do not have permission");
        require(_fund4 != address(0), "Cannot set the 0 address");
        fund4 = _fund4;
    }
    
    function updateFund5(address _fund5) external nonReentrant {
        require(msg.sender == fund5, "You do not have permission");
        require(_fund5 != address(0), "Cannot set the 0 address");
        fund5 = _fund5;
    }
    
    function updateFund6(address _fund6) external nonReentrant onlyOwner {
        require(_fund6 != address(0), "Cannot set the 0 address");
        fund6 = _fund6;
    }
    
    function updateFund7(address _fund7) external nonReentrant onlyOwner {
        require(_fund7 != address(0), "Cannot set the 0 address");
        fund7 = _fund7;
    }
    
    function amtForDist() public view returns(uint256){
        uint256 oo = totalPendingClaims();
        uint256 total = (IERC20(ROX).balanceOf(address(this))).sub(totalBurnt.add(oo));
        return total;
    }
    
    function totalPendingClaims() public view returns(uint256) {
        uint256 amt = (_balances1[fund1] + _balances1[fund2] + _balances1[fund3] + _balances1[fund4] + _balances1[fund5] + _balances1[fund6] + _balances1[fund7]);
        return amt;
    }
    
    function claimFund1() external nonReentrant {
        distributeRewards1();
        require(msg.sender == fund1, "You do not have permission");
        uint256 share = _balances1[fund1];
        _balances1[fund1] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund1, mypart);
        emit CLAIM(fund1, mypart);
    }
    
    function claimFund2() external nonReentrant{
        distributeRewards1();
        require(msg.sender == fund2, "You do not have permission");
        uint256 share = _balances1[fund2];
        _balances1[fund2] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund2, mypart);
        emit CLAIM(fund2, mypart);
    }
    
    function claimFund3() external nonReentrant{
        distributeRewards1();
        require(msg.sender == fund3, "You do not have permission");
        uint256 share = _balances1[fund3];
        _balances1[fund3] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund3, mypart);
        emit CLAIM(fund3, mypart);
    }
    
    function claimFund4() external nonReentrant{
        distributeRewards1();
        require(msg.sender == fund4, "You do not have permission");
        uint256 share = _balances1[fund4];
        _balances1[fund4] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund4, mypart);
        emit CLAIM(fund4, mypart);
    }
    
    function claimFund5() external nonReentrant{
        distributeRewards1();
        require(msg.sender == fund5, "You do not have permission");
        uint256 share = _balances1[fund5];
        _balances1[fund5] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund5, mypart);
        emit CLAIM(fund5, mypart);
    }
    
    function claimFund6() external nonReentrant{
        distributeRewards1();
        require(msg.sender == fund6, "You do not have permission");
        uint256 share = _balances1[fund6];
        _balances1[fund6] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund6, mypart);
        emit CLAIM(fund5, mypart);
    }
    
    function claimFund7() external nonReentrant{
        distributeRewards1();
        require(msg.sender == fund7, "You do not have permission");
        uint256 share = _balances1[fund7];
        _balances1[fund7] = 0;
        IERC20(address(ROX)).approve(address(ROX), share);
        _roxx.liquifyForMain(share);
        uint256 mypart = address(this).balance;
        TransferHelper.safeTransferETH(fund7, mypart);
        emit CLAIM(fund7, mypart);
    }
    
    function distributeRewards() external { // Distribute tx fees collected for conversion into rewards for planned purposes, can only be called by fund1-7
        require(msg.sender == fund1 || msg.sender == fund2 || msg.sender == fund3 || msg.sender == fund4 || msg.sender == fund5 || msg.sender == fund6 || msg.sender == fund7);
        uint256 oo = totalPendingClaims();
        uint256 transferMax = (IERC20(ROX).balanceOf(address(this))).sub(totalBurnt.add(oo));
        if(transferMax >= 1e5){
        uint256 amt  = transferMax;
        uint256 amt0 = amt.div(20);
        uint256 amt1 = amt.sub(amt.sub(amt0));
        uint256 amt2 = amt1.mul(5);
        uint256 amt3 = (amt1.mul(10));
        _balances1[fund1] += amt1;
        _balances1[fund2] += amt1;
        _balances1[fund3] += amt1;
        _balances1[fund4] += amt1;
        _balances1[fund5] += amt1;
        _balances1[fund6] += amt2;
        _balances1[fund7] += amt3;
        cast = block.timestamp + 180 days;
        emit DISTRIBUTED(amt, cast);
        }
    }
    
    function distributeRewards1() internal { // Distribute tx fees collected for conversion into rewards for planned purposes
        
        uint256 oo = totalPendingClaims();
        uint256 transferMax = (IERC20(ROX).balanceOf(address(this))).sub(totalBurnt.add(oo));
        if(transferMax >= 1e5){
        uint256 amt  = transferMax;
        uint256 amt0 = amt.div(20);
        uint256 amt1 = amt.sub(amt.sub(amt0));
        uint256 amt2 = amt1.mul(5);
        uint256 amt3 = (amt1.mul(10));
        _balances1[fund1] += amt1;
        _balances1[fund2] += amt1;
        _balances1[fund3] += amt1;
        _balances1[fund4] += amt1;
        _balances1[fund5] += amt1;
        _balances1[fund6] += amt2;
        _balances1[fund7] += amt3;
        cast = block.timestamp + 180 days;
        emit DISTRIBUTED(amt, cast);
        }
    }
    
    function saveLost() external onlyOwner { // Incase contract ever breaks, must be 180 days after last distribution
        require(block.timestamp > cast, "Must be 180 days since last claim");
        uint256 amt = IERC20(ROX).balanceOf(address(this));
        IERC20(ROX).transfer(owner, amt);
    }
}