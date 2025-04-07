/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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






contract GovVaultRewardAutoCompound {
    using SafeMath for uint;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 _flag) {
        if ((_flag & 0x1) == 0) {
            _;
        } else {
            uint gasStart = gasleft();
            _;
            uint gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    ITokenInterface public valueToken = ITokenInterface(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);

    address public govVault = address(0xceC03a960Ea678A2B6EA350fe0DbD1807B22D875);
    address public insuranceFund = address(0xb7b2Ea8A1198368f950834875047aA7294A2bDAa); // set to Governance Multisig at start
    address public exploitCompensationFund = address(0x0000000000000000000000000000000000000000); // to compensate who lost during the exploit on Nov 14 2020
    address public otherReserve = address(0x0000000000000000000000000000000000000000); // to reserve for future use

    uint public govVaultValuePerBlock = 0.2 ether;         // VALUE/block
    uint public insuranceFundValuePerBlock = 0;            // VALUE/block
    uint public exploitCompensationFundValuePerBlock = 0;  // VALUE/block
    uint public otherReserveValuePerBlock = 0;             // VALUE/block

    uint public lastRewardBlock;    // Last block number that reward distribution occurs.
    bool public minterPaused;       // if the minter is paused

    address public governance;

    event TransferToFund(address indexed fund, uint amount);

    constructor (ITokenInterface _valueToken, uint _govVaultValuePerBlock, uint _startBlock) public {
        if (address(_valueToken) != address(0)) valueToken = _valueToken;
        govVaultValuePerBlock = _govVaultValuePerBlock;
        lastRewardBlock = (block.number > _startBlock) ? block.number : _startBlock;
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }

    function setMinterPaused(bool _minterPaused) external onlyGovernance {
        minterPaused = _minterPaused;
    }

    function setGovVault(address _govVault) external onlyGovernance {
        govVault = _govVault;
    }

    function setInsuranceFund(address _insuranceFund) external onlyGovernance {
        insuranceFund = _insuranceFund;
    }

    function setExploitCompensationFund(address _exploitCompensationFund) external onlyGovernance {
        exploitCompensationFund = _exploitCompensationFund;
    }

    function setOtherReserve(address _otherReserve) external onlyGovernance {
        otherReserve = _otherReserve;
    }

    function setGovVaultValuePerBlock(uint _govVaultValuePerBlock) external onlyGovernance {
        require(_govVaultValuePerBlock <= 10 ether, "_govVaultValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        govVaultValuePerBlock = _govVaultValuePerBlock;
    }

    function setInsuranceFundValuePerBlock(uint _insuranceFundValuePerBlock) external onlyGovernance {
        require(_insuranceFundValuePerBlock <= 1 ether, "_insuranceFundValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        insuranceFundValuePerBlock = _insuranceFundValuePerBlock;
    }

    function setExploitCompensationFundValuePerBlock(uint _exploitCompensationFundValuePerBlock) external onlyGovernance {
        require(_exploitCompensationFundValuePerBlock <= 1 ether, "_exploitCompensationFundValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        exploitCompensationFundValuePerBlock = _exploitCompensationFundValuePerBlock;
    }

    function setOtherReserveValuePerBlock(uint _otherReserveValuePerBlock) external onlyGovernance {
        require(_otherReserveValuePerBlock <= 1 ether, "_otherReserveValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        otherReserveValuePerBlock = _otherReserveValuePerBlock;
    }

    function mintAndSendFund(uint8 _flag) public discountCHI(_flag) {
        if (minterPaused || lastRewardBlock >= block.number) {
            return;
        }
        uint numBlks = block.number.sub(lastRewardBlock);
        lastRewardBlock = block.number;
        if (govVaultValuePerBlock > 0) _safeValueMint(govVault, govVaultValuePerBlock.mul(numBlks));
        if (insuranceFundValuePerBlock > 0) _safeValueMint(insuranceFund, insuranceFundValuePerBlock.mul(numBlks));
        if (exploitCompensationFundValuePerBlock > 0) _safeValueMint(exploitCompensationFund, exploitCompensationFundValuePerBlock.mul(numBlks));
        if (otherReserveValuePerBlock > 0) _safeValueMint(otherReserve, otherReserveValuePerBlock.mul(numBlks));
    }

    // Safe valueToken mint, ensure it is never over cap and we are the current owner.
    function _safeValueMint(address _to, uint _amount) internal {
        if (valueToken.minters(address(this)) && _to != address(0)) {
            uint totalSupply = valueToken.totalSupply();
            uint realCap = valueToken.cap().add(valueToken.yfvLockedBalance());
            if (totalSupply.add(_amount) > realCap) {
                _amount = realCap.sub(totalSupply);
            }
            valueToken.mint(_to, _amount);
            emit TransferToFund(_to, _amount);
        }
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(ITokenInterface _token, uint _amount, address _to) external onlyGovernance {
        _token.transfer(_to, _amount);
    }
}