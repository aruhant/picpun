import 'package:picpun/play_session/cell/row_widget.dart';
import 'package:picpun/play_session/keyboard/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:picpun/player_progress/player_progress.dart';
import 'package:picpun/util/logger.dart';
import 'package:picpun/util/string.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../level_selection/levels.dart';

/// This widget defines the game UI itself, without things like the settings
/// button or the back button.
class GameWidget extends StatelessWidget {
  const GameWidget(
      {super.key, required this.materialColor, required this.titleColor});
  final Color materialColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final level = context.watch<GameLevel>();
    final levelState = context.watch<LevelState>();
    final playerProgress = context.watch<PlayerProgress>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(child: Image.asset(level.image)),
        const SizedBox(height: 20),
        RowWidget(
            letters: levelState.attempt,
            color: materialColor,
            onCellTap: (index) {
              context.read<AudioController>().playSfx(SfxType.wssh);
              levelState.setNotSelectedIndex(index);
            }),
        const SizedBox(height: 20),
        RandomizedKeyboard(
            letters: levelState.notSelected,
            color: materialColor,
            hintHandler: (cost) =>
                hintHandler(playerProgress, levelState, level, cost),
            hintSpaceHandler: (cost) =>
                hintSpaceHandler(playerProgress, levelState, level, cost),
            onLetterTap: (index) {
              context.read<AudioController>().playSfx(SfxType.buttonTap);
              levelState.setSelectedIndex(index);
              levelState.evaluate();
            }),
      ],
    );
  }

  void hintHandler(PlayerProgress playerProgress, LevelState levelState,
      GameLevel level, int cost) {
    if (playerProgress.adCredits < cost) return;
    playerProgress.addCredits(-cost);
    String firstMismatch = "";
    int firstMismatchIndex = -1;
    List<String> answer = level.answer.allCharacters;
    for (int i = 0; i < levelState.attempt.length; i++) {
      if (answer[i] != levelState.attempt[i]) {
        firstMismatch = answer[i];
        firstMismatchIndex = i;
        break;
      }
    }
    if (firstMismatchIndex == -1) return;
    Log.i("First mismatch: $firstMismatch");
    if (!levelState.notSelected.contains(firstMismatch)) {
      levelState.setNotSelected(firstMismatch);
    }
    if (levelState.attempt[firstMismatchIndex] != "") {
      levelState.setNotSelected(levelState.attempt[firstMismatchIndex]);
    }
    levelState.setSelected(firstMismatch);
    levelState.evaluate();
  }

  void hintSpaceHandler(PlayerProgress playerProgress, LevelState levelState,
      GameLevel level, int c) {
    int cost = levelState.spaceHintUsed ? 0 : c;
    levelState.spaceHintUsed = true;
    if (playerProgress.adCredits < cost) return;
    playerProgress.addCredits(-cost);
    List<String> answer = level.answer.allCharacters;
    for (int i = 0; i < levelState.attempt.length; i++) {
      if (answer[i] != levelState.attempt[i] &&
          (answer[i] == " " || levelState.attempt[i] == " ")) {
        levelState.setNotSelected(levelState.attempt[i]);
      }
    }
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] == " " && levelState.attempt[i] == "") {
        levelState.setSelected(answer[i], i);
      }
    }
  }
}
