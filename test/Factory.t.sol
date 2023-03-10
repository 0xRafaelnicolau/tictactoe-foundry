// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/Factory.sol";
import "../src/Tictactoe.sol";

contract FactoryTest is Test {
    address playerX;
    address playerO; 
    Factory factory;

    function setUp() public {
        factory = new Factory();
        playerX = address(1);
        playerO = address(2);

        vm.label(playerX, "playerX");
        vm.label(playerO, "playerO");
        vm.label(address(factory), "factory");
    }
     
    /// @dev createGame() test functions

    function test_createGame() public {
        address game = factory.createGame(playerX, playerO);
        bool isGameValid = factory.validGames(game);
        assertEq(isGameValid, true);
    }

    function test_createGame_revertIfAddressZero() public {
        vm.expectRevert(Factory.CantBeAddressZero.selector);
        factory.createGame(address(0), playerX);
    }

    /// @dev updateLeaderboard() test functions    

    function test_updateLeaderboard() public {}

    function test_updateLeaderboard_revertIfGameIsNotFinished() public {
        /// @notice the game has not finished, so it should revert.
        address game = factory.createGame(playerX, playerO);
        vm.prank(game);
        vm.expectRevert(Factory.GameHasNotFinished.selector);
        factory.updateLeaderboard();
    }

    function test_updateLeaderboard_revertIfTictactoeInvalid() public {
        /// @notice if instance is not created by the factory revert.
        Tictactoe instance = new Tictactoe(playerX, playerO);
        vm.expectRevert(Factory.InvalidTictactoe.selector);
        vm.prank(address(instance));
        factory.updateLeaderboard();
    }
}