import 'package:picpun/util/string.dart';

class GameLevel {
  final String? title;
  final String image;
  final List<String> choices;
  final String hint;
  final String answer;
  final int levelNumber;
  final int difficulty;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;

  final String? achievementIdAndroid;
  final String? onLoadMessage;

  bool get awardsAchievement => achievementIdAndroid != null;

  GameLevel(
      {this.title,
      this.difficulty = 0,
      this.achievementIdIOS,
      this.achievementIdAndroid,
      required this.image,
      List<String>? choices,
      required this.hint,
      required this.answer,
      required this.levelNumber, required this.onLoadMessage})
      : choices = (choices ?? answer.allCharacters
          ..shuffle()) {
    assert(
        (achievementIdAndroid != null && achievementIdIOS != null) ||
            (achievementIdAndroid == null && achievementIdIOS == null),
        'Either both iOS and Android achievement ID must be provided, '
        'or none');
  }
}
