/**
 *Submitted for verification at Etherscan.io on 2019-09-02
*/

pragma solidity 0.5.10;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */


/**
 * @dev ERC20 MultiTransfer contract.
 * @author www.grox.solutions
 */
contract TokenPayment {

    uint8 private _recipientLimit = 7;

    /**
    *  Send tokens to each recipient
    *
    * @param _token - address of ERC20 token
    * @param _recipients - array of recipient addresses
    * @param _tokenAmounts - array of amounts of token to send
    */
    function multiTransfer(address _token, address[] memory _recipients, uint256[] memory _tokenAmounts) public {
        require(_recipients.length == _tokenAmounts.length);
        require(_recipients.length <= _recipientLimit);

        // Calculate total
        uint256 total;
        for (uint256 i = 0; i < _recipients.length; i++) {
            total += _tokenAmounts[i];
        }

        // Claim tokens from owner first
        IERC20(_token).transferFrom(msg.sender, address(this), total);

        // Transfer to recipients
        for (uint256 i = 0; i < _recipients.length; i++) {
            IERC20(_token).transfer(_recipients[i], _tokenAmounts[i]);
        }
    }

}