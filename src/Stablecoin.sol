//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC20Burnable, ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Stablecoin is ERC20Burnable, Ownable {
    error Stablecoin_MustBeMoreThanZero();
    error Stablecoin_BurnMoreThanBalance();
    error Stablecoin_NoMintingtoZeroAddress();
    error Stablecoin_AmountMustBeMoreThanZero();

    constructor () ERC20("Stablecoin", "SBT") {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);

        if(_amount == 0) {
            revert Stablecoin_MustBeMoreThanZero();
        }

        if(balance < amount) {
            revert Stablecoin_BurnMoreThanBalance();
        }

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns bool{

        if(_to == address(0)){
            revert Stablecoin_NoMintingtoZeroAddress();
        }

        if(_amount == 0) {
            revert Stablecoin__AmountMustBeMoreThanZero();
        }

        _mint(_to, _amount);

        return true;
    }
}