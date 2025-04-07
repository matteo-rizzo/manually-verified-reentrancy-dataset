/**
 *Submitted for verification at Etherscan.io on 2021-02-28
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */


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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



/**
    @title ERC-1155 Multi Token Standard
    @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md
    Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
abstract contract IERC1155 is IERC165 {
    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be msg.sender.
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_id` argument MUST be the token type being transferred.
        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be msg.sender.
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_ids` argument MUST be the list of tokens being transferred.
        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    /**
        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absense of an event assumes disabled).
    */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
        @dev MUST emit when the URI is updated for a token ID.
        URIs are defined in RFC 3986.
        The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    */
    event URI(string _value, uint256 indexed _id);

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external virtual;

    /**
        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if length of `_ids` is not the same as length of `_values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
        MUST revert on any other error.
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type (order and length must match _values array)
        @param _values  Transfer amounts per token type (order and length must match _ids array)
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`
    */
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external virtual;

    /**
        @notice Get the balance of an account's Tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the Token
        @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view virtual returns (uint256);

    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the Tokens
        @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view virtual returns (uint256[] memory);

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external virtual;

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the Tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator) external view virtual returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(type(IERC1155Receiver).interfaceId);
    }
}

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Holder is ERC1155Receiver {
    /**
     * @dev See {IERC1155Receiver-onERC1155Received}.
     *
     * Always returns `IERC1155Receiver.onERC1155Received.selector`.
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @dev See {IERC1155BatchReceiver-onERC1155BatchReceived}.
     *
     * Always returns `IERC1155BatchReceiver.onERC1155BatchReceived.selector`.
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

/*
Simple smart contract for creating ERC1155 sales.
Users can create a new NFT sale, it supports both ETH and ERC20 as a payment system,
but in this version each sale allows to define only one payment token per time.
The sale creator can modify the tokenWant (ERC20 or ETH) and the price per tokenId unit.
ERC721 is not supported in this version.
*/
contract VendingMachine is ERC1155Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Sale {
        address creator;
        address nft;
        uint256 tokenId;
        uint256 amountLeft;
        address tokenWant;
        uint256 pricePerUnit;
    }

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
    
    mapping (uint256 => Sale) public sales;
    uint256 newSaleId;

    event NewSale(
        address indexed creator, 
        address indexed nft, 
        uint256 tokenId, 
        uint256 amount, 
        address tokenWant, 
        uint256 pricePerUnit,
        uint256 saleId
    );
    event BuyNFT(address indexed buyer, uint256 saleId, uint256 amount);
    event CancelSale(address indexed creator, uint256 saleId, uint256 amountReturned);
    event ChangePricePerUnit(uint256 indexed saleId, uint256 pricePerUnit);
    event ChangeTokenWantAndPrice(uint256 indexed saleId, address tokenWant, uint256 pricePerUnit);

    /**
     * @dev Function for creating a new ERC1155 NFT sale using ETH as payment system
     * @param erc1155 erc1155 nft address related to tokenIds
     * @param tokenId nft ids to sell
     * @param amount nft ids amounts to sell
     * @param pricePerUnit price in wei for each unit
     */
    function createNFTSaleForETH(
        address erc1155,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerUnit
    ) external {
        // set address(0) for ETH as tokenWant
        _createERC1155Sale(erc1155, tokenId, amount, address(0), pricePerUnit);   
    }

    /**
     * @dev Function for creating a new ERC1155 NFT sale using ERC20 as payment system
     * @param erc1155 nft address to sell
     * @param tokenId nft id to sell
     * @param amount nft id amount to sell
     * @param tokenWant token want address 
     * @param pricePerUnit price in tokenWant, with decimals 
     */
    function createNFTSaleForERC20(
        address erc1155, 
        uint256 tokenId, 
        uint256 amount, 
        address tokenWant, 
        uint256 pricePerUnit
    ) external {
        _createERC1155Sale(erc1155, tokenId, amount, tokenWant, pricePerUnit);
    }

    /**
     * @dev Internal function for creating a new ERC1155 NFT sale
     * @param _erc1155 nft address to sell
     * @param _tokenId nft tokenId to sell
     * @param _amount nft tokenId amount to sell
     * @param _tokenWant token want address, address(0) for ETH
     * @param _pricePerUnit price per unit
     */
    function _createERC1155Sale(
        address _erc1155, 
        uint256 _tokenId, 
        uint256 _amount, 
        address _tokenWant, 
        uint256 _pricePerUnit
    ) 
        internal 
    {   
        // check if the nft address is erc1155 compliant
        require(IERC165(_erc1155).supportsInterface(_INTERFACE_ID_ERC1155));
        
        // check if amount transfered is correct
        _sendNFTToVending(_erc1155, _tokenId, _amount);
        
        // create new sale 
        Sale memory newSale = Sale(msg.sender, _erc1155, _tokenId, _amount, _tokenWant, _pricePerUnit);
        sales[newSaleId] = newSale;
        emit NewSale(msg.sender, _erc1155, _tokenId, _amount, _tokenWant, _pricePerUnit, newSaleId);
        newSaleId = newSaleId + 1;
    }

    /**
     * @dev Function for changing the price per NFT unit in a sale
     * @param saleId nft sale id
     * @param pricePerUnit price per unit to change
     */
    function changePricePerUnit(uint256 saleId, uint256 pricePerUnit) external {
        Sale storage sale = sales[saleId];
        require(sale.creator == msg.sender);
        sale.pricePerUnit = pricePerUnit;
        emit ChangePricePerUnit(saleId, pricePerUnit);
    }

    /**
     * @dev Funtion for changing the token want and price per NFT unit in a sale already opened
     * @param saleId nft sale id
     * @param tokenWant new token want address
     * @param pricePerUnit new price per unit, with decimals
     */
    function changeTokenWantAndPrice(uint256 saleId, address tokenWant, uint256 pricePerUnit) external {
        Sale storage sale = sales[saleId];
        require(sale.creator == msg.sender);
        sale.tokenWant = tokenWant;
        sale.pricePerUnit = pricePerUnit;
        emit ChangeTokenWantAndPrice(saleId, tokenWant, pricePerUnit);
    } 

    /**
     * @dev Function for buying one or more of the same NFT id in a sale
     * @param saleId nft sale id
     * @param amount amount of tokenId to buy in saleId 
     */
    function buyNFT(uint256 saleId, uint256 amount) external payable {
        Sale storage sale = sales[saleId];
        require(sale.amountLeft >= amount, 'Sale amount exceed');
        uint256 tokenTotalAmount = amount.mul(sale.pricePerUnit);
        
        // sale in ERC20
        if (sale.tokenWant != address(0)) {
            IERC20 tokenWant = IERC20(sale.tokenWant);
            require (tokenTotalAmount <= tokenWant.balanceOf(msg.sender), 'Balance of token want too low');
            tokenWant.safeTransferFrom(msg.sender, sale.creator, tokenTotalAmount);
        } else {
            require(msg.value  == tokenTotalAmount, 'Sent wrong amount of ETH');
            payable(sale.creator).transfer(msg.value);
        }
        
        // transfer nft to buyer
        _sendNFT(sale.nft, sale.tokenId, amount);
        sale.amountLeft = sale.amountLeft.sub(amount);
        emit BuyNFT(msg.sender, saleId, sale.amountLeft);
    }

    /**
     * @dev Internal function for sending tokenId amount to users
     * @param _nft address of erc1155 nft
     * @param _tokenId erc1155 nft tokenId
     * @param _amount amount to send
     */
    function _sendNFT(address _nft, uint256 _tokenId, uint256 _amount) internal {
       IERC1155 nft = IERC1155(_nft);
       uint256 amountBefore = nft.balanceOf(address(this), _tokenId);
       nft.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, '');
       uint256 amountAfter =  nft.balanceOf(address(this), _tokenId);
       require(amountAfter.add(_amount) == amountBefore, 'Wrong nft amount sent');
    }

    /**
     * @dev Internal function for sending tokenId amount to vending
     * @param _nft address of erc1155 nft
     * @param _tokenId erc1155 nft tokenId
     * @param _amount amount to send
     */
    function _sendNFTToVending(address _nft, uint256 _tokenId, uint256 _amount) internal {
        IERC1155 nft = IERC1155(_nft);
        uint256 amountBefore = nft.balanceOf(address(this), _tokenId);
        nft.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, '');
        uint256 amountAfter = nft.balanceOf(address(this), _tokenId);
        require (amountAfter.sub(amountBefore) == _amount, 'Wrong nft amount received');
    }

    /**
     * @dev Cancel a NFT sale, it transfers all amount left to sale creator
     * @param saleId to delete
     */
    function cancelSale(uint256 saleId) external {
        Sale memory sale = sales[saleId];
        require(sale.creator == msg.sender);
        require(sale.amountLeft > 0, 'Nothing left');

        // transfer amount left to sale creator and delete sales data
        _sendNFT(sale.nft, sale.tokenId, sale.amountLeft);
        delete sales[saleId];
        emit CancelSale(msg.sender, saleId, sale.amountLeft);
    }
}