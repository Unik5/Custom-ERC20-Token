// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Himal", "HIM") {
        //calling ERC20 Constructor through inheritance
        _mint(msg.sender, initialSupply); //initalSupply provided to the address that deploys this contract
    }

    // This function overrides the decimals function in the ERC20 standard.
    // It specifies the number of decimal places used by the token.
    function decimals() public view virtual override returns (uint8) {
        // Returning 16 means the token has 16 decimal places.
        // For example, a balance of 1 token will be represented as 1 * 10^18 in the smallest unit.
        return 18;
    }

    //Mining rewards to miners
    function HimalMiningReward() public {
        _mint(block.coinbase, 100); //100 HIM to miners address
    }

    //_approve
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (!(from == address(0) && to == block.coinbase)) {
            HimalMiningReward();
        }
        super._update(from, to, value);
    }
}
