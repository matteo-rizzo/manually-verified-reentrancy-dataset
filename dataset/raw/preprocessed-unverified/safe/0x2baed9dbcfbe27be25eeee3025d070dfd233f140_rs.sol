/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity ^0.6.0;


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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


//https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md






/**
 * An IERC900 staking contract
 */
contract Staking is IERC900, IDistributable {
    using SafeMath for uint256;

    uint256 PRECISION;

    event Profit(uint256 amount);

    uint256 public bond_value;
    //just for info
    uint256 public investor_count;

    uint256 private _total_staked;
    // the amount of dust left to distribute after the bond value has been updated
    uint256 public to_distribute;
    mapping(address => uint256) private _bond_value_addr;
    mapping(address => uint256) private _stakes;

    /// @dev handle to access ERC20 token token contract to make transfers
    IERC20 private _token;

    constructor(address token_address, uint256 decimals) public {
        _token = IERC20(token_address);
        PRECISION = 10**decimals;
    }
    
    /**
        @dev Stakes a certain amount of tokens, this MUST transfer the given amount from the addr
        @param amount Amount of ERC20 token to stake
        @param data Additional data as per the EIP900
    */
    function stake(uint256 amount, bytes calldata data) external override {
        //transfer the ERC20 token from the addr, he must have set an allowance of {amount} tokens
        require(_token.transferFrom(msg.sender, address(this), amount), "ERC20 token transfer failed, did you forget to create an allowance?");
        _stakeFor(msg.sender, amount, data);
    }

    /**
        @dev Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
        @param addr Address who will own the stake afterwards
        @param amount Amount of ERC20 token to stake
        @param data Additional data as per the EIP900
    */
    function stakeFor(address addr, uint256 amount, bytes calldata data) external override {
        //transfer the ERC20 token from the addr, he must have set an allowance of {amount} tokens
        require(_token.transferFrom(msg.sender, address(this), amount), "ERC20 token transfer failed, did you forget to create an allowance?");
        //create the stake for this amount
        _stakeFor(addr, amount, data);
    }

    /**
        @dev Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the addr, if unstaking is currently not possible the function MUST revert
        @param amount Amount of ERC20 token to remove from the stake
        @param data Additional data as per the EIP900
    */
    function unstake(uint256 amount, bytes calldata data) external override {
        _unstake(amount, data);
        //make the transfer
        require(_token.transfer(msg.sender, amount),"ERC20 token transfer failed");
    }

     /**
        @dev Withdraws rewards (basically unstake then restake)
        @param amount Amount of ERC20 token to remove from the stake
    */
    function withdraw(uint256 amount) external {
        _unstake(amount, "0x");
        _stakeFor(msg.sender, amount, "0x");
    }

    /**
        @dev Called by contracts to distribute dividends
        Updates the bond value
    */
    function distribute() external payable override virtual {
        _distribute(msg.value);
    }

    /**
        @dev Called by contracts to distribute dividends
        Updates the bond value
    */
    function _distribute(uint256 amount) internal {
        //cant distribute when no stakers
        require(_total_staked > 0, "cant distribute when no stakers");
        //take into account the dust
        uint256 temp_to_distribute = to_distribute.add(amount);
        uint256 total_bonds = _total_staked.div(PRECISION);
        uint256 bond_increase = temp_to_distribute.div(total_bonds);
        uint256 distributed_total = total_bonds.mul(bond_increase);
        bond_value = bond_value.add(bond_increase);
        //collect the dust
        to_distribute = temp_to_distribute.sub(distributed_total);
        emit Profit(amount);
    }

    /**
        @dev Returns the current total of tokens staked for an address
        @param addr address owning the stake
        @return the total of staked tokens of this address
    */
    function totalStakedFor(address addr) external view override returns (uint256) {
        return _stakes[addr];
    }
    
    /**
        @dev Returns the current total of tokens staked
        @return the total of staked tokens
    */
    function totalStaked() external view override returns (uint256) {
        return _total_staked;
    }

    /**
        @dev Address of the token being used by the staking interface
        @return ERC20 token token address
    */
    function token() external view override returns (address) {
        return address(_token);
    }

    /**
        @dev MUST return true if the optional history functions are implemented, otherwise false
        We dont want this
    */
    function supportsHistory() external pure override returns (bool) {
        return false;
    }

    /**
        @dev Returns how much ETH the user can withdraw currently
        @param addr Address of the user to check reward for
        @return the amount of ETH addr will perceive if he unstakes now
    */
    function getReward(address addr) public view returns (uint256) {
        return _getReward(addr,_stakes[addr]);
    }

    /**
        @dev Returns how much ETH the user can withdraw currently
        @param addr Address of the user to check reward for
        @param amount Number of stakes
        @return the amount of ETH addr will perceive if he unstakes now
    */
    function _getReward(address addr, uint256 amount) internal view returns (uint256) {
        return amount.mul(bond_value.sub(_bond_value_addr[addr])).div(PRECISION);
    }

    /**
        @dev Internally unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the addr, if unstaking is currently not possible the function MUST revert
        @param amount Amount of ERC20 token to remove from the stake
        @param data Additional data as per the EIP900
    */
    function _unstake(uint256 amount, bytes memory data) internal {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= _stakes[msg.sender], "You dont have enough staked");
        uint256 to_reward = _getReward(msg.sender, amount);
        _total_staked = _total_staked.sub(amount);
        _stakes[msg.sender] = _stakes[msg.sender].sub(amount);
        if(_stakes[msg.sender] == 0) {
            investor_count--;
        }
        //take into account dust error during payment too
        if(address(this).balance >= to_reward) {
            msg.sender.transfer(to_reward);
        } else {
            //we cant pay the dust error, just void the balance
            msg.sender.transfer(address(this).balance);
        }
        
        emit Unstaked(msg.sender, amount, _total_staked, data);
    }

    /**
        @dev Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
        @param addr Address who will own the stake afterwards
        @param amount Amount of ERC20 token to stake
        @param data Additional data as per the EIP900
    */
    function _stakeFor(address addr, uint256 amount, bytes memory data) internal {
        require(amount > 0, "Amount must be greater than zero");
        require(addr != address(0));
        _total_staked = _total_staked.add(amount);
        if(_stakes[addr] == 0) {
            investor_count++;
        }

        uint256 accumulated_reward = getReward(addr);
        _stakes[addr] = _stakes[addr].add(amount);
        
        uint256 new_bond_value = accumulated_reward.div(_stakes[addr].div(PRECISION));
        _bond_value_addr[addr] = bond_value.sub(new_bond_value);
        emit Staked(msg.sender, amount, _total_staked, data);
    }
}

/**
 * The knights staking contract for receiving eth
 * KnightsA is the knights ETH equity token
 */
contract KnightsStaking is Staking {

    constructor(address knighta_address) public
    Staking(knighta_address, 18)
    {
    }
}