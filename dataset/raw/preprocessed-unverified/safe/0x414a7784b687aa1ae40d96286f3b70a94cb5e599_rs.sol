/**
 *Submitted for verification at Etherscan.io on 2019-10-13
*/

pragma solidity ^0.5.0;





contract PoapIndex
{
	using Set for Set.set;

	// Poap token address
	Poap public poap;

	// event to tokens
	mapping(uint256 => Set.set) private m_tokensEvent;

	event TokenAdded(uint256 indexed tokenId, uint256 indexed eventId);

	constructor(Poap _poap)
	public
	{
		poap = _poap;
	}

	function addToken(uint256 _tokenId) external
	{
		_addToken(_tokenId);
	}

	function addTokens(uint256[] calldata _tokenIds) external
	{
		for (uint256 i = 0; i < _tokenIds.length; ++i)
		{
			_addToken(_tokenIds[i]);
		}
	}

	function _addToken(uint256 _tokenId) internal
	{
		uint256 eventId = poap.tokenEvent(_tokenId);
		if (eventId != 0 && m_tokensEvent[eventId].add(_tokenId))
		{
			emit TokenAdded(_tokenId, eventId);
		}
	}

	function viewTokens(uint256 _eventId) external view returns (uint256[] memory)
	{
		return m_tokensEvent[_eventId].content();
	}
}