/**
 *Submitted for verification at Etherscan.io on 2019-12-06
*/

pragma solidity ^0.5.2;


contract LibOwnable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns(address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "NOT_OWNER");
        _;
    }

    
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    
    
    
    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LibWhitelist is LibOwnable {
    mapping (address => bool) public whitelist;
    address[] public allAddresses;

    event AddressAdded(address indexed adr);
    event AddressRemoved(address indexed adr);

    
    modifier onlyAddressInWhitelist {
        require(whitelist[msg.sender], "SENDER_NOT_IN_WHITELIST_ERROR");
        _;
    }

    
    
    function addAddress(address adr) external onlyOwner {
        emit AddressAdded(adr);
        whitelist[adr] = true;
        allAddresses.push(adr);
    }

    
    
    function removeAddress(address adr) external onlyOwner {
        emit AddressRemoved(adr);
        delete whitelist[adr];
        for(uint i = 0; i < allAddresses.length; i++){
            if(allAddresses[i] == adr) {
                allAddresses[i] = allAddresses[allAddresses.length - 1];
                allAddresses.length -= 1;
                break;
            }
        }
    }

    
    function getAllAddresses() external view returns (address[] memory) {
        return allAddresses;
    }
}

contract IMarketContractPool {
    function mintPositionTokens(
        address marketContractAddress,
        uint qtyToMint,
        bool isAttemptToPayInMKT
    ) external;
    function redeemPositionTokens(
        address marketContractAddress,
        uint qtyToRedeem
    ) external;
    function mktToken() external view returns (address);
}











