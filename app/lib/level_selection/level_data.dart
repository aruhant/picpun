import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:picpun/level_selection/levels.dart';
import 'package:picpun/util/logger.dart';

class GameLevels {
  static List<GameLevel> gameLevels = [];

  static Future init(String flavor) async {
    String data;
    try {
      data = await rootBundle.loadString('assets/levels/$flavor/$flavor.csv');
    } catch (e) {
      Log.e('Failed to load levels: $e');
      return;
    }
    List<String> rows = data.split('\n');
    Map<String, int> header = {};
    List<String> headerRow = rows[0].split('\t');
    for (int i = 0; i < headerRow.length; i++) {
      header[headerRow[i].trim()] = i;
    }
    for (int i = 1; i < rows.length; i++) {
      List<String> cols = rows[i].split('\t');
      if (cols.length != header.length) {
        continue;
      }
      String answer = cols[header['text']!].toUpperCase();
      String style = cols[header['style']!];
      String hint = cols[header['hint']!];
      if (!kDebugMode && cols[header['level']!].isEmpty) continue;
      if (hint.isEmpty) {
        hint = answer;
      }
      String image = 'assets/levels/$flavor/$style-${'$i'.padLeft(3, '0')}.png';

      gameLevels.add(GameLevel(
          image: image,
          hint: hint,
          answer: answer,
          onLoadMessage: cols[header['onLoad']!].trim().isEmpty
              ? null
              : cols[header['onLoad']!].replaceAll('\\n', '\n'),
          levelNumber: i,
          difficulty: i % 10));
    }
  }
}
