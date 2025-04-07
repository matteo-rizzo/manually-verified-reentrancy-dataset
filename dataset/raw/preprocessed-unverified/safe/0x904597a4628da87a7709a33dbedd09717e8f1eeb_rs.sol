/**

 *Submitted for verification at Etherscan.io on 2018-11-22

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract BasicAccessControl {

    address public owner;

    // address[] public moderators;

    uint16 public totalModerators = 0;

    mapping (address => bool) public moderators;

    bool public isMaintaining = false;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    modifier onlyModerators() {

        require(msg.sender == owner || moderators[msg.sender] == true);

        _;

    }



    modifier isActive {

        require(!isMaintaining);

        _;

    }



    function ChangeOwner(address _newOwner) onlyOwner public {

        if (_newOwner != address(0)) {

            owner = _newOwner;

        }

    }





    function AddModerator(address _newModerator) onlyOwner public {

        if (moderators[_newModerator] == false) {

            moderators[_newModerator] = true;

            totalModerators += 1;

        }

    }

    

    function RemoveModerator(address _oldModerator) onlyOwner public {

        if (moderators[_oldModerator] == true) {

            moderators[_oldModerator] = false;

            totalModerators -= 1;

        }

    }



    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {

        isMaintaining = _isMaintaining;

    }

}







contract CubegoCoreInterface {

    function getMaterialSupply(uint _mId) constant external returns(uint);

    function getMyMaterialById(address _owner, uint _mId) constant external returns(uint);

    function transferMaterial(address _sender, address _receiver, uint _mId, uint _amount) external;

}



contract CubegoSilver is IERC20, BasicAccessControl {

    using SafeMath for uint;

    string public constant name = "CubegoSilver";

    string public constant symbol = "CUBSI";

    uint public constant decimals = 0;

    

    mapping (address => mapping (address => uint256)) private _allowed;

    uint public mId = 9;

    CubegoCoreInterface public cubegoCore;



    function setConfig(address _cubegoCoreAddress, uint _mId) onlyModerators external {

        cubegoCore = CubegoCoreInterface(_cubegoCoreAddress);

        mId = _mId;

    }



    function emitTransferEvent(address from, address to, uint tokens) onlyModerators external {

        emit Transfer(from, to, tokens);

    }



    function totalSupply() public view returns (uint256) {

        return cubegoCore.getMaterialSupply(mId);

    }



    function balanceOf(address owner) public view returns (uint256) {

        return cubegoCore.getMyMaterialById(owner, mId);

    }



    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    function transfer(address to, uint256 value) public returns (bool) {

        cubegoCore.transferMaterial(msg.sender, to, mId, value);

        return true;

    }



    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        cubegoCore.transferMaterial(from, to, mId, value);

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



}