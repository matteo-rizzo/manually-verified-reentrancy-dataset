/**
 *Submitted for verification at Etherscan.io on 2021-06-07
*/

/**
  #SHIBIES #TREATS

   Our fully decentralized website ***** shibiestreats.crypto *****   powered by Unstoppable Domains, IPFS, Pinata and Shiba Inus
   
   All Shibas <3 TREATS!

   Finally the long hunger will come to an end! 
   The most delicious TREATS that the best INUs deserve. 
   We are SHIBIES a very yummy and experimental decentralized community MEME Treat Token Project for all hungry SHIBA INUs. 
   We celebrate this big ascent of Shiba Inu Token and surprise the community with our tasty TREATS.
   Over 50% of TREATS will burned and 40% will be distributed 1:1 to every SHIB and AKITA holder except exchanges and big holder. 
   The small rest will be used for charities and promotion.
   New unique delicacies from SHIBIES will primarily go to TREATS holder!
   Because SHIBAs love our TREATS so much, the supply is reduced with each transaction.
   and every holder gets fully automatically rewards but on Ethereum only! 
   We almost love Ethereum like Shibas.
   The best you HODL TREATS for ever, so that your Shiba never has to go hungry again!

   Because the very high Ethereum gas fees, we distribute our TREATS via Polygon/Matic Network!
   Use the same keys form your Ethereum Wallet in Polygon/Matic to get your tokens.
   Withdrawals from Polygon/Matic to Ethereum are excluded from fee.

   Features: 
   Total supply 1,100,000,000,000,000 TREATS
   TREATS can be used for farming new tasty tokens frum us in the future 
   Over 50% burn to the burnaddress
   40% distribute 1:1 to SHIB and AKITA holder but big holder get maximal 0.05% of total supply for better decentralization and we burn the other tokens
   4% distribute for promotion at the beginning phase
   4% distribute to charities and open projects:

   UNICEF France              5.500.000.000.000 TREATS   0.5%
   India Covid Relief Fund    5.500.000.000.000 TREATS   0.5%
   CoolEarth                  5.500.000.000.000 TREATS   0.5%
   Freedom of the Press       5.500.000.000.000 TREATS   0.5%
   Internet Archive           5.500.000.000.000 TREATS   0.5%
   Tor Project                5.500.000.000.000 TREATS   0.5%
   Gitcoin                    5.500.000.000.000 TREATS   0.5%
   CoinGecko                  1.100.000.000.000 TREATS   0.1%
   Etherscan                  1.100.000.000.000 TREATS   0.1%
   MyEtherWallet              1.100.000.000.000 TREATS   0.1%
   Polygon Foundation         1.100.000.000.000 TREATS   0.1%
   Shib Token Developer       1.100.000.000.000 TREATS   0.1%

   Variable transaction fee with auto rewards to all holders:

   1%                    0+ TREATS
   2%                  100+ TREATS
   3%                1,000+ TREATS
   4%               10,000+ TREATS
   5%              100,000+ TREATS
   6%            1,000,000+ TREATS
   8%           10,000,000+ TREATS
   10%         100,000,000+ TREATS
   12%       1,000,000,000+ TREATS
   15%      10,000,000,000+ TREATS
   20%   1,000,000,000,000+ TREATS

   Polygon/Matic Network is excluded from fees and rewards
   Withdrawals from Polygon/Matic to Ethereum are excluded from fee
   Charities and owner excluded from fee
   Rewards to TREATS holder on Ethereum only
   
   With our variable transaction fee, we want to avoid many large transactions for better decentralization. 
   We would like to attract so more small holders in order to become an even larger community. 
   Because the token supply is still high at the beginning, higher transaction fees will apply and early holders get more rewards. 
   The minimum fee will always be at least 1%.

   This is a full decentralized community token and we will burn the ownership after full distrubation.
   No sale or team tokens!

   Our fully decentralized website **** shibiestreats.crypto ****   powered by Unstoppable Domains, IPFS, Pinata and Shiba Inus

   */


pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed



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
 



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */


    
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    //uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract ShibiesTreats is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwn;
    mapping (address => uint256) private _tOwn;
    mapping (address => mapping (address => uint256)) private _allow;

    mapping (address => bool) private _excludedFee;

    mapping (address => bool) private _excluded;
    address[] private _exclude;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1.1 * 10**15 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFee;

    string private _name = "Shibies Treats";
    string private _symbol = "TREATS";
    uint8 private _decimals = 18;
    
    uint256 public _transFee = 1;
    address _polyBridge = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;

 constructor () public {
        _rOwn[_msgSender()] = _rTotal;
        
        //exclude this contract, owner and zero address from fee
        _excludedFee[owner()] = true;
        _excludedFee[address(this)] = true;
        _excludedFee[0x0000000000000000000000000000000000000000] = true;

        //exclude charities and projects from fee
        _excludedFee[0xA59B29d7dbC9794d1e7f45123C48b2b8d0a34636] = true; //UNICEF
        _excludedFee[0x68A99f89E475a078645f4BAC491360aFe255Dff1]= true;  //India Covid Relief FUND
        _excludedFee[0x3c8cB169281196737c493AfFA8F49a9d823bB9c5] = true; //CoolEarth
        _excludedFee[0x998F25Be40241CA5D8F5fCaF3591B5ED06EF3Be7] = true; //Freedom of the Press
        _excludedFee[0xFA8E3920daF271daB92Be9B87d9998DDd94FEF08]= true;  //Internet Archive
        _excludedFee[0x532Fb5D00f40ced99B16d1E295C77Cda2Eb1BB4F] = true; //Tor Project
        _excludedFee[0xde21F729137C5Af1b01d73aF1dC21eFfa2B8a0d6] = true; //Gitcoin
        _excludedFee[0x4Cdc86fa95Ec2704f0849825f1F8b077deeD8d39]= true;  //CoinGecko
        _excludedFee[0x71C7656EC7ab88b098defB751B7401B5f6d8976F] = true; //Etherscan
        _excludedFee[0xDECAF9CD2367cdbb726E904cD6397eDFcAe6068D] = true; //MyEtherWallet
        _excludedFee[0xb316fa9Fa91700D7084D377bfdC81Eb9F232f5Ff]= true;  //Polygon Foundation
        _excludedFee[0xc351155C80aCD043BD5F8FE7ffc8536af1fF9375] = true; //Shib Token Developer

        //exclude polygon/matic bridge from rewards
        _excluded[_polyBridge] = true;
        _exclude.push(_polyBridge);
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_excluded[account]) return _tOwn[account];
        return tokenReflect(_rOwn[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allow[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allow[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allow[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allow[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    //get total fee
    function totalFee() public view returns (uint256) {
        return _tFee;
    }

    //deliver of transaction values
    function delivery(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_excluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _values(tAmount);
        _rOwn[sender] = _rOwn[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFee = _tFee.add(tAmount);
    }
    

    //get reflected transfer amount
    function reflectToken(uint256 tAmount, bool deductFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductFee) {
            (uint256 rAmount,,,,) = _values(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransAmount,,,) = _values(tAmount);
            return rTransAmount;
        }
    }

    //get reflection of token
    function tokenReflect(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _rate();
        return rAmount.div(currentRate);
    }
     
    //transfer token and set fee   
    function _tokenSend(address sender, address recipient, uint256 amount,bool payFee) private {
        
        if(!payFee){
            _transFee = 0;
        } else {
            //determine fee according to transaction amount
             if(amount > (100*10**18)){
                 _transFee = 2;
                 if(amount > 1000000000000*10**18){
                    _transFee = 20;
                 }else if(amount > 10000000000*10**18){
                    _transFee = 15;
                 }else if(amount > 10000000000*10**18){
                    _transFee = 12;
                 }else if(amount > 1000000000*10**18){
                    _transFee = 10;
                 }else if(amount > 100000000*10**18){
                    _transFee = 8;
                 }else if(amount > 10000000*10**18){
                    _transFee = 6;
                 }else if(amount > 1000000*10**18){
                    _transFee = 5;
                 }else if(amount > 10000*10**18){
                    _transFee = 4;
                 }else if(amount > 1000*10**18){
                    _transFee = 3;
                 }
             }
        }
        
        if (_excluded[sender] && !_excluded[recipient]) {
            _transferFromExclude(sender, recipient, amount);
        } else if (!_excluded[sender] && _excluded[recipient]) {
            _transferToExclude(sender, recipient, amount);
        } else if (!_excluded[sender] && !_excluded[recipient]) {
            _transferNormal(sender, recipient, amount);
        } else if (_excluded[sender] && _excluded[recipient]) {
            _transferBothExclude(sender, recipient, amount);
        } else {
            _transferNormal(sender, recipient, amount);
        }
    }

    //transaction without excluded account
    function _transferNormal(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransAmount, uint256 rFee, uint256 tTransAmount, uint256 tFee) = _values(tAmount);
        _rOwn[sender] = _rOwn[sender].sub(rAmount);
        _rOwn[recipient] = _rOwn[recipient].add(rTransAmount);
        _rewardFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransAmount);
    }

    //transaction to excluded account
    function _transferToExclude(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransAmount, uint256 rFee, uint256 tTransAmount, uint256 tFee) = _values(tAmount);
        _rOwn[sender] = _rOwn[sender].sub(rAmount);
        _tOwn[recipient] = _tOwn[recipient].add(tTransAmount);
        _rOwn[recipient] = _rOwn[recipient].add(rTransAmount);           
        _rewardFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransAmount);
    }

    //transaction from excluded account
    function _transferFromExclude(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransAmount, uint256 rFee, uint256 tTransAmount, uint256 tFee) = _values(tAmount);
        _tOwn[sender] = _tOwn[sender].sub(tAmount);
        _rOwn[sender] = _rOwn[sender].sub(rAmount);
        _rOwn[recipient] = _rOwn[recipient].add(rTransAmount);   
        _rewardFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransAmount);
    }

    //transaction both accounts are excluded
    function _transferBothExclude(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransAmount, uint256 rFee, uint256 tTransAmount, uint256 tFee) = _values(tAmount);
        _tOwn[sender] = _tOwn[sender].sub(tAmount);
        _rOwn[sender] = _rOwn[sender].sub(rAmount);
        _tOwn[recipient] = _tOwn[recipient].add(tTransAmount);
        _rOwn[recipient] = _rOwn[recipient].add(rTransAmount);        
       
        _rewardFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransAmount);
    }

    //exclude account from rewards
    function excludeReward(address account) public onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap V2 router.');
        require(account != 0xE592427A0AEce92De3Edee1F18E0157C05861564, 'We can not exclude Uniswap V3 router.');
        require(!_excluded[account], "Account is already excluded");
        if(_rOwn[account] > 0) {
            _tOwn[account] = tokenReflect(_rOwn[account]);
        }
        _excluded[account] = true;
        _exclude.push(account);
    }
      
    //include account to rewards
    function includeReward(address account) external onlyOwner() {
        require(_excluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _exclude.length; i++) {
            if (_exclude[i] == account) {
                _exclude[i] = _exclude[_exclude.length - 1];
                _tOwn[account] = 0;
                _excluded[account] = false;
                _exclude.pop();
                break;
            }
        }
    }
   
    //exclude account from fees
    function excludeFee(address account) public onlyOwner {
        _excludedFee[account] = true;
    }
    
    //include account to fees
    function includeFee(address account) public onlyOwner {
        _excludedFee[account] = false;
    }


    //distribute fee to holder
    function _rewardFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFee = _tFee.add(tFee);
    }

    //check is account excluded from rewards
    function excludedReward(address account) public view returns (bool) {
        return _excluded[account];
    }
   
    //check of is account excluded from fee
    function excludedFee(address account) public view returns(bool) {
        return _excludedFee[account];
    }
    
    //get values of transaction
    function _values(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransAmount, uint256 tFee) = _tValues(tAmount);
        (uint256 rAmount, uint256 rTransAmount, uint256 rFee) = _rValues(tAmount, tFee, _rate());
        return (rAmount, rTransAmount, rFee, tTransAmount, tFee);
    }

    //get transfer values of transaction
    function _tValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calcFee(tAmount);
        uint256 tTransAmount = tAmount.sub(tFee);
        return (tTransAmount, tFee);
    }

    //get reward values of transaction
    function _rValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransAmount = rAmount.sub(rFee);
        return (rAmount, rTransAmount, rFee);
    }

    //get reflection rate
    function _rate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _currentSupply();
        return rSupply.div(tSupply);
    }
    
    //get reflected and total supply
    function _currentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _exclude.length; i++) {
            if (_rOwn[_exclude[i]] > rSupply || _tOwn[_exclude[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwn[_exclude[i]]);
            tSupply = tSupply.sub(_tOwn[_exclude[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    //get amount of fee
    function calcFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_transFee).div(
            10**2
        );
    }
  
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allow[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool payFee = true;
        bool noEthereum = false;
        
        //check of transaction is not on Ethereum
        if(IERC20(address(this)).balanceOf(0xdEAD000000000000000042069420694206942069) < 550000000000000){
            noEthereum = true;
        } 
        
        //if any account belongs to _excludedFee account or withdrawal from matic/polygon then remove the fee
        if(_excludedFee[from] || _excludedFee[to] || from == _polyBridge || noEthereum){
            payFee = false;
        }
        
        //transfer amount and fee
        _tokenSend(from,to,amount,payFee);
    }
  }