/**
 *Submitted for verification at Etherscan.io on 2021-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "t001");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "t002");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "t003");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}











contract ClaimErc20 is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    uint256 RewardNum = 5000;
    bool public canClaimErc20 = false;
    mapping(uint256 => bool) public hasClaimStatus;
    IERC20 public RewardAddress = IERC20(0xd947773b93455e3D97fCb8D4A030C5D0D8F3b278);
    IERC721 public NftAddress = IERC721(0xb840EC0DB3b9ab7b920710D6fc21A9D206f994Aa);

    function setRewardNum(uint256 _RewardNum) public onlyOwner {
        RewardNum = _RewardNum;
    }

    function setRewardAddress(IERC20 _RewardAddress) public onlyOwner {
        RewardAddress = _RewardAddress;
    }

    function setNftAddress(IERC721 _NftAddress) public onlyOwner {
        NftAddress = _NftAddress;
    }

    function enableCanClaimErc20() public onlyOwner {
        canClaimErc20 = true;
    }

    function disableCanClaimErc20() public onlyOwner {
        canClaimErc20 = false;
    }

    function claimErc20Token() public {
        uint256 num = NftAddress.balanceOf(msg.sender);
        require(num > 0, "t015");
        require(canClaimErc20 == true, "t016");
        uint256 num2 = 0;
        for (uint256 i = 0; i < num; i++) {
            uint256 _tokenID = NftAddress.tokenOfOwnerByIndex(msg.sender, i);
            if (hasClaimStatus[_tokenID] == false) {
                num2 = num2.add(1);
                hasClaimStatus[_tokenID] = true;
            }
        }
        require(num2 > 0, "t017");
        uint256 reward_num = RewardNum.mul(num2).mul(10 ** RewardAddress.decimals());
        RewardAddress.safeApprove(address(this), reward_num);
        RewardAddress.safeTransferFrom(address(this), msg.sender, reward_num);
    }

    function getClaimErc20TokenNum(address _user) public view returns (uint256){
        uint256 num = NftAddress.balanceOf(_user);
        if (num == 0 || canClaimErc20 == false) {
            return 0;
        }
        uint256 num2 = 0;
        for (uint256 i = 0; i < num; i++) {
            uint256 _tokenID = NftAddress.tokenOfOwnerByIndex(_user, i);
            if (hasClaimStatus[_tokenID] == false) {
                num2 = num2.add(1);
            }
        }
        return num2;
    }

    function getErc20Token(IERC20 _token) public onlyOwner {
        _token.safeApprove(address(this), _token.balanceOf(address(this)));
        _token.safeTransferFrom(address(this), msg.sender, _token.balanceOf(address(this)));
    }
}