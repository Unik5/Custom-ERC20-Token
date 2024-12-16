// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "forge-std/Test.sol";

contract CustomToken is ERC20 {
    /**Errors*/
    //error NotEnoughHIMSent();

    constructor(uint256 initialSupply) ERC20("Himal", "HIM") {
        //calling ERC20 Constructor through inheritance
        _mint(msg.sender, initialSupply * 10 ** decimals()); //initalSupply provided to the address that deploys this contract
    }

    // This function overrides the decimals function in the ERC20 standard.
    // It specifies the number of decimal places used by the token.
    function decimals() public view virtual override returns (uint8) {
        // Returning 18 means the token has 18 decimal places.
        // For example, a balance of 1 token will be represented as 1 * 10^18 in the smallest unit.
        return 18;
    }

    //Mining rewards to miners
    function HimalMiningReward(address miner) public {
        _mint(miner, 2 * 10 ** decimals()); //1 HIM to miners address
    }

    //Buring tokens
    function HimalBurning() public {
        uint256 burnAmount = 1 * 10 ** decimals();
        if (balanceOf(msg.sender) <= burnAmount) {
            revert("Not enough tokens to burn");
        } else {
            _burn(msg.sender, burnAmount);
        }
    }

    //transfer tokens with minimum limit to 5 HIM
    function minTransfer(
        address from,
        address to,
        uint256 amount
    ) public returns (address sender, address receiver) {
        if (amount < 5 * 10 ** decimals()) {
            revert("Not enough HIM sent");
        } else {
            _transfer(from, to, amount);
        }
        return (from, to);
    }

    //
    // function _update(
    //     address from,
    //     address to,
    //     uint256 value
    // ) internal virtual override {
    //     if (!(from == address(0) && to == block.coinbase)) {
    //         HimalMiningReward();
    //     }
    //     super._update(from, to, value);
    // }
}
