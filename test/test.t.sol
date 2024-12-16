//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {CustomToken} from "../src/CustomToken.sol";
import {Test, console} from "forge-std/Test.sol";

contract TokenTest is Test {
    CustomToken token;
    uint256 initialSupply = 100000;

    address alice = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address bob = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    function setUp() public {
        //Deploy token contract
        token = new CustomToken(initialSupply);
        //Give Alice Some Token
        token.transfer(alice, uint256(100 * 10 ** token.decimals()));
        token.transfer(bob, uint256(1 * 10 ** token.decimals()));
    }

    function testSenderAndReceiver() public {
        vm.prank(alice);
        (address sender, address receiver) = token.minTransfer(
            alice,
            bob,
            uint256(5 * 10 ** token.decimals())
        );
        // console.log("SENDER", sender);
        // console.log("receiver", receiver);

        //Assert sender as alice
        assertEq(sender, alice);

        //Assert receiver as bob
        assertEq(receiver, bob);
    }

    function testMinSent() public {
        vm.prank(alice);
        uint256 amount = 2 * 10 ** token.decimals();
        vm.expectRevert("Not enough HIM sent");
        (address sender, address receiver) = token.minTransfer(
            alice,
            bob,
            amount
        );
    }

    function testCheckBalancesAfterTransfer() public {
        vm.prank(alice);
        (address sender, address receiver) = token.minTransfer(
            alice,
            bob,
            10 * 10 ** token.decimals()
        );

        //Checking Balances
        assertEq(token.balanceOf(bob), 11 * 10 ** token.decimals());
        assertEq(token.balanceOf(alice), 90 * 10 ** token.decimals());
    }

    //testing burning functionality
    function testBurn() public {
        vm.startPrank(alice);
        uint256 initialBalance = token.balanceOf(alice);
        uint256 burnAmount = 1 * 10 ** token.decimals();
        token.HimalBurning();

        assertEq(token.balanceOf(alice), initialBalance - burnAmount);
        vm.stopPrank();
    }

    //testing if the burning reverts if not enough HIm is avaialble
    function testRevertBurn() public {
        vm.startPrank(bob);
        vm.expectRevert("Not enough tokens to burn");
        token.HimalBurning();
        vm.stopPrank();
    }

    //testing if miners get tokens
    function testMinerGetTokens() public {
        address miner = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC); //third anvil address
        vm.startPrank(miner);
        token.HimalMiningReward(miner);
        assertEq(token.balanceOf(miner), 2 * 10 ** token.decimals());
        vm.stopPrank();
    }
}
