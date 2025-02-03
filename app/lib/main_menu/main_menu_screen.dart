import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picpun/flavors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:picpun/generated/locale_keys.g.dart';
import 'package:provider/provider.dart';
import 'package:ripple_wave/ripple_wave.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../settings/settings.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // AnimatedMeshGradient(
          //   colors: [
          //     Colors.blue,
          //     Colors.lightBlue,
          //     Colors.blueAccent,
          //     Colors.lightBlue
          //   ],
          //   options: AnimatedMeshGradientOptions(
          //     speed: 0.4,
          //     grain: 0.02,
          //     frequency: 8,
          //     amplitude: 3,
          //   ),
          // ),
          ResponsiveScreen(
            squarishMainArea: RippleWave(
              color: Colors.orange,
              repeat: true,
              waveCount: 5,
              childTween: Tween(begin: 0.98, end: 1),
              duration: const Duration(seconds: 2),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Image.asset('assets/levels/${F.name}/${F.name}.png'),
              ),
            ),
            rectangularMenuArea: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  F.appFlavor!.title,
                  maxLines: 1,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _gap,
                MyButton(
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonTap);
                    GoRouter.of(context).go('/play');
                  },
                  label: LocaleKeys.play.tr(),
                ),
                _gap,
                MyButton(
                    onPressed: () => GoRouter.of(context).push('/settings'),
                    label: LocaleKeys.settings.tr()),
                _gap,
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: settingsController.audioOn,
                    builder: (context, audioOn, child) {
                      return IconButton(
                          onPressed: settingsController.toggleAudioOn,
                          icon: Icon(
                              audioOn ? Icons.volume_up : Icons.volume_off));
                    },
                  ),
                ),
                _gap,
                Text(LocaleKeys.music.tr()),
                _gap,
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _gap = SizedBox(height: 10);
}
