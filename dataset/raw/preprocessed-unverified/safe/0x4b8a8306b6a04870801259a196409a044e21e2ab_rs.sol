/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

pragma solidity ^0.5.8;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */


/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2дл.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor() public {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


contract WCKAds is ReentrancyGuard, Ownable, Pausable {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

    /* ********** */
    /* DATA TYPES */
    /* ********** */

    struct AdvertisingSlot {
        uint256 kittyIdBeingAdvertised;
        uint256 blockThatPriceWillResetAt;
        uint256 valuationPrice;
        address slotOwner;
    }

    /* ****** */
    /* EVENTS */
    /* ****** */

    event AdvertisingSlotRented(
        uint256 slotId,
        uint256 kittyIdBeingAdvertised,
        uint256 blockThatPriceWillResetAt,
        uint256 valuationPrice,
        address slotOwner
    );

    event AdvertisingSlotContentsChanged(
        uint256 slotId,
        uint256 newKittyIdBeingAdvertised
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    mapping (uint256 => AdvertisingSlot) public advertisingSlots;
    
    /* ********* */
    /* CONSTANTS */
    /* ********* */

    address public kittyCoreContractAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address public kittySalesContractAddress = 0xb1690C08E213a35Ed9bAb7B318DE14420FB57d8C;
    address public kittySiresContractAddress = 0xC7af99Fe5513eB6710e6D5f44F9989dA40F27F26;    
    address public wckContractAddress = 0x09fE5f0236F0Ea5D930197DCE254d77B04128075;
    uint256 public minimumPriceIncrementInBasisPoints = 500;
    uint256 public maxRentalPeriodInBlocks = 604800;
    uint256 public minimumRentalPrice = (10**18);

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    function getCurrentPriceToRentAdvertisingSlot(uint256 _slotId) external view returns (uint256) {
        AdvertisingSlot memory currentSlot = advertisingSlots[_slotId];
        if(block.number < currentSlot.blockThatPriceWillResetAt){
            return _computeNextPrice(currentSlot.valuationPrice);
        } else {
            return minimumRentalPrice;
        }
    }
    
    function ownsKitty(address _address, uint256 _kittyId) view public returns (bool) {
        if(KittyCore(kittyCoreContractAddress).ownerOf(_kittyId) == _address){
            return true;
        } else {
            address seller;
            (seller, , , , ) = KittyAuction(kittySalesContractAddress).getAuction(_kittyId);
            if(seller == _address){
                return true;
            } else {
                (seller, , , , ) = KittyAuction(kittySiresContractAddress).getAuction(_kittyId);
                if(seller == _address){
                    return true;
                } else {
                    return false; 
                }
            }
        }
    }

    function rentAdvertisingSlot(uint256 _slotId, uint256 _newKittyIdToAdvertise, uint256 _newValuationPrice) external nonReentrant whenNotPaused {
        require(ownsKitty(msg.sender, _newKittyIdToAdvertise), 'the CryptoKitties Nifty License requires you to own any kitties whose image you want to use');
        AdvertisingSlot storage currentSlot = advertisingSlots[_slotId];
        if(block.number < currentSlot.blockThatPriceWillResetAt){
            require(_newValuationPrice >= _computeNextPrice(currentSlot.valuationPrice), 'you must submit a higher valuation price if the rental term has not elapsed');
            ERC20(wckContractAddress).transferFrom(msg.sender, address(this), _newValuationPrice);
        } else {
            ERC20(wckContractAddress).transferFrom(msg.sender, address(this), minimumRentalPrice);
        }
        uint256 newBlockThatPriceWillResetAt = (block.number).add(maxRentalPeriodInBlocks);
        AdvertisingSlot memory newAdvertisingSlot = AdvertisingSlot({
            kittyIdBeingAdvertised: _newKittyIdToAdvertise,
            blockThatPriceWillResetAt: newBlockThatPriceWillResetAt,
            valuationPrice: _newValuationPrice,
            slotOwner: msg.sender
        });
        advertisingSlots[_slotId] = newAdvertisingSlot;
        emit AdvertisingSlotRented(
            _slotId,
            _newKittyIdToAdvertise,
            newBlockThatPriceWillResetAt,
            _newValuationPrice,
            msg.sender
        );
    }

    function changeKittyIdBeingAdvertised(uint256 _slotId, uint256 _kittyId) external nonReentrant whenNotPaused {
        require(ownsKitty(msg.sender, _kittyId), 'the CryptoKitties Nifty License requires you to own any kitties whose image you want to use');
        AdvertisingSlot storage currentSlot = advertisingSlots[_slotId];
        require(msg.sender == currentSlot.slotOwner, 'only the current owner of this slot can change the advertisements subject matter');
        currentSlot.kittyIdBeingAdvertised = _kittyId;
        emit AdvertisingSlotContentsChanged(
            _slotId,
            _kittyId
        );
    }

    function ownerUpdateMinimumRentalPrice(uint256 _newMinimumRentalPrice) external onlyOwner {
        minimumRentalPrice = _newMinimumRentalPrice;
    }

    function ownerUpdateMinimumPriceIncrement(uint256 _newMinimumPriceIncrementInBasisPoints) external onlyOwner {
        minimumPriceIncrementInBasisPoints = _newMinimumPriceIncrementInBasisPoints;
    }

    function ownerUpdateMaxRentalPeriod(uint256 _newMaxRentalPeriodInBlocks) external onlyOwner {
        maxRentalPeriodInBlocks = _newMaxRentalPeriodInBlocks;
    }

    function ownerWithdrawERC20(address _erc20Address, uint256 _value) external onlyOwner {
        ERC20(_erc20Address).transfer(msg.sender, _value);
    }

    function ownerWithdrawEther() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    constructor() public {}

    function() external payable {}

    function _computeNextPrice(uint256 _currentPrice) view internal returns (uint256) {
        return _currentPrice.add((_currentPrice.mul(minimumPriceIncrementInBasisPoints)).div(uint256(10000)));
    }
}

/// @title Interface for interacting with the previous version of the WCK contract
contract ERC20 {
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract KittyCore {
    function ownerOf(uint256 _tokenId) external view returns (address owner);
}

contract KittyAuction {
    function getAuction(uint256 _tokenId) external view returns (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    );
}