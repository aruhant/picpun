import 'package:picpun/play_session/cell/cell_widget.dart';
import 'package:flutter/material.dart';
import 'package:picpun/util/logger.dart';
import 'package:tinycolor2/tinycolor2.dart';

class RowWidget extends StatelessWidget {
  final List<String> letters;
  final Function(int) onCellTap;

  final Color color;
  const RowWidget(
      {super.key,
      required this.letters,
      required this.color,
      required this.onCellTap});

  @override
  Widget build(BuildContext context) {
    int wordsPerLine =
        findBestColumns(letters.length, MediaQuery.of(context).size.width);
    Color textColor =
        TinyColor.fromColor(color).isDark() ? Colors.white : Colors.black;
    double width =
        ((MediaQuery.of(context).size.width - 8) / wordsPerLine) - 0 - 4;
    return Wrap(
      runSpacing: 4,
      spacing: 4,
      children: [
        for (int i = 0; i < letters.length; i++)
          CellWidget(
            letter: letters[i],
            index: i,
            onCellTap: onCellTap,
            color: color,
            textColor: textColor,
            width: width,
          )
      ],
    );
  }

  int findBestColumns(int sentenceLength, double screenWidth) {
    List<int> possibleColumns = [
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24
    ];
    int minColumns = screenWidth ~/ 50;
    Log.i('Min columns: $minColumns');
    int bestColumns = minColumns;
    int minEmptyCells = sentenceLength % bestColumns;
    for (var columns in possibleColumns) {
      if (columns < minColumns) continue;
      // if (columns >= sentenceLength) return sentenceLength;

      int remainder = sentenceLength % columns;
      int emptyInLastRow = (remainder == 0) ? 0 : columns - remainder;
      if ((emptyInLastRow <= minEmptyCells) && (screenWidth / columns > 34)) {
        minEmptyCells = emptyInLastRow;
        bestColumns = columns;
      }
      Log.i(
          'Columns: $columns, empty: $emptyInLastRow, minempty:$minEmptyCells best: $bestColumns, ${(screenWidth / columns)} sentence: $sentenceLength');
    }

    return bestColumns;
  }
}
