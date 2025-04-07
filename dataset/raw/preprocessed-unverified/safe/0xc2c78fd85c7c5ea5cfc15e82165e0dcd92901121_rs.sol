/**
 *Submitted for verification at Etherscan.io on 2020-11-02
*/

/**
█  █▀ ▄█    ▄▄▄▄▀ ▄▄▄▄▄   ▄      ▄   ▄███▄   ▄████  ▄█    ▄   ██      ▄   ▄█▄    ▄███▄   
█▄█   ██ ▀▀▀ █   █     ▀▄  █      █  █▀   ▀  █▀   ▀ ██     █  █ █      █  █▀ ▀▄  █▀   ▀  
█▀▄   ██     █ ▄  ▀▀▀▀▄ █   █ ██   █ ██▄▄    █▀▀    ██ ██   █ █▄▄█ ██   █ █   ▀  ██▄▄    
█  █  ▐█    █   ▀▄▄▄▄▀  █   █ █ █  █ █▄   ▄▀ █      ▐█ █ █  █ █  █ █ █  █ █▄  ▄▀ █▄   ▄▀ 
  █    ▐   ▀            █▄ ▄█ █  █ █ ▀███▀ ██ █      ▐ █  █ █    █ █  █ █ ▀███▀  ▀███▀   
 ▀                       ▀▀▀  █   ██           ▀       █   ██   █  █   ██                
/**                                                               ▀                         
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@***@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@***@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@&%%..,%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%...%%@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@,  ##(  @@@@@@@@@@@@@@@@@@@@@@@@@@@@%  ###  @@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@     ##(     @@@@@@@@@@@@@@@@@@@@@@@     ###     @@@@@@@@@@@@@@@
@@@@@@@@@@@@@     /##%%%##     @@@@@@@@@@@@@@@@@@.    .##%%%##     #@@@@@@@@@@@@
@@@@@@@@@@@@@   ###%%%%%%%###  @@@@@@@@@@@@@@@@@@.  ###%%%%%%%###  #@@@@@@@@@@@@
@@@@@@@@@@@     ###%%%%%%%###     @@@@@@@@@@@@@     ###%%%%%%%###     @@@@@@@@@@
@@@@@@@@@@@     ###%%%%%%%###     @@@@@@@@@@@@@     ###%%%%%%%###     @@@@@@@@@@
@@@@@@@@@@@     ###%%%%%%%###     @@@@@@@@@@@@@     ###%%%%%%%###     @@@@@@@@@@
@@@@@@@@@@@     %%########%%%                       %%########%%%     @@@@@@@@@@
@@@@@@@@@@@       (%%%%%%%             @@@            ,%%%%%%%        @@@@@@@@@@
@@@@@@@@@@@                         /@@@@@@@                          @@@@@@@@@@
@@@@@@@@          (%#             @@@@@@@@@@@@@             #%           @@@@@@@
@@@@@@@@        #%&@@%##          @@@@@@@@@@@@@          %#%@@#%#        @@@@@@@
@@@@@#          #%&@@@@&#%        @@@@@@@@@@@@@       .%#@@@@@%%#          @@@@@
@@@@@#          ##&@@@@@@@###     @@@@@@@@@@@@@     ##%@@@@@@@###          @@@@@
@@@@@#            (%#@@@@@%%#     @@@@@@@@@@@@@     #%%@@@@@#%             @@@@@
@@@@@#            (%#%#%@@@@@%#     /@@@@@@@     ##%@@@@@%#%#%             @@@@@
@@@@@#               %%%@@@@@%%                  #%%@@@@@%%%               @@@@@
@@@@@@@@                #####                       #####                @@@@@@@
@@@@@@@@                                                                 @@@@@@@
@@@@@@@@@@@            .@@                            ,@@             @@@@@@@@@@
@@@@@@@@@@@       #@@     @@@                       @@#     @@        @@@@@@@@@@
@@@@@@@@@@@&&        %%#     @@   @@@@@&&&@@@@@  %@@     %%%          @@@@@@@@@@
@@@@@@@@@@@@@&&&     %%%@@        @@@@@&&&@@@@@       ,@@%%%       (&&@@@@@@@@@@
@@@@@@@@@@@@@&&&          @@@       /@@@@@@@        @@#          &&&@@@@@@@@@@@@
@@@@@@@@@@@%#%%%&&,       @@@@@        @@@       &@@@@#       &&&%%%#%@@@@@@@@@@
@@@@@@@@@@@&&###%%###     ,,,,,###     @@@     ##*,,,,.     ##%%%##%&&@@@@@@@@@@
@@@@@@@@@@@@@%%%#%%&%**,       (((  .**@@@**   ((        ***%&%%#%%&@@@@@@@@@@@@
@@@@@@@@@@@@@@@@#%#%#&&%            /@@@@@@@             &&&#%#%#@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@%%%%%&&%            /@@@@@@@             &&&%%%%%@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@##%%%&&&&&          /@@@@@@@          ,&&&&&%%###@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@&&&&&&&&       /@@@@@@@        &&&&&&&&@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@&&&&&&&&   @@@@@@@@@@@@@  %&&&&&&&@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&@@@@@@@@@@@@@@@@@@&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/

pragma solidity 0.6.0;





contract KitsuneFinance is Ownable {
  using SafeMath for uint256;

  // standard ERC20 variables. 
  string public constant name = "Kitsune.Finance";
  string public constant symbol = "KTSU";
  uint256 public constant decimals = 18;
  // the supply will not exceed 10,000 KTSU
  uint256 private constant _maximumSupply = 10000 * 10 ** decimals;
  // owner of the contract
  uint256 public _totalSupply;

  // events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // mappings
  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor() public override {
    // transfer the entire supply into the address of the Contract creator.
    _owner = msg.sender;
    _totalSupply = _maximumSupply;
    _balanceOf[msg.sender] = _maximumSupply;
    emit Transfer(address(0x0), msg.sender, _maximumSupply);
  }

  function totalSupply () public view returns (uint256) {
    return _totalSupply; 
  }

  function balanceOf (address who) public view returns (uint256) {
    return _balanceOf[who];
  }

  // ensure the address is valid.
  function _transfer(address _from, address _to, uint256 _value) internal {
    _balanceOf[_from] = _balanceOf[_from].sub(_value);
    _balanceOf[_to] = _balanceOf[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }

  // send tokens
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_balanceOf[msg.sender] >= _value);
    _transfer(msg.sender, _to, _value);
    return true;
  }

  // approve tokens
  function approve(address _spender, uint256 _value) public returns (bool success) {
    require(_spender != address(0));
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  // transfer from
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value <= _balanceOf[_from]);
    require(_value <= allowance[_from][msg.sender]);
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
    _transfer(_from, _to, _value);
    return true;
  }
}