// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DemoUSD} from "../src/DemoUSD.sol";

contract DemoUSDTest is Test {
    DemoUSD token;

    address admin = makeAddr("admin");
    address minter = makeAddr("minter");
    address pauser = makeAddr("pauser");
    address user = makeAddr("user");
    address outsider = makeAddr("outsider");

    function setUp() public {
        token = new DemoUSD(admin, minter, pauser);
    }

    function testTokenMetadata() public view {
        assertEq(token.name(), "Demo USD");
        assertEq(token.symbol(), "USDD");
        assertEq(token.decimals(), 6);
    }

    function testAuthorisedMinterCanMint() public {
        bytes32 refId = bytes32("DEMO-MINT-001");

        vm.prank(minter);
        token.mint(user, 100e6, refId);

        assertEq(token.balanceOf(user), 100e6);
        assertEq(token.totalSupply(), 100e6);
    }

    function testUnauthorisedMintReverts() public {
        vm.prank(outsider);
        vm.expectRevert();
        token.mint(user, 1e6, bytes32("UNAUTHORISED"));
    }

    function testPauseBlocksTransfers() public {
        vm.prank(minter);
        token.mint(user, 10e6, bytes32("DEMO-MINT-002"));

        vm.prank(pauser);
        token.pause();

        vm.prank(user);
        vm.expectRevert(bytes("token paused"));
        token.transfer(outsider, 1e6);
    }

    function testRedeemBurnReducesSupply() public {
        vm.prank(minter);
        token.mint(user, 10e6, bytes32("DEMO-MINT-003"));

        vm.prank(user);
        token.redeemBurn(2e6, bytes32("DEMO-BURN-001"));

        assertEq(token.balanceOf(user), 8e6);
        assertEq(token.totalSupply(), 8e6);
    }
}
