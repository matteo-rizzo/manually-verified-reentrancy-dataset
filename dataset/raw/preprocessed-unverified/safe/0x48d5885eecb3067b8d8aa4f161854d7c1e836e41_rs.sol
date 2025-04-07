/**
 *Submitted for verification at Etherscan.io on 2021-03-16
*/

/**                  ____ 
                  .'* *.'
               __/_*_*(_
              / _______ \
             _\_)/___\(_/_ 
            / _((\- -/))_ \
            \ \())(-)(()/ /
             ' \(((()))/ '
            / ' \)).))/ ' \
           / _ \ - | - /_  \
          (   ( .;''';. .'  )
          _\"__ /    )\ __"/_
            \/  \   ' /  \/
             .'  '...' ' )
              / /  |  \ \
             / .   .   . \
            /   .     .   \
           /   /   |   \   \
         .'   /    b    '.  '.
     _.-'    /     Bb     '-. '-._ 
 _.-'       |      BBb       '-.  '-. 
(___________\____.dBBBb.________)____)

╔╦╗┌─┐┌─┐┬┌─┐  ╔╗ ┌─┐┬  ┌─┐┌┐┌┌─┐┌─┐┬─┐
║║║├─┤│ ┬││    ╠╩╗├─┤│  ├─┤││││  ├┤ ├┬┘
╩ ╩┴ ┴└─┘┴└─┘  ╚═╝┴ ┴┴─┘┴ ┴┘└┘└─┘└─┘┴└─
     
     https://magicbalancer.org/
*/
// SPDX-License-Identifier: MIT

pragma solidity =0.6.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Allows anyone to claim a token if they exist in a merkle root.


contract MagicDistributor is IMerkleDistributor {
    address public immutable override token;


    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_) public {
        token = token_;
        
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account) external override {
        uint256 amount = 5e16;
        require(!isClaimed(index), 'MagicDistributor: Drop already claimed.');


        // Mark it claimed and send the token.
        _setClaimed(index);
        require(ERC20(token).transfer(account, amount), 'MagicDistributor: Transfer failed.');

        emit Claimed(index, account);
    }
}