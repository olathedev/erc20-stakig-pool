// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/Staking.sol";
import "../src/tokens/Bead.sol";

contract StakingPoolContractTest is Test {
    StakingPoolContract public factory;
    Bead public token;

    address public admin = vm.addr(1);
    address public user1 = vm.addr(2);
    address public user2 = vm.addr(3);

    function setUp() public {
        token = new Bead();
        factory = new StakingPoolContract();
        vm.prank(admin);
        token.transfer(user1, 100 ether);
        vm.prank(admin);
        token.transfer(user2, 100 ether);
        vm.startPrank(admin);
    }

    function testCreatePool() public {
        uint256 initialPoolCount = factory.poolCount();
        factory.createPool(address(token), 100, 1 days);
        uint256 poolId = factory.poolCount();
        (address stakingToken, uint256 rewardPercentage, uint256 minDuration, uint256 totalStaked) = factory.getPoolDetails(poolId);
        assertEq(stakingToken, address(token));
        assertEq(rewardPercentage, 100);
        assertEq(minDuration, 1 days);
        assertEq(totalStaked, 0);
        assertEq(factory.poolCount(), initialPoolCount + 1);
    }

    function testStakeInPool() public {
        uint256 poolId = createPool(100, 1 days);
        vm.startPrank(user1);
        uint256 amountToStake = 10 ether;
        token.approve(address(factory), amountToStake);
        factory.stake(poolId, amountToStake);
        (uint256 amount, uint256 timestamp) = factory.getUserStake(poolId, user1);
        assertEq(amount, amountToStake);
        assertGe(timestamp, block.timestamp);
        (, , , uint256 totalStaked) = factory.getPoolDetails(poolId);
        assertEq(totalStaked, amountToStake);
        vm.stopPrank();
    }

    function testWithdrawFromPool() public {
        uint256 poolId = createPool(100, 1 days);
        vm.startPrank(user1);
        uint256 amountToStake = 10 ether;
        token.approve(address(factory), amountToStake);
        factory.stake(poolId, amountToStake);
        vm.warp(block.timestamp + 2 days);
        factory.withdraw(poolId);
        (uint256 amount, ) = factory.getUserStake(poolId, user1);
        assertEq(amount, 0);
        (, , , uint256 totalStaked) = factory.getPoolDetails(poolId);
        assertEq(totalStaked, 0);
        uint256 balanceAfterWithdrawal = token.balanceOf(user1);
        uint256 expectedBalance = amountToStake + (amountToStake * 100 / 10000);
        assertEq(balanceAfterWithdrawal, 100 ether - amountToStake + expectedBalance);
        vm.stopPrank();
    }

    function createPool(uint256 rewardPercentage, uint256 minDuration) internal returns (uint256) {
        factory.createPool(address(token), rewardPercentage, minDuration);
        return factory.poolCount();
    }
}