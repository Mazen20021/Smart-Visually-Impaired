// ignore: file_names
import 'package:flutter/material.dart';
@immutable
class ArcedSquareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color textcolor;
  final double Bourders;
  final double widths , heights;
  final double IconSize;
  final double textsize;
  final Color Iconcolor;
  final List<Color> ButtonColors;
const ArcedSquareButton(
      {required this.IconSize, required this.textsize,required this.Iconcolor,required this.textcolor ,required this.Bourders ,required this.widths ,required this.heights,required this.ButtonColors,required this.icon, required this.label, required this.onPressed , super.key});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widths,
            height: heights,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: ButtonColors,
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight),
              borderRadius: BorderRadius.circular(Bourders),
            ),
            child: Icon(
              icon,
              color: Iconcolor,
              size: IconSize,
              shadows: const [
                Shadow(
                    color:  Color.fromARGB(80, 0, 0, 0), offset: Offset(-3, 5))
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textcolor,
              fontSize: textsize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
