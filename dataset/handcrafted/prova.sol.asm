
======= prova.sol:A =======
EVM assembly:
    /* "prova.sol":64:132  contract A {... */
  mstore(0x40, 0x80)
  callvalue
  dup1
  iszero
  tag_1
  jumpi
  revert(0x00, 0x00)
tag_1:
  pop
  dataSize(sub_0)
  dup1
  dataOffset(sub_0)
  0x00
  codecopy
  0x00
  return
stop

sub_0: assembly {
        /* "prova.sol":64:132  contract A {... */
      mstore(0x40, 0x80)
      callvalue
      dup1
      iszero
      tag_1
      jumpi
      revert(0x00, 0x00)
    tag_1:
      pop
      jumpi(tag_2, lt(calldatasize, 0x04))
      shr(0xe0, calldataload(0x00))
      dup1
      0x5a2ee019
      eq
      tag_3
      jumpi
    tag_2:
      revert(0x00, 0x00)
        /* "prova.sol":80:129  function m() external {... */
    tag_3:
      tag_4
      tag_5
      jump	// in
    tag_4:
      stop
    tag_5:
        /* "prova.sol":107:115  uint64 a */
      0x00
        /* "prova.sol":118:123  2 + 3 */
      0x05
        /* "prova.sol":107:123  uint64 a = 2 + 3 */
      swap1
      pop
        /* "prova.sol":102:129  {... */
      pop
        /* "prova.sol":80:129  function m() external {... */
      jump	// out

    auxdata: 0xa26469706673582212204484aed37e72e7015be3168c97278b8bd5bdc2529f5627fa35cc6a0550eea99d64736f6c634300081e0033
}


======= prova.sol:C =======
EVM assembly:
    /* "prova.sol":136:326  contract C {... */
  mstore(0x40, 0x80)
  callvalue
  dup1
  iszero
  tag_1
  jumpi
  revert(0x00, 0x00)
tag_1:
  pop
  dataSize(sub_0)
  dup1
  dataOffset(sub_0)
  0x00
  codecopy
  0x00
  return
stop

