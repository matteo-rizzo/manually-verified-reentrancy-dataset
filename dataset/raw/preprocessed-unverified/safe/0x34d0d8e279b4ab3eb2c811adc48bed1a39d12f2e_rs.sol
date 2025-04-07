/**

 *Submitted for verification at Etherscan.io on 2018-11-18

*/



/**

 * RatesProvider.sol

 * Provides rates, conversion methods and tools for ETH and CHF currencies.



 * The unflattened code is available through this github tag:

 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-1



 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved



 * @notice All matters regarding the intellectual property of this code 

 * @notice or software are subject to Swiss Law without reference to its 

 * @notice conflicts of law rules.



 * @notice License for each contract is available in the respective file

 * @notice or in the LICENSE.md file.

 * @notice https://github.com/MtPelerin/



 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:

 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity

 */





pragma solidity ^0.4.24;



// File: contracts/zeppelin/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/interface/IRatesProvider.sol



/**

 * @title IRatesProvider

 * @dev IRatesProvider interface

 *

 * @author Cyril Lapinte - <[email protected]>

 *

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice Please refer to the top of this file for the license.

 */

contract IRatesProvider {

  function rateWEIPerCHFCent() public view returns (uint256);

  function convertWEIToCHFCent(uint256 _amountWEI)

    public view returns (uint256);



  function convertCHFCentToWEI(uint256 _amountCHFCent)

    public view returns (uint256);

}



// File: contracts/zeppelin/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/Authority.sol



/**

 * @title Authority

 * @dev The Authority contract has an authority address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 * Authority means to represent a legal entity that is entitled to specific rights

 *

 * @author Cyril Lapinte - <[email protected]>

 *

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice Please refer to the top of this file for the license.

 *

 * Error messages

 * AU01: Message sender must be an authority

 */

contract Authority is Ownable {



  address authority;



  /**

   * @dev Throws if called by any account other than the authority.

   */

  modifier onlyAuthority {

    require(msg.sender == authority, "AU01");

    _;

  }



  /**

   * @dev return the address associated to the authority

   */

  function authorityAddress() public view returns (address) {

    return authority;

  }



  /**

   * @dev rdefines an authority

   * @param _name the authority name

   * @param _address the authority address.

   */

  function defineAuthority(string _name, address _address) public onlyOwner {

    emit AuthorityDefined(_name, _address);

    authority = _address;

  }



  event AuthorityDefined(

    string name,

    address _address

  );

}



// File: contracts/RatesProvider.sol



/**

 * @title RatesProvider

 * @dev RatesProvider interface

 *

 * @author Cyril Lapinte - <[email protected]>

 *

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice Please refer to the top of this file for the license.

 *

 * Error messages

 */

contract RatesProvider is IRatesProvider, Authority {

  using SafeMath for uint256;



  // WEICHF rate is in ETH_wei/CHF_cents with no fractional parts

  uint256 public rateWEIPerCHFCent;



  /**

   * @dev constructor

   */

  constructor() public {

  }



  /**

   * @dev convert rate from ETHCHF to WEICents

   */

  function convertRateFromETHCHF(

    uint256 _rateETHCHF,

    uint256 _rateETHCHFDecimal)

    public pure returns (uint256)

  {

    if (_rateETHCHF == 0) {

      return 0;

    }



    return uint256(

      10**(_rateETHCHFDecimal.add(18 - 2))

    ).div(_rateETHCHF);

  }



  /**

   * @dev convert rate from WEICents to ETHCHF

   */

  function convertRateToETHCHF(

    uint256 _rateWEIPerCHFCent,

    uint256 _rateETHCHFDecimal)

    public pure returns (uint256)

  {

    if (_rateWEIPerCHFCent == 0) {

      return 0;

    }



    return uint256(

      10**(_rateETHCHFDecimal.add(18 - 2))

    ).div(_rateWEIPerCHFCent);

  }



  /**

   * @dev convert CHF to ETH

   */

  function convertCHFCentToWEI(uint256 _amountCHFCent)

    public view returns (uint256)

  {

    return _amountCHFCent.mul(rateWEIPerCHFCent);

  }



  /**

   * @dev convert ETH to CHF

   */

  function convertWEIToCHFCent(uint256 _amountETH)

    public view returns (uint256)

  {

    if (rateWEIPerCHFCent == 0) {

      return 0;

    }



    return _amountETH.div(rateWEIPerCHFCent);

  }



  /* Current ETHCHF rates */

  function rateWEIPerCHFCent() public view returns (uint256) {

    return rateWEIPerCHFCent;

  }

  

  /**

   * @dev rate ETHCHF

   */

  function rateETHCHF(uint256 _rateETHCHFDecimal)

    public view returns (uint256)

  {

    return convertRateToETHCHF(rateWEIPerCHFCent, _rateETHCHFDecimal);

  }



  /**

   * @dev define rate

   */

  function defineRate(uint256 _rateWEIPerCHFCent)

    public onlyAuthority

  {

    rateWEIPerCHFCent = _rateWEIPerCHFCent;

    emit Rate(currentTime(), _rateWEIPerCHFCent);

  }



  /**

   * @dev define rate with decimals

   */

  function defineETHCHFRate(uint256 _rateETHCHF, uint256 _rateETHCHFDecimal)

    public onlyAuthority

  {

    // The rate is inverted to maximize the decimals stored

    defineRate(convertRateFromETHCHF(_rateETHCHF, _rateETHCHFDecimal));

  }



  /**

   * @dev current time

   */

  function currentTime() private view returns (uint256) {

    // solium-disable-next-line security/no-block-members

    return now;

  }



  event Rate(uint256 at, uint256 rateWEIPerCHFCent);

}