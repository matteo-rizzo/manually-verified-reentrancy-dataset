/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

pragma solidity ^0.4.24;// SPDX-License-Identifier: MIT



//True POZ Token will have this, 
// stakeOf(address account) public view returns (uint256)
// SPDX-License-Identifier: MIT



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
}/**
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
}/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
// SPDX-License-Identifier: MIT








contract Benefit is IPOZBenefit, Ownable {
    constructor() public {
        MinHold = 1;
        ChecksCount = 0;
    }

    struct BalanceCheckData {
        bool IsToken; //token or staking contract address
        address ContractAddress; // the address of the token or the staking
        address LpContract; // check the current Token Holdin in Lp
    }

    uint256 public MinHold; //minimum total holding to be POOLZ Holder
    mapping(uint256 => BalanceCheckData) CheckList; //All the contracts to get the sum
    uint256 public ChecksCount; //Total Checks to make

    function SetMinHold(uint256 _MinHold) public onlyOwner {
        require(_MinHold > 0, "Must be more then 0");
        MinHold = _MinHold;
    }

    function AddNewLpCheck(address _Token, address _LpContract)
        public
        onlyOwner
    {
        CheckList[ChecksCount] = BalanceCheckData(false, _Token, _LpContract);
        ChecksCount++;
    }

    function AddNewToken(address _ContractAddress) public onlyOwner {
        CheckList[ChecksCount] = BalanceCheckData(
            true,
            _ContractAddress,
            address(0x0)
        );
        ChecksCount++;
    }

    function AddNewStaking(address _ContractAddress) public onlyOwner {
        CheckList[ChecksCount] = BalanceCheckData(
            false,
            _ContractAddress,
            address(0x0)
        );
        ChecksCount++;
    }

    function RemoveLastBalanceCheckData() public onlyOwner {
        require(ChecksCount > 0, "Can't remove from none");
        ChecksCount--;
    }

    function RemoveAll() public onlyOwner {
        ChecksCount = 0;
    }

    function CheckBalance(address _Token, address _Subject)
        internal
        view
        returns (uint256)
    {
        return ERC20(_Token).balanceOf(_Subject);
    }

    function CheckStaking(address _Contract, address _Subject)
        internal
        view
        returns (uint256)
    {
        return IStaking(_Contract).stakeOf(_Subject);
    }

    function IsPOZHolder(address _Subject) external view returns (bool) {
        return CalcTotal(_Subject) >= MinHold;
    }

    function CalcTotal(address _Subject) public view returns (uint256) {
        uint256 Total = 0;
        for (uint256 index = 0; index < ChecksCount; index++) {
            if (CheckList[index].LpContract == address(0x0)) {
                Total =
                    Total +
                    (
                        CheckList[index].IsToken
                            ? CheckBalance(
                                CheckList[index].ContractAddress,
                                _Subject
                            )
                            : CheckStaking(
                                CheckList[index].ContractAddress,
                                _Subject
                            )
                    );
            } else {
                Total =
                    Total +
                    _CalcLP(
                        CheckList[index].LpContract,
                        CheckList[index].ContractAddress,
                        _Subject
                    );
            }
        }
        return Total;
    }

    function _CalcLP(
        address _Contract,
        address _Token,
        address _Subject
    ) internal view returns (uint256) {
        uint256 TotalLp = ERC20(_Contract).totalSupply();
        uint256 SubjectLp = ERC20(_Contract).balanceOf(_Subject);
        uint256 TotalTokensOnLp = ERC20(_Token).balanceOf(_Contract);
        //SubjectLp * TotalTokensOnLp / TotalLp
        return SafeMath.div(SafeMath.mul(SubjectLp, TotalTokensOnLp), TotalLp);
    }
}