/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

pragma solidity 0.6.12;


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 , add some function for gToken and cToken
 */






// File: @openzeppelin/contracts/utils/Address.sol



/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol







/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */







contract PledgeDeposit is Ownable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
    struct PoolInfo {
        IERC20 token;
        string symbol;
    }

    struct DepositInfo {
        uint256 userOrderId;
        uint256 depositAmount;
        uint256 pledgeAmount;
        uint256 depositTime;
        uint256 depositBlock;
        uint256 expireBlock;
    }
    

    IERC20 public zild;

    /**
     * @dev  Guard variable for re-entrancy checks
     */
    bool internal _notEntered;

    uint256 public minDepositBlock = 1;

 
    PoolInfo[] public poolArray;


    // poolId , user address, DepositInfo
    mapping (uint256 => mapping (address => DepositInfo[])) public userDepositMap;

    mapping (address => uint256) public lastUserOrderIdMap;

    uint256 public pledgeBalance;    

    event NewPool(address addr, string symbol);

    event UpdateMinDepositBlock(uint256 dblock,address  who,uint256 time);

    event ZildBurnDeposit(address  userAddress,uint256 userOrderId, uint256 burnAmount);
    event Deposit(address  userAddress,uint256 userOrderId, uint256 poolId,string symbol,uint256 depositId, uint256 depositAmount,uint256 pledgeAmount);
    event Withdraw(address  userAddress,uint256 userOrderId, uint256 poolId,string symbol,uint256 depositId, uint256 depositAmount,uint256 pledgeAmount);
    
    constructor(address _zild,address _usdt) public {
        zild = IERC20(_zild);

        // poolArray[0] :  ETH 
        addPool(address(0),'ETH');  

        // poolArray[1] : ZILD  
        addPool(_zild,'ZILD');  

        // poolArray[2] : USDT  
        addPool(_usdt,'USDT');  

        _notEntered = true;
  
    }

        /*** Reentrancy Guard ***/

    /**
     * Prevents a contract from calling itself, directly or indirectly.
     */
    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }
    

    function addPool(address  _token, string memory _symbol) public onlyAdmin {
        poolArray.push(PoolInfo({token: IERC20(_token),symbol: _symbol}));
        emit NewPool(_token, _symbol);
    }

    function poolLength() external view returns (uint256) {
        return poolArray.length;
    }

    function updateMinDepositBlock(uint256 _minDepositBlock) public onlyAdmin {
        require(_minDepositBlock > 0,"Desposit: New deposit time must be greater than 0");
        minDepositBlock = _minDepositBlock;
        emit UpdateMinDepositBlock(minDepositBlock,msg.sender,now);
    }
      
    function tokenDepositCount(address _user, uint256 _poolId)  view public returns(uint256) {
        require(_poolId < poolArray.length, "invalid _poolId");
        return userDepositMap[_poolId][_user].length;
    }

    function burnDeposit(uint256 _userOrderId, uint256 _burnAmount) public{
       require(_userOrderId > lastUserOrderIdMap[msg.sender], "_userOrderId should greater than lastUserOrderIdMap[msg.sender]");
       
       lastUserOrderIdMap[msg.sender]  = _userOrderId;
       
       zild.transferFrom(address(msg.sender), address(1024), _burnAmount);       
  
       emit ZildBurnDeposit(msg.sender, _userOrderId, _burnAmount);
    }

    function deposit(uint256 _userOrderId, uint256 _poolId, uint256 _depositAmount,uint256 _pledgeAmount) public nonReentrant  payable{
       require(_poolId < poolArray.length, "invalid _poolId");
       require(_userOrderId > lastUserOrderIdMap[msg.sender], "_userOrderId should greater than lastUserOrderIdMap[msg.sender]");
       
       lastUserOrderIdMap[msg.sender]  = _userOrderId;
       PoolInfo storage poolInfo = poolArray[_poolId];

       // ETH
       if(_poolId == 0){
            require(_depositAmount == msg.value, "invald  _depositAmount for ETH");
            zild.safeTransferFrom(address(msg.sender), address(this), _pledgeAmount);
       }
       // ZILD
       else if(_poolId == 1){
            uint256 zildAmount = _pledgeAmount.add(_depositAmount);
            zild.safeTransferFrom(address(msg.sender), address(this), zildAmount);
       }
       else{
            zild.safeTransferFrom(address(msg.sender), address(this), _pledgeAmount);
            poolInfo.token.safeTransferFrom(address(msg.sender), address(this), _depositAmount);
       }

       pledgeBalance = pledgeBalance.add(_pledgeAmount);

       uint256 depositId = userDepositMap[_poolId][msg.sender].length;
       userDepositMap[_poolId][msg.sender].push(
            DepositInfo({
                userOrderId: _userOrderId,
                depositAmount: _depositAmount,
                pledgeAmount: _pledgeAmount,
                depositTime: now,
                depositBlock: block.number,
                expireBlock: block.number.add(minDepositBlock)
            })
        );
    
        emit Deposit(msg.sender, _userOrderId, _poolId, poolInfo.symbol, depositId, _depositAmount, _pledgeAmount);
    }

    function getUserDepositInfo(address _user, uint256 _poolId,uint256 _depositId) public view returns (
        uint256 _userOrderId, uint256 _depositAmount,uint256 _pledgeAmount,uint256 _depositTime,uint256 _depositBlock,uint256 _expireBlock) {
        require(_poolId < poolArray.length, "invalid _poolId");
        require(_depositId < userDepositMap[_poolId][_user].length, "invalid _depositId");

        DepositInfo memory depositInfo = userDepositMap[_poolId][_user][_depositId];
        
        _userOrderId = depositInfo.userOrderId;
        _depositAmount = depositInfo.depositAmount;
        _pledgeAmount = depositInfo.pledgeAmount;
        _depositTime = depositInfo.depositTime;
        _depositBlock = depositInfo.depositBlock;
        _expireBlock = depositInfo.expireBlock;
    }

    function withdraw(uint256 _poolId,uint256 _depositId) public nonReentrant {
        require(_poolId < poolArray.length, "invalid _poolId");
        require(_depositId < userDepositMap[_poolId][msg.sender].length, "invalid _depositId");

        PoolInfo storage poolInfo = poolArray[_poolId];
        DepositInfo storage depositInfo = userDepositMap[_poolId][msg.sender][_depositId];

        require(block.number > depositInfo.expireBlock, "The withdrawal block has not arrived");
        uint256 depositAmount =  depositInfo.depositAmount;
        require( depositAmount > 0, "There is no deposit available!");

        uint256 pledgeAmount = depositInfo.pledgeAmount;

        pledgeBalance = pledgeBalance.sub(pledgeAmount);
        depositInfo.depositAmount =  0;    
        depositInfo.pledgeAmount = 0;

        // ETH
        if(_poolId == 0) {
            msg.sender.transfer(depositAmount);
            zild.safeTransfer(msg.sender,pledgeAmount);
        }
        // ZILD
        else if(_poolId == 1){
            zild.safeTransfer(msg.sender, depositAmount.add(pledgeAmount));
        }
        else{
            poolInfo.token.safeTransfer(msg.sender, depositAmount);
            zild.safeTransfer(msg.sender,pledgeAmount);
        }   
      
        emit Withdraw(msg.sender, depositInfo.userOrderId, _poolId, poolInfo.symbol, _depositId, depositAmount, pledgeAmount);
      }
}