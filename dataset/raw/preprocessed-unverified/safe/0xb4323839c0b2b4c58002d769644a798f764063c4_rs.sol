/**

 *Submitted for verification at Etherscan.io on 2018-08-14

*/



pragma solidity ^0.4.24;



// File: zeppelin-solidity/contracts/ECRecovery.sol



/**

 * @title Eliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */







// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: zeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: contracts/BookingPoC.sol



/**

 * @title BookingPoC

 * @dev A contract to offer hotel rooms for booking, the payment can be done

 * with ETH or Lif

 */

contract BookingPoC is Ownable {



  using SafeMath for uint256;

  using ECRecovery for bytes32;



  // The account that will sign the offers

  address public offerSigner;



  // The time where no more bookings can be done

  uint256 public endBookings;



  // A mapping of the rooms booked by night, it saves the guest address by

  // room/night

  // RoomType => Night => Room => Booking

  struct Booking {

    address guest;

    bytes32 bookingHash;

    uint256 payed;

    bool isEther;

  }

  struct RoomType {

    uint256 totalRooms;

    mapping(uint256 => mapping(uint256 => Booking)) nights;

  }

  mapping(string => RoomType) rooms;



  // An array of the refund polices, it has to be ordered by beforeTime

  struct Refund {

    uint256 beforeTime;

    uint8 dividedBy;

  }

  Refund[] public refunds;



  // The total amount of nights offered for booking

  uint256 public totalNights;



  // The ERC20 lifToken that will be used for payment

  ERC20 public lifToken;



  event BookingCanceled(

    string roomType, uint256[] nights, uint256 room,

    address newGuest, bytes32 bookingHash

  );



  event BookingChanged(

    string roomType, uint256[] nights, uint256 room,

    address newGuest, bytes32 bookingHash

  );



  event BookingDone(

    string roomType, uint256[] nights, uint256 room,

    address guest, bytes32 bookingHash

  );



  event RoomsAdded(string roomType, uint256 newRooms);



  /**

   * @dev Constructor

   * @param _offerSigner Address of the account that will sign offers

   * @param _lifToken Address of the Lif token contract

   * @param _totalNights The max amount of nights to be booked

   */

  constructor(

    address _offerSigner, address _lifToken,

    uint256 _totalNights, uint256 _endBookings

  ) public {

    require(_offerSigner != address(0));

    require(_lifToken != address(0));

    require(_totalNights > 0);

    require(_endBookings > now);

    offerSigner = _offerSigner;

    lifToken = ERC20(_lifToken);

    totalNights = _totalNights;

    endBookings = _endBookings;

  }



  /**

   * @dev Change the signer or lif token addresses, only called by owner

   * @param _offerSigner Address of the account that will sign offers

   * @param _lifToken Address of the Lif token contract

   */

  function edit(address _offerSigner, address _lifToken) onlyOwner public {

    require(_offerSigner != address(0));

    require(_lifToken != address(0));

    offerSigner = _offerSigner;

    lifToken = ERC20(_lifToken);

  }



  /**

   * @dev Add a refund policy

   * @param _beforeTime The time before this refund can be executed

   * @param _dividedBy The divisor of the payment value

   */

  function addRefund(uint256 _beforeTime, uint8 _dividedBy) onlyOwner public {

    if (refunds.length > 0)

      require(refunds[refunds.length-1].beforeTime > _beforeTime);

    refunds.push(Refund(_beforeTime, _dividedBy));

  }



  /**

   * @dev Change a refund policy

   * @param _beforeTime The time before this refund can be executed

   * @param _dividedBy The divisor of the payment value

   */

  function changeRefund(

    uint8 _refundIndex, uint256 _beforeTime, uint8 _dividedBy

  ) onlyOwner public {

    if (_refundIndex > 0)

      require(refunds[_refundIndex-1].beforeTime > _beforeTime);

    refunds[_refundIndex].beforeTime = _beforeTime;

    refunds[_refundIndex].dividedBy = _dividedBy;

  }



  /**

   * @dev Increase the amount of rooms offered, only called by owner

   * @param roomType The room type to be added

   * @param amount The amount of rooms to be increased

   */

  function addRooms(string roomType, uint256 amount) onlyOwner public {

    rooms[roomType].totalRooms = rooms[roomType].totalRooms.add(amount);

    emit RoomsAdded(roomType, amount);

  }



  /**

   * @dev Book a room for a certain address, internal function

   * @param roomType The room type to be booked

   * @param _nights The nights that we want to book

   * @param room The room that wants to be booked

   * @param guest The address of the guest that will book the room

   */

  function bookRoom(

    string roomType, uint256[] _nights, uint256 room,

    address guest, bytes32 bookingHash, uint256 weiPerNight, bool isEther

  ) internal {

    for (uint i = 0; i < _nights.length; i ++) {

      rooms[roomType].nights[_nights[i]][room].guest = guest;

      rooms[roomType].nights[_nights[i]][room].bookingHash = bookingHash;

      rooms[roomType].nights[_nights[i]][room].payed = weiPerNight;

      rooms[roomType].nights[_nights[i]][room].isEther = isEther;

    }

    emit BookingDone(roomType, _nights, room, guest, bookingHash);

  }



  event log(uint256 msg);



  /**

   * @dev Cancel a booking

   * @param roomType The room type to be booked

   * @param _nights The nights that we want to book

   * @param room The room that wants to be booked

   */

  function cancelBooking(

    string roomType, uint256[] _nights,

    uint256 room, bytes32 bookingHash, bool isEther

  ) public {



    // Check the booking and delete it

    uint256 totalPayed = 0;

    for (uint i = 0; i < _nights.length; i ++) {

      require(rooms[roomType].nights[_nights[i]][room].guest == msg.sender);

      require(rooms[roomType].nights[_nights[i]][room].isEther == isEther);

      require(rooms[roomType].nights[_nights[i]][room].bookingHash == bookingHash);

      totalPayed = totalPayed.add(

        rooms[roomType].nights[_nights[i]][room].payed

      );

      delete rooms[roomType].nights[_nights[i]][room];

    }



    // Calculate refund amount

    uint256 refundAmount = 0;

    for (i = 0; i < refunds.length; i ++) {

      if (now < endBookings.sub(refunds[i].beforeTime)){

        refundAmount = totalPayed.div(refunds[i].dividedBy);

        break;

      }

    }



    // Forward refund funds

    if (isEther)

      msg.sender.transfer(refundAmount);

    else

      lifToken.transfer(msg.sender, refundAmount);



    emit BookingCanceled(roomType, _nights, room, msg.sender, bookingHash);

  }



  /**

   * @dev Withdraw tokens and eth, only from owner contract

   */

  function withdraw() public onlyOwner {

    require(now > endBookings);

    lifToken.transfer(owner, lifToken.balanceOf(address(this)));

    owner.transfer(address(this).balance);

  }



  /**

   * @dev Book a room paying with ETH

   * @param pricePerNight The price per night in wei

   * @param offerTimestamp The timestamp of when the offer ends

   * @param offerSignature The signature provided by the offer signer

   * @param roomType The room type that the guest wants to book

   * @param _nights The nights that the guest wants to book

   */

  function bookWithEth(

    uint256 pricePerNight,

    uint256 offerTimestamp,

    bytes offerSignature,

    string roomType,

    uint256[] _nights,

    bytes32 bookingHash

  ) public payable {

    // Check that the offer is still valid

    require(offerTimestamp < now);

    require(now < endBookings);



    // Check the eth sent

    require(pricePerNight.mul(_nights.length) <= msg.value);



    // Check if there is at least one room available

    uint256 available = firstRoomAvailable(roomType, _nights);

    require(available > 0);



    // Check the signer of the offer is the right address

    bytes32 priceSigned = keccak256(abi.encodePacked(

      roomType, pricePerNight, offerTimestamp, "eth", bookingHash

    )).toEthSignedMessageHash();

    require(offerSigner == priceSigned.recover(offerSignature));



    // Assign the available room to the guest

    bookRoom(

      roomType, _nights, available, msg.sender,

      bookingHash, pricePerNight, true

    );

  }



  /**

   * @dev Book a room paying with Lif

   * @param pricePerNight The price per night in wei

   * @param offerTimestamp The timestamp of when the offer ends

   * @param offerSignature The signature provided by the offer signer

   * @param roomType The room type that the guest wants to book

   * @param _nights The nights that the guest wants to book

   */

  function bookWithLif(

    uint256 pricePerNight,

    uint256 offerTimestamp,

    bytes offerSignature,

    string roomType,

    uint256[] _nights,

    bytes32 bookingHash

  ) public {

    // Check that the offer is still valid

    require(offerTimestamp < now);



    // Check the amount of lifTokens allowed to be spent by this contract

    uint256 lifTokenAllowance = lifToken.allowance(msg.sender, address(this));

    require(pricePerNight.mul(_nights.length) <= lifTokenAllowance);



    // Check if there is at least one room available

    uint256 available = firstRoomAvailable(roomType, _nights);

    require(available > 0);



    // Check the signer of the offer is the right address

    bytes32 priceSigned = keccak256(abi.encodePacked(

      roomType, pricePerNight, offerTimestamp, "lif", bookingHash

    )).toEthSignedMessageHash();

    require(offerSigner == priceSigned.recover(offerSignature));



    // Assign the available room to the guest

    bookRoom(

      roomType, _nights, available, msg.sender,

      bookingHash, pricePerNight, false

    );



    // Transfer the lifTokens to booking

    lifToken.transferFrom(msg.sender, address(this), lifTokenAllowance);

  }



  /**

   * @dev Get the total rooms for a room type

   * @param roomType The room type that wants to be booked

   */

  function totalRooms(string roomType) view public returns (uint256) {

    return rooms[roomType].totalRooms;

  }



  /**

   * @dev Get a booking information

   * @param roomType The room type

   * @param room The room booked

   * @param night The night of the booking

   */

  function getBooking(

    string roomType, uint256 room, uint256 night

  ) view public returns (address, uint256, bytes32, bool) {

    return (

      rooms[roomType].nights[night][room].guest,

      rooms[roomType].nights[night][room].payed,

      rooms[roomType].nights[night][room].bookingHash,

      rooms[roomType].nights[night][room].isEther

    );

  }



  /**

   * @dev Get the availability of a specific room

   * @param roomType The room type that wants to be booked

   * @param _nights The nights to check availability

   * @param room The room that wants to be booked

   * @return bool If the room is available or not

   */

  function roomAvailable(

    string roomType, uint256[] _nights, uint256 room

  ) view public returns (bool) {

    require(room <= rooms[roomType].totalRooms);

    for (uint i = 0; i < _nights.length; i ++) {

      require(_nights[i] <= totalNights);

      if (rooms[roomType].nights[_nights[i]][room].guest != address(0))

        return false;

      }

    return true;

  }



  /**

   * @dev Get the available rooms for certain nights

   * @param roomType The room type that wants to be booked

   * @param _nights The nights to check availability

   * @return uint256 Array of the rooms available for that nights

   */

  function roomsAvailable(

    string roomType, uint256[] _nights

  ) view public returns (uint256[]) {

    require(_nights[i] <= totalNights);

    uint256[] memory available = new uint256[](rooms[roomType].totalRooms);

    for (uint z = 1; z <= rooms[roomType].totalRooms; z ++) {

      available[z-1] = z;

      for (uint i = 0; i < _nights.length; i ++)

        if (rooms[roomType].nights[_nights[i]][z].guest != address(0)) {

          available[z-1] = 0;

          break;

        }

    }

    return available;

  }



  /**

   * @dev Get the first available room for certain nights

   * @param roomType The room type that wants to be booked

   * @param _nights The nights to check availability

   * @return uint256 The first available room

   */

  function firstRoomAvailable(

    string roomType, uint256[] _nights

  ) internal returns (uint256) {

    require(_nights[i] <= totalNights);

    uint256 available = 0;

    bool isAvailable;

    for (uint z = rooms[roomType].totalRooms; z >= 1 ; z --) {

      isAvailable = true;

      for (uint i = 0; i < _nights.length; i ++) {

        if (rooms[roomType].nights[_nights[i]][z].guest != address(0))

          isAvailable = false;

          break;

        }

      if (isAvailable)

        available = z;

    }

    return available;

  }



}