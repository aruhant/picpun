import 'dart:async';
import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:colorgram/colorgram.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:picpun/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:picpun/util/ads.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../game_internals/score.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'game_widget.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:animate_do/animate_do.dart';

/// This widget defines the entirety of the screen that the player sees when
/// they are playing a level.
///
/// It is a stateful widget because it manages some state of its own,
/// such as whether the game is in a "celebration" state.
class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen>
    with SingleTickerProviderStateMixin {
  static final _log = Logger('PlaySessionScreen');
  late AnimationController animateController;

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();
    _getColors();
    loadAd();
  }

  void _getColors() async {
    List<Color> colors =
        (await extractColor(Image.asset(widget.level.image).image, 1))
            .map((e) => Color.fromARGB(255, e.r, e.g, e.b))
            .toList();
    setState(() {
      _bgcolor = colors[0];
      _fgcolor = TinyColor.fromColor(_bgcolor).complement().color;
      _on_bgcolor = TinyColor.fromColor(_bgcolor).isDark()
          ? TinyColor.fromColor(_bgcolor).lighten(20).color
          : TinyColor.fromColor(_bgcolor).saturate(100).darken(60).color;
    });
  }

  Color _bgcolor = Colors.white;
  Color _fgcolor = Colors.black;
  Color _on_bgcolor = Colors.blueGrey;
  bool onLoadAnimation = true;
  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final credits = context.watch<PlayerProgress>().adCredits;
    final PlayerProgress playerProgress = context.watch<PlayerProgress>();

    return MultiProvider(
        providers: [
          Provider.value(value: widget.level),
          ChangeNotifierProvider(
              create: (context) =>
                  LevelState(level: widget.level, onWin: _playerWon)),
        ],
        child: IgnorePointer(
            // Ignore all input during the celebration animation.
            ignoring: _duringCelebration,
            child: Scaffold(
                backgroundColor: _bgcolor,
                body: Stack(alignment: Alignment.topCenter, children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10, top: 12, left: 20, right: 20),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      makeHomeButton(context, _on_bgcolor),
                                      SizedBox(width: 20),
                                      makeSettingsButton(context, _on_bgcolor),
                                    ],
                                  ),
                                  NeumorphicText(
                                      '${LocaleKeys.level.tr()}: ${widget.level.levelNumber}',
                                      style: NeumorphicStyle(
                                          depth: 1,
                                          intensity: 0.8,
                                          color: _on_bgcolor),
                                      textStyle: NeumorphicTextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Baloo 2')),
                                  CreditsWidget(
                                      clickable: false,
                                      credits: playerProgress.adCredits,
                                      color: _on_bgcolor,
                                      onColor: _bgcolor),
                                ]),
                          ),
                          GameWidget(
                              materialColor: TinyColor.fromColor(_fgcolor)
                                  .darken(20)
                                  .color,
                              titleColor: _on_bgcolor),
                        ],
                      ),
                    ),
                  ),
                  SizedBox.expand(
                      child: Visibility(
                          visible: _duringCelebration,
                          child: IgnorePointer(
                            child: Confetti(isStopped: !_duringCelebration),
                          ))),
                  if (widget.level.onLoadMessage != null && onLoadAnimation)
                    SizedBox.expand(
                      child: JelloIn(
                        animate: true,
                        controller: (controller) =>
                            animateController = controller,
                        onFinish: (direction) {
                          Future.delayed(Duration(milliseconds: 2000), () {
                            animateController.reverse();
                            onLoadAnimation = false;
                          });
                        },
                        child: Container(
                          height: 50,
                          color: Colors.black87,
                          padding: EdgeInsets.all(30),
                          alignment: Alignment.center,
                          child: AutoSizeText(widget.level.onLoadMessage!,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ]))));
  }

  Future<void> _playerWon() async {
    int levelNumber = widget.level.levelNumber;
    _log.info('Level $levelNumber won');

    final score = Score(
      levelNumber,
      widget.level.difficulty,
      DateTime.now().difference(_startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(levelNumber);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() => _duringCelebration = true);

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}

makeSettingsButton(BuildContext context, Color? onBgcolor) {
  return makeIconButton(
      Icons.settings, onBgcolor, () => GoRouter.of(context).push('/settings'));
}

makeHomeButton(BuildContext context, Color? onBgcolor) {
  return makeIconButton(
      Icons.home, onBgcolor, () => GoRouter.of(context).go('/play'));
}

makeIconButton(
  IconData icon,
  Color? color,
  VoidCallback onPressed,
) {
  return InkResponse(
      onTap: onPressed,
      child: NeumorphicIcon(
        icon,
        size: 40,
        style: NeumorphicStyle(
            color: color ?? Colors.black38,
            depth: 2,
            intensity: 0.7,
            shape: NeumorphicShape.concave),
      ));
}

makeTitle(String title) {
  return NeumorphicText(title,
      style: NeumorphicStyle(
          depth: 2, intensity: 0.8, color: Colors.black.withOpacity(0.5)),
      textStyle: NeumorphicTextStyle(
          fontFamily: 'Baloo 2', fontSize: 40, fontWeight: FontWeight.bold));
}

class CreditsWidget extends StatelessWidget {
  final int credits;
  final Color color;
  final Color onColor;
  final bool clickable;

  const CreditsWidget(
      {super.key,
      required this.credits,
      required this.color,
      required this.onColor,
      required this.clickable});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: clickable
          ? () => showAd((s) {
                return context.read<PlayerProgress>().addCredits(s);
              })
          : null,
      padding: EdgeInsets.all(2),
      style: NeumorphicStyle(
        shape: NeumorphicShape.concave,
        boxShape: NeumorphicBoxShape.stadium(),
        color: color,
        depth: 2,
      ),
      child: AnimatedFlipCounter(
          duration: Duration(milliseconds: 500),
          value: credits,
          prefix: "  💎 ",
          suffix: isAdLoaded && clickable ? " ▶️ " : " ",
          textStyle: TextStyle(
              color: onColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Baloo 2')),
    );
  }
}

class MyShapePathProvider extends NeumorphicPathProvider {
  @override
  bool shouldReclip(NeumorphicPathProvider oldClipper) {
    return true;
  }

  @override
  Path getPath(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool get oneGradientPerPath => false;
}
