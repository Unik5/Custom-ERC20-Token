//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {CustomToken} from "../src/CustomToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {Stake} from "../src/Stake.sol";

contract TokenTest is Test {
    CustomToken token;
    Stake stake;
    uint256 initialSupply = 100000;

    address alice = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address bob = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address testforBurn = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    function setUp() public {
        //Deploy token contract
        token = new CustomToken(initialSupply);
        //Deploy Staking Contract
        stake = new Stake(address(token));
        //Give Alice Some Token
        token.mint(alice, uint256(100 * 10 ** token.decimals()));
        token.mint(bob, uint256(6 * 10 ** token.decimals()));
        token.mint(testforBurn, uint256(1 * 10 ** token.decimals()));
    }

    /////////////////////////////
    //Testing CustomToken.sol/////
    /////////////////////////////

    function testSenderAndReceiver() public {
        vm.prank(alice);
        (address sender, address receiver) = token.minTransfer(
            alice,
            bob,
            uint256(5 * 10 ** token.decimals())
        );

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
        assertEq(token.balanceOf(bob), 16 * 10 ** token.decimals());
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
        vm.startPrank(testforBurn);
        vm.expectRevert("Not enough tokens to burn");
        token.HimalBurning();
        vm.stopPrank();
    }

    //testing if miners get tokens
    function testMinerGetTokens() public {
        address miner = address(0x90F79bf6EB2c4f870365E785982E1f101E93b906); //fourth anvil address
        vm.startPrank(miner);
        token.HimalMiningReward(miner);
        assertEq(token.balanceOf(miner), 2 * 10 ** token.decimals());
        vm.stopPrank();
    }

    //testing if staking address is set or not
    function testSetStakingAddress() public {
        vm.startPrank(address(token));
        //sending setaking Contract Address to Custom Token contract
        token.setStakingContract(address(stake));
        vm.stopPrank();
        assertEq(token.stakingContract(), address(stake));
    }

    /////////////////////////////
    //testing staking function///
    /////////////////////////////

    //test if the staking operation reverts if not enough HIM tokens are sent
    function testMinimumStakeAmount() public {
        vm.expectRevert(Stake.NotEnoughHIMSentForStaking.selector);
        stake.stake(5 * 10 ** 18, alice);
    }

    //testing is wrapper.burn is called and tokens are burned or not
    function testWrapperBurnCall() public {
        vm.startPrank(address(stake));
        uint256 initialBalance = alice.balance;
        uint256 stakedAmount = 11 * 10 ** 18;
        stake.stake(stakedAmount, alice);
        uint256 afterStakeAmount = alice.balance;
        vm.stopPrank();
        console.log(alice.balance);
        assertEq(initialBalance, stakedAmount + afterStakeAmount);
    }

    //test if staked address is pushed into the saking address array
    function testInsertedIntoStakedAddressArray() public {
        vm.startPrank(address(stake));
        stake.stake(15 * 10 ** 18, alice);
        address enteredAddress = stake.staked_addresses(0);
        vm.stopPrank();
        assertEq(enteredAddress, alice);
    }

    //testing if staking amount is mapped to staking address , checking mapping functionality
    function testAmountMappedToAddress() public {
        vm.startPrank(address(stake));
        uint256 stakedAmount = 15 * 10 ** 18;
        stake.stake(stakedAmount, alice);
        uint256 returnedAmount = stake.stakingAmount(alice);
        vm.stopPrank();
        assertEq(stakedAmount, returnedAmount);
    }

    //testing if staking time is stored
    function testStakingTimeStorage() public {
        vm.startPrank(address(stake));
        stake.stake(15 * 10 ** 18, alice);
        uint256 returnedTime = stake.stakingTime(alice);
        vm.stopPrank();
        assertEq(returnedTime, block.timestamp);
    }
}
