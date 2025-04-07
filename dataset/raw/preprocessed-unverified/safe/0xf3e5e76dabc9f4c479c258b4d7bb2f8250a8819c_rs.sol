/**
 *Submitted for verification at Etherscan.io on 2019-07-03
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

pragma solidity 0.5.7;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function decimals() public view returns (uint256);

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
}



/*
    Modified Util contract as used by Kyber Network
*/



contract Partner {

    address payable public partnerBeneficiary;
    uint256 public partnerPercentage; //This is out of 1 ETH, e.g. 0.5 ETH is 50% of the fee

    uint256 public companyPercentage;
    address payable public companyBeneficiary;

    event LogPayout(
        address token,
        uint256 partnerAmount,
        uint256 companyAmount
    );

    function init(
        address payable _companyBeneficiary,
        uint256 _companyPercentage,
        address payable _partnerBeneficiary,
        uint256 _partnerPercentage
    ) public {
        require(companyBeneficiary == address(0x0) && partnerBeneficiary == address(0x0));
        companyBeneficiary = _companyBeneficiary;
        companyPercentage = _companyPercentage;
        partnerBeneficiary = _partnerBeneficiary;
        partnerPercentage = _partnerPercentage;
    }

    function payout(
        address[] memory tokens
    ) public {
        // Payout both the partner and the company at the same time
        for(uint256 index = 0; index<tokens.length; index++){
            uint256 balance = tokens[index] == Utils.eth_address()? address(this).balance : ERC20(tokens[index]).balanceOf(address(this));
            uint256 partnerAmount = SafeMath.div(SafeMath.mul(balance, partnerPercentage), getTotalFeePercentage());
            uint256 companyAmount = balance - partnerAmount;
            if(tokens[index] == Utils.eth_address()){
                partnerBeneficiary.transfer(partnerAmount);
                companyBeneficiary.transfer(companyAmount);
            } else {
                ERC20SafeTransfer.safeTransfer(tokens[index], partnerBeneficiary, partnerAmount);
                ERC20SafeTransfer.safeTransfer(tokens[index], companyBeneficiary, companyAmount);
            }
        }
    }

    function getTotalFeePercentage() public view returns (uint256){
        return partnerPercentage + companyPercentage;
    }

    function() external payable {

    }
}

contract PartnerRegistry is Ownable {

    address target;
    mapping(address => bool) partnerContracts;
    address payable public companyBeneficiary;
    uint256 public companyPercentage;

    event PartnerRegistered(address indexed creator, address indexed beneficiary, address partnerContract);


    constructor(address _target, address payable _companyBeneficiary, uint256 _companyPercentage) public {
        target = _target;
        companyBeneficiary = _companyBeneficiary;
        companyPercentage = _companyPercentage;
    }

    function registerPartner(address payable partnerBeneficiary, uint256 partnerPercentage) external {
        Partner newPartner = Partner(createClone());
        newPartner.init(companyBeneficiary, companyPercentage, partnerBeneficiary, partnerPercentage);
        partnerContracts[address(newPartner)] = true;
        emit PartnerRegistered(address(msg.sender), partnerBeneficiary, address(newPartner));
    }

    function overrideRegisterPartner(
        address payable _companyBeneficiary,
        uint256 _companyPercentage,
        address payable partnerBeneficiary,
        uint256 partnerPercentage
    ) external onlyOwner {
        Partner newPartner = Partner(createClone());
        newPartner.init(_companyBeneficiary, _companyPercentage, partnerBeneficiary, partnerPercentage);
        partnerContracts[address(newPartner)] = true;
        emit PartnerRegistered(address(msg.sender), partnerBeneficiary, address(newPartner));
    }

    function deletePartner(address _partnerAddress) public onlyOwner {
        partnerContracts[_partnerAddress] = false;
    }

    function createClone() internal returns (address payable result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    function isValidPartner(address partnerContract) public view returns(bool) {
        return partnerContracts[partnerContract];
    }

    function updateCompanyInfo(address payable newCompanyBeneficiary, uint256 newCompanyPercentage) public onlyOwner {
        companyBeneficiary = newCompanyBeneficiary;
        companyPercentage = newCompanyPercentage;
    }
}