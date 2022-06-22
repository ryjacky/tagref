import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

typedef VoidCallback = Function(String tag);

class TagInputField extends StatefulWidget {
  final VoidCallback onSubmitted;

  final String hintText;
  const TagInputField(
      {Key? key, required this.onSubmitted, required this.hintText})
      : super(key: key);

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (tag) {
        widget.onSubmitted(tag);
        setState(() {
          controller.clear();
        });
      },
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade400.withOpacity(0.5),
          filled: true,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white),
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: BorderSide.none,
          ),
          constraints: const BoxConstraints(maxHeight: 42)),
    );
  }
}
