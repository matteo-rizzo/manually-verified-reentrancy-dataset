/**
 *Submitted for verification at Etherscan.io on 2021-04-12
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity <=0.7.4;

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







contract EdgeStakingV1 is ReentrancyGuard {

    uint256 public currentROI; // ROI per second in 10^13 precision
    address public edgexContract; // edge196 token contract
    address public admin;
    
    struct Stake{
        uint256 amount;
        uint256 maturesAt;
        uint256 createdAt;
        uint256 roiAtStake;
        bool isClaimed;
        uint256 interest;
    }

    mapping(address => uint256) public totalStakingContracts;
    mapping(address => mapping(uint256 => Stake)) public stakeContract;

    event RevokeOwnership(address indexed newOwner);
    event ChangeROI(uint256 newROI);

    modifier onlyAdmin(){
        require(msg.sender == admin,"Caller not admin");
        _;
    }

    modifier isZero(address _address){
        require(_address != address(0),"Invalid Address");
        _;
    }

    constructor(address _edgexContract,uint256 _newROI, address _admin){
        edgexContract = _edgexContract;
        currentROI = _newROI;
        admin = _admin;
    }

    function stake(uint256 _amount, uint256 _tenureInDays) public nonReentrant returns(bool) {
        require(
            IERC20(edgexContract)
            .allowance(msg.sender,address(this)) >= _amount, "Allowance Exceeded"
            );
        require(
            IERC20(edgexContract)
            .balanceOf(msg.sender) >= _amount, "Insufficient Balance"
            );
        updateStakeData(_amount,_tenureInDays,msg.sender);
        totalStakingContracts[msg.sender] = Math.add(totalStakingContracts[msg.sender],1);
        IERC20(edgexContract)
        .transferFrom(msg.sender,address(this),_amount);
        return true;
        }

    function updateStakeData(uint256 _amount, uint256 _tenureInDays, address _user) internal{
        uint256 totalContracts = Math.add(totalStakingContracts[_user],1);         
        Stake storage sc = stakeContract[_user][totalContracts];
        sc.amount = _amount;
        sc.createdAt = block.timestamp;
        uint256 maturityInSeconds = Math.mul(_tenureInDays,1 minutes);
        sc.maturesAt = Math.add(block.timestamp,maturityInSeconds);
        sc.roiAtStake = currentROI;
    }

    function claim(uint256 _stakingContractId) public nonReentrant returns(bool){
        Stake storage sc = stakeContract[msg.sender][_stakingContractId];
        require(
            sc.maturesAt <= block.timestamp,
            "Not Yet Matured"
        );
        require(
            !sc.isClaimed,
            "Already Claimed"
        );
        uint256 total; uint256 interest;
        (total,interest) = calculateClaimAmount(msg.sender,_stakingContractId);
        sc.isClaimed = true;
        sc.interest = interest;
        IERC20(edgexContract)
        .transfer(msg.sender,total);
        return true;
    }

    function calculateClaimAmount(address _user, uint256 _contractId) public view returns(uint256,uint256){
        Stake storage sc = stakeContract[_user][_contractId];
        uint256 a = Math.mul(sc.amount,sc.roiAtStake);
        uint256 time = Math.sub(sc.maturesAt,sc.createdAt);
        uint256 b = Math.mul(a,time);
        uint256 interest = Math.div(b,Math.mul(31536,10**18));
        uint256 total = Math.add(sc.amount,interest);
        return(total,interest);
    }
    
    /**
        @dev changing the admin of the oracle
        Warning : Admin can change ROI & other features.
     */

    function revokeOwnership(address _newOwner) public onlyAdmin isZero(_newOwner) returns(bool){
        admin = payable(_newOwner);
        emit RevokeOwnership(_newOwner);
        return true;
    }

    function changeROI(uint256 _newROI) public onlyAdmin returns(bool){
        currentROI = _newROI;
        emit ChangeROI(_newROI);
        return true;
    }
    
    function updateEdgexContract(address _contractAddress) public onlyAdmin isZero(_contractAddress) returns(bool){
        edgexContract = _contractAddress;
        return true;
    }

    function withdrawLiquidity(uint256 _edgexAmount, address _to) public virtual onlyAdmin isZero(_to) returns(bool){
        IERC20(edgexContract)
        .transfer(_to,_edgexAmount);
        return true;
    }

}