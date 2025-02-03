import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:picpun/flavors.dart';
import 'package:picpun/generated/locale_keys.g.dart';
import 'package:picpun/level_selection/version_number.dart';
import 'package:picpun/play_session/play_session_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import 'level_data.dart';
import 'package:easy_localization/easy_localization.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  makeSettingsButton(context, Colors.black38),
                  SizedBox(width: 18)
                ],
              ),
              makeTitle(LocaleKeys.level_selection.tr()),
              GameLevels.gameLevels.isEmpty
                  ? Text("Loading Levels For ${F.appFlavor?.name}")
                  : GridView.count(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 5,
                      children: [
                          for (int i = 0; i < GameLevels.gameLevels.length; i++)
                            InkWell(
                                onTap: playerProgress.highestLevelReached < i
                                    ? null
                                    : () {
                                        final audioController =
                                            context.read<AudioController>();
                                        audioController
                                            .playSfx(SfxType.buttonTap);
                                        GoRouter.of(context)
                                            .go('/play/session/$i');
                                      },
                                child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Stack(children: [
                                      Container(
                                        clipBehavior: Clip.antiAlias,
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                blurRadius: 5,
                                                // offset: const Offset(2, 2),
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: playerProgress
                                                    .highestLevelReached <
                                                i
                                            ? ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                    sigmaX: 4, sigmaY: 4),
                                                child: Image.asset(GameLevels
                                                    .gameLevels[i].image))
                                            : Image.asset(
                                                GameLevels.gameLevels[i].image),
                                      ),
                                      Text(' ${i + 1}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              // fontFamily: 'Baloo 2',
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 4,
                                                    color: Colors.black)
                                              ]))
                                    ])))
                        ]),
              VersionNumber(),
            ],
          ),
        ),
      ),
    );
  }
}
