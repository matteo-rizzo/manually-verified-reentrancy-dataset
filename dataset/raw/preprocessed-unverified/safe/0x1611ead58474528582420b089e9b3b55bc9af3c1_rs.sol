/**

 *Submitted for verification at Etherscan.io on 2018-10-29

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



// File: contracts/interface/IBasicMultiToken.sol



contract IBasicMultiToken is ERC20 {

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);

    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);



    function tokensCount() public view returns(uint256);

    function tokens(uint i) public view returns(ERC20);

    function bundlingEnabled() public view returns(bool);

    

    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;

    function bundle(address _beneficiary, uint256 _amount) public;



    function unbundle(address _beneficiary, uint256 _value) public;

    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;



    // Owner methods

    function disableBundling() public;

    function enableBundling() public;



    bytes4 public constant InterfaceId_IBasicMultiToken = 0xd5c368b6;

      /**

       * 0xd5c368b6 ===

       *   bytes4(keccak256('tokensCount()')) ^

       *   bytes4(keccak256('tokens(uint256)')) ^

       *   bytes4(keccak256('bundlingEnabled()')) ^

       *   bytes4(keccak256('bundleFirstTokens(address,uint256,uint256[])')) ^

       *   bytes4(keccak256('bundle(address,uint256)')) ^

       *   bytes4(keccak256('unbundle(address,uint256)')) ^

       *   bytes4(keccak256('unbundleSome(address,uint256,address[])')) ^

       *   bytes4(keccak256('disableBundling()')) ^

       *   bytes4(keccak256('enableBundling()'))

       */

}



// File: contracts/interface/IMultiToken.sol



contract IMultiToken is IBasicMultiToken {

    event Update();

    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);



    function weights(address _token) public view returns(uint256);

    function changesEnabled() public view returns(bool);

    

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);

    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);



    // Owner methods

    function disableChanges() public;



    bytes4 public constant InterfaceId_IMultiToken = 0x81624e24;

      /**

       * 0x81624e24 ===

       *   InterfaceId_IBasicMultiToken(0xd5c368b6) ^

       *   bytes4(keccak256('weights(address)')) ^

       *   bytes4(keccak256('changesEnabled()')) ^

       *   bytes4(keccak256('getReturn(address,address,uint256)')) ^

       *   bytes4(keccak256('change(address,address,uint256,uint256)')) ^

       *   bytes4(keccak256('disableChanges()'))

       */

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/ext/CheckedERC20.sol







// File: contracts/ext/ExternalCall.sol







// File: contracts/network/MultiChanger.sol



contract IEtherToken is ERC20 {

    function deposit() public payable;

    function withdraw(uint256 amount) public;

}





contract MultiChanger {

    using SafeMath for uint256;

    using CheckedERC20 for ERC20;

    using ExternalCall for address;



    function() public payable {

        require(tx.origin != msg.sender);

    }



    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length

        for (uint i = 0; i < starts.length - 1; i++) {

            require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));

        }

    }



    // Ether



    function sendEthValue(address target, uint256 value) external {

        // solium-disable-next-line security/no-call-value

        require(target.call.value(value)());

    }



    function sendEthProportion(address target, uint256 mul, uint256 div) external {

        uint256 value = address(this).balance.mul(mul).div(div);

        // solium-disable-next-line security/no-call-value

        require(target.call.value(value)());

    }



    // Ether token



    function depositEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {

        etherToken.deposit.value(amount)();

    }



    function depositEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {

        uint256 amount = address(this).balance.mul(mul).div(div);

        etherToken.deposit.value(amount)();

    }



    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {

        etherToken.withdraw(amount);

    }



    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {

        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);

        etherToken.withdraw(amount);

    }



    // Token



    function transferTokenAmount(address target, ERC20 fromToken, uint256 amount) external {

        require(fromToken.asmTransfer(target, amount));

    }



    function transferTokenProportion(address target, ERC20 fromToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);

        require(fromToken.asmTransfer(target, amount));

    }



    function transferFromTokenAmount(ERC20 fromToken, uint256 amount) external {

        require(fromToken.asmTransferFrom(tx.origin, this, amount));

    }



    function transferFromTokenProportion(ERC20 fromToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);

        require(fromToken.asmTransferFrom(tx.origin, this, amount));

    }



    // MultiToken



    function multitokenChangeAmount(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 amount) external {

        if (fromToken.allowance(this, mtkn) == 0) {

            fromToken.asmApprove(mtkn, uint256(-1));

        }

        mtkn.change(fromToken, toToken, amount, minReturn);

    }



    function multitokenChangeProportion(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);

        this.multitokenChangeAmount(mtkn, fromToken, toToken, minReturn, amount);

    }

}