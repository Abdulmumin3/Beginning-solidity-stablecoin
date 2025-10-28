//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Stablecoin} from "./Stablecoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract StablecoinSkeleton is ReentrancyGuard {
    error StablecoinSkeleton_NeedsMoreThanZero();
    error StablecoinSkeleton_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error StablecoinSkeleton_NotAllowedToken();
    error StablecoinSkeleton_TransferFailed();
    error StablecoinSkeleton_BreaksHealthFactor(uint256 healthFactor);
    error StablecoinSkeleton_MintingFailed();
    error StablecoinSkeleton_HealthFactorIsFine();
    uint256 constant LIQUIDATION_THRESHOLD = 50; // 50%

    mapping(address token => address priceFeed) s_priceFeed;
    mapping(address user => mapping(address token => uint256 amount)) s_collateralDeposited;
    mapping(address user => uint256 amountSBTMinted) s_SBTMinted;

    address[] s_collateralTokens;

    Stablecoin immutable i_stablecoin;
    
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    modifier collateralMoreThanZero(uint256 _amount) {
        if(_amount == 0) {
            revert StablecoinSkeleton_NeedsMoreThanZero();
        }_;
    }

    modifier isAllowedToken(address token) {
        if(s_priceFeed[token] == address(0)) {
            revert StablecoinSkeleton_NotAllowedToken();
        }_;
    }

    constructor (address[] memory tokenAddresses, address[] memory priceFeedAddresses, address stableCoinAddress) {
        if(tokenAddresses.length != priceFeedAddresses.length) {
            revert StablecoinSkeleton_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeed[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_stablecoin = Stablecoin(stableCoinAddress);
    }

    function depositCollateralAndMintSBT(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountSBTtoMint) external {
        // depositCollateral(tokenCollateralAddress, amountCollateral);
        // mintSBT(amountSBTtoMint);
    }
}