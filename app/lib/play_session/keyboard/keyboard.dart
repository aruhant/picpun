import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:picpun/audio/audio_controller.dart';
import 'package:picpun/player_progress/player_progress.dart';
import 'package:picpun/util/ads.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:provider/provider.dart';

class RandomizedKeyboard extends StatelessWidget {
  final List<String> letters;
  final Function(int) onLetterTap;
  final Function(int) hintHandler;
  final Function(int) hintSpaceHandler;
  final Color color;

  const RandomizedKeyboard(
      {super.key,
      required this.letters,
      required this.hintHandler,
      required this.hintSpaceHandler,
      required this.onLetterTap,
      this.color = Colors.orange});

  @override
  Widget build(BuildContext context) {
    final PlayerProgress playerProgress = context.watch<PlayerProgress>();
    final Color textColor;
    final double intensity;
    if (TinyColor.fromColor(this.color).isDark()) {
      textColor = Colors.white;
      intensity = 0.8;
    } else {
      textColor = Colors.black;
      intensity = 1.0;
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ...[
                for (int index = 0; index < letters.length; index++)
                  makeButton(index, textColor, intensity)
              ],
              if (playerProgress.adCredits >= 10)
                makeHintButton(Icons.lightbulb_outline, intensity, textColor,
                    10, hintHandler),
              if (playerProgress.adCredits >= 15)
                makeHintButton(Icons.lightbulb, intensity, textColor, 15,
                    hintSpaceHandler),
              if (playerProgress.adCredits > 999)
                makeHintButton(Icons.bolt, intensity, textColor, 0, (_) {
                  for (int i = 0; i < letters.length; i++) {
                    if (letters[i] != "") hintHandler(0);
                  }
                }),
              makeAdButton(playerProgress, intensity, textColor, 25, context),
            ]));
  }

  Widget makeButton(int index, Color textColor, double intensity) {
    return Opacity(
        opacity: letters[index] == "" ? 0 : 1,
        child: NeumorphicButton(
            padding: EdgeInsets.all(8),
            style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                intensity: intensity,
                depth: 2,
                color: this.color),
            onPressed: () => tapHandler(index),
            child: Container(
              alignment: Alignment.center,
              width: 40,
              height: 40,
              child: AutoSizeText(letters[index],
                  maxLines: 1,
                  minFontSize: 8,
                  maxFontSize: 40,
                  style: TextStyle(fontSize: 40, color: textColor)),
            )));
  }

  Widget makeHintButton(IconData hintIcon, double intensity, Color textColor,
      int cost, Function(int) hintHandler) {
    return NeumorphicButton(
        padding: EdgeInsets.all(8),
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          color: TinyColor.fromColor(this.color).spin(30).color,
          intensity: intensity,
        ),
        onPressed: () => hintHandler(cost),
        child: Container(
            alignment: Alignment.center,
            width: 40,
            height: 40,
            child: Stack(children: [
              Icon(hintIcon, color: textColor),
              Align(
                  alignment: Alignment.bottomRight,
                  child: AutoSizeText("$cost 💎",
                      maxLines: 1,
                      style: TextStyle(fontSize: 12, color: textColor)))
            ])));
  }

  void tapHandler(int index) {
    if (letters[index] != "") onLetterTap(index);
  }

  Widget makeAdButton(playerProgress, double intensity, Color textColor,
      int credits, BuildContext context) {
    return AdWidget(
        loadingBuilder: () => Container(),
        errorBuilder: (_) => Container(),
        onAdShownBuilder: () => Container(),
        onAdShown: (c) => playerProgress.addCredits(c),
        showAdBuilder: (f) => NeumorphicButton(
            padding: EdgeInsets.all(8),
            style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                intensity: intensity,
                color: TinyColor.fromColor(this.color).spin(-30).color),
            onPressed: f,
            child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                child: Stack(children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AutoSizeText(
                      'AD',
                      maxLines: 1,
                      style: TextStyle(color: Colors.white, fontSize: 2),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: AutoSizeText("$credits 💎",
                          maxLines: 1,
                          style: TextStyle(fontSize: 2, color: textColor)))
                ]))));
  }
}
