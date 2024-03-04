import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TicTacToe());
}

class TicTacToe extends StatelessWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return const Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: TicTacToeBoard(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TicTacToeBoard extends StatefulWidget {
  const TicTacToeBoard({Key? key}) : super(key: key);

  @override
  _TicTacToeBoardState createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard> {
  late List<List<String>> board;
  late String currentPlayer;
  late String? winner;
  late Color currentColor;
  late FocusNode _focusNode;
  final Color colorX = Colors.blue;
  final Color colorO = Colors.red;

  int selectedRow = 0;
  int selectedCol = 0;

  @override
  void initState() {
    super.initState();
    startGame();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  void startGame() {
    board = List.generate(3, (_) => List.filled(3, ''));
    currentPlayer = 'X';
    winner = null;
    currentColor = currentPlayer == 'X' ? colorX : colorO;
  }

  void _playMove(int row, int col) {
    if (board[row][col] == '' && winner == null) {
      setState(() {
        board[row][col] = currentPlayer;
        if (_checkWinner(row, col)) {
          winner = currentPlayer;
          _showSnackBar('Player $winner wins!', context);
        } else if (_isBoardFull()) {
          winner = 'Draw';
          _showSnackBar('It\'s a draw!', context);
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
          currentColor = currentPlayer == 'X' ? colorX : colorO;
        }
      });
    }
  }

  bool _checkWinner(int row, int col) {
    String player = board[row][col];
    if (board[row].every((element) => element == player)) return true;
    if (board.every((row) => row[col] == player)) return true;
    if (board[1][1] == player) {
      if ((board[0][0] == player && board[2][2] == player) ||
          (board[0][2] == player && board[2][0] == player)) {
        return true;
      }
    }
    return false;
  }

  bool _isBoardFull() {
    return board.every((row) => row.every((cell) => cell != ''));
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final isArrowKey = event.physicalKey == PhysicalKeyboardKey.arrowLeft ||
          event.physicalKey == PhysicalKeyboardKey.arrowRight ||
          event.physicalKey == PhysicalKeyboardKey.arrowUp ||
          event.physicalKey == PhysicalKeyboardKey.arrowDown;

      if (isArrowKey) {
        setState(() {
          if (event.physicalKey == PhysicalKeyboardKey.arrowLeft) {
            selectedCol = (selectedCol - 1) % 3;
            if (selectedCol < 0) selectedCol = 2;
          } else if (event.physicalKey == PhysicalKeyboardKey.arrowRight) {
            selectedCol = (selectedCol + 1) % 3;
          } else if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
            selectedRow = (selectedRow - 1) % 3;
            if (selectedRow < 0) selectedRow = 2;
          } else if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
            selectedRow = (selectedRow + 1) % 3;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _playMove(selectedRow, selectedCol);
        _selectRandomCell();
      }
    }
  }

  void _selectRandomCell() {
    List<int> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == '') {
          emptyCells.add(i * 3 + j);
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      int randomIndex = _generateRandomNumber(emptyCells.length - 1);
      int randomCell = emptyCells[randomIndex];
      setState(() {
        selectedRow = randomCell ~/ 3;
        selectedCol = randomCell % 3;
      });
    }
  }

  int _generateRandomNumber(int max) {
    return DateTime.now().millisecondsSinceEpoch % (max + 1);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {},
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                winner != null
                    ? 'Winner: $winner'
                    : 'Current Player: ${currentPlayer == 'X' ? 'Player X' : 'Player O'}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: currentColor,
                ),
              ),
              const SizedBox(height: 20.0),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (BuildContext context, int index) {
                  int row = index ~/ 3;
                  int col = index % 3;
                  bool isSelected = selectedRow == row && selectedCol == col;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRow = row;
                        selectedCol = col;
                      });
                      _playMove(row, col);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Focus(
                        autofocus: isSelected, // Focus the selected cell
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? currentColor
                                  : Colors
                                      .black, // Customize border color based on selection
                            ),
                            color: isSelected
                                ? currentColor.withOpacity(0.5)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              board[row][col],
                              style: TextStyle(
                                fontSize: 40.0,
                                color: board[row][col] == 'X' ? colorX : colorO,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    startGame();
                  });
                },
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
