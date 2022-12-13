// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./utils/Caller.sol";
import "./utils/tokens/TokenERC20.sol";

import {StreamConversion} from "../StreamConversion.sol";

contract StreamConversionTest is Test {
    StreamConversion private conversion;
    address private owner;

    function setUp() public {
        owner = address(this);

        conversion = new StreamConversion(owner);
    }

    function testCanChangeOwner() public {
        conversion.transferOwnership(address(0x2));
        assertEq(conversion.owner(), address(0x2));
    }

    function testOtherUsersCannotChangeOwner() public {
        Caller user = new Caller();

        (bool ok, ) = user.externalCall(
            address(conversion),
            abi.encodeWithSelector(
                conversion.transferOwnership.selector,
                (address(0x2))
            )
        );

        assertTrue(!ok, "Only the owner can change owner");
    }

    function testEncodeStreamId() public {
        address userEncoded = address(0x1);
        uint64 startTimeEncoded = 1669852800;

        bytes32 streamId = conversion.encodeStreamId(userEncoded, startTimeEncoded);
        (address userDecoded, uint64 startTimeDecoded) = conversion.decodeStreamId(streamId);

        assertEq(userDecoded, userEncoded);
        assertEq(startTimeDecoded, startTimeEncoded);
    }
}
