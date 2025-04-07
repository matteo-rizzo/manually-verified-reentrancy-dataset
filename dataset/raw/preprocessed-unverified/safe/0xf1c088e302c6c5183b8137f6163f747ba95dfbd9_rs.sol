/**

 *Submitted for verification at Etherscan.io on 2019-04-10

*/



pragma solidity ^0.4.24;







// ERC20Basic



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





// SafeMath











// Math









// Arrays









//Counters















// Ownable











// BasicToken



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }





  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    // SafeMath.sub will throw if there is not enough balance.

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];

  }



}







// ERC20



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  function transfer(address _to, uint256 _value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}









//



contract ERC20Snapshot is ERC20 {

    using SafeMath for uint256;

    using Arrays for uint256[];

    using Counters for Counters.Counter;





    struct Snapshots {

        uint256[] ids;

        uint256[] values;

    }



    mapping (address => Snapshots) private _accountBalanceSnapshots;

    Snapshots private _totalSupplySnaphots;





    Counters.Counter private _currentSnapshotId;



    event Snapshot(uint256 id);





    function snapshot() public returns (uint256) {

        _currentSnapshotId.increment();



        uint256 currentId = _currentSnapshotId.current();

        emit Snapshot(currentId);

        return currentId;

    }



    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {

        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);



        return snapshotted ? value : balanceOf(account);

    }



    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {

        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnaphots);



        return snapshotted ? value : totalSupply();

    }





    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)

        private view returns (bool, uint256)

    {

        require(snapshotId > 0);

        require(snapshotId <= _currentSnapshotId.current());



        uint256 index = snapshots.ids.findUpperBound(snapshotId);



        if (index == snapshots.ids.length) {

            return (false, 0);

        } else {

            return (true, snapshots.values[index]);

        }

    }



    function _updateAccountSnapshot(address account) private {

        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));

    }



    function _updateTotalSupplySnapshot() private {

        _updateSnapshot(_totalSupplySnaphots, totalSupply());

    }



    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {

        uint256 currentId = _currentSnapshotId.current();

        if (_lastSnapshotId(snapshots.ids) < currentId) {

            snapshots.ids.push(currentId);

            snapshots.values.push(currentValue);

        }

    }



    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {

        if (ids.length == 0) {

            return 0;

        } else {

            return ids[ids.length - 1];

        }

    }

}







//StandardToken



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit  Transfer(_from, _to, _value);

    return true;

  }



  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit  Approval(msg.sender, _spender, _value);

    return true;

  }



  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }



  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}







// MintableToken



contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;





  modifier canMint() {

    require(!mintingFinished);

    _;

  }





  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {



    totalSupply_ = totalSupply_.add(_amount);

    balances[_to] = balances[_to].add(_amount);

    Mint(_to, _amount);

    Transfer(address(0), _to, _amount);

    return true;

  }



  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    MintFinished();

    return true;

  }

}









// test



contract test is MintableToken, ERC20Snapshot {



    using SafeMath for uint256;

    string public name = "test";

    string public   symbol = "test";

    uint public   decimals = 18;

    bool public  TRANSFERS_ALLOWED = false;

    uint256 public MAX_TOTAL_SUPPLY = 10000000000 * (10 **18);





    struct LockParams {

        uint256 TIME;

        address ADDRESS;

        uint256 AMOUNT;

    }



    LockParams[] public  locks;



    event Burn(address indexed burner, uint256 value);



    function burnFrom(uint256 _value, address victim) onlyOwner canMint {

        require(_value <= balances[victim]);



        balances[victim] = balances[victim].sub(_value);

        totalSupply_ = totalSupply().sub(_value);



        Burn(victim, _value);

    }

    

    

    function burn(uint256 _value) onlyOwner {

        require(_value <= balances[msg.sender]);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        totalSupply_ = totalSupply().sub(_value);



        Burn(msg.sender, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(TRANSFERS_ALLOWED || msg.sender == owner);

        require(canBeTransfered(_from, _value));



        return super.transferFrom(_from, _to, _value);

    }





    function lock(address _to, uint256 releaseTime, uint256 lockamount) onlyOwner public returns (bool) {



        LockParams memory lockdata;

        lockdata.TIME = releaseTime;

        lockdata.AMOUNT = lockamount;

        lockdata.ADDRESS = _to;



        locks.push(lockdata);



        return true;

    }



    function canBeTransfered(address addr, uint256 value) onlyOwner public returns (bool){

        for (uint i=0; i<locks.length; i++) {

            if (locks[i].ADDRESS == addr){

                if ( value > balanceOf(addr).sub(locks[i].AMOUNT) && locks[i].TIME > now){



                    return false;

                }

            }

        }



        return true;

    }



    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

        if (totalSupply_.add(_amount) > MAX_TOTAL_SUPPLY){

            return false;

        }



        return super.mint(_to, _amount);

    }





    function transfer(address _to, uint256 _value) returns (bool){

        require(TRANSFERS_ALLOWED || msg.sender == owner);

        require(canBeTransfered(msg.sender, _value));



        return super.transfer(_to, _value);

    }







    function Pause() onlyOwner {

        TRANSFERS_ALLOWED = false;

    }



    function Unpause() onlyOwner {

        TRANSFERS_ALLOWED = true;

    }



}