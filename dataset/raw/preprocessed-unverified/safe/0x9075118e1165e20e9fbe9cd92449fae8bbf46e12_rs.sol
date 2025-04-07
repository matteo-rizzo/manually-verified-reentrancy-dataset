/**

 *Submitted for verification at Etherscan.io on 2019-04-15

*/



pragma solidity 0.5.7;











contract Core is Owned {



    string public name = "AdzBrick";

    string public symbol = "ADZB";

    uint256 public decimals = 18;

    mapping(address => mapping(address => uint256)) public userAllowances;



    constructor() public {



        userBalances[msg.sender] = _totalSupply;



    }



    function _transferCheck(address _sender, address _recipient, uint256 _amount) private view returns (bool success) {



        require(transferStatus == true);

        require(_amount > 0);

        require(_recipient != address(0));

        require(userBalances[_sender] >= _amount);

        require(SafeMath.safeSub(userBalances[_sender], _amount) >= 0);

        require(SafeMath.safeAdd(userBalances[_recipient], _amount) > userBalances[_recipient]);

        

        return true;



    }



    function transfer(address _receiver, uint256 _amount) public returns (bool status) {



        require(_transferCheck(msg.sender, _receiver, _amount));

        userBalances[msg.sender] = SafeMath.safeSub(userBalances[msg.sender], _amount);

        userBalances[_receiver] = SafeMath.safeAdd(userBalances[_receiver], _amount);

        

        emit Transfer(msg.sender, _receiver, _amount);

        

        return true;



    }



    function transferFrom(address _owner, address _receiver, uint256 _amount) public returns (bool status) {



        require(_transferCheck(_owner, _receiver, _amount));

        require(SafeMath.safeSub(userAllowances[_owner][msg.sender], _amount) >= 0);

        userAllowances[_owner][msg.sender] = SafeMath.safeSub(userAllowances[_owner][msg.sender], _amount);

        userBalances[_owner] = SafeMath.safeSub(userBalances[_owner], _amount);

        userBalances[_receiver] = SafeMath.safeAdd(userBalances[_receiver], _amount);

        

        emit Transfer(_owner, _receiver, _amount);



        return true;



    }



    function multiTransfer(address[] memory _destinations, uint256[] memory _values) public returns (uint256) {



        uint256 max = 0;



		for (uint256 i = 0; i < _destinations.length; i++) {

            require(transfer(_destinations[i], _values[i]));

            max = i;

        }



        return max;



    }



    function approve(address _spender, uint256 _amount) public returns (bool approved) {



        require(_amount >= 0);

        userAllowances[msg.sender][_spender] = _amount;

        

        emit Approval(msg.sender, _spender, _amount);



        return true;



    }



    function balanceOf(address _address) public view returns (uint256 balance) {



        return userBalances[_address];



    }



    function allowance(address _owner, address _spender) public view returns (uint256 allowed) {



        return userAllowances[_owner][_spender];



    }



    function totalSupply() public view returns (uint256 supply) {



        return _totalSupply;



    }



}