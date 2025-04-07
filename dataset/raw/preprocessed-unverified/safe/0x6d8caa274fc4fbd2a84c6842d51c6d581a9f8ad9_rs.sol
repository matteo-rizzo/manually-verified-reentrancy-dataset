/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */



/**
 * @dev Unsigned math operations with safety checks that revert on error.
 */


contract exchange {
    using SafeMath for uint256;
    address public manager;
    address public USDT;
    address public GWTB;
    uint256 public USDT_GWTB; // default 0.19
    bool public USDT_GWTB_IS_OPEN;
    bool public GWTB_USDT_IS_OPEN;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

    struct user{
        address user;
        address referrer;
        uint256 gwtb_total; // usdt -> gwtb 总量
        uint256 usdt_total; // gwtb -> usdt 总量
    }
    user[] public UserData;
    mapping(address => uint256) public UserIndex;

    event usdt_gwtb_event(address user,uint256 from_usdt,uint256 to_gwtb);
    event gwtb_usdt_event(address user,uint256 from_gwtb,uint256 to_usdt);
    
    constructor(address usdt,address gwtb)public{
        USDT = usdt;
        GWTB = gwtb;
        manager = msg.sender;
    }

    // USDT - GWTB 
    function usdt_gwtb(address referrer,uint256 value)public{
        require(value > 0 && USDT_GWTB_IS_OPEN == true);
        // 转入USDT
        _safeFromTransfer(USDT,msg.sender,address(this),value);
        uint256 total = getUSDT_GWTB(value.mul((10 ** 12)));
        // 将GWTB转到用户地址
        InterfaceERC20(GWTB).transfer(msg.sender,total);
        uint256 index = UserIndex[msg.sender];
        if(index == 0){
            if(referrer != msg.sender && referrer != address(0)){
                UserData.push(user({user:msg.sender,referrer:referrer,gwtb_total:total,usdt_total:0}));
            }else{
                UserData.push(user({user:msg.sender,referrer:address(0),gwtb_total:total,usdt_total:0}));
            }
            UserIndex[msg.sender] = UserData.length;
        }else if(UserData[UserIndex[msg.sender].sub(1)].referrer == address(0) && referrer != msg.sender){
            UserData[UserIndex[msg.sender].sub(1)].referrer = referrer;
        }
        if(index != 0){
            UserData[UserIndex[msg.sender].sub(1)].gwtb_total += total;
        }
        emit usdt_gwtb_event(msg.sender,value,total);
    }
    
    // GWTB - USDT
    function gwtb_usdt(address referrer,uint256 value)public{
        require(value > 0 && GWTB_USDT_IS_OPEN == true);
        // 转入GWTB
        _safeFromTransfer(GWTB,msg.sender,address(this),value);
        uint256 total = getGWTB_USDT(value.div((10 ** 12)));
        InterfaceERC20(USDT).transfer(msg.sender,total);
        
        uint256 index = UserIndex[msg.sender];
        if(index == 0){
            if(referrer != msg.sender && referrer != address(0)){
                UserData.push(user({user:msg.sender,referrer:referrer,gwtb_total:0,usdt_total:total}));
            }else{
                UserData.push(user({user:msg.sender,referrer:address(0),gwtb_total:0,usdt_total:total}));
            }
            UserIndex[msg.sender] = UserData.length;
        }else if(UserData[UserIndex[msg.sender].sub(1)].referrer == address(0) && referrer != msg.sender){
            UserData[UserIndex[msg.sender].sub(1)].referrer = referrer;
        }
        if(index != 0){
            UserData[UserIndex[msg.sender].sub(1)].usdt_total += total;
        }
        emit gwtb_usdt_event(msg.sender,value,total);
    }
    
    function getUserData() view public returns(user[] memory){
        return UserData;
    }
    // 5263000
    // 计算交换金额
    // 公式：1 / 190 * 1000
    function getUSDT_GWTB(uint256 value) view public returns(uint256){
        return value.div(USDT_GWTB).mul(1000);
    }
    
    // 公式：1 * 190 / 1000
    function getGWTB_USDT(uint256 value) view public returns(uint256){
        return value.mul(USDT_GWTB).div(1000);
    }
    
    // 设置USDT当前兑换价格
    function ownerSetUSDT_GWTB(uint256 value)public onlyOwner{
        require(value > 0);
        USDT_GWTB = value;
    }
    
    // 开启USDT-GWTB
    function ownerIsOpenExchange(bool b,uint256 i) public onlyOwner{
        if (i == 1){
            USDT_GWTB_IS_OPEN = b;
        }else if(i == 2){
            GWTB_USDT_IS_OPEN = b;
        }
    }
    
    // Owner转移
    function ownerTransfer(address newOwner) public onlyOwner{
        require(newOwner != address(0));
        manager = newOwner;
    }
    
    // 提币
    function ownerWithdrawal(uint256 value,uint256 i) public onlyOwner{
        if(i == 1){
            InterfaceERC20(USDT).transfer(msg.sender,value);
        }else if(i == 2){
            InterfaceERC20(GWTB).transfer(msg.sender,value);
        }
    }
    
    function _safeFromTransfer(address _token,address f, address to, uint value) private {
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(SELECTOR, f, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Exchange: TRANSFER_FAILED');
    }
    
    modifier onlyOwner {
        require(manager == msg.sender);
        _;
    }
}