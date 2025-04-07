/**
 *Submitted for verification at Etherscan.io on 2021-03-14
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.6;



// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: IMoonCats



// Part: OpenZeppelin/[email protected]/IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// Part: Uniswap

// sushi router: 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
// uni router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D



// Part: OpenZeppelin/[email protected]/IERC721

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
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

// Part: cat20

interface cat20 is IERC20 {
	function multi721Deposit(uint256[] calldata _ids, address _referral) external;
}

// Part: ICatWrapper

interface ICatWrapper is IERC721 {
	function wrap(bytes5 catId) external;
	function totalSupply() external view returns (uint256);
	function unwrap(uint256 tokenID) external;
}

// File: CatSeller.sol

contract CatSeller {
	ICatWrapper constant wrapper = ICatWrapper(0x7C40c393DC0f283F318791d746d894DdD3693572);
	IMoonCats constant cats = IMoonCats(0x60cd862c9C687A9dE49aecdC3A99b74A4fc54aB6);

	cat20 constant tokenWrapper = cat20(0xf961A1Fa7C781Ecd23689fE1d0B7f3B6cBB2f972);
	Uniswap constant router = Uniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
	address constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

	constructor() public {
		tokenWrapper.approve(address(router), uint256(-1));
	}


	function nftsToEth(uint256[] calldata _tokenIds, uint256 _min, bytes calldata _data) external {
		address wrap = address(tokenWrapper);
		for (uint256 i = 0; i < _tokenIds.length; i++)
			wrapper.safeTransferFrom(msg.sender, wrap, _tokenIds[i], _data);
		_swapAll(_min);
	}

	function nftToEth(uint256 _tokenId, uint256 _min, bytes memory _data) public {
		wrapper.safeTransferFrom(msg.sender, address(tokenWrapper), _tokenId, _data);
		_swapAll(_min);
	}

	function _swapAll(uint256 _min) internal {
		address[] memory path = new address[](2);
		path[0] = address(tokenWrapper);
		path[1] = weth;

		router.swapExactTokensForETH(tokenWrapper.balanceOf(address(this)), _min, path, msg.sender, block.timestamp + 1);
	}
}