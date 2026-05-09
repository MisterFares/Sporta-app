import 'package:flutter/material.dart';

Widget textButton(
  double fontSize,
  Color color,
  String text,
  void Function() onPressed,
) {
  return TextButton(
    onPressed: onPressed,
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    ),
  );
}
