/**
 *Submitted for verification at Etherscan.io on 2021-02-22
*/

pragma solidity ^0.8.1;




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract NexenVesting is Ownable {
    using SafeMath for uint256;

    TokenInterface public token;
    
    address[] public holders;
    
    mapping (address => Holding[]) public holdings;

    struct Holding {
        uint256 totalTokens;
        uint256 unlockDate;
        bool claimed;
    }
    
    // Events
    event VestingCreated(address _to, uint256 _totalTokens, uint256 _unlockDate);
    event TokensReleased(address _to, uint256 _tokensReleased);
    
    function getVestingByBeneficiary(address _beneficiary, uint256 _index) external view returns (uint256 totalTokens, uint256 unlockDate, bool claimed) {
        require(holdings[_beneficiary].length > _index, "The holding doesn't exist");
        Holding memory holding = holdings[_beneficiary][_index];
        totalTokens = holding.totalTokens;
        unlockDate = holding.unlockDate;
        claimed = holding.claimed;
    }
    
    function getTotalVestingsByBeneficiary(address _beneficiary) external view returns (uint256) {
        return holdings[_beneficiary].length;
    }

    function getTotalToClaimNowByBeneficiary(address _beneficiary) public view returns(uint256) {
        uint256 total = 0;
        
        for (uint256 i = 0; i < holdings[_beneficiary].length; i++) {
            Holding memory holding = holdings[_beneficiary][i];
            if (!holding.claimed && block.timestamp > holding.unlockDate) {
                total = total.add(holding.totalTokens);
            }
        }

        return total;
    }
    
    function getTotalVested() public view returns(uint256) {
        uint256 total = 0;
        
        for (uint256 i = 0; i < holders.length; i++) {
            for (uint256 j = 0; j < holdings[holders[i]].length; j++) {
                Holding memory holding = holdings[holders[i]][j];
                total = total.add(holding.totalTokens);
            }
        }

        return total;
    }
    
    function getTotalClaimed() public view returns(uint256) {
        uint256 total = 0;
        
        for (uint256 i = 0; i < holders.length; i++) {
            for (uint256 j = 0; j < holdings[holders[i]].length; j++) {
                Holding memory holding = holdings[holders[i]][j];
                if (holding.claimed) {
                    total = total.add(holding.totalTokens);
                }
            }
        }

        return total;
    }

    function claimTokens() external
    {
        uint256 tokensToClaim = getTotalToClaimNowByBeneficiary(msg.sender);
        require(tokensToClaim > 0, "Nothing to claim");
        
        for (uint256 i = 0; i < holdings[msg.sender].length; i++) {
            Holding storage holding = holdings[msg.sender][i];
            if (!holding.claimed && block.timestamp > holding.unlockDate) {
                holding.claimed = true;
            }
        }

        require(token.transfer(msg.sender, tokensToClaim), "Insufficient balance in vesting contract");
        emit TokensReleased(msg.sender, tokensToClaim);
    }
    
    function _addHolderToList(address _beneficiary) internal {
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == _beneficiary) {
                return;
            }
        }
        holders.push(_beneficiary);
    }

    function createVesting(address _beneficiary, uint256 _totalTokens, uint256 _unlockDate) public onlyOwner {
        token.transferFrom(msg.sender, address(this), _totalTokens);

        _addHolderToList(_beneficiary);
        Holding memory holding = Holding(_totalTokens, _unlockDate, false);
        holdings[_beneficiary].push(holding);
        emit VestingCreated(_beneficiary, _totalTokens, _unlockDate);
    }
    
    constructor(address _token) {
        token = TokenInterface(_token);
    }
}