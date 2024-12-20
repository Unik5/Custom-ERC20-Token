// SPDX-License-Identifier:MIT

pragma solidity ^0.8.20;

import {CustomToken} from "./CustomToken.sol";

contract Stake {
    //errors declearation
    error NotEnoughHIMSentForStaking();
    error InvalidUnstakingAddress();
    error NotEnoughTimeStaked();

    //Mapping for testing if unstaking address is present in staked_addresses stack
    mapping(address => uint256) public stakingAmount;
    mapping(address => uint256) public stakingTime;

    CustomToken public HimalInstance;

    constructor(address tokenDeployAddress) {
        HimalInstance = CustomToken(tokenDeployAddress);
        HimalInstance.setStakingContract(address(this));
    }

    address[] public staked_addresses;

    //constants
    uint256 private constant MINIMUM_STAKING_AMOUNT = 10 * 10 ** 18;
    uint256 private constant MINIMUM_STAKING_TIME = 1 days;

    //events declearation
    event Staked(uint amountstake, uint time);
    event unStaked(uint amountunstake, uint time, uint rewards);
    event claimReward(uint time, uint rewards);

    function stake(uint256 stake_amount, address staking_address) public {
        if (stake_amount >= MINIMUM_STAKING_AMOUNT) {
            HimalInstance.wrapper_burn(staking_address, stake_amount);
            staked_addresses.push(staking_address);
            stakingAmount[staking_address] = stake_amount;
            stakingTime[staking_address] = block.timestamp;
            emit Staked(stake_amount, stakingTime[staking_address]);
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
        (bool timeValidity, uint256 staked_time) = checkStakingTime(
            unstaking_address
        );
        if (validity == true) {
            if (timeValidity == true) {
                uint256 staked_rewards = calculateRewards(
                    unstaking_address,
                    staked_time
                );
                claimRewards(
                    unstaking_address,
                    stakingAmount[unstaking_address],
                    staked_rewards
                );
                removeAccount(unstaking_address);
                emit unStaked(
                    stakingAmount[unstaking_address],
                    block.timestamp,
                    staked_rewards
                );
            } else {
                revert NotEnoughTimeStaked();
            }
        } else {
            revert InvalidUnstakingAddress();
        }
    }

    //fnction to check whether the minimum staking time has passed or not
    function checkStakingTime(
        address checking_address
    ) public view returns (bool, uint256) {
        uint256 staking_time = stakingTime[checking_address];
        uint256 current_time = block.timestamp;
        uint256 time_difference = current_time - staking_time;
        if (time_difference >= MINIMUM_STAKING_TIME) {
            return (true, time_difference);
        } else {
            return (false, time_difference);
        }
    }

    //Rewards Calculation
    function calculateRewards(
        address claim_address,
        uint256 staked_time
    ) public view returns (uint256) {
        uint256 rewards = 0;
        uint256 staking_amount = stakingAmount[claim_address];
        rewards = (staking_amount * staked_time) / MINIMUM_STAKING_TIME;
        return rewards;
    }

    // Claim Rewards
    function claimRewards(
        address claim_address,
        uint256 original_staked_amount,
        uint256 staked_rewards
    ) public {
        HimalInstance.wrapper_mint(
            claim_address,
            original_staked_amount + staked_rewards
        );
        emit claimReward(block.timestamp, staked_rewards);
    }
}
