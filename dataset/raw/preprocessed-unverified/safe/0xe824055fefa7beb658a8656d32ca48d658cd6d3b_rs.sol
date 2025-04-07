pragma solidity ^0.4.18;





contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;


	/**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	/**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
	modifier whenPaused() {
		require(paused);
		_;
	}

	/**
   * @dev called by the owner to pause, triggers stopped state
   */
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		Pause();
	}

	/**
   * @dev called by the owner to unpause, returns to normal state
   */
	function unpause() onlyOwner whenPaused public {
		paused = false;
		Unpause();
	}
}

contract CryptoLambos is Pausable, Destructible {
  using SafeMath for uint256;

  struct Lambo {
    string  model;
    address ownerAddress;
    uint256 price;
    bool    enabled;
    string  nickname;
    string  note;
  }

  Lambo[] public lambos;

  event Bought(uint256 id, string model, address indexed ownerAddress, uint256 price, string nickname, string note);
  event Added(uint256 id, string model, address indexed ownerAddress, uint256 price, bool enabled);
  event Enabled(uint256 id);

  function CryptoLambos() public { }

  function _calcNextPrice(uint256 _price) internal pure returns(uint256) {
    return _price
      .mul(13).div(10) // Add 30%
      .div(1 finney).mul(1 finney); // Round to 1 finney
  }

  function buy(uint256 _id, string _nickname, string _note) public payable whenNotPaused {
    Lambo storage _lambo = lambos[_id];

    require(_lambo.enabled);
    require(msg.value  >= _lambo.price);
    require(msg.sender != _lambo.ownerAddress);
    require(bytes(_nickname).length <= 50);
    require(bytes(_note).length <= 100);

    uint256 _price      = _lambo.price;
    uint256 _commission = _price.div(20);
    uint256 _payout     = _price - _commission;
    address _prevOwner  = _lambo.ownerAddress;
    uint256 _newPrice   = _calcNextPrice(_price);

    if (bytes(_lambo.nickname).length > 0) {
      delete _lambo.nickname;
    }
    
    if (bytes(_lambo.note).length > 0) {
      delete _lambo.note;
    }
    
    _lambo.ownerAddress = msg.sender;
    _lambo.price        = _newPrice;
    _lambo.nickname     = _nickname;
    _lambo.note         = _note;

    owner.transfer(_commission);
    _prevOwner.transfer(_payout);

    Bought(_id, _lambo.model, _lambo.ownerAddress, _lambo.price, _lambo.nickname, _lambo.note);
  }

  function getLambosCount() public view returns (uint256) {
    return lambos.length;
  }

  function enableLambo(uint256 _id) public whenNotPaused onlyOwner {
    require(!lambos[_id].enabled);

    lambos[_id].enabled = true;

    Enabled(_id);
  }

  function addLambo(string _model, uint256 _price, bool _enabled) public whenNotPaused onlyOwner {
    lambos.push(Lambo(_model, owner, _price, _enabled, "Crypto_Lambos", "Look ma! A Lambo!"));

    Added(lambos.length, _model, owner, _price, _enabled);
  }

  function withdrawAll() public onlyOwner {
    owner.transfer(this.balance);
  }
}