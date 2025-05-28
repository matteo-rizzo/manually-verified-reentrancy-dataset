interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ECOExpansionLocker {
    IERC20 private _token;
    address private _beneficiary;
    uint256 private _releaseTime;

    constructor() public {
        _token = IERC20(address(0x95DA1E3eECaE3771ACb05C145A131Dca45C67FD4));
        _beneficiary = address(0x0CAF53b63b1F417A72170380Aa94fBFC15E95fcd);
        _releaseTime = 1630540800;

    }

    function token() public view returns (IERC20) {
        return _token;
    }

    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    function release() external {
        require(
            block.timestamp >= _releaseTime,
            "TokenTimelock: current time is before release time"
        );

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");
        _token.transfer(_beneficiary, amount);
    }
}
