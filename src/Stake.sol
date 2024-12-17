// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {CustomToken} from "./CustomToken.sol";

contract Stake {
    error NotEnoughHIMSentForStaking();
    error InvalidUnstakingAddress();

    //Mapping for testing if unstaking address is present in staked_addresses stack
    mapping(address => uint256) public stakingAmount;

    CustomToken public HimalInstance;

    address[] staked_addresses;
    uint256 private constant MINIMUM_STAKING_AMOUNT = 10 * 10 ** 18;

    // uint256 constant MINIMUM_STAKING_TIME= ;

    // event Staked(uint amountstake, uint totalAmountStaked, uint time);
    // event unStaked(uint amountstake, uint totalAmountStaked, uint time, uint rewards);
    // event claimReward(uint time, uint rewards);

    function stake(uint256 stake_amount, address staking_address) public {
        if (stake_amount >= MINIMUM_STAKING_AMOUNT) {
            HimalInstance.wrapper_burn(staking_address, stake_amount);
            staked_addresses.push(staking_address);
            stakingAmount[staking_address] = stake_amount;
        } else {
            revert NotEnoughHIMSentForStaking();
        }
    }

    ////////////////////////
    /// unstaking feature///
    ////////////////////////

    //check if the adress requesting the unsaking feature has staked first and foremost
    function checkUnsatkingAddress(
        address checking_address
    ) public view returns (bool) {
        for (uint i = 0; i < staked_addresses.length; i++) {
            if (checking_address == staked_addresses[i]) {
                return true;
            }
        }
        return false;
    }

    //function for removing address from array. Simple way xaina
    function removeAccount(address _account) internal {
        uint256 arraylength = staked_addresses.length;
        for (uint i = 0; i < arraylength; i++) {
            if (staked_addresses[i] == _account) {
                staked_addresses[i] = staked_addresses[arraylength - 1]; // move the last account to _account's index
                staked_addresses.pop();
                break;
            }
        }
    }

    //main unstake function
    function unstake(address unstaking_address) public {
        bool validity = checkUnsatkingAddress(unstaking_address);
        if (validity == true) {
            HimalInstance.wrapper_mint(
                unstaking_address,
                stakingAmount[unstaking_address]
            );
            removeAccount(unstaking_address);
        } else {
            revert InvalidUnstakingAddress();
        }
    }
}
