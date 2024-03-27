import 'package:flutter/material.dart';

class FollowBtnWidget extends StatelessWidget {
  final Function() function;
  final Color bgColor;
  final Color borderColor;
  final String text;
  final Color textColor;
  const FollowBtnWidget(
      {super.key,
      required this.function,
      required this.bgColor,
      required this.borderColor,
      required this.text,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: function,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
