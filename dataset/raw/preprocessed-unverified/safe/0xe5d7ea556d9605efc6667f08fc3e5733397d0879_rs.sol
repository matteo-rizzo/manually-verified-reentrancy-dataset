/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

pragma solidity ^0.4.26;






contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool); //real elf
  //function transfer(address _to, uint256 _value) public;
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  //function burnTokens(uint256 _amount) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract LockMapping is Owned {

    using SafeMath for uint256;
	event NewReceipt(uint256 receiptId, address asset, address owner, uint256 endTime);

	address public asset = 0xbf2179859fc6D5BEE9Bf9158632Dc51678a4100e;
	uint256 public saveTime = 86400*30; //30 days;
    uint256 public receiptCount = 0;

	struct Receipt {

		address asset;		//token to deposit  ELF:0xbf2179859fc6d5bee9bf9158632dc51678a4100e
	    address owner;		//owner of this receipt
	    string targetAddress;
	    uint256 amount;
	    uint256 startTime;
	    uint256 endTime;
	    bool finished;

  	}


  	Receipt[] public receipts;

  	mapping (uint256 => address) private receiptToOwner;
  	mapping (address => uint256[]) private ownerToReceipts;


  	modifier haveAllowance(address _asset, uint256 _amount) {

  		uint256 allowance = ERC20(asset).allowance(msg.sender, address(this));
	    require(allowance >= _amount);
	    _;
	}

	modifier exceedEndtime(uint256 _id) {

	    require(receipts[_id].endTime != 0 && receipts[_id].endTime <= now);
	    _;
	}

	modifier notFinished(uint256 _id) {

	    require(receipts[_id].finished == false);
	    _;
	}


  	function _createReceipt(
  		address _asset,
  		address _owner,
  		string _targetAddress,
  		uint256 _amount,
  		uint256 _startTime,
  		uint256 _endTime,
  		bool _finished
  		) internal {

	    uint256 id = receipts.push(Receipt(_asset, _owner, _targetAddress, _amount, _startTime, _endTime, _finished)) - 1;

        receiptCount = id + 1;
	    receiptToOwner[id] = msg.sender;
	    ownerToReceipts[msg.sender].push(id);
	    emit NewReceipt(id, _asset, _owner, _endTime);
	}


	//create new receipt
	function createReceipt(uint256 _amount, string targetAddress) external haveAllowance(asset,_amount) {

		//other processes

		//deposit token to this contract
		require (ERC20(asset).transferFrom(msg.sender, address(this), _amount));

		//
	    _createReceipt(asset, msg.sender, targetAddress, _amount, now, now + saveTime, false );
  	}

  	//finish the receipt and withdraw bonus and token
  	function finishReceipt(uint256 _id) external notFinished(_id) exceedEndtime(_id) {
        // only receipt owner can finish receipt
        require (msg.sender == receipts[_id].owner);
        ERC20(asset).transfer(receipts[_id].owner, receipts[_id].amount );
	    receipts[_id].finished = true;
  	}

    function getMyReceipts(address _address) external view returns (uint256[]){

        return ownerToReceipts[_address];

    }

    function getLockTokens(address _address) external view returns (uint256){
        uint256[] memory myReceipts = ownerToReceipts[_address!=address(0) ? _address:msg.sender];
        uint256 amount = 0;

        for(uint256 i=0; i< myReceipts.length; i++) {
            if(receipts[myReceipts[i]].finished == false){
                amount += receipts[myReceipts[i]].amount;
            }

        }

        return amount;
    }

  	function fixSaveTime(uint256 _period) external onlyOwner {
  		saveTime = _period;
  	}

    function getReceiptInfo(uint256 index) public view returns(bytes32, string, uint256, bool){

        return (sha256(index), receipts[index].targetAddress, receipts[index].amount, receipts[index].finished);

    }
}


