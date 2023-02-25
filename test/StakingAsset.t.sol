// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../src/AssetToken.sol";
import "../src/StakingAsset.sol";
import "../src/RewardToken.sol";

contract StakingAssetTest is Test {
    AssetToken assetToken;
    RewardToken rToken;
    address alice;
    StakingAsset pool;

    function setUp() public {
        assetToken = new AssetToken();

        pool = new StakingAsset(address(assetToken));
        rToken = pool.rewardToken();
        alice = address(1);
        vm.startPrank(alice);
        assetToken.mintAsset(40e18);
        vm.stopPrank();
    }

    function testDepositAsset() public {
        vm.startPrank(alice);

        IERC20(address(assetToken)).approve(address(pool), 10e18);

        pool.deposit(10e18);

        assertEq(IERC20(address(assetToken)).balanceOf(address(pool)), 10e18);
    }

    function testFailInvalidTokenAmount() public {
        vm.startPrank(alice);
        assetToken.mintAsset(5e18);
        IERC20(address(assetToken)).approve(address(pool), 5e18);

        pool.deposit(5e18);
    }

    function testClaimAsset() public {
        vm.startPrank(alice);
        assetToken.mintAsset(10e18);
        IERC20(address(assetToken)).approve(address(pool), 10e18);

        pool.deposit(10e18);

        vm.warp(24 hours);

        pool.claimRewards();

        assertEq(IERC20(address(rToken)).balanceOf(alice), 1e17);
    }

    function testWithdrawAssets() public {
        vm.startPrank(alice);
        assetToken.mintAsset(20e18);
        IERC20(address(assetToken)).approve(address(pool), 20e18);

        pool.deposit(20e18);

        pool.withdrawAssets(1);

        assertEq(pool.getNumberOfAssets(), 1);
    }

    function testFailWithdrawTooManyAssets() public {
        vm.startPrank(alice);
        assetToken.mintAsset(20e18);
        IERC20(address(assetToken)).approve(address(pool), 20e18);

        pool.deposit(20e18);

        pool.withdrawAssets(5);
    }

    function testWithdrawSomeAssetsAndClaimRewards() public {
        vm.startPrank(alice);
        assetToken.mintAsset(20e18);
        IERC20(address(assetToken)).approve(address(pool), 20e18);

        pool.deposit(20e18);

        pool.withdrawAssets(1);

        vm.warp(24 hours);

        pool.claimRewards();

        assertEq(IERC20(address(rToken)).balanceOf(alice), 1e17);
    }

    function testNumberOfAssets() public {
        vm.startPrank(alice);
        assetToken.mintAsset(20e18);
        IERC20(address(assetToken)).approve(address(pool), 20e18);

        pool.deposit(20e18);

        assertEq(pool.getNumberOfAssets(), 2);
    }
}
