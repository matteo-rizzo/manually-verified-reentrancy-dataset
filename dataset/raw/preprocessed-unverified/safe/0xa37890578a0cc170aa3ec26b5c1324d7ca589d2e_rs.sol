/**
 *Submitted for verification at Etherscan.io on 2021-08-04
*/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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







contract Contribut is Ownable {
    struct EventData {
        string eventName;
        address depositToken;
        uint256 depositTotal;
        uint256 hardCap;
        uint256 maxContribut;
        uint256 minContribut;
        uint256 FCFSTimer;
        address[] users;
        address owner;
        bool active;
    }
    mapping(uint256 => EventData) public eventList;
    uint256 public eventNonce;
    
    struct ContributionData {
        uint256 eventId;
        uint256 depositAmount;
    }
    mapping(address => ContributionData[]) public userList;

    struct UserData {
        address user;
        uint256 depositAmount;
    }

    event Published(uint256 eventId, string eventName, address depositToken, uint256 hardCap, uint256 maxContribut, uint256 minContribut, uint256 FCFSTimer, address owner, bool active);
    event Close(uint256 eventId, address depositToken, uint256 depositTotal);
    event Contribution(uint256 eventId, address user, uint256 depositAmount);
    event Vested(uint256 eventId, address user, address tokenAddress, uint256 amount);

    receive() external payable {}

    function RecoverERC20(address _tokenAddress) public onlyOwner {
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(_tokenAddress, owner(), balance);
    }

    function RecoverETH() public onlyOwner() {
        address owner = owner();
        payable(owner).transfer(address(this).balance);
    }

    function SetEvent(string calldata _eventName, address _depositToken, uint256 _hardCap, uint256 _maxContribut, uint256 _minContribut, uint256 _FCFSTimer) external onlyOwner {
        require(_hardCap >= _maxContribut, "Invalid hardCap");
        require(_maxContribut >= _minContribut, "Invalid minContribut");
        require(_depositToken != address(0), "Invalid depositToken");
        address[] memory users;
        eventList[eventNonce] = EventData({
            eventName : _eventName,
            depositToken : _depositToken,
            depositTotal : 0,
            hardCap : _hardCap,
            maxContribut : _maxContribut,
            minContribut : _minContribut,
            FCFSTimer : _FCFSTimer,
            users : users,
            owner : msg.sender,
            active : true
        });
        emit Published(eventNonce, _eventName, _depositToken, _hardCap, _maxContribut, _minContribut, _FCFSTimer, msg.sender, true);
        eventNonce++;
    }

    function CloseEvent(uint256 _eventId) external onlyOwner {
        require(_eventId < eventNonce, "Invalid EventId");
        require(eventList[_eventId].active, "Event is not active");
        require(eventList[_eventId].hardCap == eventList[_eventId].depositTotal, "Not reached hardCap");
        
        TransferHelper.safeTransfer(eventList[_eventId].depositToken, msg.sender, eventList[_eventId].depositTotal);
        eventList[_eventId].active = false;
        emit Close(_eventId, eventList[_eventId].depositToken, eventList[_eventId].depositTotal);
    }

    function SetVested(uint256 _eventId, address _tokenAddress, uint256 _amount) external onlyOwner {
        require(_eventId < eventNonce, "Invalid EventId");
        require(eventList[_eventId].active == false, "Event is active");
        
        uint256 preBalance = IERC20(_tokenAddress).balanceOf(address(this));
        TransferHelper.safeTransferFrom(_tokenAddress, msg.sender, address(this), _amount);
        UserData[] memory data = getEventData(_eventId);

        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this)) - preBalance;
        for (uint256 i = 0; i < data.length; i++) {
            uint256 vestedBalance = balance * 1e18 * data[i].depositAmount / eventList[_eventId].depositTotal / 1e18;
            if (vestedBalance > 0) {
                TransferHelper.safeTransfer(_tokenAddress, data[i].user, vestedBalance);
                emit Vested(_eventId, data[i].user, _tokenAddress, vestedBalance);
            }
        }
        balance = IERC20(_tokenAddress).balanceOf(address(this));
        if (balance > preBalance) {
            TransferHelper.safeTransfer(_tokenAddress, msg.sender, balance - preBalance);
        }
    }

    function Deposit(uint256 _eventId, uint256 _depositAmount) external {
        require(_eventId < eventNonce, "Invalid EventId");
        require(eventList[_eventId].active, "Event is not active");
        require(eventList[_eventId].FCFSTimer < block.timestamp || eventList[_eventId].maxContribut >= _depositAmount, "Deposit is high");
        require(eventList[_eventId].minContribut <= _depositAmount, "Deposit is low");
        require(eventList[_eventId].hardCap >= eventList[_eventId].depositTotal + _depositAmount, "It is beyond hardCap");
        bool flag = false;
        ContributionData[] storage data = userList[msg.sender];
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].eventId ==  _eventId) {
                data[i].depositAmount += _depositAmount;
                require(eventList[_eventId].FCFSTimer < block.timestamp || eventList[_eventId].maxContribut >= data[i].depositAmount, "Deposit is high");
                eventList[_eventId].depositTotal += _depositAmount;
                TransferHelper.safeTransferFrom(eventList[_eventId].depositToken, msg.sender, address(this), _depositAmount);
                emit Contribution(_eventId, msg.sender, data[i].depositAmount);
                flag = true;
                break;
            }
        }
        if (!flag) {
            data.push(
                ContributionData({
                    eventId : _eventId,
                    depositAmount : _depositAmount
                })
            );
            eventList[_eventId].depositTotal += _depositAmount;
            TransferHelper.safeTransferFrom(eventList[_eventId].depositToken, msg.sender, address(this), _depositAmount);
            emit Contribution(_eventId, msg.sender, _depositAmount);
            address[] storage users = eventList[_eventId].users;
            users.push(msg.sender);
            eventList[_eventId].users = users;
        }
        userList[msg.sender] = data;
    }

    function Refund(uint256 _eventId, uint256 _refundAmount) external {
        require(_eventId < eventNonce, "Invalid EventId");
        require(eventList[_eventId].active, "Event is not active");
        ContributionData[] storage data = userList[msg.sender];
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].eventId ==  _eventId) {
                require(data[i].depositAmount >= _refundAmount, "Contributions are insufficient");
                data[i].depositAmount -= _refundAmount;
                eventList[_eventId].depositTotal -= _refundAmount;
                TransferHelper.safeTransfer(eventList[_eventId].depositToken, msg.sender, _refundAmount);
                emit Contribution(_eventId, msg.sender, data[i].depositAmount);
                userList[msg.sender] = data;
                break;
            }
        }
    }

    function getUserData(address _user, uint256 _eventId) public view returns (uint256 _depositAmount) {
        ContributionData[] memory data = userList[_user];
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].eventId ==  _eventId) {
                return data[i].depositAmount;
            }
        }
    }

    function getUserAllData(address _user) public view returns (ContributionData[] memory _userAllData) {
        return userList[_user];
    }
    
    function getEventData(uint256 _eventId) public view returns (UserData[] memory _userData) {
        address[] memory users = eventList[_eventId].users;
        UserData[] memory data = new UserData[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            data[i].user = users[i];
            data[i].depositAmount = getUserData(users[i], _eventId);
        }
        return data;
    }

}