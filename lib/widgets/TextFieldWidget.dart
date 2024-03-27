import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPassword;
  final String hintText;
  final TextInputType textInputType;
  const TextFieldWidget({
    super.key,
    required this.textEditingController,
    required this.isPassword,
    required this.hintText,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 8),
      child: TextField(
        controller: textEditingController,
        obscureText: isPassword,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
