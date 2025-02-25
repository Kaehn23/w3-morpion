// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract TicTacToe {
    //State variables
    address public player1;
    address public player2;
    address public currentPlayer;
    uint8[9] public board; // 0=empty, 1 = player 1, 2 = player 2
    bool public gameActive;
    uint8 public movesCount;

    // Event to track game progress
    event GameStarted(address player1, address player2);
    event MoveMade(address player, uint8 position);
    event GameWon(address winner);
    event GameDraw();

    // Modifier to restrict function to players only
    modifier onlyPlayer() {
        require(msg.sender == player1 || msg.sender == player2, "Not a player");
        _;
    }

    // Modifier to ensure game is active
    modifier isActiveGame() {
        require(gameActive, "Game is not active");
        _;
    }

    // Constructor: deployer becomes player1
    constructor() {
        player1 = msg.sender;
        gameActive = false;
    }

    // Internal function to check for a win condition
    function checkWin(uint8 mark) internal view returns (bool) {
        // All possible winning combinations
        uint8[3][8] memory winningPositions = [
            [uint8(0), 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6]
        ];

        // Loop through each winning combination
        for (uint i = 0; i < winningPositions.length; i++) {
            if (
                board[winningPositions[i][0]] == mark &&
                board[winningPositions[i][1]] == mark &&
                board[winningPositions[i][2]] == mark
            ) {
                return true;
            }
        }
        return false;
    }

    // Function for a second player to join & start the game
    function joinGame() external {
        require(!gameActive, "Game already started");
        require(msg.sender != player1, "Player1 cannot join as player2");
        player2 = msg.sender;
        gameActive = true;
        currentPlayer = player1;
        emit GameStarted(player1, player2);
    }

    // Function to make a move on the board
    function makeMove(uint8 position) external onlyPlayer isActiveGame {
        require(position < 9, "Invalid board position");
        require(board[position] == 0, "Position already taken");
        require(msg.sender == currentPlayer, "It's not your turn my friend!");

        // Set board value based on the player: 1 for player 1, 2 for player2
        uint8 mark = (msg.sender == player1) ? 1 : 2;
        board[position] = mark;
        movesCount++;
        emit MoveMade(msg.sender, position);

        // Check for a winning condition
        if (checkWin(mark)) {
            gameActive = false;
            emit GameWon(msg.sender);
            return;
        }

        // Check for draw (all positions filled without a win)
        if (movesCount == 9) {
            gameActive = false;
            emit GameDraw();
            return;
        }

        // Switch turn for other player
        currentPlayer = (currentPlayer == player1) ? player2 : player1;
    }

        // Getter function to return the current board state
    function getBoard() external view returns (uint8[9] memory) {
        return board;
    }
}
