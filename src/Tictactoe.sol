// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Factory} from "./Factory.sol";

/// @title Tictactoe.sol
/// @author rafaelnicolau.eth
/// @notice This contract is a tictactoe game.
contract Tictactoe {
    address public playerX;
    address public playerO;
    address public currentPlayer;
    address public winner;
    address immutable factory = msg.sender;
    bool public isFinished;
    uint8 public movesCount;
    /// @dev creates a board, and stores the moves of each player.
    /// @notice although a uint8 the max value should be 2.
    mapping(uint8 => mapping(uint8 => address)) board;

    error InvalidPlayer();
    error GameHasNotFinished();
    error PositionAlreadyOcuppied();
    error InvalidPosition();

    modifier onlyPlayers() {
        if (msg.sender != playerX || msg.sender != playerO) revert InvalidPlayer();
        _;
    }

    /// @param _playerX address of the player X
    /// @param _playerO address of the player O 
    constructor(address _playerX, address _playerO) {
        playerX = _playerX;
        playerO = _playerO;
        currentPlayer = playerX;
    }

    /// @dev add the move of each player to the board.
    /// @param row number of rows from 0 to 2.
    /// @param col number of columns from 0 to 2.
    function makeMove(uint8 row, uint8 col) external onlyPlayers {
        if (isFinished) revert GameHasNotFinished();
        if (board[row][col] == address(0)) revert PositionAlreadyOcuppied();
        if (row > 2 || col > 2) revert InvalidPosition();

        board[row][col] = currentPlayer;
        movesCount++;

        Factory f = Factory(factory);

        if (_checkWin()) {
            winner = currentPlayer;
            isFinished = true;
            f.updateLeaderboard();
        } else if (movesCount == 9) {
            isFinished = true;
        } else {
            currentPlayer = _changeTurn();
        }
    }

    /// @dev returns the address of the winner.
    function getWinner() external view returns (address) {
        return winner;
    }

    /// @dev returns if the game is finished.
    function isGameFinished() external view returns (bool) {
        return isFinished;
    }

    /// @dev checks for a winning combination.
    function _checkWin() internal view returns (bool) {
        /// @notice checks for a winning combination in rows
        for (uint8 i = 0; i < 3; i++) {
            if (board[i][0] != address(0) && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
                return true;
            }
        }

        /// @notice checks for a winning combination in columns
        for (uint8 j = 0; j < 3; j++) {
            if (board[0][j] != address(0) && board[0][j] == board[1][j] && board[1][j] == board[2][j]) {
                return true;
            }
        }

        /// @notice checks for a winning combination in diagonals
        if (board[0][0] != address(0) && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
            return true;
        }

        if (board[2][0] != address(0) && board[2][0] == board[1][1] && board[1][1] == board[0][2]) {
            return true;
        }

        return false;
    }

    /// @dev switches the currentPlayer to make it turn-based.
    function _changeTurn() internal view returns (address) {
        if (currentPlayer == playerX) {
            return playerO;
        } else {
            return playerX;
        }
    }
}