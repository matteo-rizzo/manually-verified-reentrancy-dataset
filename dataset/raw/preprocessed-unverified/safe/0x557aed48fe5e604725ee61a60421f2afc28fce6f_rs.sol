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




contract Minter {
    using SafeMath for uint256;

    uint256 constant public TARGET_SUPPLY = 2_200_000_000 * 1e18; // 2.2B tokens
    uint256 constant public DURATION = 155_520_000; // 1800 days in seconds
    uint256 private s_initialSupply;
    uint256 private s_startTime;
    uint256 private s_minted;
    address private s_beneficiary;
    IToken private s_token;
    bool private s_started;

    event Created(address sender, address token, address beneficiary);
    event Started(uint256 initialSupply, uint256 timestamp);
    event Minted(uint256 amount, uint256 timestamp);

    modifier onlyBeneficiary() {
      require(msg.sender == s_beneficiary, "not beneficiary");
      _;
    }

    constructor (IToken token, address beneficiary) public {
        s_token = token;
        s_beneficiary = beneficiary;
        emit Created(msg.sender, address(token), beneficiary);
    }

    receive () external payable {
        require(false, "Minter: not accepting ether");
    }

    function start() external onlyBeneficiary() {
        require(s_started == false, "TokenMinter: already started");
        require(s_token.getRoleMemberCount(s_token.MINTER_ADMIN_ROLE()) == 0, "TokenMinter: minter roles are not final");
        minterRoleValidation();
        s_started = true;
        s_initialSupply = s_token.totalSupply();
        s_startTime = block.timestamp;
        emit Started(s_initialSupply, block.timestamp);
    }
    
    function mint(uint256 amount) public onlyBeneficiary() {
        require(s_started == true, "TokenMinter: not started");
        require(amount > 0, "TokenMinter: nothing to mint");
        s_minted = s_minted.add(amount);
        require(s_minted <= mintLimit(), "TokenMinter: amount too high");
        s_token.mint(s_beneficiary, amount);
        emit Minted(amount, block.timestamp);
    }

    function mintAll() external {
        mint(mintLimit().sub(s_minted));
    }

    function minterRoleValidation() public view {
        require(s_token.hasRole(s_token.MINTER_ROLE(), address(this)), "TokenMinter: do not have a minter role");
        require(s_token.getRoleMemberCount(s_token.MINTER_ROLE()) == 1, "TokenMinter: minter role is not exclusive");
    }

    function mintLimit() public view returns (uint256) {
        uint256 maxMinting = TARGET_SUPPLY.sub(s_initialSupply);
        uint256 currentDuration = block.timestamp.sub(s_startTime);
        uint256 effectiveDuration = currentDuration < DURATION ? currentDuration : DURATION;
        return maxMinting.mul(effectiveDuration).div(DURATION);
    }

    function left() public view returns (uint256) {
        return TARGET_SUPPLY.sub(s_initialSupply).sub(s_minted);
    }

    function maxCap() external view returns (uint256) {
        return s_token.totalSupply().add(left());
    }

    function initialSupply() external view returns (uint256) {
        return s_initialSupply;
    }

    function startTime() external view returns (uint256) {
        return s_startTime;
    }

    function endTime() external view returns (uint256) {
        return s_startTime.add(DURATION);
    }

    function minted() external view returns (uint256) {
        return s_minted;
    }

    function beneficiary() external view returns (address) {
        return s_beneficiary;
    }

    function token() external view returns (address) {
        return address(s_token);
    }

    function started() external view returns (bool) {
        return s_started;
    }

}