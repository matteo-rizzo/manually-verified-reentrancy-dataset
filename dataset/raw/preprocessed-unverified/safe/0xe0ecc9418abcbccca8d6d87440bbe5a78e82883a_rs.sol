/**
 *Submitted for verification at Etherscan.io on 2021-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;









contract FTPLiqLock is Ownable {
    using SafeMath for uint256;
    
    UniFactory private Factory;

    address private m_WebThree;
    address private m_Factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    mapping (address => bool) private m_Locked;
    mapping (address => uint256) private m_PairRelease;
    mapping (address => address) private m_PayoutAddress;
    
    event Lock (address Contract);

    constructor() {
        Factory = UniFactory(m_Factory);
    }

    function setWebThree(address _address) external {
        require(msg.sender == owner() || msg.sender == m_WebThree);
        m_WebThree = _address;
    }

    function lockTokens(address _uniPair, uint256 _epoch, address _tokenPayout) external {
        require(Factory.getPair(UniV2Pair(_uniPair).token0(), UniV2Pair(_uniPair).token1()) == _uniPair, "Please only deposit UniV2 tokens");
        require(!m_Locked[_uniPair], "Liquidity already locked before");
        require(UniV2Pair(_uniPair).balanceOf(msg.sender).mul(100).div(UniV2Pair(_uniPair).totalSupply()) >= 98, "Caller must hold all UniV2 tokens");
        m_PairRelease[_uniPair] = _epoch;
        m_PayoutAddress[_uniPair] = _tokenPayout;
        UniV2Pair(_uniPair).transferFrom(address(msg.sender), address(this), UniV2Pair(_uniPair).balanceOf(msg.sender));
        m_Locked[_uniPair] = true;
        
        emit Lock(_uniPair);
    }
    
    function releaseTokens(address _uniPair) external {
        require(msg.sender == m_WebThree || msg.sender == m_PayoutAddress[_uniPair]);
        require(m_Locked[_uniPair], "No liquidity locked currently");
        require(UniV2Pair(_uniPair).balanceOf(address(this)) > 0, "No tokens to release");
        require(block.timestamp > m_PairRelease[_uniPair], "Lock expiration not reached");

        UniV2Pair(_uniPair).approve(address(this), UniV2Pair(_uniPair).balanceOf(address(this)));
        UniV2Pair(_uniPair).transfer(m_PayoutAddress[_uniPair], UniV2Pair(_uniPair).balanceOf(address(this)));
    }

    function getLockedTokens(address _uniPair) external view returns (bool Locked, uint256 ReleaseDate) {
        if(block.timestamp < m_PairRelease[_uniPair])
            return (true, m_PairRelease[_uniPair]);
        return (false, m_PairRelease[_uniPair]);
    }
}