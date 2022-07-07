import 'package:flutter/material.dart';

import '../assets/constant.dart';

typedef OnSubmitted = Function(String val);

class TagInputField extends StatefulWidget {
  final String hintText;
  final OnSubmitted onSubmitted;
  const TagInputField(
      {Key? key, required this.hintText, required this.onSubmitted})
      : super(key: key);

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (val) {
        widget.onSubmitted(val);
        _controller.clear();
      },
      controller: _controller,
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
      style: const TextStyle(color: Colors.white),
    );
  }
}
