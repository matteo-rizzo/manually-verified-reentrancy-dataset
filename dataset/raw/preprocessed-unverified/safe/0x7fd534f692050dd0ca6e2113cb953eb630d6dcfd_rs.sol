pragma experimental ABIEncoderV2;
pragma solidity 0.6.4;

contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}








contract RewardPool is Initializable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public theForceToken; // 奖励的FOR token地址
    address public bankController;//允许bankController从此合约中划账
    address public admin;

    modifier onlyAdmin {
        require(msg.sender == admin, "OnlyAdmin");
        _;
    }

    modifier onlyBankController {
        require(msg.sender == bankController, "require bankcontroller");
        _;
    }

    function initialize(address _theForceToken, address _bankController)
        public
        initializer
    {
        theForceToken = _theForceToken;
        bankController = _bankController;
        admin = msg.sender;
    }

    function deposit(uint256 amount) external {
        address who = msg.sender;
        require(
            IERC20(theForceToken).allowance(who, address(this)) >= amount,
            "insufficient allowance to deposit"
        );
        require(
            IERC20(theForceToken).balanceOf(who) >= amount,
            "insufficient balance to deposit"
        );
        IERC20(theForceToken).safeTransferFrom(who, address(this), amount);
    }

    function withdraw(uint256 amount) external onlyAdmin {
        IERC20(theForceToken).safeTransfer(msg.sender, amount);
    }

    function withdraw() external onlyAdmin {
        IERC20(theForceToken).safeTransfer(msg.sender, IERC20(theForceToken).balanceOf(address(this)));
    }

    function setTheForceToken(address _theForceToken) external onlyAdmin {
        theForceToken = _theForceToken;
    }

    function setBankController(address _bankController) external onlyAdmin {
        bankController = _bankController;
    }
    
    function reward(address who, uint256 amount) external onlyBankController {
        IERC20(theForceToken).safeTransfer(who, amount);
    }
}