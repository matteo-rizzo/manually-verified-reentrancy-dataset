/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

// https://github.com/ethereum/EIPs/issues/20


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract SubscriptionsContract is Ownable {
    using SafeMath for uint256;
    
    address public feeWallet;
    address public currency;
    uint public feePercent;
    
    struct Subscription {
        address user;
        address merchant;
        string productId;
        string parentProductId;
        string status;
        bool unlimited;
        bool isSubProduct;
        uint cycles;
        uint payment;
        uint successPaymentsAmount;
        uint lastPaymentDate;
    }
    
    mapping(string => Subscription) private subscriptions;
    mapping(string => bool) private productPaused;
    
    event SubscriptionCreated(address user, address merchant, string subscriptionId, string productId);
    event SubscriptionMonthlyPaymentPaid(address user, address merchant, uint payment, uint lastPaymentDate);
    
    constructor(address _feeWallet, address _currency, uint _feePercent) public {
        feeWallet = _feeWallet;
        currency = _currency;
        feePercent = _feePercent;
    }
    
    function subscribeUser(address user, address merchant, string memory subscriptionId, string memory productId, uint cycles, uint payment, bool unlimited, bool isSubProduct, string memory parentProductId) public onlyOwner {
        require(ERC20(currency).balanceOf(user) >= payment, 'User doesnt have enough tokens for first payment');
        require(ERC20(currency).allowance(user, address(this)) >= payment.mul(cycles), 'User didnt approve needed amount of tokens');
        require(!productPaused[productId], 'Product paused by merchant');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("active"))), "User already has an active subscription for this merchant");
        
        if(subscriptions[subscriptionId].isSubProduct) {
            require(!productPaused[subscriptions[subscriptionId].parentProductId], "Parent product paused by merchant");
        }
        
        subscriptions[subscriptionId] = Subscription(user, merchant, productId, parentProductId, 'active', unlimited, isSubProduct, cycles, payment, 0, 0);
        emit SubscriptionCreated(user, merchant, subscriptionId, productId);
        processPayment(subscriptionId, payment);
    }
    
    function processPayment(string memory subscriptionId, uint payment) public onlyOwner {
        require((subscriptions[subscriptionId].successPaymentsAmount < subscriptions[subscriptionId].cycles) || subscriptions[subscriptionId].unlimited, 'Subscription is over');
        require((payment <= subscriptions[subscriptionId].payment) || subscriptions[subscriptionId].unlimited, 'Payment cant be more then started payment amount');
        require(!productPaused[subscriptions[subscriptionId].productId], 'Product paused by merchant');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("unsubscribe"))), 'Subscription must be unsubscribed');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("pause"))), 'Subscription must not be paused');
        
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, payment.mul(uint(1000).sub(feePercent)).div(1000).sub(300000000000000000)), "Transfer to merchant failed");
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, feeWallet, payment.mul(feePercent).div(1000).add(300000000000000000)), "Transfer to fee wallet failed");
        
        subscriptions[subscriptionId].status = "active";
        subscriptions[subscriptionId].lastPaymentDate = block.timestamp;
        subscriptions[subscriptionId].successPaymentsAmount = subscriptions[subscriptionId].successPaymentsAmount.add(1);
        
        emit SubscriptionMonthlyPaymentPaid(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, payment, subscriptions[subscriptionId].lastPaymentDate);
        
        if(subscriptions[subscriptionId].successPaymentsAmount == subscriptions[subscriptionId].cycles && !subscriptions[subscriptionId].unlimited) {
            subscriptions[subscriptionId].status = "end";
        }
    }
    
    function pauseSubscriptionsByMerchant(string memory productId) public onlyOwner {
        productPaused[productId] = true;
    }
    
    function activateSubscriptionsByMerchant(string memory productId) public onlyOwner {
        productPaused[productId] = false;
    }
    
    function unsubscribeBatchByMerchant(string[] memory subscriptionIds) public onlyOwner {
        for(uint i = 0; i < subscriptionIds.length; i++) {
            subscriptions[subscriptionIds[i]].status = "unsubscribe";
        }
    }
    
    function cancelSubscription(string memory subscriptionId) public onlyOwner {
        subscriptions[subscriptionId].status = "unsubscribe";
    }
    
    function pauseSubscription(string memory subscriptionId) public onlyOwner {
        require(ERC20(currency).balanceOf(subscriptions[subscriptionId].user) >= subscriptions[subscriptionId].payment.mul(125).div(1000), 'User doesnt have enough tokens for first payment');
        require(ERC20(currency).allowance(subscriptions[subscriptionId].user, address(this)) >= subscriptions[subscriptionId].payment.mul(125).div(1000), 'User didnt approve needed amount of tokens');
        
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, subscriptions[subscriptionId].payment.mul(10).div(100)), "Transfer to merchant failed");
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, feeWallet, subscriptions[subscriptionId].payment.mul(25).div(1000)), "Transfer to fee wallet failed");
        
        subscriptions[subscriptionId].status = "pause";
    }
    
    function activateSubscription(string memory subscriptionId) public onlyOwner {
        require((keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked("active"))), "Subscription already active");
        subscriptions[subscriptionId].status = "active";
    }
    
    function getSubscriptionStatus(string calldata subscriptionId) external view returns(string memory) {
        return subscriptions[subscriptionId].status;
    }
    
    function getSubscriptionDetails(string calldata subscriptionId) external view returns(Subscription memory) {
        return subscriptions[subscriptionId];
    }
    
}