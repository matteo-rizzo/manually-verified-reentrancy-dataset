/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.5.0;








contract ManualApproval is Ownable {
    struct TransferReq {
        address from;
        address to;
        uint256 value;
    }

    uint256 public _reqNumber;
    ISRC20 public _src20;

    mapping(uint256 => TransferReq) public _transferReq;
    mapping(address => bool) public _greyList;

    event TransferRequest(
        uint256 indexed requestNumber,
        address from,
        address to,
        uint256 value
    );

    event TransferApproval(
        uint256 indexed requestNumber,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event TransferRequestCanceled(
        uint256 indexed requestNumber,
        address indexed from,
        address indexed to,
        uint256 value
    );

    constructor () public {
    }

    
    function transferApproval(uint256 reqNumber) external onlyOwner returns (bool) {
        TransferReq memory req = _transferReq[reqNumber];

        require(_src20.executeTransfer(address(this), req.to, req.value), "SRC20 transfer failed");

        delete _transferReq[reqNumber];
        emit TransferApproval(reqNumber, req.from, req.to, req.value);
        return true;
    }

    
    function cancelTransferRequest(uint256 reqNumber) external returns (bool) {
        TransferReq memory req = _transferReq[reqNumber];
        require(req.from == msg.sender, "Not owner of the transfer request");

        require(_src20.executeTransfer(address(this), req.from, req.value), "SRC20: External transfer failed");

        delete _transferReq[reqNumber];
        emit TransferRequestCanceled(reqNumber, req.from, req.to, req.value);

        return true;
    }

    
    function isGreyListed(address account) public view returns (bool){
        return _greyList[account];
    }

    function greyListAccount(address account) external onlyOwner returns (bool) {
        _greyList[account] = true;
        return true;
    }

    function bulkGreyListAccount(address[] calldata accounts) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < accounts.length ; i++) {
            address account = accounts[i];
            _greyList[account] = true;
        }
        return true;
    }

    function unGreyListAccount(address account) external onlyOwner returns (bool) {
        delete _greyList[account];
        return true;
    }

    function bulkUnGreyListAccount(address[] calldata accounts) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < accounts.length ; i++) {
            address account = accounts[i];
            delete _greyList[account];
        }
        return true;
    }

    function _transferRequest(address from, address to, uint256 value) internal returns (bool) {
        require(_src20.executeTransfer(from, address(this), value), "SRC20 transfer failed");

        _transferReq[_reqNumber] = TransferReq(from, to, value);

        emit TransferRequest(_reqNumber, from, to, value);
        _reqNumber = _reqNumber + 1;

        return true;
    }
}

contract Whitelisted is Ownable {
    mapping (address => bool) public _whitelisted;

    function whitelistAccount(address account) external onlyOwner {
        _whitelisted[account] = true;
    }

    function bulkWhitelistAccount(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length ; i++) {
            address account = accounts[i];
            _whitelisted[account] = true;
        }
    }

    function unWhitelistAccount(address account) external onlyOwner {
         delete _whitelisted[account];
    }

    function bulkUnWhitelistAccount(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length ; i++) {
            address account = accounts[i];
            delete _whitelisted[account];
        }
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisted[account];
    }
}



contract TransferRules is ITransferRules, ManualApproval, Whitelisted {

    modifier onlySRC20 {
        require(msg.sender == address(_src20));
        _;
    }

    constructor(address owner) public {
        _transferOwnership(owner);
        _whitelisted[owner] = true;
    }

    
    function setSRC(address src20) external returns (bool) {
        require(address(_src20) == address(0), "SRC20 already set");
        _src20 = ISRC20(src20);
        return true;
    }

    
    function authorize(address from, address to, uint256 value) public returns (bool) {
        return (isWhitelisted(from) || isGreyListed(from)) &&
        (isWhitelisted(to) || isGreyListed(to));
    }

    
    function doTransfer(address from, address to, uint256 value) external onlySRC20 returns (bool) {
        require(authorize(from, to, value), "Transfer not authorized");

        if (isGreyListed(from) || isGreyListed(to)) {
            _transferRequest(from, to, value);
            return true;
        }

        require(ISRC20(_src20).executeTransfer(from, to, value), "SRC20 transfer failed");

        return true;
    }
}