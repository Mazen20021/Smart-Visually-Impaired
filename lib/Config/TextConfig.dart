import 'package:flutter/material.dart';

class ConfigText extends StatelessWidget {
  const ConfigText(this.customtext, this.textcolor, this.font, {super.key});
  final String customtext;
  final Color textcolor;
  final double font;
  @override
  Widget build(BuildContext context) {
    return Text(
      customtext,
      style: TextStyle(
        color: textcolor,
        fontSize: font,
      ),
    );
  }
}
