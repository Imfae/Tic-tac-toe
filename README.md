# Tic-tac-toe
UPDATE:
A computer player is added and replaces one of the player in the previous version of the game.

The computer player uses the [minimax](https://en.wikipedia.org/wiki/Minimax) algorithm to choose the best move and implements [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) to decrease call stack and runtime.
-----
This is a command line version of Tic-tac-toe that can be played between two human players named Cross (X) and Nought (O).

To mark a desired square, player must input the number representing the square in the console when prompted. FAILURE to enter a number between 1 and 9 would result in a repeat prompt.

The squares are marked as follows:

            1 |2 |3
            --|--|--
            4 |5 |6
            --|--|--
            7 |8 |9

Play the game live here: [Replit](https://replit.com/@Conjurer/Tic-tac-toe#main.rb).