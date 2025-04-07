/**
 *Submitted for verification at Etherscan.io on 2021-09-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
    Fully commented standard ERC721 Distilled from OpenZeppelin Docs
    Base for Building ERC721 by offgridgecko
    Optimized and outfitted with the custom features our customers demand.
    
    
    Notes @dev from offgridgecko:
    -----------------------------
    Scroll to the bottom of the contract and update contractURI() for OpenSea
    Metadata collection json.
    
    Update tokenURI() with the proper naming convention for the collection
    
    Change the last line of supportsInterface() to reflect the contract name
    
    
    Emeejis Notes:
    --------------
    set tokenURI and contractURI as per emeejis standards, utilizing _baseURI if possible
*/




interface IERC721 is IERC165 {
    //@dev Emitted when `tokenId` token is transferred from `from` to `to`.
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    //@dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    //@dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    //@dev Returns the number of tokens in ``owner``'s account.
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from,address to,uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    //@dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Metadata is IERC721 {
    //@dev Returns the token collection name.
    function name() external view returns (string memory);

    //@dev Returns the token collection symbol.
    function symbol() external view returns (string memory);

    //@dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function tokenURI(uint256 tokenId) external view returns (string memory);
}





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



// ******************************************************************************************************************************
// **************************************************  Start of Main Contract ***************************************************
// ******************************************************************************************************************************

