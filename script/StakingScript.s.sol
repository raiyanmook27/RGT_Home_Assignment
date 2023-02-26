// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/StakingAsset.sol";
import "../src/AssetToken.sol";
import "../src/RewardToken.sol";

contract StakingScript is Script {
    function run() external {
        uint256 deployedPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployedPrivateKey);

        AssetToken assetToken = new AssetToken();
        RewardToken rewardToken = new RewardToken();

        StakingAsset stakeAsset = new StakingAsset(assetToken, rewardToken);

        vm.stopBroadcast();
    }
}
