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
    mapping(address user => mapping(address token => uint256 amount)) s_collateralDeposit;
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
        depositCollateral(tokenCollateralAddress, amountCollateral);
        mintSBT(amountSBTtoMint);
    }

    function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral) public collateralMoreThanZero(_amountOfCollateral) isAllowedToken(_tokenCollateralAddress) nonReentrant {
        s_collateralDeposit[msg.sender][_tokenCollateralAddress] += _amountCollateral;
        emit CollateralDeposited(msg.sender, _tokenCollateralAddress, _amountCollateral);
        bool success = IERC20(_tokenCollateralAddress).transferFrom(msg.sender, address(this), _amountCollateral);
        if(!success) {
            revert StablecoinSkeleton_TransferFailed();
        }
    }

    function redeemCollateralForSBT(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountSBTtoburn) external {
        burnSBT(amountSBTtoburn);
        redeemCollateral(tokenCollateralAddress, amountCollateral);
    }

    function redeemCollateral(address tokenCollateralAddress, uint256 amountOfCollateral) public collateralMoreThanZero(amountOfCollateral) nonReentrant {
        s_collateralDeposit[msg.sender][tokenCollateralAddress] -= amountOfCollateral;
        emit CollateralRedeemed(msg.sender, tokenCollateralAddress, amountOfCollateral);
        bool success = IERC20(tokenCollateralAddress).transfer(msg.sender, amountOfCollateral);
        if(!success) {
            revert StablecoinSkeleton_TransferFailed();
        }
    }

    function mintSBT(uint256 amountSBTToBeMinted) public collateralMoreThanZero(amountSBTToBeMinted) nonReentrant {
        s_SBTMinted[msg.sender] += amountSBTToBeMinted;
        revertIfHealthFactorDoesNotWork(msg.sender);
        bool minted = i_stablecoin.mint(msg.sender, amountSBTToBeMinted);

        if(!minted) {
            revert StablecoinSkeleton__MintingFailed();
        }
    }

    function burnSBT(uint256 _amount) public collateralMoreThanZero(_amount) {
        s_SBTMinted[msg.sender] -= amount;
        bool success = i_stablecoin.transferFrom(msg.sender, address(this), _amount);
        if(!success){
            revert StablecoinSkeleton_TransferFailed();
        }

        i_stablecoin.burn(_amount);

        revertIfHealthFactorDoesNotWork(msg.sender);
    }

    function liquidate(address _collateral, address _user, uint256 debtToCover) external collateralMoreThanZero(debtToCover) {
        uint256 startingUserHealthFactor = healthFactor(_user);

        if(startingUserHealthFactor >= 1e18) {
            revert StablecoinSkeleton__HealthFactorIsFine();
        }

        uint256 tokenAmountFromDebtCovered = getUSDValue(_collateral, debtToCover);

        uint256 bonusCollateral = (tokenAmountFromDebtCovered * 10) / 100;

        uint256 totalCollateralToRedeem = tokenAmountFromDebtCovered  + bonusCollateral;
    }

    function _redeemCollateral(address AddressforTokenCollateral, uint256 amountofCollateral, address from, address to) private {}

    function getAccountInformation(address user) private view returns(uint256 totalSBTMinted, uint256 collateralValueInUSD) {
        totalSBTMinted = s_SBTminted[user];
        collateralValueInUSD = getAccountCollateralValue(user);
    }

    function healthFactor(address _user) private view returns(uint256) {
        (uint256 totalSBTMinted, uint256 collateralValueInUSD) = getAccountInformation(_user);
        uint256 collateralAdjustedForThreshold = (collateralValueInUSD * LIQUIDITATION_THRESHOLD) / 100;
        return (collateralAdjustedForThreshold * 1e10) / totalSBTMinted;
    }

    function revertIfHealthFactorDoesNotWork(address user) internal view {
        uint256 userHealthFactor = healthFactor(user);

        if(userHealthFactor < 1) {
            revert StablecoinSkeleton__BreaksHealthFactor(userHealthFactor);
        }
    }
    
    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUSD) {
        for(uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposit[user][token];
            totalCollateralValueInUSD += getUSDValue(token, amount);
        }

        return totalCollateralValueInUSD;
    }

    function getUSDValue(address token, uint256 amount) public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed[token]);

        (, int256 answer,,,) = priceFeed.latestRoundData();

        return((uint256(answer) * 1e10) * amount) / 1e18;
    }
}