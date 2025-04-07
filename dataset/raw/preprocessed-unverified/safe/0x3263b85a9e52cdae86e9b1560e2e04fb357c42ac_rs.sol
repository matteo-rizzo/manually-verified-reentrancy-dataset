/**

 *Submitted for verification at Etherscan.io on 2019-05-31

*/



/**

 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.

 * Licensed under the Apache License, Version 2.0.

 */

 

pragma solidity 0.5.8;





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



/**

 * @title EIP20/ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract EIP20 is ERC20 {

    string public name;

    uint8 public decimals;

    string public symbol;

}



contract WETHInterface is EIP20 {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.

  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056

  uint256 internal constant REENTRANCY_GUARD_FREE = 1;



  /// @dev Constant for locked guard state

  uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;



  /**

   * @dev We use a single lock for the whole contract.

   */

  uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one `nonReentrant` function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and an `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");

    reentrancyLock = REENTRANCY_GUARD_LOCKED;

    _;

    reentrancyLock = REENTRANCY_GUARD_FREE;

  }



}



contract LoanTokenization is ReentrancyGuard, Ownable {



    uint256 internal constant MAX_UINT = 2**256 - 1;



    string public name;

    string public symbol;

    uint8 public decimals;



    address public bZxContract;

    address public bZxVault;

    address public bZxOracle;

    address public wethContract;



    address public loanTokenAddress;



    // price of token at last user checkpoint

    mapping (address => uint256) internal checkpointPrices_;

}



contract PositionTokenStorage is LoanTokenization {



    bool internal isInitialized_ = false;



    address public loanTokenLender;

    address public tradeTokenAddress;



    uint256 public leverageAmount;

    bytes32 public loanOrderHash;



    uint256 public initialPrice;

}



contract SplittableTokenStorage is PositionTokenStorage {

    using SafeMath for uint256;



    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

    event Mint(

        address indexed minter,

        uint256 tokenAmount,

        uint256 assetAmount,

        uint256 price

    );

    event Burn(

        address indexed burner,

        uint256 tokenAmount,

        uint256 assetAmount,

        uint256 price

    );



    mapping(address => uint256) internal balances;

    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 internal totalSupply_;



    uint256 public splitFactor = 10**18;



    function totalSupply()

        public

        view

        returns (uint256)

    {

        return denormalize(totalSupply_);

    }



    function balanceOf(

        address _owner)

        public

        view

        returns (uint256)

    {

        return denormalize(balances[_owner]);

    }



    function allowance(

        address _owner,

        address _spender)

        public

        view

        returns (uint256)

    {

        return denormalize(allowed[_owner][_spender]);

    }



    function normalize(

        uint256 _value)

        internal

        view

        returns (uint256)

    {

        return _value

            .mul(splitFactor)

            .div(10**18);

    }



    function denormalize(

        uint256 _value)

        internal

        view

        returns (uint256)

    {

        return _value

            .mul(10**18)

            .div(splitFactor);

    }

}



contract PositionToken is SplittableTokenStorage {



    address internal target_;



    constructor(

        address _newTarget)

        public

    {

        _setTarget(_newTarget);

    }



    function()

        external

        payable

    {

        address target = target_;

        bytes memory data = msg.data;

        assembly {

            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)

            let size := returndatasize

            let ptr := mload(0x40)

            returndatacopy(ptr, 0, size)

            switch result

            case 0 { revert(ptr, size) }

            default { return(ptr, size) }

        }

    }



    function setTarget(

        address _newTarget)

        public

        onlyOwner

    {

        _setTarget(_newTarget);

    }



    function _setTarget(

        address _newTarget)

        internal

    {

        require(_isContract(_newTarget), "target not a contract");

        target_ = _newTarget;

    }



    function _isContract(

        address addr)

        internal

        view

        returns (bool)

    {

        uint256 size;

        assembly { size := extcodesize(addr) }

        return size > 0;

    }

}