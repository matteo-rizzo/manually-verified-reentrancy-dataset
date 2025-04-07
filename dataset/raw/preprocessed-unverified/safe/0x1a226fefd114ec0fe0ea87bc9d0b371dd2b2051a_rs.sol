/**
 *Submitted for verification at Etherscan.io on 2021-08-20
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



contract Context {
	function _msgSender() internal view returns (address) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this;
		return msg.data;
	}
}





contract Controllable is Context {
    mapping (address => bool) public controllers;

	constructor () {
		address msgSender = _msgSender();
		controllers[msgSender] = true;
	}

	modifier onlyController() {
		require(controllers[_msgSender()], "Controllable: caller is not a controller");
		_;
	}

    function addController(address _address) public onlyController {
        controllers[_address] = true;
    }

    function removeController(address _address) public onlyController {
        delete controllers[_address];
    }
}

contract Pausable is Controllable {
	event Pause();
	event Unpause();

	bool public paused = false;

	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	modifier whenPaused() {
		require(paused);
		_;
	}

	function pause() public onlyController whenNotPaused {
		paused = true;
		emit Pause();
	}

	function unpause() public onlyController whenPaused {
		paused = false;
		emit Unpause();
	}
}

contract MNW_tokenswap is Controllable, Pausable {
	using SafeMath for uint256;
	using SafeERC20 for iERC20;

	mapping (address => bool) public blocklist;

    iERC20 public constant tokenOld = iERC20(0x7B0C06043468469967DBA22d1AF33d77d44056c8); 
    iERC20 public constant tokenNew = iERC20(0xd3E4Ba569045546D09CF021ECC5dFe42b1d7f6E4);
    address public tokenPool; // 0x8BbF984Be7fc6db1602E056AA4256D7FB1954BF4
    uint256 public blocked;

	constructor(address _tokenPool) {
        tokenPool = _tokenPool;
    	controllers[msg.sender] = true;
	}
	
	function switchPool(address _tokenPool) public onlyController {
	    tokenPool = _tokenPool;
	}

	function receiveEther() public payable {
		revert();
	}

    function swap() public {
        uint256 _amount = tokenOld.balanceOf(msg.sender);
        require(_amount > 0,"No balance of MRPH tokens");
        _swap(_amount);
    }

    function _swap(uint256 _amount) internal {
        tokenOld.safeTransferFrom(address(msg.sender), tokenPool, _amount);
        if (blocklist[msg.sender]) {
            blocked.add(_amount);
        } else {
            tokenNew.safeTransferFrom(tokenPool, address(msg.sender), _amount * (10 ** 14));
        }
        emit swapped(_amount);
    }
    
    function blockAddress(address _address, bool _state) external onlyController returns (bool) {
		blocklist[_address] = _state;
		return true;
	}

	function transferToken(address tokenAddress, uint256 amount) external onlyController {
		iERC20(tokenAddress).safeTransfer(msg.sender,amount);
	}

	function flushToken(address tokenAddress) external onlyController {
		uint256 amount = iERC20(tokenAddress).balanceOf(address(this));
		iERC20(tokenAddress).safeTransfer(msg.sender,amount);
	}

    event swapped(uint256 indexed amount);
}