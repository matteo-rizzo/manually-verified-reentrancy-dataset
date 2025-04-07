/**
 *Submitted for verification at Etherscan.io on 2021-04-03
*/

// Dependency file: contracts/token/IERC20.sol

// pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



// Dependency file: contracts/IToken.sol

// pragma solidity ^0.5.0;




// Dependency file: contracts/GSN/Context.sol

// pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: contracts/BridgeBase.sol

// pragma solidity ^0.5.0;

// import 'contracts/token/IERC20.sol';
// import 'contracts/IToken.sol';
// import 'contracts/GSN/Context.sol';

contract BridgeBase is Context {
    address public admin;
    IToken public token;
    mapping(uint256 => bool) public processedNonces;

    enum Step {Burn, Mint}
    event CrossTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 date,
        uint256 nonce,
        Step indexed step
    );

    constructor(address _token) public {
        admin = _msgSender();
        token = IToken(_token);
    }

    modifier onlyAdmin() {
        require(
            _msgSender() == admin,
            'Only admin is allowed to execute this operation.'
        );
        _;
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function updateTokenAdmin(address newAdmin) external onlyAdmin {
        token.updateAdmin(newAdmin);
    }

    function isProcessed(uint256 _nonce) external view returns (bool) {
        return processedNonces[_nonce];
    }

    function mint(
        address to,
        uint256 amount,
        uint256 otherChainNonce
    ) external onlyAdmin {
        require(
            processedNonces[otherChainNonce] == false,
            'transfer already processed'
        );
        processedNonces[otherChainNonce] = true;
        token.mint(to, amount);
        emit CrossTransfer(
            _msgSender(),
            to,
            amount,
            block.timestamp,
            otherChainNonce,
            Step.Mint
        );
    }
}


// Root file: contracts/BridgeEth.sol

pragma solidity ^0.5.0;

// import "contracts/BridgeBase.sol";

contract BridgeEth is BridgeBase {
    constructor(address token) public BridgeBase(token) {}
}