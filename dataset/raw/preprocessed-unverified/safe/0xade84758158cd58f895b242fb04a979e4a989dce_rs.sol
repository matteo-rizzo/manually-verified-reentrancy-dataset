/**

 *Submitted for verification at Etherscan.io on 2018-09-23

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol



/**

 * @title DetailedERC20 token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract DetailedERC20 is ERC20 {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }

}



// File: contracts/interface/IBasicMultiToken.sol



contract IBasicMultiToken is ERC20 {

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);

    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);



    ERC20[] public tokens;



    function tokensCount() public view returns(uint256);



    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;

    function bundle(address _beneficiary, uint256 _amount) public;



    function unbundle(address _beneficiary, uint256 _value) public;

    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;



    function disableBundling() public;

    function enableBundling() public;

}



// File: contracts/interface/IMultiToken.sol



contract IMultiToken is IBasicMultiToken {

    event Update();

    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);



    mapping(address => uint256) public weights;



    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);

    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);



    function disableChanges() public;

}



// File: contracts/interface/IMultiTokenInfo.sol



contract IMultiTokenInfo {

    function allTokens(IBasicMultiToken _mtkn) public view returns(ERC20[] _tokens);



    function allBalances(IBasicMultiToken _mtkn) public view returns(uint256[] _balances);



    function allDecimals(IBasicMultiToken _mtkn) public view returns(uint8[] _decimals);



    function allNames(IBasicMultiToken _mtkn) public view returns(bytes32[] _names);



    function allSymbols(IBasicMultiToken _mtkn) public view returns(bytes32[] _symbols);



    function allTokensBalancesDecimalsNamesSymbols(IBasicMultiToken _mtkn) public view returns(

        ERC20[] _tokens,

        uint256[] _balances,

        uint8[] _decimals,

        bytes32[] _names,

        bytes32[] _symbols

        );



    // MultiToken



    function allWeights(IMultiToken _mtkn) public view returns(uint256[] _weights);



    function allTokensBalancesDecimalsNamesSymbolsWeights(IMultiToken _mtkn) public view returns(

        ERC20[] _tokens,

        uint256[] _balances,

        uint8[] _decimals,

        bytes32[] _names,

        bytes32[] _symbols,

        uint256[] _weights

        );

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/ext/CheckedERC20.sol



