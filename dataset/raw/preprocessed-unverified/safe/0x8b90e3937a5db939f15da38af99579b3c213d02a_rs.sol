pragma solidity ^0.4.15;

/**
 * @title CrowdsaleLib
 * @author Majoolr.io
 *
 * version 2.0.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The Crowdsale Library provides basic functionality to create an initial coin
 * offering for different types of token sales.
 *
 * Majoolr provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology. For further information: majoolr.io
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
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function name() constant returns (string) {
    return token.name;
  }

  function symbol() constant returns (string) {
    return token.symbol;
  }

  function decimals() constant returns (uint8) {
    return token.decimals;
  }

  function totalSupply() constant returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() constant returns (uint256) {
    return token.INITIAL_SUPPLY;
  }

  function balanceOf(address who) constant returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) constant returns (uint256) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint value) returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value) returns (bool ok) {
    return token.approve(spender, value);
  }

  function changeOwner(address newOwner) returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function burnToken(uint256 amount) returns (bool ok) {
    return token.burnToken(amount);
  }
}