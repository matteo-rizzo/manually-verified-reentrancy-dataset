/**

 *Submitted for verification at Etherscan.io on 2019-06-05

*/



pragma solidity 0.5.8;



/**

 * @title SafeMath 

 * @dev Unsigned math operations with safety checks that revert on error.

 */









contract Operable is Ownable {



    address private _operator; 



    event OperatorChanged(address indexed oldOperator, address indexed newOperator);



    /**

     * @dev Tells the address of the operator.

     * @return The address of the operator.

     */

    function operator() external view returns (address) {

        return _operator;

    }

    

    /**

     * @dev Only the operator can operate store.

     */

    modifier onlyOperator() {

        require(msg.sender == _operator, "msg.sender should be operator");

        _;

    }



    function isContract(address addr) internal view returns (bool) {

        uint size;

        assembly { size := extcodesize(addr) }

        return size > 0;

    }



    /**

     * @dev Update the storgeOperator.

     * @param _newOperator The newOperator to update.

     */

    function updateOperator(address _newOperator) public onlyOwner {

        require(_newOperator != address(0), "Cannot change the newOperator to the zero address");

        require(isContract(_newOperator), "New operator must be contract address");

        emit OperatorChanged(_operator, _newOperator);

        _operator = _newOperator;

    }



}



contract DUSDStorage is Operable {



    using SafeMath for uint256;

    bool private paused = false;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowances;

    mapping (address=>bool) private blackList;

    string private constant name = "Digital USD";

    string private constant symbol = "DUSD";

    uint8 private constant decimals = 18;

    uint256 private totalSupply;



    constructor() public {

        _owner = 0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1;

    }

    

    function getTokenName() public view onlyOperator returns (string memory) {

        return name;

    }

    

    function getSymbol() public view onlyOperator returns (string memory) {

        return symbol;

    }

    

    function getDecimals() public view onlyOperator returns (uint8) {

        return decimals;

    }

    

    function getTotalSupply() public view onlyOperator returns (uint256) {

        return totalSupply;

    }



    function getBalance(address _holder) public view onlyOperator returns (uint256) {

        return balances[_holder];

    }



    function addBalance(address _holder, uint256 _value) public onlyOperator {

        balances[_holder] = balances[_holder].add(_value);

    }



    function subBalance(address _holder, uint256 _value) public onlyOperator {

        balances[_holder] = balances[_holder].sub(_value);

    }



    function setBalance(address _holder, uint256 _value) public onlyOperator {

        balances[_holder] = _value;

    }

    

    function getAllowance(address _holder, address _spender) public view onlyOperator returns (uint256) {

        return allowances[_holder][_spender];

    }



    function addAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {

        allowances[_holder][_spender] = allowances[_holder][_spender].add(_value);

    }



    function subAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {

        allowances[_holder][_spender] = allowances[_holder][_spender].sub(_value);

    }



    function setAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {

        allowances[_holder][_spender] = _value;

    }



    function addTotalSupply(uint256 _value) public onlyOperator {

        totalSupply = totalSupply.add(_value);

    }



    function subTotalSupply(uint256 _value) public onlyOperator {

        totalSupply = totalSupply.sub(_value);

    }



    function setTotalSupply(uint256 _value) public onlyOperator {

        totalSupply = _value;

    }



    function addBlackList(address user) public onlyOperator {

        blackList[user] = true;

    }



    function removeBlackList (address user) public onlyOperator {

        blackList[user] = false;

    }

    

    function isBlackList(address user) public view onlyOperator returns (bool) {

        return blackList[user];

    }



    function getPaused() public view onlyOperator returns (bool) {

        return paused;

    }

    

    function pause() public onlyOperator {

        paused = true;

    }

    

    function unpause() public onlyOperator {

        paused = false;

    }



}