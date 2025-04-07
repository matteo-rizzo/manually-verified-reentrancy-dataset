pragma solidity ^0.4.15;

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This is the token contract for the RBIT Token, incentive based token for the
 * RHOVIT Platform. It utilizes Majoolr&#39;s TokenLib library to reduce custom source
 * code surface area and increase overall security. Majoolr provides smart contract
 * services and security reviews for contract deployments in addition to working
 * on open source projects in the Ethereum community.
 * For further information: rhovit.info, majoolr.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

contract RBITToken {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage token;

  function RBITToken(address owner,
                    string name, //RBIT Token
                    string symbol, //RBIT
                    uint8 decimals, //18
                    uint256 initialSupply, //90000000000000000000000000
                    bool allowMinting) //false
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function owner() constant returns (address) {
    return token.owner;
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

  function initialSupply() constant returns (uint256) {
    return token.INITIAL_SUPPLY;
  }

  function totalSupply() constant returns (uint256) {
    return token.totalSupply;
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



