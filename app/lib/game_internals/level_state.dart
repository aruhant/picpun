import 'package:picpun/level_selection/levels.dart';
import 'package:flutter/foundation.dart';

class LevelState extends ChangeNotifier {
  final VoidCallback onWin;

  GameLevel level;
  int tries = 0;
  bool spaceHintUsed = false;
  final List<bool> _choiceUsed = [];
  final List<String> attempt = [];

  LevelState({required this.onWin, required this.level}) {
    for (int i = 0; i < level.choices.length; i++) {
      _choiceUsed.add(false);
      attempt.add('');
    }
  }

  List<String> get notSelected => List.generate(level.choices.length,
      (index) => _choiceUsed[index] ? '' : level.choices[index]);

  void setSelectedIndex(int index) {
    tries++;
    _choiceUsed[index] = true;
    attempt[attempt.indexOf('')] = level.choices[index];
    notifyListeners();
  }

  void setSelected(String value, [int? index]) {
    tries++;
    for (int i = 0; i < _choiceUsed.length; i++) {
      if (level.choices[i] == value && !_choiceUsed[i]) {
        _choiceUsed[i] = true;
        break;
      }
    }
    attempt[index ?? attempt.indexOf('')] = value;
    notifyListeners();
  }

  void setNotSelected(String value) {
    for (int i = 0; i < _choiceUsed.length; i++) {
      if (level.choices[i] == value && _choiceUsed[i]) {
        _choiceUsed[i] = false;
        break;
      }
    }
    attempt[attempt.indexOf(value)] = '';
    notifyListeners();
  }

  void setNotSelectedIndex(int value) {
    String letter = attempt[value];
    for (int i = 0; i < _choiceUsed.length; i++) {
      if (level.choices[i] == letter && _choiceUsed[i]) {
        _choiceUsed[i] = false;
        break;
      }
    }
    attempt[value] = '';
    notifyListeners();
  }

  void evaluate() {
    if (attempt.join() == level.answer) {
      onWin();
    }
  }
}