contract Emeejis is IERC721, Ownable {

    using Address for address;
    using Strings for uint256;
    
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // URI Root Location for Json Files
    string private _baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;
    // Mapping owner address to token count
    mapping(address => uint256) private _balances;
    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    //Contract Specific Variables and Mappings
    uint256 public maximumTokens;       //The total number of NFTs to be minted
    uint256 private _reserveTokens;     //Number of tokens reserved for Owner Distribution
    uint256 public tokenPrice;          //Current Sales Price from Contract
    uint256 public purchaseLimit;       //Maximum mints per transaction
    uint256 public numberMinted;        //Total minted so far
    
    //Map user address to payout percentage
    mapping(address => uint256) private percPayout;
    mapping(address => uint256) private payoutAmount;
    address[] private payees;
    
    bool reentrancyLock;                //lockdown fucntions to prevent reentrant attacks
    bool orderLock;                     //Lockup the mint function when not in use

    constructor() {
        _name = "Emeejis";
        _symbol = "EMG";
        _baseURI = "https://emeejis.com/metadata.php?tokenID=";
        
        tokenPrice = 35 * 10 ** 15; // 35 finney or 0.035 ETH
        maximumTokens = 6666;
        _reserveTokens = 200;
        purchaseLimit = 20;
        orderLock = true;
        
        payees.push(0xD15e7ab216AdDB92Bd95d96cb5D0F3f43719C679);  //Jovan
        payees.push(0x7B2a2e3813b7906C4E6573C80Ff73824AB69a4f9);  //Korvis
        payees.push(0x72b5216bd6Ee23a6FfC50340263dc9f8606DFe49);  //Chief
        payees.push(0xC7f02456dD3FC26aAE2CA1d68528CF9764bf5598);  //Squeebo
        payees.push(0x2496286BDB820d40C402802F828ae265b244188A);  //OGG
        payees.push(0xD0A1258f1cf379CB798Eea6776D9855F0B02F49B);  //Community
        payees.push(0x3B4B9283E1049E504e7E76e0A5e5E05630c9Ccd2);  //Charities
		
		percPayout[payees[0]] = 20; //Jovan
		percPayout[payees[1]] = 40;  //Korvis
		percPayout[payees[2]] = 5;  //Chief
		percPayout[payees[3]] = 5;  //Squeebo
		percPayout[payees[4]] = 5;  //OGG
		percPayout[payees[5]] = 10; //community
		percPayout[payees[6]] = 15; //charities
				
    }

    function orderEmeejis(uint256 orderSize) public payable {
        require(msg.value >= orderSize * tokenPrice, "orderEmeejis: Insufficient Funds");
        require(orderSize <= purchaseLimit, "orderEmeejis: Order Size too big");
        require(orderSize < maximumTokens - _reserveTokens - numberMinted, "orderEmeejis: Not enough NFTs remaining to fill order");
        require(!orderLock, "currently closed for business");
        
        require(!reentrancyLock);  //Lock up this whole function just in case
        reentrancyLock = true;
        
        uint256 mintSeedValue = numberMinted; //Store the starting value of the mint batch
        numberMinted += orderSize;
        
        //Handle ETH transactions
        uint256 cashIn = msg.value;
        uint256 cashChange = cashIn - (orderSize * tokenPrice);
        //assign approvals for payouts
        approvePayouts(cashIn);
        
        //send tokens
        for(uint256 i = 0; i < orderSize; i++) {
            _safeMint(msg.sender, mintSeedValue + i);
        }
                
        if (cashChange > 0){
            (bool success, bytes memory data) = msg.sender.call{value: cashChange}("");
            require(success, "orderEmeejis: unable to send change to user");
        }
        reentrancyLock = false;
    }

    function giveawayEmeeji(address _to, uint256 numberToMint) public onlyOwner {
        require(_to != address(0), "giveawayEmeeji: Cannot Send to 0 address");
        require(numberToMint < maximumTokens - numberMinted, "giveawayEmeeji: Not enough Emeejis remaining");
        
        uint256 currentToken = numberMinted;
        for (uint256 i; i < numberToMint; i++) {
            numberMinted++;
            if (_reserveTokens > 0) {
                _reserveTokens --;
            }
            _safeMint(_to, currentToken + i);
        }
    }
    
    function checkMyWallet() view external returns (uint256) {
    	//allows approved team members to check their current payout amount
    	return payoutAmount[_msgSender()];
    }
    
    function checkWallet(address checkAddress) view external onlyOwner returns(uint256) {
        //Checks for funds available to a specific address
        //OwnerOnly for now, mostly for testing purposes
        return payoutAmount[checkAddress];
    }
    
    function approvePayouts(uint256 purchaseAmount) internal {
    	//transaction totals sent here to assign approvals to each account on file
    	for (uint256 i; i < payees.length; i++){
    		payoutAmount[payees[i]] += (purchaseAmount * percPayout[payees[i]]) / 100;
    	}
    }
    
    function withdraw() external {
    	//payout approved amount to sender.
    	uint256 payout = payoutAmount[_msgSender()];
    	payoutAmount[_msgSender()] = 0;
    	
        (bool success, bytes memory data) = msg.sender.call{value: payout}("");
        require(success, "Withdraw: Could not transact funds");
    }

    // ************************************ Setters and Getters
    
    function lockOrders() external onlyOwner {
        orderLock = true;
    }
    
    function unlockOrders() external onlyOwner {
        orderLock = false;
    }

    function setTokenPrice(uint256 amount) public onlyOwner {
        tokenPrice = amount;
    }
    
    function setPurchaseLimit(uint256 amount) public onlyOwner {
        purchaseLimit = amount;
    }
    
    function setBaseURI(string memory uri_) public onlyOwner {
        _baseURI = uri_;
    }
    
    function setReserveTokens(uint amount) public onlyOwner {
        _reserveTokens = amount;
    }
    
    function setTotalTokens(uint256 numTokens) public onlyOwner {
        maximumTokens = numTokens;
    }
    
    function tokensRemaining() public view returns (uint256) {
        return maximumTokens - numberMinted;
    }
    
    function checkOrderLock() public view returns (bool) {
        return orderLock;
    }
    
    function checkReserves() public view returns (uint256) {
        return _reserveTokens;
    }

    // ***********************************************************************************************************************
    // **********************************************  ERC721 Standard Calls  ************************************************
    // ***********************************************************************************************************************


    //@dev See {IERC165-supportsInterface}. Interfaces Supported by this Standard
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return  interfaceId == type(IERC721).interfaceId ||
                interfaceId == type(IERC721Metadata).interfaceId ||
                interfaceId == type(IERC165).interfaceId ||
                interfaceId == Emeejis.onERC721Received.selector;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    
    // A standardized externally accessable burn function for coin owners
    function burn(uint256 tokenId) external virtual {
        require(_msgSender() == _owners[tokenId]);
        _burn(tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    
    // *********************** ERC721 Token Receiver **********************
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4) {
        //InterfaceID=0x150b7a02
        //return "0x150b7a02";
        return this.onERC721Received.selector;
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    
    // **************************************** Metadata Standard Functions **********
    //@dev Returns the token collection name.
    function name() external view returns (string memory) {
        return _name;
    }

    //@dev Returns the token collection symbol.
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    //@dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function tokenURI(uint256 tokenId) external view returns (string memory) {   //Fill out file location here later
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        //221 -> Emeeji221.json
        return string(abi.encodePacked(_baseURI, tokenId.toString(), ".json"));
    }
    
    // *******************************************************************************
    
    receive() external payable {
    approvePayouts(msg.value);    
    }
    
    fallback() external payable {
    approvePayouts(msg.value);    
    }
}