sub_0: assembly {
        /* "prova.sol":136:326  contract C {... */
      mstore(0x40, 0x80)
      callvalue
      dup1
      iszero
      tag_1
      jumpi
      revert(0x00, 0x00)
    tag_1:
      pop
      jumpi(tag_2, lt(calldatasize, 0x04))
      shr(0xe0, calldataload(0x00))
      dup1
      0xfc68521a
      eq
      tag_3
      jumpi
    tag_2:
      revert(0x00, 0x00)
        /* "prova.sol":151:261  function f(address a) public {... */
    tag_3:
      tag_4
      0x04
      dup1
      calldatasize
      sub
      dup2
      add
      swap1
      tag_5
      swap2
      swap1
      tag_6
      jump	// in
    tag_5:
      tag_7
      jump	// in
    tag_4:
      stop
    tag_7:
        /* "prova.sol":185:192  new A() */
      mload(0x40)
      tag_9
      swap1
      tag_10
      jump	// in
    tag_9:
      mload(0x40)
      dup1
      swap2
      sub
      swap1
      0x00
      create
      dup1
      iszero
      dup1
      iszero
      tag_11
      jumpi
      returndatacopy(0x00, 0x00, returndatasize)
      revert(0x00, returndatasize)
    tag_11:
      pop
        /* "prova.sol":185:194  new A().m */
      0xffffffffffffffffffffffffffffffffffffffff
      and
      0x5a2ee019
        /* "prova.sol":185:196  new A().m() */
      mload(0x40)
      dup2
      0xffffffff
      and
      0xe0
      shl
      dup2
      mstore
      0x04
      add
      0x00
      mload(0x40)
      dup1
      dup4
      sub
      dup2
      0x00
      dup8
      dup1
      extcodesize
      iszero
      dup1
      iszero
      tag_12
      jumpi
      revert(0x00, 0x00)
    tag_12:
      pop
      gas
      call
      iszero
      dup1
      iszero
      tag_14
      jumpi
      returndatacopy(0x00, 0x00, returndatasize)
      revert(0x00, returndatasize)
    tag_14:
      pop
      pop
      pop
      pop
        /* "prova.sol":151:261  function f(address a) public {... */
      pop
      jump	// out
    tag_10:
      dataSize(sub_0)
      dup1
      dataOffset(sub_0)
      dup4
      codecopy
      add
      swap1
      jump	// out
        /* "#utility.yul":88:205   */
    tag_16:
        /* "#utility.yul":197:198   */
      0x00
        /* "#utility.yul":194:195   */
      0x00
        /* "#utility.yul":187:199   */
      revert
        /* "#utility.yul":334:460   */
    tag_18:
        /* "#utility.yul":371:378   */
      0x00
        /* "#utility.yul":411:453   */
      0xffffffffffffffffffffffffffffffffffffffff
        /* "#utility.yul":404:409   */
      dup3
        /* "#utility.yul":400:454   */
      and
        /* "#utility.yul":389:454   */
      swap1
      pop
        /* "#utility.yul":334:460   */
      swap2
      swap1
      pop
      jump	// out
        /* "#utility.yul":466:562   */
    tag_19:
        /* "#utility.yul":503:510   */
      0x00
        /* "#utility.yul":532:556   */
      tag_28
        /* "#utility.yul":550:555   */
      dup3
        /* "#utility.yul":532:556   */
      tag_18
      jump	// in
    tag_28:
        /* "#utility.yul":521:556   */
      swap1
      pop
        /* "#utility.yul":466:562   */
      swap2
      swap1
      pop
      jump	// out
        /* "#utility.yul":568:690   */
    tag_20:
        /* "#utility.yul":641:665   */
      tag_30
        /* "#utility.yul":659:664   */
      dup2
        /* "#utility.yul":641:665   */
      tag_19
      jump	// in
    tag_30:
        /* "#utility.yul":634:639   */
      dup2
        /* "#utility.yul":631:666   */
      eq
        /* "#utility.yul":621:684   */
      tag_31
      jumpi
        /* "#utility.yul":680:681   */
      0x00
        /* "#utility.yul":677:678   */
      0x00
        /* "#utility.yul":670:682   */
      revert
        /* "#utility.yul":621:684   */
    tag_31:
        /* "#utility.yul":568:690   */
      pop
      jump	// out
        /* "#utility.yul":696:835   */
    tag_21:
        /* "#utility.yul":742:747   */
      0x00
        /* "#utility.yul":780:786   */
      dup2
        /* "#utility.yul":767:787   */
      calldataload
        /* "#utility.yul":758:787   */
      swap1
      pop
        /* "#utility.yul":796:829   */
      tag_33
        /* "#utility.yul":823:828   */
      dup2
        /* "#utility.yul":796:829   */
      tag_20
      jump	// in
    tag_33:
        /* "#utility.yul":696:835   */
      swap3
      swap2
      pop
      pop
      jump	// out
        /* "#utility.yul":841:1170   */
    tag_6:
        /* "#utility.yul":900:906   */
      0x00
        /* "#utility.yul":949:951   */
      0x20
        /* "#utility.yul":937:946   */
      dup3
        /* "#utility.yul":928:935   */
      dup5
        /* "#utility.yul":924:947   */
      sub
        /* "#utility.yul":920:952   */
      slt
        /* "#utility.yul":917:1036   */
      iszero
      tag_35
      jumpi
        /* "#utility.yul":955:1034   */
      tag_36
      tag_16
      jump	// in
    tag_36:
        /* "#utility.yul":917:1036   */
    tag_35:
        /* "#utility.yul":1075:1076   */
      0x00
        /* "#utility.yul":1100:1153   */
      tag_37
        /* "#utility.yul":1145:1152   */
      dup5
        /* "#utility.yul":1136:1142   */
      dup3
        /* "#utility.yul":1125:1134   */
      dup6
        /* "#utility.yul":1121:1143   */
      add
        /* "#utility.yul":1100:1153   */
      tag_21
      jump	// in
    tag_37:
        /* "#utility.yul":1090:1153   */
      swap2
      pop
        /* "#utility.yul":1046:1163   */
      pop
        /* "#utility.yul":841:1170   */
      swap3
      swap2
      pop
      pop
      jump	// out
    stop

    sub_0: assembly {
            /* "prova.sol":64:132  contract A {... */
          mstore(0x40, 0x80)
          callvalue
          dup1
          iszero
          tag_1
          jumpi
          revert(0x00, 0x00)
        tag_1:
          pop
          dataSize(sub_0)
          dup1
          dataOffset(sub_0)
          0x00
          codecopy
          0x00
          return
        stop

        sub_0: assembly {
                /* "prova.sol":64:132  contract A {... */
              mstore(0x40, 0x80)
              callvalue
              dup1
              iszero
              tag_1
              jumpi
              revert(0x00, 0x00)
            tag_1:
              pop
              jumpi(tag_2, lt(calldatasize, 0x04))
              shr(0xe0, calldataload(0x00))
              dup1
              0x5a2ee019
              eq
              tag_3
              jumpi
            tag_2:
              revert(0x00, 0x00)
                /* "prova.sol":80:129  function m() external {... */
            tag_3:
              tag_4
              tag_5
              jump	// in
            tag_4:
              stop
            tag_5:
                /* "prova.sol":107:115  uint64 a */
              0x00
                /* "prova.sol":118:123  2 + 3 */
              0x05
                /* "prova.sol":107:123  uint64 a = 2 + 3 */
              swap1
              pop
                /* "prova.sol":102:129  {... */
              pop
                /* "prova.sol":80:129  function m() external {... */
              jump	// out

            auxdata: 0xa26469706673582212204484aed37e72e7015be3168c97278b8bd5bdc2529f5627fa35cc6a0550eea99d64736f6c634300081e0033
        }
    }

    auxdata: 0xa2646970667358221220012eb8b12541d478d3435258ee7fe357091f749c2dc7b015e329c5287bd3153b64736f6c634300081e0033
}

