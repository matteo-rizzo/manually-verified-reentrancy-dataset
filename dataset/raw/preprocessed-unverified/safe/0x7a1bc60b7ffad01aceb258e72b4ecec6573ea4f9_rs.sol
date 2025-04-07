pragma solidity ^0.4.18;

/**
 * @title EvenDistroCrowdsaleLib
 * @author Modular Inc, https://modular.network
 *
 * version 2.2.1
 * Copyright (c) 2017 Modular Inc
 * The MIT License (MIT)
 * https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE
 *
 * The EvenDistroCrowdsale Library provides functionality to create a initial coin offering
 * for a standard token sale with high demand where the amount of ether a single address
 * can contribute is calculated by dividing the sale&#39;s contribution cap by the number
 * of addresses who register before the sale starts
 *
 * Modular provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology. For further information: modular.network
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */







contract CrowdsaleToken {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage public token;

  function CrowdsaleToken(address owner,
                                   string name,
                                   string symbol,
                                   uint8 decimals,
                                   uint256 initialSupply,
                                   bool allowMinting)
                                   public
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function name() public view returns (string) {
    return token.name;
  }

  function symbol() public view returns (string) {
    return token.symbol;
  }

  function decimals() public view returns (uint8) {
    return token.decimals;
  }

  function totalSupply() public view returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() public view returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who) public view returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint256 value) public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint256 value) public returns (bool ok) {
    return token.approve(spender, value);
  }

  function approveChange(address spender, uint256 valueChange, bool increase)
                         public
                         returns (bool)
  {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner) public returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function burnToken(uint256 amount) public returns (bool ok) {
    return token.burnToken(amount);
  }
}

