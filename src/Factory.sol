// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Tictactoe} from "./Tictactoe.sol";

/// @title Factory.sol
/// @author rafaelnicolau.eth
/// @notice Implements a factory to create new instances of tictactoe games
/// and updates the wincount of the player who won in the leaderboard.
contract Factory {
    /// @dev storing addresses of Tictactoe game instances.
    mapping(address => bool) public validGames;
    /// @dev storing number of wins each address has.
    mapping(address => uint) public leaderboard;

    error InvalidTictactoe();
    error CantBeAddressZero();
    error NotTheOwner();
    error GameHasNotFinished();

    modifier onlyTictactoe() {
        if (!validGames[msg.sender]) revert InvalidTictactoe();
        _;
    }

    /// @dev creates a new instance of Tictactoe and stores it's address in validGames.
    /// @notice the user interacts with this function to create a new instance of the game.
    /// @param _playerX address of player one.
    /// @param _playerO address of player two.
    function createGame(address _playerX, address _playerO) external returns (address) {
        if (_playerX == address(0) || _playerO == address(0)) revert CantBeAddressZero();
        Tictactoe game = new Tictactoe(_playerX, _playerO);
        validGames[address(game)] = true;
        return address(game);
    }

    /// @dev updates the wincount of the winning address in the leaderboard.
    /// @dev only tictactoe instances can call this function.
    function updateLeaderboard() external onlyTictactoe {
        Tictactoe game = Tictactoe(msg.sender);

        /// @notice if the game hasnt finished yet it is not supposed that
        /// the win count is updated.
        bool isFinished = game.isGameFinished();
        if (!isFinished) revert GameHasNotFinished();
        
        address winner = game.getWinner();
        leaderboard[winner] += 1;
        
        validGames[msg.sender] = false;
    }
}