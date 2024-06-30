import "package:flutter/material.dart";

class ColorConfig extends StatelessWidget {
  final List<Color> colorsets;
  final Alignment bg, ed;
  const ColorConfig(this.bg, this.ed, this.colorsets, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: colorsets, begin: bg, end: ed)),
    );
  }
}
