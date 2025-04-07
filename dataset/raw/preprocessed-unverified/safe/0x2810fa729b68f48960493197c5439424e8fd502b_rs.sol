/**
 *Submitted for verification at Etherscan.io on 2020-04-26
*/

pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// File: contracts/MultisigVaultETH.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract MultisigVaultETH {

    using SafeMath for uint256;

    struct Approval {
        bool transfered;
        uint256 coincieded;
        mapping(address => bool) coinciedeParties;
    }

    uint256 private participantsAmount;
    uint256 private signatureMinThreshold;
    address payable private serviceAddress;
    uint256 private serviceFeeMicro;

    string  private _symbol;
    uint8   private _decimals;

    address constant public ETHER_ADDRESS = address(0x1);

    mapping(address => bool) public parties;

    mapping(
        // Destination
        address => mapping(
            // Amount
            uint256 => Approval
        )
    ) public approvals;

    event ConfirmationReceived(address indexed from, address indexed destination, address currency, uint256 amount);
    event ConsensusAchived(address indexed destination, address currency, uint256 amount);

    /**
      * @dev Construcor.
      *
      * Requirements:
      * - `_signatureMinThreshold` .
      * - `_parties`.
      * - `_serviceAddress`.
      * - `_serviceFeeMicro` represented by integer amount of million'th fractions.
      */
    constructor(
        uint256 _signatureMinThreshold,
        address[] memory _parties,
        address payable _serviceAddress,
        uint256 _serviceFeeMicro
    ) public {
        require(_parties.length > 0 && _parties.length <= 10);
        require(_signatureMinThreshold > 0 && _signatureMinThreshold <= _parties.length);

        signatureMinThreshold = _signatureMinThreshold;
        serviceAddress = _serviceAddress;
        serviceFeeMicro = _serviceFeeMicro;

        _symbol = "ETH";
        _decimals = 18;

        for (uint256 i = 0; i < _parties.length; i++) parties[_parties[i]] = true;
    }

    modifier isMember() {
        require(parties[msg.sender]);
        _;
    }

    modifier sufficient(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }

    function partyCoincieded(
        address _destination,
        uint256 _amount,
        address _partyAddress
    ) public view returns (bool) {
        Approval storage approval = approvals[_destination][_amount];
        return approval.coinciedeParties[_partyAddress];
    }

    // https://ethereum.stackexchange.com/questions/19341/address-send-vs-address-transfer-best-practice-usage
    function approve(
        address payable _destination,
        uint256 _amount
    ) public isMember sufficient(_amount) returns (bool) {
        Approval storage approval  = approvals[_destination][_amount]; // Create new project

        if (!approval.coinciedeParties[msg.sender]) {
            approval.coinciedeParties[msg.sender] = true;
            approval.coincieded += 1;

            emit ConfirmationReceived(msg.sender, _destination, ETHER_ADDRESS, _amount);

            if (
                approval.coincieded >= signatureMinThreshold &&
                !approval.transfered
            ) {
                approval.transfered = true;

                uint256 _amountToWithhold = _amount.mul(serviceFeeMicro).div(1000000);
                uint256 _amountToRelease = _amount.sub(_amountToWithhold);

                _destination.transfer(_amountToRelease);    // Release funds
                serviceAddress.transfer(_amountToWithhold); // Take service margin

                emit ConsensusAchived(_destination, ETHER_ADDRESS, _amount);
            }

            return true;
        } else {
            // Raise will eat rest of gas. Lets not waist it. Just record this approval instead
            return false;
        }
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function() external payable { }
}