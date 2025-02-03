import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picpun/generated/locale_keys.g.dart';
import 'package:picpun/play_session/play_session_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../player_progress/player_progress.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'custom_name_dialog.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            _gap,
            makeTitle(LocaleKeys.settings.tr()),
            _gap,
            _NameChangeLine(LocaleKeys.name.tr()),
            ValueListenableBuilder<bool>(
              valueListenable: settings.soundsOn,
              builder: (context, soundsOn, child) => _SettingsLine(
                LocaleKeys.sound_fx.tr(),
                Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                onSelected: settings.toggleSoundsOn,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.musicOn,
              builder: (context, musicOn, child) => _SettingsLine(
                LocaleKeys.music.tr(),
                Icon(musicOn ? Icons.music_note : Icons.music_off),
                onSelected: settings.toggleMusicOn,
              ),
            ),
            _gap,
            ValueListenableBuilder<bool>(
                valueListenable: settings.cheatOn,
                builder: (context, cheatOn, child) => !cheatOn
                    ? Container()
                    : Column(children: [
                        _SettingsLine(
                            'Unlock all levels', const Icon(Icons.lock_open),
                            onSelected: () {
                          context.read<PlayerProgress>().unlock();
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(const SnackBar(
                              content: Text('All levels have been unlocked.')));
                        }),
                        const _CreditsChangeLine('Credits')
                      ])),
            _SettingsLine(
                LocaleKeys.reset_progress.tr(), const Icon(Icons.delete),
                onSelected: () {
              context.read<PlayerProgress>().reset();

              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(const SnackBar(
                  content: Text('Player progress has been reset.')));
            }),
            _gap,
          ],
        ),
        rectangularMenuArea: MyButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          label: LocaleKeys.back.tr(),
        ),
      ),
    );
  }
}

class _NameChangeLine extends StatelessWidget {
  final String title;

  const _NameChangeLine(this.title);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: () => showCustomNameDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Baloo 2',
                  fontSize: 30,
                )),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: settings.playerName,
              builder: (context, name, child) => Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Baloo 2',
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditsChangeLine extends StatelessWidget {
  final String creditsTitle;

  const _CreditsChangeLine(this.creditsTitle);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PlayerProgress>();

    return InkResponse(
        highlightShape: BoxShape.rectangle,
        onTap: () => showCustomCreditsDialog(context),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(creditsTitle.toString(),
                  style: const TextStyle(fontFamily: 'Baloo 2', fontSize: 30)),
              const Spacer(),
              Text('${settings.adCredits}',
                  style: const TextStyle(fontFamily: 'Baloo 2', fontSize: 30))
            ])));
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;

  final Widget icon;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, this.icon, {this.onSelected});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Baloo 2',
                  fontSize: 30,
                ),
              ),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
