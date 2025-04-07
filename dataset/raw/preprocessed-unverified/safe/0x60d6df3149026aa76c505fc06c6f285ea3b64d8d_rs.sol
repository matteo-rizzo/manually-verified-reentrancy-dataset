/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract YFStablePresale is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    IYFStable token;
    // Presale stuff below
    uint256 private _presaleMint;
    uint256 public presaleTime = now;
    uint256 public presalePrice;
    mapping (address => uint256) private _presaleParticipation;
    bool public presale = false;

    constructor (address tokenAdd) public {
        token = IYFStable(tokenAdd);
        presaleTime;
        presalePrice = Constants.getPresaleRate();
    }

    function setPresaleTime(uint256 time) external onlyOwner() {
        require(token.isPresaleDone() == false, "This cannot be modified after the presale is done");
        presaleTime = time;
    }

    function setPresaleFlag(bool flag) external onlyOwner() {
        require(!token.isPresaleDone(), "This cannot be modified after the presale is done");
        if (flag == true) {
            require(presalePrice > 0, "Sale price has to be greater than 0");
        }
        presale = flag;
    }
    

    function setPresalePrice(uint256 priceInWei) external onlyOwner() {
        require(!presale && !token.isPresaleDone(),"Can only be set before presale starts");
        presalePrice = priceInWei;
    }

    // Presale function
    receive() external payable {
        require(presale, "Presale is inactive");
        require(!token.isPresaleDone(), "Presale is already completed");
        require(presaleTime <= now, "Presale hasn't started yet");
        uint256 invest = _presaleParticipation[_msgSender()].add(msg.value);
        require(invest <= Constants.getPresaleMaxIndividualCap() && invest >= Constants.getPresaleMinIndividualCap(), "Crossed individual cap");
        require(presalePrice != 0, "Presale price is not set");
        require(msg.value > 1, "Cannot buy without sending at least 1 eth mate!");
        require(!Address.isContract(_msgSender()),"no contracts");
        require(tx.gasprice <= Constants.getMaxPresaleGas(),"gas price above limit");
        uint256 amountToMint = msg.value.div(10**11).mul(presalePrice);
        require(_presaleMint.add(amountToMint) <= Constants.getPresaleCap(), "Presale max cap already reached");
        token.mint(_msgSender(),amountToMint);
        _presaleParticipation[_msgSender()] = _presaleParticipation[_msgSender()].add(msg.value);
        _presaleMint = _presaleMint.add(amountToMint);
    }

    function presaleDone() external onlyOwner() {
        require(!token.isPresaleDone(), "Presale is already completed");
        token.setPresaleDone{value:address(this).balance}();
    }

    function emergencyWithdraw() external onlyOwner() {
        require(!token.isPresaleDone(), "Presale is already completed");
        _msgSender().transfer(address(this).balance);
    }
}