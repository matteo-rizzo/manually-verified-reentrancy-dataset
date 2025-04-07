/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

pragma solidity 0.7.3;



abstract contract Context {
    function _msgSender() 
        internal
        view 
        virtual
        returns (address payable) 
    {
        return msg.sender;
    }

    function _msgData() 
        internal
        view 
        virtual 
        returns (bytes memory) 
    {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}







abstract contract Ownable is Context {
    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );

    constructor () {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(
        address newOwner
    ) 
        onlyOwner 
        external 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        pendingOwner = newOwner;
     }
    
     function claimOwnership() 
        external 
    {
        require(_msgSender() == pendingOwner);
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
     }
}



contract ETHPortal is Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (bytes32 => bool) public txNonces;
    address public signAddress;
    address public tokenAddress;

    string public chainName = "ETH_BLOCKCHAIN";

    event TokensLocked(
        address user,
        uint256 amount
    );

    event TokensUnlocked(
        address user,
        uint256 amount,
        bytes32 txNonce
    );

    constructor(address _signAddress, address _tokenAddress) public {
        signAddress = _signAddress;
        tokenAddress = _tokenAddress;
    }

    function changeSignAddress(address _signAddress) public onlyOwner {
        signAddress = _signAddress;
    }

    function changeTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }

    function lockedTokens() public view returns(uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function sendToBSC(uint256 _amount) public {
        require(_amount > 0, "AMOUNT_CANT_BE_ZERO");
        IERC20(tokenAddress).transferFrom(_msgSender(), address(this), _amount);
        emit TokensLocked(_msgSender(), _amount);
    }

    function withdrawFromBSC(bytes calldata _signature, uint256 _amount, bytes32 _txNonce) public {
        require(txNonces[_txNonce] == false, "INVALID_TRANSACTION");
        txNonces[_txNonce] = true;
        require(_amount > 0, "AMOUNT_CANT_BE_ZERO");

        bytes32 message = keccak256(abi.encodePacked(_amount, _msgSender(), _txNonce, chainName));
        require(VerifySignature.verify(message, _signature, signAddress) == true, "INVALID_SIGNATURE");

        IERC20(tokenAddress).transfer(_msgSender(), _amount);
        emit TokensUnlocked(_msgSender(), _amount, _txNonce);

    }
}