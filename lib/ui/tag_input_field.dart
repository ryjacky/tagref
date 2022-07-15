import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (val) {
        widget.onSubmitted(val);
        _controller.clear();
      },
      controller: _controller,
      inputFormatters: [
        FilteringTextInputFormatter(RegExp("[\"'~!@#\$%^&*()_+{}\\[\\]:;,.<>/?-]"), allow: false)
      ],
      decoration: InputDecoration(
          fillColor: Colors.grey.shade400.withOpacity(0.5),
          filled: true,
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.bodySmall,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: BorderSide.none,
          ),
          constraints: const BoxConstraints(maxHeight: 42)),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
