// ignore: file_names
import 'package:flutter/material.dart';

@immutable
class ArcedSquareButtoncustom extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color textcolor;
  final double Bourders;
  final double widths, heights;
  final double textsize;
  final Alignment begin;
  final Alignment end;
  final List<Color> ButtonColors;

  const ArcedSquareButtoncustom(
      {required this.textsize,
      required this.textcolor,
      required this.Bourders,
      required this.widths,
      required this.heights,
      required this.ButtonColors,
      required this.label,
      required this.onPressed,
        required this.begin,
        required this.end,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
          width: widths,
          height: heights,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: ButtonColors,
                begin: begin,
                end: end),
            borderRadius: BorderRadius.circular(Bourders),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textcolor,
                fontSize: textsize,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
    );
  }
}
@immutable
class ArcedSquareButtoncustomICON extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color textcolor;
  final double Bourders;
  final double widths, heights;
  final double textsize;
  final Alignment begin;
  final Alignment end;
  final List<Color> ButtonColors;
  final Widget ICS;

  const ArcedSquareButtoncustomICON(
      {required this.textsize,
        required this.textcolor,
        required this.Bourders,
        required this.widths,
        required this.heights,
        required this.ButtonColors,
        required this.label,
        required this.onPressed,
        required this.begin,
        required this.end,
        required this.ICS,
        super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
          width: widths,
          height: heights,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: ButtonColors,
                begin: begin,
                end: end),
            borderRadius: BorderRadius.circular(Bourders),
          ),
          child: Center(child: Column(children:
          [
            SizedBox(height:  20),
            ICS,
            Text(
              label,
              style: TextStyle(
                color: textcolor,
                fontSize: textsize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],),

          )),

    );
  }
}
