import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picpun/player_progress/player_progress.dart';
import 'package:picpun/style/my_button.dart';
import 'package:provider/provider.dart';

import 'settings.dart';

void showCustomNameDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomNameDialog(animation: animation));
}

class CustomNameDialog extends StatefulWidget {
  final Animation<double> animation;

  const CustomNameDialog({required this.animation, super.key});

  @override
  State<CustomNameDialog> createState() => _CustomNameDialogState();
}

class _CustomNameDialogState extends State<CustomNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text('Change name?'),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 12,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  counterStyle: TextStyle(height: double.minPositive)),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (value) =>
                  context.read<SettingsController>().setPlayerName(value),
              onSubmitted: (value) => Navigator.pop(context),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(
                onPressed: () => Navigator.pop(context),
                label: 'Close',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<SettingsController>().playerName.value;
  }
}

void showCustomCreditsDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomCreditsDialog(animation: animation));
}

class CustomCreditsDialog extends StatefulWidget {
  final Animation<double> animation;

  const CustomCreditsDialog({required this.animation, super.key});

  @override
  State<CustomCreditsDialog> createState() => _CustomCreditsDialogState();
}

class _CustomCreditsDialogState extends State<CustomCreditsDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text('Edit Credits'),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 12,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  counterStyle: TextStyle(height: double.minPositive)),
              textInputAction: TextInputAction.done,
              onChanged: (value) => context
                  .read<PlayerProgress>()
                  .setCredits(int.tryParse(value) ?? 0),
              onSubmitted: (value) => Navigator.pop(context),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(
                onPressed: () => Navigator.pop(context),
                label: 'Close',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<PlayerProgress>().adCredits.toString();
  }
}
