// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/****************LIBRARIES********************************/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./RewardToken.sol";
import "./AssetToken.sol";

/***************ERRORS******************/

error StakingAsset__AmountNotOK();
error StakingAsset__InvalidAsset();
error StakingAsset__NotEnoughRewards();
error StakingAsset__NotEnoughAssets();

/**
 * @title Stake Asset Contract
 * @author Raiyan Mukhtar
 * @notice A staking contract accepts assetToken and rewards stakers with reward Token(rewards).
 */
contract StakingAsset {
    using SafeERC20 for IERC20;

    /******************CONSTANT VARIABLES***********************************/

    uint256 private constant ASSET_TOKENS_PER_DEPOSIT = 10e18; //10 tokens
    uint256 private constant REWARD_TOKENS_PER_DAY = 1e17; // 0.1 token per day
    uint256 private constant REWARD_POOL_SIZE = 10000e18; // 10,000 tokens
    uint256 private constant NUMBER_OF_DAYS_TO_CLAIM_REWARDS = 24 hours;

    struct Asset {
        uint256 id;
    }

    /*******************STATE VARIABLES***********************/

    // address private immutable aToken;
    //address private immutable rToken;
    AssetToken public assetToken;
    RewardToken public rewardToken;
    mapping(address => Asset[]) public userToAssets;

    /***************************EVENTS***************************/

    event TokensDeposited(address indexed _user, uint256 indexed numAssets);
    event RewardsClaimed(address indexed _user, uint256 indexed rewards);
    event AssetsWithdrawn(address indexed _user, uint256 indexed numAssets);

    /**********MODIFIERS*******************/

    modifier isTokensAmountOK(uint256 amount) {
        if (!(amount % ASSET_TOKENS_PER_DEPOSIT == 0)) {
            revert StakingAsset__AmountNotOK();
        }
        _;
    }

    constructor(AssetToken _assetToken, RewardToken _rewardToken) {
        // require(_aToken != address(0), "Invalid Asset Token");
        // require(_rToken != address(0), "Invalid Asset Token");
        //aToken = _assetToken;
        assetToken = _assetToken;
        rewardToken = _rewardToken;
    }

    /**
     * @notice deposits user assetToken in multiples of 10.
     * eg. 10,20,30 tokens
     * @param tokenAmount - number of tokens depoosited
     */
    function deposit(
        uint256 tokenAmount
    ) external isTokensAmountOK(tokenAmount) {
        require(tokenAmount != 0, "Token cant be zero");
        require(tokenAmount < 1000e18, "Too much token amount"); //To prevent rewards allocation manipulation
        uint256 numAssets = tokenAmount / ASSET_TOKENS_PER_DEPOSIT;

        for (uint256 i; i < numAssets; ) {
            userToAssets[msg.sender].push(Asset(i));

            unchecked {
                i++; //reduce gas since overflow will never occur
            }
        }
        emit TokensDeposited(msg.sender, numAssets);
        // user has to approve this contract to transfer funds

        IERC20(address(assetToken)).safeTransferFrom(
            msg.sender,
            address(this),
            tokenAmount
        ); //using safeTransferFrom to ensure transfer was successful
        //IERC20(aToken).safeTransfer(address(this), tokenAmount);
    }

    /**
     * @notice claim user rewards for all assets at anytime
     * @dev every 24hours user can claim 1e17 (0.1) Reward Token per Asset owned.
     */
    function claimRewards() external {
        uint256 numAssets = getNumberOfAssets();
        require(numAssets != 0, "No Assets");

        uint256 rewardPoolBalance = rewardToken.totalSupply();
        require(rewardPoolBalance < REWARD_POOL_SIZE, "No rewards");

        uint256 totalRewards;
        for (uint256 i; i < numAssets; ) {
            uint256 rewards = (block.timestamp * REWARD_TOKENS_PER_DAY) /
                NUMBER_OF_DAYS_TO_CLAIM_REWARDS;

            totalRewards = totalRewards + rewards;

            unchecked {
                i++; //reduce gas since overflow will never occur
            }
        }

        emit RewardsClaimed(msg.sender, totalRewards);
        // Transfer rewards to the user.
        rewardToken.mint(msg.sender, totalRewards);
    }

    /**
     * @notice withdraws an amount of asset of the user
     * @param assets - number of assets to withdraw
     */
    function withdrawAssets(uint256 assets) external {
        require(assets != 0, "Assets cant be zero");
        uint256 numOfAssets = getNumberOfAssets();
        if (numOfAssets < assets) {
            revert StakingAsset__NotEnoughAssets();
        }
        for (uint i; i < assets; ) {
            (userToAssets[msg.sender]).pop();
            unchecked {
                i++;
            }
        }

        emit AssetsWithdrawn(msg.sender, assets);
    }

    /**
     * @return returns the number of assets a user owns.
     */
    function getNumberOfAssets() public view returns (uint) {
        return (userToAssets[msg.sender]).length;
    }
}
