import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class CellWidget extends StatelessWidget {
  final String letter;
  final Function(int) onCellTap;
  final double width;
  final Color color;
  final int index;
  final Color textColor;

  const CellWidget(
      {super.key,
      required this.letter,
      required this.width,
      required this.color,
      required this.textColor,
      required this.onCellTap,
      required this.index});

  @override
  Widget build(BuildContext context) {
    const margin = 2.0;
    return NeumorphicButton(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.all(margin),
      margin: EdgeInsets.all(0),
      style: NeumorphicStyle(
          depth: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
          intensity: 0.8,
          color: letter == "" ? Colors.transparent : color,
          shape:
              letter == "" ? NeumorphicShape.concave : NeumorphicShape.convex),
      onPressed: () => onCellTap(index),
      child: Container(
        alignment: Alignment.center,
        width: width - 2 * margin,
        height: width - 2 * margin,
        child: AutoSizeText(letter,
            style: TextStyle(fontSize: 40, color: textColor),
            minFontSize: 10,
            maxFontSize: 40,
            maxLines: 1),
      ),
    );
  }
}