contract MintingPool is LibOwnable, LibWhitelist {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
    mapping(address => uint256) public minted;
    mapping(address => uint256) public redeemed;
    mapping(address => uint256) public sent;
    mapping(address => uint256) public received;

    event Mint(address indexed contractAddress, address indexed to, uint256 value);
    event Redeem(address indexed contractAddress, address indexed to, uint256 value);
    event Withdraw(address indexed tokenAddress, address indexed to, uint256 amount);
    event Approval(address indexed tokenAddress, address indexed spender, uint256 amount);

    
    
    
    function withdrawERC20(address token, uint256 amount)
        external
        onlyOwner
    {
        require(amount > 0, "INVALID_AMOUNT");

        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdraw(token, msg.sender, amount);
    }


    
    
    
    
    
    function approveERC20(address token, address spender, uint256 amount)
        public
        onlyOwner
    {
        IERC20(token).safeApprove(spender, amount);

        emit Approval(token, msg.sender, amount);
    }


    
    
    
    
    
    
    function internalMintPositionTokens(
        address marketContractAddress,
        uint qtyToMint,
        bool payInMKT
    )
        external
        onlyOwner
    {
        IMarketContract marketContract = IMarketContract(marketContractAddress);
        IMarketContractPool marketContractPool = IMarketContractPool(
            marketContract.COLLATERAL_POOL_ADDRESS()
        );
        marketContractPool.mintPositionTokens(
            marketContractAddress,
            qtyToMint,
            payInMKT
        );

        emit Mint(marketContractAddress, address(this), qtyToMint);
    }


    
    
    
    
    
    function internalRedeemPositionTokens(
        address marketContractAddress,
        uint qtyToRedeem
    )
        external
        onlyOwner
    {
        IMarketContract marketContract = IMarketContract(marketContractAddress);
        IMarketContractPool marketContractPool = IMarketContractPool(
            marketContract.COLLATERAL_POOL_ADDRESS()
        );
        marketContractPool.redeemPositionTokens(marketContractAddress, qtyToRedeem);

        emit Redeem(marketContractAddress, address(this), qtyToRedeem);
    }


    
    
    
    
    
    
    
    
    
    function mintPositionTokens(
        address marketContractAddress,
        uint qtyToMint,
        bool
    )
        external
        onlyAddressInWhitelist
    {
        require(qtyToMint > 0, "INVALID_AMOUNT");

        IMarketContract marketContract = IMarketContract(marketContractAddress);

        uint256 neededCollateral = calculateTotalCollateral(marketContract, qtyToMint);

        IERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransferFrom(
            msg.sender,
            address(this),
            neededCollateral
        );

        if (hasEnoughPositionBalance(marketContractAddress, qtyToMint)) {
            sent[marketContractAddress] = sent[marketContractAddress].add(qtyToMint);
        } else {
            uint256 neededMakretToken = calculateMarketTokenFee(marketContract, qtyToMint);

            IMarketContractPool marketContractPool = IMarketContractPool(
                marketContract.COLLATERAL_POOL_ADDRESS()
            );
            bool useMarketToken = hasEnoughBalance(
                marketContractPool.mktToken(),
                neededMakretToken
            );
            marketContractPool.mintPositionTokens(marketContractAddress, qtyToMint, useMarketToken);

            minted[marketContractAddress] = minted[marketContractAddress].add(qtyToMint);
        }

        IERC20(marketContract.LONG_POSITION_TOKEN()).safeTransfer(msg.sender, qtyToMint);
        IERC20(marketContract.SHORT_POSITION_TOKEN()).safeTransfer(msg.sender, qtyToMint);

        emit Mint(marketContractAddress, msg.sender, qtyToMint);
    }

    
    
    
    
    
    
    function redeemPositionTokens(
        address marketContractAddress,
        uint qtyToRedeem
    )
        external
        onlyAddressInWhitelist
    {
        require(qtyToRedeem > 0, "INVALID_AMOUNT");

        IMarketContract marketContract = IMarketContract(marketContractAddress);

        IERC20(marketContract.LONG_POSITION_TOKEN()).safeTransferFrom(
            msg.sender,
            address(this),
            qtyToRedeem
        );
        IERC20(marketContract.SHORT_POSITION_TOKEN()).safeTransferFrom(
            msg.sender,
            address(this),
            qtyToRedeem
        );

        uint256 collateralToReturn = calculateCollateralToReturn(marketContract, qtyToRedeem);

        if (hasEnoughBalance(marketContract.COLLATERAL_TOKEN_ADDRESS(), collateralToReturn)) {
            received[marketContractAddress] = received[marketContractAddress].add(qtyToRedeem);
        } else {
            IMarketContractPool marketContractPool = IMarketContractPool(
                marketContract.COLLATERAL_POOL_ADDRESS()
            );
            marketContractPool.redeemPositionTokens(marketContractAddress, qtyToRedeem);

            redeemed[marketContractAddress] = redeemed[marketContractAddress].add(qtyToRedeem);
        }
        IERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransfer(
            msg.sender,
            collateralToReturn
        );

        emit Redeem(marketContractAddress, msg.sender, qtyToRedeem);
    }

    
    
    
    
    function hasEnoughBalance(address tokenAddress, uint256 amount)
        internal
        view
        returns (bool)
    {
        return IERC20(tokenAddress).balanceOf(address(this)) >= amount;
    }

    
    
    
    
    function hasEnoughPositionBalance(address marketContractAddress, uint256 amount)
        internal
        view
        returns (bool)
    {
        IMarketContract marketContract = IMarketContract(marketContractAddress);
        return hasEnoughBalance(marketContract.LONG_POSITION_TOKEN(), amount)
            && hasEnoughBalance(marketContract.SHORT_POSITION_TOKEN(), amount);
    }

    
    
    
    
    function calculateTotalCollateral(IMarketContract marketContract, uint256 qtyToMint)
        internal
        view
        returns (uint256)
    {
        return marketContract.COLLATERAL_PER_UNIT()
            .add(marketContract.COLLATERAL_TOKEN_FEE_PER_UNIT())
            .mul(qtyToMint);
    }

    
    
    
    
    function calculateMarketTokenFee(IMarketContract marketContract, uint256 qtyToMint)
        internal
        view
        returns (uint256)
    {
        return marketContract.MKT_TOKEN_FEE_PER_UNIT().mul(qtyToMint);
    }

    
    
    
    
    function calculateCollateralToReturn(IMarketContract marketContract, uint256 qtyToRedeem)
        internal
        view
        returns (uint256)
    {
        return marketContract.COLLATERAL_PER_UNIT().mul(qtyToRedeem);
    }
}